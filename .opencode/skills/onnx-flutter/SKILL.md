---
name: onnx-flutter
description: Domain knowledge for integrating ONNX Runtime into Flutter apps, especially local image classification pipelines using bundled model.onnx assets, preprocessing metadata, tensor contracts, and result postprocessing.
-------------------------

# ONNX Runtime in Flutter

## Scope

This skill covers ONNX integration inside Flutter applications.

It assumes the app already has an ONNX model artifact, usually named:

```text
model.onnx
```

This skill does not cover model training, model export, safetensors, PyTorch, TensorFlow conversion, or Hugging Face model preparation.

The relevant Flutter-side pipeline is:

```text
image or other input source
→ app-side preprocessing
→ ONNX Runtime input tensor
→ ONNX Runtime session
→ output tensor
→ app-side postprocessing
→ UI result
```

## Core Concepts

### ONNX

ONNX is a portable machine-learning model format.

An ONNX file represents:

```text
model graph
operators
input tensors
output tensors
tensor shapes
tensor data types
weights
metadata
```

For a Flutter application, the ONNX file is the deployable model artifact. Flutter does not execute the model directly. Flutter loads the model and sends tensors to ONNX Runtime.

### ONNX Runtime

ONNX Runtime is the native inference engine that executes the ONNX model.

Flutter communicates with ONNX Runtime through a plugin. The Flutter code usually owns the app-level lifecycle, while ONNX Runtime owns native model execution.

The runtime relationship is:

```text
Flutter Dart code
→ ONNX Runtime Flutter plugin
→ native ONNX Runtime library
→ model.onnx
```

### Flutter ONNX plugin

A Flutter ONNX plugin usually exposes concepts such as:

```text
runtime environment
session options
session
input tensor
run options
output tensor
dispose/release lifecycle
```

The exact class names depend on the package, but the architecture is stable.

The session is the loaded model. It should normally be long-lived and reused. Creating a session for each inference call is inefficient.

## Asset Model

ONNX models are commonly bundled as Flutter assets.

A typical asset layout is:

```text
assets/
  ml/
    model.onnx
    labels.json
    model_metadata.json
```

`model.onnx` is the executable model graph.

`labels.json` maps numeric output indices to human-readable labels.

`model_metadata.json` stores app-side model contract information that the Flutter app needs in order to prepare inputs and interpret outputs.

Useful metadata fields include:

```json
{
  "inputName": "pixel_values",
  "outputName": "logits",
  "inputShape": [1, 3, 224, 224],
  "inputDType": "float32",
  "layout": "NCHW",
  "channelOrder": "RGB",
  "imageWidth": 224,
  "imageHeight": 224,
  "mean": [0.485, 0.456, 0.406],
  "std": [0.229, 0.224, 0.225],
  "rescaleFactor": 0.00392156862745098,
  "outputType": "logits"
}
```

The ONNX file defines the graph, but the app often still needs external metadata for image preprocessing, label mapping, and output interpretation.

## Runtime Lifecycle

The ONNX runtime integration has two lifecycle levels.

### Long-lived lifecycle

Long-lived objects exist for as long as the classifier or model feature is active:

```text
runtime environment
session options
ONNX session
model metadata
label mapping
```

The ONNX session should be reused across inference calls.

### Per-inference lifecycle

Per-inference objects exist for a single model run:

```text
decoded image or source data
preprocessed tensor buffer
input tensor
run options
output tensor
postprocessed result
```

Native objects may allocate memory outside the Dart heap. Runtime-specific release/disposal rules matter. Do not rely only on Dart garbage collection for native runtime objects when the plugin exposes explicit cleanup APIs.

A healthy lifecycle model is:

```text
initialize runtime once
load model once
create session once
run many inferences
release temporary tensors after each run
dispose session when feature is no longer used
dispose runtime environment when app no longer needs ONNX
```

## Input Tensor Contract

Every ONNX model has named inputs.

A model input contract includes:

```text
input name
input shape
input data type
input layout
batch dimension
channel dimension
spatial dimensions
```

For image classification, common input shapes are:

```text
[1, 3, 224, 224]
[1, 224, 224, 3]
```

These represent different layouts.

### NCHW

```text
[batch, channels, height, width]
```

Example:

```text
[1, 3, 224, 224]
```

This means:

```text
1 image
3 channels
224 height
224 width
```

NCHW is common for PyTorch-style vision models.

### NHWC

```text
[batch, height, width, channels]
```

Example:

```text
[1, 224, 224, 3]
```

NHWC is common in many image APIs and TensorFlow-style pipelines.

The number of tensor values can be identical while the semantic layout is different. Passing NHWC data into an NCHW model usually produces incorrect predictions.

## Image Preprocessing Contract

For image models, preprocessing is part of the model contract.

The app must convert a camera/gallery image into exactly the tensor expected by the ONNX model.

Common preprocessing operations:

```text
decode encoded image bytes
apply orientation handling if needed
convert to RGB
remove alpha channel if present
resize or crop to model input size
convert integer pixels to float values
rescale pixel values
normalize channels
arrange values into the expected tensor layout
create a typed input tensor
```

Common image pixel flow:

```text
uint8 pixel in range 0..255
→ float value
→ rescale to 0..1
→ normalize with mean/std
→ place into tensor layout
```

Common normalization:

```text
rescaled = pixel * rescaleFactor
normalized = (rescaled - mean) / std
```

For `rescaleFactor = 1 / 255`, this is:

```text
rescaled = pixel / 255.0
normalized = (rescaled - mean) / std
```

Preprocessing mistakes are the most common cause of bad model output.

Common mistakes:

```text
wrong image size
wrong crop strategy
RGB/BGR mismatch
alpha channel accidentally included
wrong mean/std
missing rescale
wrong tensor layout
height and width swapped
ignored EXIF orientation
integer tensor passed where float tensor is expected
```

## Pixel Memory Layout

Decoded image libraries often expose pixels in interleaved RGB order:

```text
R G B R G B R G B ...
```

A model expecting NCHW usually needs planar channel order:

```text
all R values
all G values
all B values
```

For NCHW, the flattened tensor usually looks like:

```text
R plane: height × width values
G plane: height × width values
B plane: height × width values
```

The preprocessor owns this conversion.

## Output Tensor Contract

Image classifiers commonly return logits.

Logits are raw scores. They are not probabilities.

A typical classification output shape is:

```text
[1, numberOfClasses]
```

The postprocessor converts raw output into user-facing predictions.

Common output postprocessing:

```text
flatten output tensor
select relevant output if model has multiple outputs
apply softmax if output is logits
rank classes by score
map indices to labels
return top-k predictions
```

Softmax:

```text
probability_i = exp(logit_i - max_logit) / sum(exp(logit_j - max_logit))
```

Subtracting `max_logit` improves numerical stability.

The final result model usually contains:

```text
class index
label
score
optional raw logit
```

## Label Contract

The model output provides numeric positions, not readable labels.

A label file maps output indices to human-readable names.

Example:

```json
{
  "0": "cat",
  "1": "dog",
  "2": "bird"
}
```

The invariant is:

```text
output score at index i belongs to label i
```

If labels are out of order, the app can show confident but wrong predictions.

## Flutter Architecture

Keep ONNX-specific logic below the UI layer.

A clean architecture separates:

```text
UI layer
  shows image, loading state, errors, and classification results

input layer
  obtains image bytes from camera, gallery, file, stream, or memory

preprocessing layer
  converts raw app input into model tensor data

runtime layer
  owns ONNX Runtime environment/session/tensors

postprocessing layer
  converts raw outputs into app-level results

domain model layer
  represents classification results
```

Widgets should not know:

```text
ONNX input names
tensor layout
channel order
mean/std normalization
runtime object cleanup rules
nested output tensor shapes
```

Widgets should consume stable app-level objects such as:

```text
ClassificationResult
ClassificationState
ClassificationError
```

## Still Image Classification

Still image classification is the simplest ONNX/Flutter path.

Flow:

```text
camera/gallery produces encoded image file
→ app reads bytes
→ decoder creates RGB image
→ preprocessor creates tensor
→ ONNX Runtime runs once
→ postprocessor creates top-k result
→ UI displays result
```

This is easier than live camera inference because it avoids high-frequency frame conversion and throttling.

## Live Camera Inference

Live camera inference is a different design.

Flow:

```text
camera stream frame
→ platform-specific frame format
→ RGB conversion
→ preprocessing
→ inference
→ throttled result update
```

Live frames may arrive as YUV or other platform-specific formats. RGB conversion becomes a separate correctness and performance concern.

Live inference should usually be throttled. The app rarely needs to classify every camera frame.

## Threading and Responsiveness

Model inference is not the only expensive operation.

Potentially expensive work:

```text
image decoding
image resizing
crop/orientation handling
tensor allocation
normalization loops
ONNX Runtime inference
output conversion
```

For still-image classification, async inference may be enough.

For repeated inference or live camera use, isolate-based separation can reduce UI jank.

Good separation:

```text
UI isolate:
  visual state and interaction

worker/inference layer:
  decode
  preprocess
  run model
  postprocess
```

## Execution Providers

ONNX Runtime can use execution providers for hardware-specific acceleration.

Common mobile-related providers include:

```text
CPU
Android NNAPI
Apple CoreML
other build-specific acceleration providers
```

CPU is the simplest and most portable baseline.

Hardware acceleration can improve speed but introduces compatibility concerns:

```text
operator support varies
device support varies
platform version matters
runtime build configuration matters
fallback behavior can differ
```

For small classifiers, CPU inference may be sufficient. Optimize only after measuring the full pipeline, including preprocessing.

## Performance Model

End-to-end latency includes:

```text
input acquisition
file I/O
image decoding
orientation correction
resize/crop
normalization
tensor allocation
runtime dispatch
model execution
output parsing
softmax/top-k
UI update
```

A small model can still feel slow if the app repeatedly decodes huge camera images or performs expensive preprocessing on the UI isolate.

Important performance principles:

```text
reuse ONNX sessions
avoid recreating runtime state per image
resize source images before expensive processing when possible
avoid unnecessary tensor copies
avoid running inference on every camera frame
measure preprocessing and inference separately
prefer correctness before acceleration
```

## Metadata Design

A metadata file should encode the model contract in machine-readable form.

Useful fields:

```text
model version
input name
output name
input shape
input dtype
layout
channel order
image width
image height
rescale factor
normalization mean
normalization std
output type
label file path
top-k display default
```

Example:

```json
{
  "modelVersion": "1.0.0",
  "inputName": "pixel_values",
  "outputName": "logits",
  "inputShape": [1, 3, 224, 224],
  "inputDType": "float32",
  "layout": "NCHW",
  "channelOrder": "RGB",
  "imageWidth": 224,
  "imageHeight": 224,
  "rescaleFactor": 0.00392156862745098,
  "mean": [0.485, 0.456, 0.406],
  "std": [0.229, 0.224, 0.225],
  "outputType": "logits",
  "labelsAsset": "assets/ml/labels.json",
  "defaultTopK": 5
}
```

Metadata reduces hardcoded assumptions in Dart code.

## Testing Concepts

A reliable ONNX integration benefits from reference fixtures.

Useful fixtures:

```text
fixed input image
expected input tensor shape
expected top-1 label
expected top-k labels
expected logits or probabilities
model metadata
labels file
```

Exact floating-point equality across environments is not always required. Stable top-1 or top-k agreement is often the more useful correctness check.

Strong tests cover:

```text
metadata loading
label loading
image preprocessing shape
tensor dtype
tensor length
softmax behavior
top-k selection
invalid image handling
classifier initialization/disposal
```

Golden tests are useful because they catch silent preprocessing regressions.

## Error Taxonomy

### Model loading errors

Common causes:

```text
missing asset declaration
wrong asset path
unsupported ONNX operator
unsupported ONNX opset
native runtime library not available
platform architecture mismatch
```

### Input errors

Common causes:

```text
wrong input name
wrong shape
wrong dtype
missing batch dimension
wrong channel count
NCHW/NHWC mismatch
height/width swapped
```

### Preprocessing errors

Common causes:

```text
RGB/BGR mismatch
wrong resize behavior
wrong crop behavior
missing rescale
wrong mean/std
ignored EXIF orientation
alpha channel included
integer values used instead of floats
```

### Output errors

Common causes:

```text
logits treated as probabilities
softmax applied over wrong dimension
wrong output selected
nested tensor parsed incorrectly
label mapping order mismatch
top-k sorted ascending instead of descending
```

### Lifecycle errors

Common causes:

```text
session recreated per image
native tensors not released
runtime environment released too early
classification called before initialization
parallel calls through a session wrapper that is not concurrency-safe
```

## Package-Agnostic ONNX Runtime Pattern

Even when plugin APIs differ, the integration shape remains similar:

```text
load model bytes from Flutter assets
create runtime/session options
create ONNX session
load metadata and labels
prepare typed input buffer
create input tensor with expected shape
run session with named inputs
read output tensor
release temporary runtime objects
postprocess output
dispose session when finished
```

The exact class names are package-specific. The contracts are not.

## Correctness Invariants

A correct ONNX/Flutter integration preserves these invariants:

```text
The bundled ONNX file is the inference model.

The ONNX session is reused while active.

The input tensor name matches the model contract.

The input tensor shape matches the model contract.

The input tensor dtype matches the model contract.

The preprocessing matches the model contract.

The tensor layout matches the model contract.

The label mapping matches the output order.

Logits are converted before displaying confidence values.

Native runtime objects follow plugin lifecycle rules.

The app can run inference offline after installation.
```

## Design Smells

Avoid these patterns:

```text
hardcoding input name without metadata
hardcoding image size without metadata
mixing tensor code into Flutter widgets
creating an ONNX session inside a button handler
assuming logits are probabilities
assuming all models use NCHW
assuming all image models use 224x224
ignoring orientation of camera images
ignoring native resource disposal
optimizing with hardware acceleration before correctness is verified
```

## Preferred Mental Model

ONNX integration in Flutter is mostly a contract-preservation problem.

The important contracts are:

```text
Asset contract:
  Flutter can load the model and metadata.

Input contract:
  Dart creates exactly the tensor expected by the model.

Runtime contract:
  ONNX Runtime executes the graph and owns native resources.

Output contract:
  Raw tensors become meaningful app results.

Lifecycle contract:
  Runtime objects are initialized, reused, and disposed safely.

UI contract:
  The user sees stable results without blocked interaction.
```

Most bugs happen at the boundaries, especially between decoded image pixels and the ONNX input tensor.
