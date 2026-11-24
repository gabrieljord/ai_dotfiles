#!/usr/bin/env python3
"""
scripts/audio/record_until_silence.py
==============================================================================
Intelligent Voice Activity & Silence Detection Audio Recorder
==============================================================================
Records microphone audio into a 16kHz, 16-bit mono WAV file for Whisper STT.
Automatically stops recording after detecting a period of silence following
active speech.

Features:
  - Adaptive noise floor calibration
  - Pre-speech ring buffer (prevents clipping the first syllable)
  - PyAudio primary backend with automatic subprocess fallback (arecord, ffmpeg)
  - C-level ALSA stderr suppression to prevent terminal spam
  - Safe Ctrl+C handling (flushes captured audio to disk)
  - Trailing silence trimming (optimizes Whisper transcription latency)
==============================================================================
"""

import argparse
import collections
import contextlib
import math
import os
import signal
import struct
import subprocess
import sys
import time
import wave

# Fast RMS via numpy if available, else standard struct
try:
    import numpy as np

    def calc_rms(data: bytes) -> float:
        if not data:
            return 0.0
        samples = np.frombuffer(data, dtype=np.int16).astype(np.float64)
        if len(samples) == 0:
            return 0.0
        return float(np.sqrt(np.mean(samples**2)))
except ImportError:
    np = None

    def calc_rms(data: bytes) -> float:
        count = len(data) // 2
        if count == 0:
            return 0.0
        shorts = struct.unpack(f"{count}h", data[: count * 2])
        return math.sqrt(sum(s * s for s in shorts) / count)


@contextlib.contextmanager
def suppress_c_stderr():
    """Redirects C-level stderr (fd 2) to /dev/null temporarily."""
    devnull = -1
    old_stderr = -1
    try:
        try:
            devnull = os.open(os.devnull, os.O_WRONLY)
            old_stderr = os.dup(2)
            os.dup2(devnull, 2)
            os.close(devnull)
            devnull = -1
        except Exception:
            pass
        yield
    finally:
        if old_stderr != -1:
            try:
                os.dup2(old_stderr, 2)
                os.close(old_stderr)
            except Exception:
                pass
        if devnull != -1:
            try:
                os.close(devnull)
            except Exception:
                pass


class AudioStreamBase:
    def read(self, num_samples: int) -> bytes:
        raise NotImplementedError

    def close(self):
        pass


class PyAudioStream(AudioStreamBase):
    def __init__(self, sample_rate: int = 16000, chunk_size: int = 512, device_index=None):
        with suppress_c_stderr():
            import pyaudio
            self.pa = pyaudio.PyAudio()
            self.stream = self.pa.open(
                format=pyaudio.paInt16,
                channels=1,
                rate=sample_rate,
                input=True,
                input_device_index=device_index,
                frames_per_buffer=chunk_size,
            )

    def read(self, num_samples: int) -> bytes:
        return self.stream.read(num_samples, exception_on_overflow=False)

    def close(self):
        try:
            with suppress_c_stderr():
                if hasattr(self, "stream") and self.stream:
                    self.stream.stop_stream()
                    self.stream.close()
                if hasattr(self, "pa") and self.pa:
                    self.pa.terminate()
        except Exception:
            pass


class SubprocessStream(AudioStreamBase):
    def __init__(self, sample_rate: int = 16000, backend: str = "auto", device: str = "default"):
        self.proc = None
        cmd = None

        if backend == "auto":
            if self._has_cmd("arecord"):
                backend = "arecord"
            elif self._has_cmd("parecord"):
                backend = "parecord"
            elif self._has_cmd("ffmpeg"):
                backend = "ffmpeg"
            else:
                raise RuntimeError("No subprocess audio recording tools (arecord, parecord, ffmpeg) available.")

        if backend == "arecord":
            cmd = ["arecord", "-q", "-r", str(sample_rate), "-c", "1", "-f", "S16_LE", "-t", "raw"]
            if device and device != "default":
                cmd.extend(["-D", device])
        elif backend == "parecord":
            cmd = ["parecord", "--rate", str(sample_rate), "--channels", "1", "--format", "s16le", "--raw"]
            if device and device != "default":
                cmd.extend(["--device", device])
        elif backend == "ffmpeg":
            cmd = ["ffmpeg", "-loglevel", "quiet", "-f", "alsa", "-i", device, "-ar", str(sample_rate), "-ac", "1", "-f", "s16le", "-"]

        self.proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, bufsize=4096)

    @staticmethod
    def _has_cmd(cmd: str) -> bool:
        return subprocess.call(["which", cmd], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0

    def read(self, num_samples: int) -> bytes:
        num_bytes = num_samples * 2
        data = self.proc.stdout.read(num_bytes)
        return data

    def close(self):
        if self.proc:
            try:
                self.proc.terminate()
                self.proc.wait(timeout=1.0)
            except Exception:
                try:
                    self.proc.kill()
                except Exception:
                    pass


class WavFileStream(AudioStreamBase):
    """File stream for unit testing VAD logic with existing audio files."""
    def __init__(self, wav_path: str, chunk_size: int = 512):
        self.wf = wave.open(wav_path, "rb")
        self.chunk_size = chunk_size

    def read(self, num_samples: int) -> bytes:
        data = self.wf.readframes(num_samples)
        # Simulate slight real-time delay in test mode if desired, or return immediately
        return data

    def close(self):
        if self.wf:
            self.wf.close()


def open_input_stream(backend: str, sample_rate: int, chunk_size: int, device: str = "default", test_file: str = None) -> AudioStreamBase:
    if test_file:
        return WavFileStream(test_file, chunk_size=chunk_size)

    if backend in ("pyaudio", "auto"):
        try:
            return PyAudioStream(sample_rate=sample_rate, chunk_size=chunk_size)
        except Exception as e:
            if backend == "pyaudio":
                raise
            # Fall back to subprocess
            sys.stderr.write(f"[ai-record] PyAudio init failed ({e}); falling back to subprocess capture.\n")
            return SubprocessStream(sample_rate=sample_rate, backend="auto", device=device)

    return SubprocessStream(sample_rate=sample_rate, backend=backend, device=device)


def parse_threshold(threshold_str: str) -> float:
    t = str(threshold_str).strip()
    if t.endswith("%"):
        pct = float(t[:-1]) / 100.0
        # 16-bit signed audio max value is 32768
        return pct * 32768.0
    return float(t)


def save_wav(output_path: str, frames: list, sample_rate: int):
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    with wave.open(output_path, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)  # 16-bit
        wf.setframerate(sample_rate)
        wf.writeframes(b"".join(frames))


def main():
    parser = argparse.ArgumentParser(
        description="Record audio until user stops speaking (Voice Activity & Silence Detection)."
    )
    parser.add_argument("-o", "--output", default=os.getenv("AI_AUDIO_OUTPUT", "/tmp/ai_dotfiles/input_recording.wav"),
                        help="Path to save output WAV file")
    parser.add_argument("-s", "--silence-duration", type=float,
                        default=float(os.getenv("AUDIO_SILENCE_DURATION", "5.0")),
                        help="Duration of silence in seconds to trigger end of recording (default: 5.0)")
    parser.add_argument("-t", "--threshold", default=os.getenv("AUDIO_SILENCE_THRESHOLD", "2.0%"),
                        help="Silence/energy threshold as percentage (e.g. 2%%) or raw RMS value (e.g. 600)")
    default_listen_timeout = float(
        os.getenv("AUDIO_LISTEN_TIMEOUT", os.getenv("LISTEN_TIMEOUT", os.getenv("AUDIO_WAIT_TIMEOUT", "30.0")))
    )
    parser.add_argument("-w", "--wait-timeout", "--listen-timeout", type=float,
                        default=default_listen_timeout,
                        help="Max seconds to wait for speech while listening before exiting (default: 30)")
    parser.add_argument("-m", "--max-duration", type=float,
                        default=float(os.getenv("AUDIO_MAX_DURATION", "120.0")),
                        help="Maximum total recording duration in seconds (default: 120)")
    parser.add_argument("-r", "--sample-rate", type=int,
                        default=int(os.getenv("AUDIO_SAMPLE_RATE", "16000")),
                        help="Sample rate in Hz (default: 16000)")
    parser.add_argument("--backend", default=os.getenv("AUDIO_RECORDER", "auto"),
                        choices=["auto", "pyaudio", "arecord", "parecord", "ffmpeg"],
                        help="Recording backend (default: auto)")
    parser.add_argument("--device", default=os.getenv("AUDIO_DEVICE", "default"),
                        help="Audio input device name (default: default)")
    parser.add_argument("--prefix", default="[ai-dictate] ",
                        help="Log prefix string for terminal output (default: '[ai-dictate] ')")
    parser.add_argument("-q", "--quiet", action="store_true",
                        help="Suppress status and progress messages to stderr")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Print real-time RMS audio levels to stderr")
    parser.add_argument("--test-input", default=None,
                        help="Path to existing WAV file for testing VAD logic without microphone")

    args = parser.parse_args()
    prefix = args.prefix

    # Audio chunk configuration: 512 samples at 16000Hz = 32ms
    chunk_size = 512
    sample_rate = args.sample_rate
    chunk_duration = chunk_size / sample_rate

    # Pre-speech buffer: 400ms ring buffer to capture the beginning of speech
    pre_speech_chunks = max(4, int(0.4 / chunk_duration))
    pre_speech_ring = collections.deque(maxlen=pre_speech_chunks)

    # Convert user threshold
    base_threshold = parse_threshold(args.threshold)

    # Signal handling for graceful Ctrl+C
    captured_frames = []
    interrupted = False

    def handle_signal(sig, frame):
        nonlocal interrupted
        interrupted = True
        if not args.quiet:
            sys.stderr.write(f"\n{prefix}Interrupted by user. Finalizing audio file...\n")

    signal.signal(signal.SIGINT, handle_signal)
    signal.signal(signal.SIGTERM, handle_signal)

    stream = open_input_stream(
        backend=args.backend,
        sample_rate=sample_rate,
        chunk_size=chunk_size,
        device=args.device,
        test_file=args.test_input,
    )

    try:
        # Phase 1: Noise Floor Calibration (~250ms / 8 chunks)
        calibration_samples = []
        for _ in range(8):
            data = stream.read(chunk_size)
            if not data:
                break
            calibration_samples.append(calc_rms(data))

        avg_noise_floor = sum(calibration_samples) / max(1, len(calibration_samples))
        # Adaptive threshold: must be above noise floor * 1.5, or base_threshold
        effective_threshold = max(base_threshold, avg_noise_floor * 1.5, 350.0)

        if args.verbose:
            sys.stderr.write(
                f"{prefix}Noise floor: {avg_noise_floor:.1f} RMS | Effective threshold: {effective_threshold:.1f} RMS\n"
            )

        if not args.quiet:
            sys.stderr.write(f"{prefix}Listening... (Speak now; recording stops after {args.silence_duration:.0f}s of silence)\n")

        # Phase 2: State Machine
        STATE_WAITING = 0
        STATE_RECORDING = 1
        state = STATE_WAITING

        consecutive_voice_chunks = 0
        silence_duration_acc = 0.0
        start_wait_time = time.time()
        start_record_time = None

        while not interrupted:
            data = stream.read(chunk_size)
            if not data:
                # End of stream (e.g. test file or closed pipe)
                break

            rms = calc_rms(data)

            if args.verbose:
                state_str = "REC" if state == STATE_RECORDING else "WAIT"
                sys.stderr.write(f"\r[{state_str}] RMS: {rms:6.1f} | Thr: {effective_threshold:6.1f} | Silence: {silence_duration_acc:4.2f}s")
                sys.stderr.flush()

            if state == STATE_WAITING:
                pre_speech_ring.append(data)

                if rms >= effective_threshold:
                    consecutive_voice_chunks += 1
                else:
                    consecutive_voice_chunks = 0

                # Require 2 consecutive voice chunks (~64ms) to prevent clicks/pops from triggering
                if consecutive_voice_chunks >= 2:
                    state = STATE_RECORDING
                    start_record_time = time.time()
                    # Prepend pre-speech buffer
                    captured_frames.extend(pre_speech_ring)
                    captured_frames.append(data)
                    silence_duration_acc = 0.0
                    if not args.quiet and not args.verbose:
                        sys.stderr.write(f"{prefix}Voice detected; recording (stops after {args.silence_duration:.0f}s of silence)...\n")

                # Check initial wait timeout
                if time.time() - start_wait_time > args.wait_timeout:
                    if not args.quiet:
                        sys.stderr.write(f"\n{prefix}No speech detected after {args.wait_timeout:.1f}s. Exiting.\n")
                    # Clean up stale output file if it exists
                    if os.path.exists(args.output):
                        try:
                            os.remove(args.output)
                        except OSError:
                            pass
                    return 2

            elif state == STATE_RECORDING:
                captured_frames.append(data)

                if rms < effective_threshold:
                    silence_duration_acc += chunk_duration
                    if silence_duration_acc >= args.silence_duration:
                        # User stopped speaking!
                        if args.verbose:
                            sys.stderr.write("\n")
                        break
                else:
                    # Speech continued: reset silence accumulation
                    silence_duration_acc = 0.0

                # Max duration safety cutoff
                if time.time() - start_record_time >= args.max_duration:
                    if not args.quiet:
                        sys.stderr.write(f"\n{prefix}Max duration reached ({args.max_duration}s). Stopping.\n")
                    break

    finally:
        stream.close()

    if captured_frames:
        # Phase 3: Trailing silence trimming
        # Keep approx 0.3s of silence at the end for natural Whisper STT ending
        trim_silence_chunks = int(max(0.0, args.silence_duration - 0.3) / chunk_duration)
        if trim_silence_chunks > 0 and len(captured_frames) > trim_silence_chunks:
            final_frames = captured_frames[:-trim_silence_chunks]
        else:
            final_frames = captured_frames

        save_wav(args.output, final_frames, sample_rate)
        total_duration = len(final_frames) * chunk_duration
        if not args.quiet:
            sys.stderr.write(f"{prefix}Audio captured: {total_duration:.1f}s -> {args.output}\n")
        return 0
    else:
        # If nothing was captured, clean up any output file and exit with code 2
        if os.path.exists(args.output):
            try:
                os.remove(args.output)
            except OSError:
                pass
        if not args.quiet:
            sys.stderr.write(f"{prefix}No speech recorded.\n")
        return 2


if __name__ == "__main__":
    sys.exit(main())
