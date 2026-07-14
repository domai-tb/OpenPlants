/// Immutable value object representing a structured care plan for a species.
class CarePlan {
  final String wateringGuidance;
  final String lightGuidance;
  final String humidityGuidance;
  final String soilRecommendation;
  final String repottingAdvice;

  const CarePlan({
    required this.wateringGuidance,
    required this.lightGuidance,
    required this.humidityGuidance,
    required this.soilRecommendation,
    required this.repottingAdvice,
  });
}
