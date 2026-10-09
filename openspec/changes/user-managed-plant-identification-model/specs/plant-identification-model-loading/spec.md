## REMOVED Requirements

### Requirement: Model assets use correct filenames
**Reason**: Model files are selected from a user-imported archive rather than loaded from the Flutter asset bundle.
**Migration**: Import the published model ZIP through Model Information or the plant identification setup state.

### Requirement: Identity-based cache invalidation
**Reason**: There is no longer a bundled model identity to compare against an OS cache.
**Migration**: The imported package's own metadata identifies the installed model; validation and atomic replacement are defined by `plant-model-management`.

### Requirement: Tests use correct asset paths
**Reason**: Tests now exercise archive import and the installed model store rather than mocking model asset paths.
**Migration**: Test the four-entry ZIP contract and installed package lifecycle.
