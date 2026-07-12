#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"
REQ_FILE="$SCRIPT_DIR/requirements.txt"

# Create venv if missing
if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment..."
  python3.12 -m venv "$VENV_DIR"
fi

# Activate
source "$VENV_DIR/bin/activate"

# Install requirements if any package is missing
if ! python -c "import torch, transformers, onnx, onnxruntime, numpy" 2>/dev/null; then
  echo "Installing dependencies..."
  pip install -q -r "$REQ_FILE"
fi

# Run the export
python "$SCRIPT_DIR/convert_to_onnx.py" \
  --model domai-tb/OpenPlants-Identification-ViT-Base-Patch16-224 \
  --out "$SCRIPT_DIR/../assets/ml/plant-identification"
