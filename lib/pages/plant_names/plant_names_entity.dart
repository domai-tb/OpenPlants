/// A plant name entry mapping a species ID to localized common names.
class PlantNameEntry {
  final String speciesId;
  final Map<String, String> localizedNames;

  const PlantNameEntry({
    required this.speciesId,
    required this.localizedNames,
  });

  factory PlantNameEntry.fromJson(String speciesId, Map<String, dynamic> json) {
    return PlantNameEntry(
      speciesId: speciesId,
      localizedNames: json.map((key, value) => MapEntry(key, value.toString())),
    );
  }
}
