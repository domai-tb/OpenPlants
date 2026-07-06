#!/usr/bin/env python3
"""
Convert a Hugging Face ViT image-classification model from Safetensors/PyTorch
to ONNX for mobile/Flutter inference.

Default target:
  juppy44/plant-identification-2m-vit-b

Outputs:
  output_dir/
    model.onnx
    labels.json
    preprocessor_config.json
    config.json
    model.int8.onnx        # optional, only with --quantize-dynamic

Install:
  pip install torch transformers safetensors huggingface_hub onnx onnxruntime pillow numpy

For gated models:
  huggingface-cli login
  # or:
  export HF_TOKEN=hf_...
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
from pathlib import Path
from typing import Any

import numpy as np
import onnx
import onnxruntime as ort
import torch
from torch import nn
from transformers import AutoConfig, AutoImageProcessor, AutoModelForImageClassification


DEFAULT_MODEL_ID = "juppy44/plant-identification-2m-vit-b"


class LogitsOnlyWrapper(nn.Module):
    """
    Hugging Face image-classification models return an ImageClassifierOutput.
    ONNX export should expose only the logits tensor.
    """

    def __init__(self, model: nn.Module):
        super().__init__()
        self.model = model

    def forward(self, pixel_values: torch.Tensor) -> torch.Tensor:
        return self.model(pixel_values=pixel_values).logits


def resolve_image_size(processor: Any, config: Any) -> tuple[int, int]:
    """
    Resolve model input size from processor/config.

    ViT usually expects 224x224 pixel_values:
      [batch, 3, height, width]
    """

    size = getattr(processor, "size", None)

    if isinstance(size, dict):
        if "height" in size and "width" in size:
            return int(size["height"]), int(size["width"])
        if "shortest_edge" in size:
            edge = int(size["shortest_edge"])
            return edge, edge

    image_size = getattr(config, "image_size", None)
    if isinstance(image_size, int):
        return image_size, image_size
    if isinstance(image_size, (list, tuple)) and len(image_size) == 2:
        return int(image_size[0]), int(image_size[1])

    return 224, 224


def save_json(path: Path, data: Any) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def copy_if_exists(src_dir_or_model_id: str, filename: str, out_dir: Path) -> None:
    """
    If the model is a local directory, copy config/preprocessor files directly.
    For Hub models, save_pretrained handles this better.
    """
    src_path = Path(src_dir_or_model_id) / filename
    if src_path.exists():
        shutil.copy2(src_path, out_dir / filename)


def export_onnx(
    model_id_or_path: str,
    out_dir: Path,
    hf_token: str | None,
    opset: int,
    dynamic_batch: bool,
    quantize_dynamic: bool,
    validate: bool,
) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"[1/7] Loading config: {model_id_or_path}")
    config = AutoConfig.from_pretrained(
        model_id_or_path,
        token=hf_token,
        trust_remote_code=False,
    )

    print("[2/7] Loading image processor")
    processor = AutoImageProcessor.from_pretrained(
        model_id_or_path,
        token=hf_token,
        trust_remote_code=False,
    )

    print("[3/7] Loading model weights")
    model = AutoModelForImageClassification.from_pretrained(
        model_id_or_path,
        token=hf_token,
        trust_remote_code=False,
        use_safetensors=True,
    )
    model.eval()
    model.to("cpu")

    height, width = resolve_image_size(processor, config)
    num_labels = int(getattr(config, "num_labels", 0))

    print(f"      Input shape: [1, 3, {height}, {width}]")
    print(f"      Labels: {num_labels}")

    wrapped = LogitsOnlyWrapper(model).eval()

    dummy_input = torch.randn(1, 3, height, width, dtype=torch.float32)

    onnx_path = out_dir / "model.onnx"

    input_names = ["pixel_values"]
    output_names = ["logits"]

    dynamic_axes = None
    if dynamic_batch:
        dynamic_axes = {
            "pixel_values": {0: "batch"},
            "logits": {0: "batch"},
        }

    print(f"[4/7] Exporting ONNX: {onnx_path}")
    with torch.no_grad():
        torch.onnx.export(
            wrapped,
            dummy_input,
            str(onnx_path),
            input_names=input_names,
            output_names=output_names,
            dynamic_axes=dynamic_axes,
            opset_version=opset,
            do_constant_folding=True,
        )

    print("[5/7] Checking ONNX graph")
    exported = onnx.load(str(onnx_path))
    onnx.checker.check_model(exported)

    print("[6/7] Saving metadata")
    processor.save_pretrained(out_dir)
    config.save_pretrained(out_dir)

    id2label = getattr(config, "id2label", None) or {}
    id2label = {str(k): v for k, v in id2label.items()}
    save_json(out_dir / "labels.json", id2label)

    export_info = {
        "source_model": model_id_or_path,
        "onnx_file": "model.onnx",
        "input_name": "pixel_values",
        "input_shape": [1, 3, height, width],
        "input_dtype": "float32",
        "output_name": "logits",
        "output_shape": [1, num_labels if num_labels > 0 else "num_labels"],
        "output_semantics": "raw logits; apply softmax in app code if probabilities are needed",
        "image_preprocessing": {
            "use": "preprocessor_config.json",
            "typical_layout": "RGB image -> resize/crop according to processor -> normalize -> NCHW float32",
        },
        "dynamic_batch": dynamic_batch,
        "opset": opset,
    }
    save_json(out_dir / "onnx_export_info.json", export_info)

    if validate:
        print("[7/7] Validating ONNXRuntime output against PyTorch")
        ort_session = ort.InferenceSession(
            str(onnx_path),
            providers=["CPUExecutionProvider"],
        )

        with torch.no_grad():
            torch_logits = wrapped(dummy_input).cpu().numpy()

        ort_logits = ort_session.run(
            ["logits"],
            {"pixel_values": dummy_input.cpu().numpy()},
        )[0]

        max_abs_diff = float(np.max(np.abs(torch_logits - ort_logits)))
        mean_abs_diff = float(np.mean(np.abs(torch_logits - ort_logits)))

        print(f"      max_abs_diff:  {max_abs_diff:.8f}")
        print(f"      mean_abs_diff: {mean_abs_diff:.8f}")

        if max_abs_diff > 1e-3:
            raise RuntimeError(
                "ONNX validation difference is larger than expected. "
                "The export completed, but inspect the graph before using it."
            )
    else:
        print("[7/7] Validation skipped")

    if quantize_dynamic:
        print("[optional] Creating dynamically quantized INT8 model")
        from onnxruntime.quantization import QuantType, quantize_dynamic

        int8_path = out_dir / "model.int8.onnx"
        quantize_dynamic(
            model_input=str(onnx_path),
            model_output=str(int8_path),
            weight_type=QuantType.QInt8,
        )

        quantized = onnx.load(str(int8_path))
        onnx.checker.check_model(quantized)

        print(f"      Quantized model: {int8_path}")

    print("\nDone.")
    print(f"ONNX model: {onnx_path}")
    print(f"Metadata:   {out_dir}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL_ID,
        help="Hugging Face model ID or local model directory.",
    )
    parser.add_argument(
        "--out",
        default="onnx_export/plant-identification-2m-vit-b",
        help="Output directory.",
    )
    parser.add_argument(
        "--hf-token",
        default=os.environ.get("HF_TOKEN"),
        help="Hugging Face token. Defaults to HF_TOKEN env var.",
    )
    parser.add_argument(
        "--opset",
        type=int,
        default=17,
        help="ONNX opset version. 17 is a safe modern default.",
    )
    parser.add_argument(
        "--dynamic-batch",
        action="store_true",
        help="Export with dynamic batch axis. For mobile, static batch=1 is often simpler.",
    )
    parser.add_argument(
        "--quantize-dynamic",
        action="store_true",
        help="Also export model.int8.onnx using ONNX Runtime dynamic quantization.",
    )
    parser.add_argument(
        "--no-validate",
        action="store_true",
        help="Skip ONNXRuntime numerical validation.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    export_onnx(
        model_id_or_path=args.model,
        out_dir=Path(args.out),
        hf_token=args.hf_token,
        opset=args.opset,
        dynamic_batch=args.dynamic_batch,
        quantize_dynamic=args.quantize_dynamic,
        validate=not args.no_validate,
    )


if __name__ == "__main__":
    main()