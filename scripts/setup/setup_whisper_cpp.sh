#!/usr/bin/env bash
# ==============================================================================
# Helper script to download, compile whisper.cpp, and fetch models
# ==============================================================================

set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

MODEL_DIR="${HOME}/.local/share/whisper.cpp/models"
BUILD_DIR="${HOME}/.local/share/whisper.cpp/src"
TARGET_BIN="${HOME}/.local/bin/whisper-cli"

mkdir -p "${MODEL_DIR}" "${BUILD_DIR}" "$(dirname "$TARGET_BIN")"

echo "===> Setting up whisper.cpp"

if [[ ! -d "${BUILD_DIR}/.git" ]]; then
    echo "Cloning whisper.cpp repository..."
    git clone --depth 1 https://github.com/ggerganov/whisper.cpp.git "${BUILD_DIR}"
else
    echo "Updating whisper.cpp..."
    git -C "${BUILD_DIR}" pull
fi

echo "===> Compiling whisper.cpp..."
cd "${BUILD_DIR}"

# Build CPU-only by default with SIMD acceleration (AVX2/FMA/NEON) and OpenMP
ENABLE_GPU="${ENABLE_GPU:-false}"

if command -v cmake &>/dev/null; then
    if [[ "$ENABLE_GPU" == "true" ]] && command -v nvcc &>/dev/null; then
        echo "CUDA detected: building with GGML_CUDA=1"
        cmake -B build -DGGML_CUDA=1
    else
        echo "Building CPU-optimized whisper.cpp with cmake (AVX2/FMA/OpenMP, no GPU/CUDA)..."
        cmake -B build \
            -DGGML_CUDA=OFF \
            -DGGML_VULKAN=OFF \
            -DGGML_METAL=OFF \
            -DGGML_OPENMP=ON \
            -DGGML_NATIVE=ON
    fi
    cmake --build build --config Release -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"
elif command -v make &>/dev/null; then
    echo "cmake not found; building directly with GNU make (CPU-optimized)..."
    make -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"
else
    echo "Error: Neither cmake nor make found. Please install cmake or gcc-c++ / build-essential." >&2
    exit 1
fi

# Link whisper-cli to local bin
if [[ -f "${BUILD_DIR}/build/bin/whisper-cli" ]]; then
    ln -sf "${BUILD_DIR}/build/bin/whisper-cli" "${TARGET_BIN}"
    echo "Installed whisper-cli to ${TARGET_BIN}"
elif [[ -f "${BUILD_DIR}/build/bin/main" ]]; then
    ln -sf "${BUILD_DIR}/build/bin/main" "${TARGET_BIN}"
    echo "Installed main as ${TARGET_BIN}"
elif [[ -f "${BUILD_DIR}/whisper-cli" ]]; then
    ln -sf "${BUILD_DIR}/whisper-cli" "${TARGET_BIN}"
    echo "Installed whisper-cli to ${TARGET_BIN}"
elif [[ -f "${BUILD_DIR}/main" ]]; then
    ln -sf "${BUILD_DIR}/main" "${TARGET_BIN}"
    echo "Installed main as ${TARGET_BIN}"
else
    FOUND_BIN="$(find "${BUILD_DIR}" -type f \( -name "whisper-cli" -o -name "main" \) -perm -111 2>/dev/null | head -n 1 || true)"
    if [[ -n "$FOUND_BIN" && -x "$FOUND_BIN" ]]; then
        ln -sf "$FOUND_BIN" "${TARGET_BIN}"
        echo "Installed $(basename "$FOUND_BIN") as ${TARGET_BIN}"
    else
        echo "Error: Built whisper binary not found in ${BUILD_DIR}." >&2
        exit 1
    fi
fi

echo "===> Downloading recommended models to ${MODEL_DIR}..."
# Download tiny.en (fastest for laptops/ThinkPad), tiny.en-q5_1, base.en, and large-v3-turbo
bash "${BUILD_DIR}/models/download-ggml-model.sh" tiny.en "${MODEL_DIR}"
bash "${BUILD_DIR}/models/download-ggml-model.sh" tiny.en-q5_1 "${MODEL_DIR}"
bash "${BUILD_DIR}/models/download-ggml-model.sh" base.en "${MODEL_DIR}"
bash "${BUILD_DIR}/models/download-ggml-model.sh" large-v3-turbo "${MODEL_DIR}"

echo "Setup complete! Models available at: ${MODEL_DIR}"
