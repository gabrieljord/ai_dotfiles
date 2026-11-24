#!/usr/bin/env python3
"""
scripts/pipeline/validator.py
=============================
Subprocess Linter & Validation Loop for voice-driven code dictation.
Routes generated source code to local language linters/compilers:
  .rs      -> rustfmt
  .py      -> python3 -m py_compile or ruff check
  .ts/.js  -> biome check

Verification Loop:
  - If linter exits 0: prints code to stdout and exits 0.
  - If linter exits with error: captures stderr, appends correction request,
    and re-invokes decoder.py via Ollama API.
  - Hardcapped at 2 retries (3 total attempts).
  - If still failing on 3rd attempt: outputs the code with the commented-out
    linter error appended to the top.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any, Dict, Optional, Tuple, Union

# Resolve repository paths
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent

# Import decoder module from same pipeline package
try:
    from . import decoder
except ImportError:
    import decoder  # type: ignore

MAX_RETRIES = 2  # Hardcap at 2 retries (3 total attempts)


def find_env_file() -> Optional[Path]:
    """Locate project .env file in standard search locations."""
    candidates = [
        Path(os.environ.get("AI_DOTFILES_ENV", "")),
        REPO_ROOT / ".env",
        Path.cwd() / ".env",
        Path.home() / ".config" / "ai_dotfiles" / ".env",
    ]
    for candidate in candidates:
        if candidate and candidate.is_file():
            return candidate
    return None


def load_env_variables() -> Dict[str, str]:
    """Parse .env file into key-value dictionary."""
    env_vars: Dict[str, str] = {}
    env_path = find_env_file()
    if not env_path:
        return env_vars

    try:
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    key, val = line.split("=", 1)
                    key = key.strip()
                    val = val.strip().strip("'\"")
                    env_vars[key] = val
                    if key not in os.environ:
                        os.environ[key] = val
    except Exception as e:
        print(f"[validator] WARN: Failed to read .env at {env_path}: {e}", file=sys.stderr)

    return env_vars


LOADED_ENV = load_env_variables()
TMP_DIR = Path(os.environ.get("AI_TMP_DIR", "/tmp/ai_dotfiles"))
TMP_DIR.mkdir(parents=True, exist_ok=True)


def check_brackets_fallback(code: str) -> Tuple[bool, str]:
    """Lightweight fallback syntax validator checking balanced brackets & string delimiters."""
    stack: list[str] = []
    pairs = {")": "(", "}": "{", "]": "["}
    in_string: Optional[str] = None
    escaped = False

    for idx, char in enumerate(code):
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == in_string:
                in_string = None
            continue

        if char in ("'", '"', "`"):
            in_string = char
            continue

        if char in pairs.values():
            stack.append(char)
        elif char in pairs:
            if not stack or stack[-1] != pairs[char]:
                return False, f"Syntax Error: Unmatched closing bracket '{char}' at position {idx}."
            stack.pop()

    if stack:
        return False, f"Syntax Error: Unclosed bracket '{stack[-1]}' before end of file."
    if in_string:
        return False, f"Syntax Error: Unterminated string literal ({in_string}) before end of file."

    return True, ""


def run_linter(code: str, ext: str) -> Tuple[bool, str]:
    """
    Routes source code to local linter based on file extension:
      .rs      -> rustfmt
      .py      -> python -m py_compile or ruff check
      .ts/.js  -> biome check

    Returns:
        (is_valid, error_output)
    """
    clean_ext = ext.lower().lstrip(".")
    temp_file = TMP_DIR / f"linter_check_{os.getpid()}.{clean_ext}"

    try:
        with open(temp_file, "w", encoding="utf-8") as f:
            f.write(code)

        # 1. Python (.py)
        if clean_ext in ("py", "python"):
            if shutil.which("ruff"):
                cmd = ["ruff", "check", "--isolated", "--no-cache", str(temp_file)]
                res = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
                if res.returncode == 0:
                    return True, ""
                err = res.stderr.strip() or res.stdout.strip()
                return False, err
            else:
                cmd = [sys.executable, "-m", "py_compile", str(temp_file)]
                res = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
                if res.returncode == 0:
                    return True, ""
                err = res.stderr.strip() or res.stdout.strip()
                return False, err

        # 2. Rust (.rs)
        elif clean_ext in ("rs", "rust"):
            if shutil.which("rustfmt"):
                cmd = ["rustfmt", "--check", str(temp_file)]
                res = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
                if res.returncode == 0:
                    return True, ""
                err = res.stderr.strip() or res.stdout.strip()
                return False, err
            elif shutil.which("rustc"):
                cmd = ["rustc", "--crate-type", "lib", "--emit=metadata", "-o", "/dev/null", str(temp_file)]
                res = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
                if res.returncode == 0:
                    return True, ""
                err = res.stderr.strip() or res.stdout.strip()
                return False, err
            else:
                # Fallback syntax balance validation if toolchain not installed
                return check_brackets_fallback(code)

        # 3. TypeScript / JavaScript (.ts, .js)
        elif clean_ext in ("ts", "typescript", "js", "javascript"):
            if shutil.which("biome"):
                cmd = ["biome", "check", str(temp_file)]
                res = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
                if res.returncode == 0:
                    return True, ""
                err = res.stderr.strip() or res.stdout.strip()
                return False, err
            elif clean_ext in ("js", "javascript") and shutil.which("node"):
                cmd = ["node", "--check", str(temp_file)]
                res = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
                if res.returncode == 0:
                    return True, ""
                err = res.stderr.strip() or res.stdout.strip()
                return False, err
            else:
                # Fallback syntax balance validation if biome not in PATH
                return check_brackets_fallback(code)

        # 4. Other languages: perform general bracket balance check
        return check_brackets_fallback(code)

    except subprocess.TimeoutExpired:
        return False, "Linter timed out after 5.0 seconds."
    except Exception as e:
        return False, f"Linter execution failure: {e}"
    finally:
        if temp_file.is_file():
            try:
                temp_file.unlink()
            except Exception:
                pass


def format_commented_error(error_msg: str, ext: str) -> str:
    """Format linter error as comment block matching target language syntax."""
    clean_ext = ext.lower().lstrip(".")
    comment_char = "#" if clean_ext in ("py", "sh", "bash", "rb", "yml", "yaml", "r") else "//"

    lines = [f"{comment_char} LINTER ERROR:"]
    for l in error_msg.strip().splitlines():
        lines.append(f"{comment_char} {l}")
    return "\n".join(lines)


def validate_and_correct(
    code: str,
    ext: str,
    ir: Optional[Union[Dict[str, Any], str]] = None,
    max_retries: int = MAX_RETRIES,
) -> Tuple[str, bool]:
    """
    Executes the verification loop:
      - Validates with linter.
      - On error: queries decoder.decode with correction request up to max_retries.
      - Returns: (final_code, is_valid_boolean)
    """
    current_code = code.strip()
    last_error = ""

    # Parse IR if string provided
    ir_data: Optional[Union[Dict[str, Any], str]] = ir
    if isinstance(ir, str) and ir.strip():
        try:
            ir_data = json.loads(ir)
        except Exception:
            ir_data = ir

    for attempt in range(max_retries + 1):
        is_valid, error = run_linter(current_code, ext)
        if is_valid:
            return current_code, True

        last_error = error
        print(f"[validator] WARN: Validation failed on attempt {attempt + 1}/{max_retries + 1}: {error}", file=sys.stderr)

        if attempt < max_retries:
            # Re-invoke Ollama Decoder with correction prompt
            correction_request = (
                f"Linter validation error on .{ext} code:\n"
                f"{error}\n\n"
                f"Previous code attempt:\n"
                f"{current_code}\n\n"
                f"Please fix the code to resolve the linter error and return valid .{ext} code only."
            )
            try:
                current_code = decoder.decode(
                    ir=ir_data or {"intent": "code_correction", "code": current_code},
                    ext=ext,
                    correction=correction_request,
                ).strip()
            except Exception as e:
                print(f"[validator] WARN: Re-invocation of decoder failed: {e}", file=sys.stderr)

    # Failed after 2 retries (3 total attempts):
    # Output the last generated code with the commented-out linter error appended to the top
    commented_error = format_commented_error(last_error, ext)
    final_output = f"{commented_error}\n{current_code}"
    return final_output, False


def main() -> None:
    parser = argparse.ArgumentParser(description="Subprocess Linter & Code Validation Loop")
    parser.add_argument("code_input", nargs="?", default="", help="Raw source code or file path")
    parser.add_argument("-e", "--ext", default="py", help="File extension (e.g. py, rs, ts)")
    parser.add_argument("--ir", default=None, help="Original JSON AST string")
    parser.add_argument("--ir-file", default=None, help="Path to original JSON AST file")
    args = parser.parse_args()

    code_input = args.code_input
    if not code_input:
        if not sys.stdin.isatty():
            code_input = sys.stdin.read()

    if not code_input:
        print("[validator] Error: No code input provided.", file=sys.stderr)
        sys.exit(1)

    # If code_input is path to existing file, read contents
    if os.path.isfile(code_input):
        with open(code_input, "r", encoding="utf-8") as f:
            code_input = f.read()

    # Read IR if provided via file
    ir_payload = args.ir
    if not ir_payload and args.ir_file and os.path.isfile(args.ir_file):
        with open(args.ir_file, "r", encoding="utf-8") as f:
            ir_payload = f.read()

    final_code, is_valid = validate_and_correct(
        code=code_input,
        ext=args.ext,
        ir=ir_payload,
    )

    # Dump verified code to stdout
    print(final_code)
    sys.exit(0 if is_valid else 1)


if __name__ == "__main__":
    main()
