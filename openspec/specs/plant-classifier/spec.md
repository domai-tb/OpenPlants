# Plant Classifier

## Purpose

Provides the ONNX-based image classification pipeline: model loading, image preprocessing, inference, and postprocessing.

## Requirements

### Requirement: ONNX session lifecycle
The system SHALL create a single ONNX Runtime session from the bundled `model.onnx` asset on first use and reuse it for all subsequent inference calls. The session SHALL be disposed when the plant identification feature is no longer needed.

#### Scenario: Session initialization on first inference
- **WHEN** the classifier receives its first inference request
- **THEN** it loads `assets/ml/plant-identification/model.onnx` into an ONNX Runtime session and stores it for reuse

#### Scenario: Session reuse on subsequent inference
- **WHEN** the classifier receives a second inference request after a session already exists
- **THEN** it reuses the existing session without creating a new one

#### Scenario: Session disposal
- **WHEN** the classifier is disposed
- **THEN** the ONNX Runtime session and all associated native resources are released

### Requirement: Image preprocessing pipeline
The system SHALL convert a raw image (from camera or gallery) into an input tensor matching the model contract: `pixel_values` shaped `[1, 3, 224, 224]` float32 in NCHW layout.

#### Scenario: Preprocessing applies correct normalization
- **WHEN** a raw RGB image is provided to the preprocessor
- **THEN** each pixel is rescaled by factor `0.00392156862745098` (1/255) and normalized as `(x - 0.5) / 0.5` per channel

#### Scenario: Preprocessing produces correct tensor shape
- **WHEN** preprocessing completes
- **THEN** the output tensor SHALL have shape `[1, 3, 224, 224]` with float32 dtype

#### Scenario: Preprocessing handles EXIF orientation
- **WHEN** the source image has EXIF orientation metadata indicating rotation
- **THEN** the preprocessor applies the correct rotation before resizing to 224x224

### Requirement: Model inference execution
The system SHALL run the ONNX session with the preprocessed input tensor and return raw logits.

#### Scenario: Successful inference
- **WHEN** a valid input tensor is passed to the inference runner
- **THEN** the model produces an output tensor of shape `[1, 14829]` containing float32 logits

#### Scenario: Inference error handling
- **WHEN** the ONNX session fails to run (e.g., invalid input shape, native error)
- **THEN** the system returns a classified error rather than crashing

### Requirement: Softmax postprocessing
The system SHALL convert raw logits into probabilities using numerically stable softmax.

#### Scenario: Softmax produces valid probabilities
- **WHEN** a logit vector of length 14,829 is provided
- **THEN** the output is a probability distribution where all values are in `[0, 1]` and sum to approximately 1.0

#### Scenario: Numerical stability
- **WHEN** the logit vector contains extreme values (e.g., max > 100)
- **THEN** softmax subtracts the max logit before exponentiation to prevent overflow

### Requirement: Top-k label mapping
The system SHALL map the top-k highest-probability indices to species names using `labels.json`.

#### Scenario: Top-5 results returned
- **WHEN** classification completes successfully
- **THEN** the system returns the 5 species with highest confidence scores, each with a label name and probability

#### Scenario: Label lookup correctness
- **WHEN** the model output has highest logit at index 42
- **THEN** the top-1 result label matches `labels.json["42"]`

### Requirement: Label file loading
The system SHALL load `assets/ml/plant-identification/labels.json` at initialization and maintain a map from string indices to Latin species names.

#### Scenario: Labels loaded from asset
- **WHEN** the classifier initializes
- **THEN** `labels.json` is decoded and available for index-to-name lookup

#### Scenario: Missing labels file
- **WHEN** `labels.json` cannot be found or parsed
- **THEN** the system returns an initialization error with a descriptive message
