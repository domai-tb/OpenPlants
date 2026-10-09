## 1. Define and distribute the archive

- [ ] 1.1 Change the export script to write outside Flutter assets and create the flat ZIP with model, external data, labels, and export metadata.
- [ ] 1.2 Track the small labels asset and restrict `pubspec.yaml` to that asset; ensure no ONNX graph or sidecar is included in the APK.
- [ ] 1.3 Update the tagged release workflow to build and upload the model ZIP separately from the APK, with source revision and checksum.
- [ ] 1.4 Publish the generated current-model archive to Hugging Face and document the stable browser/download URL and maintainer update steps.

## 2. Import and store the model

- [ ] 2.1 Replace asset-cache loading with a shared app-support model store and expose installed status, import, replace, and remove through the existing Model Information use case.
- [ ] 2.2 Add system document-picker import and stream archive contents into a staging directory without extracting arbitrary paths.
- [ ] 2.3 Validate required entries, size limits, JSON manifest, supported model contract, label/output count, and ONNX session creation before activation.
- [ ] 2.4 Make activation recoverable: failed or interrupted imports leave the old installation intact and clean temporary files on the next attempt.
- [ ] 2.5 Migrate a complete compatible legacy cache and test the absent/incompatible-cache path.
- [ ] 2.6 Load classifier graph, sidecar, and labels from the same installed package; close and recreate the ONNX session when the package changes.

## 3. Expose model setup

- [ ] 3.1 Update Model Information to show installed/missing state, source revision, external-browser download, import/replace, remove, and understandable errors.
- [ ] 3.2 Add a skippable onboarding model setup step; picker cancellation or import failure must not prevent onboarding completion.
- [ ] 3.3 Add a missing-model state to plant identification with links to Model Information and the external download page; refresh status on return.
- [ ] 3.4 Add localized English and German strings for setup, status, storage/import errors, and the optional step; regenerate localization.

## 4. Verify

- [ ] 4.1 Replace asset-cache tests with archive tests for valid import, missing/duplicate/unsafe entries, incompatible metadata, corrupt ONNX, interrupted writes, and preservation of an existing installation.
- [ ] 4.2 Verify the model is absent from the APK while the separately generated ZIP contains the four required files.
- [ ] 4.3 Verify plant-care paths work with no model and classification works after import with matching labels.
- [ ] 4.4 Run strict OpenSpec change validation and the repository's analyzer/test/build gates during implementation.
