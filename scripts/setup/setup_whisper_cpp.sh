#!/usr/bin/env bash
# ==============================================================================
# Helper script to download, compile whisper.cpp, and fetch models
# ==============================================================================

set -euo pipefail

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

if [[ "$ENABLE_GPU" == "true" ]] && command -v nvcc &>/dev/null; then
    echo "CUDA detected: building with GGML_CUDA=1"
    cmake -B build -DGGML_CUDA=1
else
    echo "Building CPU-optimized whisper.cpp (AVX2/FMA/OpenMP, no GPU/CUDA)..."
    cmake -B build \
        -DGGML_CUDA=OFF \
        -DGGML_VULKAN=OFF \
        -DGGML_METAL=OFF \
        -DGGML_OPENMP=ON \
        -DGGML_NATIVE=ON
fi

cmake --build build --config Release -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"

# Link whisper-cli to local bin
if [[ -f "${BUILD_DIR}/build/bin/whisper-cli" ]]; then
    ln -sf "${BUILD_DIR}/build/bin/whisper-cli" "${TARGET_BIN}"
    echo "Installed whisper-cli to ${TARGET_BIN}"
elif [[ -f "${BUILD_DIR}/build/bin/main" ]]; then
    ln -sf "${BUILD_DIR}/build/bin/main" "${TARGET_BIN}"
    echo "Installed main as ${TARGET_BIN}"
fi

echo "===> Downloading recommended models to ${MODEL_DIR}..."
# Download large-v3-turbo and base.en if not present
bash "${BUILD_DIR}/models/download-ggml-model.sh" large-v3-turbo "${MODEL_DIR}"
bash "${BUILD_DIR}/models/download-ggml-model.sh" base.en "${MODEL_DIR}"

echo "Setup complete! Models available at: ${MODEL_DIR}"
