// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get appTitle => 'OpenPlant';

  @override
  String get todayDashboardTitle => 'Today';

  @override
  String get dueToday => 'Due Today';

  @override
  String get overdue => 'Overdue';

  @override
  String get recentPlants => 'Recent Plants';

  @override
  String get noPlantsYet => 'No plants yet';

  @override
  String get addYourFirstPlant => 'Add your first plant to get started!';

  @override
  String get quickAddPlant => 'Add Plant';

  @override
  String get quickIdentify => 'Identify';

  @override
  String get quickDiagnose => 'Diagnose';

  @override
  String get daysOverdue => 'd overdue';

  @override
  String get taskDueToday => 'Due today';

  @override
  String get taskTypeWater => 'Water';

  @override
  String get taskTypeFertilize => 'Fertilize';

  @override
  String get taskTypeMist => 'Mist';

  @override
  String get taskTypePrune => 'Prune';

  @override
  String get taskTypeRotate => 'Rotate';

  @override
  String get taskTypeRepot => 'Repot';

  @override
  String get taskTypeClean => 'Clean';

  @override
  String get taskTypeInspect => 'Inspect';

  @override
  String get moreTitle => 'More';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get aboutTitle => 'About';

  @override
  String get detailTitle => 'Detail';

  @override
  String get searchLabel => 'Search';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get onboardingIntroBody =>
      'Welcome to OpenPlant — your open-source & privacy-friendly plant companion.';

  @override
  String get onboardingIntroHint =>
      'Track your plants, set reminders, and watch them thrive.';

  @override
  String get onboardingPrivacyTitle => 'Your Privacy Matters';

  @override
  String get onboardingPrivacyWorksLocally => 'Works Locally';

  @override
  String get onboardingPrivacyWorksLocallyBody =>
      'All data and processing happen on-device. No internet connection needed.';

  @override
  String get onboardingPrivacyNoAccount => 'No Account Required';

  @override
  String get onboardingPrivacyNoAccountBody =>
      'No sign-up, login, or account creation. Just open and use.';

  @override
  String get onboardingPrivacyPhotosPrivate => 'Photos Stay Private';

  @override
  String get onboardingPrivacyPhotosPrivateBody =>
      'Plant photos are processed on-device and never uploaded.';

  @override
  String get onboardingPrivacyNoThirdParties => 'No Third Parties';

  @override
  String get onboardingPrivacyNoThirdPartiesBody =>
      'No analytics SDKs, no ad trackers, no external services.';

  @override
  String get onboardingPrivacyBadgeLocal => 'Local';

  @override
  String get onboardingPrivacyBadgeNoAccount => 'No account';

  @override
  String get onboardingPrivacyBadgePhotos => 'Private photos';

  @override
  String get onboardingPrivacyBadgeNoTrackers => 'No trackers';

  @override
  String get onboardingPreferencesTitle => 'Preferences';

  @override
  String get themeLabel => 'Theme';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'German';

  @override
  String get accessibilityLabel => 'Accessibility';

  @override
  String get useSystemTextScaling => 'Use system text scaling';

  @override
  String get temperatureUnitLabel => 'Temperature Unit';

  @override
  String get temperatureCelsius => 'Celsius';

  @override
  String get temperatureFahrenheit => 'Fahrenheit';

  @override
  String get plantNamesTitle => 'Plant Names';

  @override
  String get plantNamesDescription => 'Localized plant name lookup service.';

  @override
  String get walletPlaceholderBody => 'Placeholder for a wallet-style feature.';

  @override
  String get primaryAction => 'Primary Action';

  @override
  String get secondaryAction => 'Secondary Action';

  @override
  String get primaryActionSnack => 'Replace this with your real action';

  @override
  String get secondaryActionSnack => 'Another placeholder action';

  @override
  String get menuSettingsSubtitle => 'OpenPlant settings';

  @override
  String get menuAboutSubtitle => 'About OpenPlant';

  @override
  String get aboutBody =>
      'OpenPlant is an open-source & privacy-friendly companion app for your plants.\n\nTrack your plant care, set watering reminders, and keep your garden healthy — all without compromising your privacy.';

  @override
  String get serverFailureMessage => 'Could not load server data.';

  @override
  String get generalFailureMessage => 'An error has occurred.';

  @override
  String get errorMessage => 'Error.';

  @override
  String get unexpectedError => 'An unexpected error occured...';

  @override
  String get invalid2FATokenFailureMessage =>
      'Your TOTP is incorrect. Please try again!';

  @override
  String get invalidLoginIDAndPasswordFailureMessage =>
      'The credentials are invalid!';

  @override
  String get welcome => 'Welcome!';

  @override
  String get login_prompt => 'Please login with your username and password.';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get empty_input_field => 'Please enter your credentials!';

  @override
  String get login_error => 'Invalid input!';

  @override
  String get login_success => 'Successfully logged in!';

  @override
  String get login_already => 'Allready logged in.';

  @override
  String get enter_totp => 'Please enter your TOTP.';

  @override
  String get plantIdCapturePrompt => 'Take a photo of a plant to identify it';

  @override
  String get plantIdCamera => 'Camera';

  @override
  String get plantIdGallery => 'Gallery';

  @override
  String get plantIdResults => 'Results';

  @override
  String get plantIdRetake => 'Retake';

  @override
  String get plantIdBestMatch => 'Best match';

  @override
  String get plantIdCouldNotIdentify => 'Could not identify plant';

  @override
  String get plantIdFailedToCapture => 'Failed to capture image';

  @override
  String get plantIdFailedToPick => 'Failed to pick image';

  @override
  String get plantIdIdentificationFailed => 'Identification failed';

  @override
  String get plantIdTryAgain => 'Try Again';

  @override
  String get plantIdIdentifying => 'Identifying species...';

  @override
  String get plantIdSelectSpecies => 'Select a species';

  @override
  String get plantIdCouldNotIdentifyEnterManually =>
      'Could not identify species. Enter manually below.';

  @override
  String get plantIdEnterSpeciesManually => 'Enter species manually';

  @override
  String get plantIdSkipIdentification =>
      'Skip identification / enter manually';

  @override
  String get plantIdIdentificationErrorWithManual =>
      'Identification failed. You can still enter the species manually.';

  @override
  String get plantCollectionTitle => 'Plant Collection';

  @override
  String get plantCollectionEmpty => 'No plants yet';

  @override
  String get plantCollectionTapToAdd => 'Tap + to add your first plant';

  @override
  String get addPlant => 'Add Plant';

  @override
  String get editPlant => 'Edit Plant';

  @override
  String get deletePlant => 'Delete Plant';

  @override
  String get deletePlantTitle => 'Delete Plant';

  @override
  String deletePlantConfirm(Object plantName) {
    return 'Are you sure you want to delete $plantName?';
  }

  @override
  String get careStatus => 'Care Status';

  @override
  String get careStatusHappy => 'Happy';

  @override
  String get careStatusNeedsWater => 'Needs Water';

  @override
  String get careStatusNeedsFertilizer => 'Needs Fertilizer';

  @override
  String get markAsWatered => 'Mark as Watered';

  @override
  String get markAsFertilized => 'Mark as Fertilized';

  @override
  String get lastWatered => 'Last Watered';

  @override
  String get lastFertilized => 'Last Fertilized';

  @override
  String get confirmDelete => 'Are you sure you want to delete this plant?';

  @override
  String get searchPlants => 'Search plants';

  @override
  String get filterAll => 'All';

  @override
  String get room => 'Room';

  @override
  String get species => 'Species';

  @override
  String get notes => 'Notes';

  @override
  String get photo => 'Photo';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get nameRequired => 'Name *';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String errorSavingPlant(Object error) {
    return 'Error saving plant: $error';
  }

  @override
  String get never => 'Never';

  @override
  String get careScheduleTitle => 'Care Schedule';

  @override
  String get careScheduleOverdue => 'Overdue';

  @override
  String get careScheduleDueToday => 'Due Today';

  @override
  String get careScheduleUpcoming => 'Upcoming';

  @override
  String get careScheduleMarkDone => 'Mark done';

  @override
  String get careScheduleSnooze => 'Snooze';

  @override
  String get careScheduleSkip => 'Skip';

  @override
  String get careScheduleAllPlants => 'All plants';

  @override
  String get careScheduleAllTypes => 'All types';

  @override
  String get careScheduleEmpty => 'Add plants to see care tasks';

  @override
  String careTaskCompleted(String taskType) {
    return '$taskType completed';
  }

  @override
  String careTaskCompletedWithNote(String taskType, String note) {
    return '$taskType completed — $note';
  }

  @override
  String get symptomLoggerTitle => 'Log Symptom';

  @override
  String get symptomLoggerLogSymptom => 'Log Symptom';

  @override
  String get symptomLoggerSaved => 'Symptom logged successfully!';

  @override
  String get symptomLoggerStep => 'Step';

  @override
  String get symptomLoggerStepSymptoms => 'Symptoms';

  @override
  String get symptomLoggerStepSeverity => 'Severity';

  @override
  String get symptomLoggerStepParts => 'Affected Parts';

  @override
  String get symptomLoggerStepOnset => 'When did it start?';

  @override
  String get symptomLoggerStepEnvironment => 'Environment';

  @override
  String get symptomLoggerStepNotes => 'Notes & Photo';

  @override
  String get symptomLoggerStepReview => 'Review';

  @override
  String get symptomLoggerSelectSymptoms =>
      'What symptoms do you see? (select at least one)';

  @override
  String get symptomLoggerSelectSeverity => 'How severe is the problem?';

  @override
  String get symptomLoggerSelectParts => 'Which parts are affected?';

  @override
  String get symptomLoggerSelectOnset => 'When did you first notice?';

  @override
  String get symptomLoggerSoilMoisture => 'Soil Moisture';

  @override
  String get symptomLoggerLightCondition => 'Light Condition';

  @override
  String get symptomLoggerNotesLabel => 'Notes';

  @override
  String get symptomLoggerNotesHint =>
      'Add any observations (optional, max 500 characters)';

  @override
  String get symptomLoggerPhotoLabel => 'Photo';

  @override
  String get symptomLoggerAddPhoto => 'Add Photo';

  @override
  String get symptomLoggerRemovePhoto => 'Remove Photo';

  @override
  String get symptomLoggerPhotoAttached => 'Photo attached';

  @override
  String get symptomLoggerReviewTitle => 'Review your entry';

  @override
  String get symptomLoggerSave => 'Save Entry';

  @override
  String get symptomLoggerSelectRequired =>
      'Please make a selection before proceeding';

  @override
  String get symptomLoggerSelectPlant => 'Select a plant';

  @override
  String get symptomTypeYellowLeaves => 'Yellow Leaves';

  @override
  String get symptomTypeBrownTips => 'Brown Tips';

  @override
  String get symptomTypeDrooping => 'Drooping';

  @override
  String get symptomTypePests => 'Pests';

  @override
  String get symptomTypeMold => 'Mold';

  @override
  String get symptomTypeSoftStems => 'Soft Stems';

  @override
  String get symptomTypeDrySoil => 'Dry Soil';

  @override
  String get symptomTypeWetSoil => 'Wet Soil';

  @override
  String get symptomTypeLeafSpots => 'Leaf Spots';

  @override
  String get symptomSeverityMild => 'Mild';

  @override
  String get symptomSeverityMildDesc =>
      'Minor issue, plant looks mostly healthy';

  @override
  String get symptomSeverityModerate => 'Moderate';

  @override
  String get symptomSeverityModerateDesc =>
      'Noticeable problem, needs attention soon';

  @override
  String get symptomSeveritySevere => 'Severe';

  @override
  String get symptomSeveritySevereDesc =>
      'Serious issue, requires immediate action';

  @override
  String get symptomPartLeaves => 'Leaves';

  @override
  String get symptomPartStems => 'Stems';

  @override
  String get symptomPartRoots => 'Roots';

  @override
  String get symptomPartSoil => 'Soil';

  @override
  String get symptomPartFlowers => 'Flowers';

  @override
  String get symptomPartMultiple => 'Multiple Areas';

  @override
  String get symptomOnsetToday => 'Today';

  @override
  String get symptomOnsetFewDays => 'A few days ago';

  @override
  String get symptomOnsetAboutWeek => 'About a week ago';

  @override
  String get symptomOnsetMoreThanWeek => 'More than a week ago';

  @override
  String get symptomSoilDry => 'Dry';

  @override
  String get symptomSoilMoist => 'Moist';

  @override
  String get symptomSoilWet => 'Wet';

  @override
  String get symptomSoilSoggy => 'Soggy';

  @override
  String get symptomLightFullSun => 'Full Sun';

  @override
  String get symptomLightPartialShade => 'Partial Shade';

  @override
  String get symptomLightLowLight => 'Low Light';

  @override
  String get symptomLightUnknown => 'Unknown';

  @override
  String get symptomLoggerHistory => 'Symptom History';

  @override
  String get symptomLoggerNoEntries => 'No symptoms logged yet';

  @override
  String get symptomLoggerMarkResolved => 'Mark Resolved';

  @override
  String get symptomLoggerMarkResolvedConfirm =>
      'Mark this symptom as resolved?';

  @override
  String get symptomLoggerRecentEvents => 'Recent Health Events';

  @override
  String get careStatusNeedsAttention => 'Needs Attention';

  @override
  String get journalTitle => 'Journal';

  @override
  String journalPageTitle(Object plantName) {
    return '$plantName — Journal';
  }

  @override
  String get journalEmpty => 'No journal entries yet';

  @override
  String get journalTapToAdd => 'Tap + to add your first entry';

  @override
  String get journalNewEntry => 'New Journal Entry';

  @override
  String get journalEditEntry => 'Edit Entry';

  @override
  String get journalDeleteEntry => 'Delete Entry';

  @override
  String get journalDeleteConfirm =>
      'Are you sure you want to delete this journal entry?';

  @override
  String get journalEntryType => 'Entry Type';

  @override
  String get journalTypeText => 'Text Note';

  @override
  String get journalTypePhoto => 'Photo';

  @override
  String get journalTypeTask => 'Completed Task';

  @override
  String get journalTypeGrowth => 'Growth Update';

  @override
  String get journalTypeRepotting => 'Repotting';

  @override
  String get journalTypePest => 'Pest Observation';

  @override
  String get journalTypeDiagnosis => 'Diagnosis';

  @override
  String get journalNotes => 'Notes';

  @override
  String get journalNotesHint => 'Add your observations...';

  @override
  String get journalPhoto => 'Photo';

  @override
  String get journalAddPhoto => 'Add Photo';

  @override
  String get journalTakePhoto => 'Take Photo';

  @override
  String get journalChooseFromGallery => 'Choose from Gallery';

  @override
  String get growthPhotosTitle => 'Growth Photos';

  @override
  String get growthPhotosAdd => 'Add';

  @override
  String get growthPhotosEmpty => 'Add your first growth photo';

  @override
  String get growthPhotosEmptyHint => 'Add photos from the plant detail page';

  @override
  String get growthPhotosNoTimeline => 'No growth photos yet';

  @override
  String get growthPhotosNoTimelineHint =>
      'Add photos from the plant detail page';

  @override
  String get growthPhotoDeleteTitle => 'Delete Photo';

  @override
  String get growthPhotoDeleteConfirm =>
      'Are you sure you want to delete this photo?';

  @override
  String get growthPhotoNotFound => 'Photo not found';

  @override
  String get growthPhotoCamera => 'Camera';

  @override
  String get growthPhotoGallery => 'Gallery';

  @override
  String get careRulesTitle => 'Care Rules';

  @override
  String get careRulesManage => 'Manage';

  @override
  String get careRulesEmpty => 'No custom rules';

  @override
  String get careRulesEmptyHint =>
      'Add a rule to override the computed schedule';

  @override
  String careRulesActiveCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active rules',
      one: '1 active rule',
    );
    return '$_temp0';
  }

  @override
  String get careRulesDeleteTitle => 'Delete Rule';

  @override
  String careRulesDeleteConfirm(Object ruleType) {
    return 'Delete \"$ruleType\" rule?';
  }

  @override
  String get careRulesAdd => 'Add Rule';

  @override
  String get careRulesEdit => 'Edit Rule';

  @override
  String get careRulesTaskType => 'Task Type';

  @override
  String get careRulesBuiltIn => 'Built-in';

  @override
  String get careRulesCustom => 'Custom';

  @override
  String get careRulesSelectType => 'Select task type';

  @override
  String get careRulesCustomType => 'Custom task type';

  @override
  String get careRulesCustomTypeHint => 'e.g. Check for flowers';

  @override
  String get careRulesSelectTypeRequired => 'Please select a task type';

  @override
  String get careRulesCustomTypeRequired => 'Please enter a task type';

  @override
  String get careRulesInterval => 'Interval (days)';

  @override
  String get careRulesIntervalHint => 'Days between tasks';

  @override
  String get careRulesIntervalRequired => 'Please enter an interval';

  @override
  String get careRulesIntervalPositive => 'Please enter a positive number';

  @override
  String get careRulesEnableReminder => 'Enable Reminder';

  @override
  String get careRulesReminderTimeHint => '09:00';

  @override
  String get careRulesReminderDays => 'Reminder days';

  @override
  String careRulesSaveFailed(Object error) {
    return 'Failed to save rule: $error';
  }

  @override
  String get diagnosisTitle => 'Plant Diagnosis';

  @override
  String get diagnosisSubtitle => 'Diagnose plant problems';

  @override
  String get diagnosisStep => 'Step';

  @override
  String diagnosisStepProgress(int currentStep, int totalSteps) {
    return 'Step $currentStep/$totalSteps';
  }

  @override
  String get diagnosisStepSymptoms => 'Symptoms';

  @override
  String get diagnosisStepContext => 'Environment';

  @override
  String get diagnosisStepDetails => 'Details';

  @override
  String get diagnosisStepReview => 'Review';

  @override
  String get diagnosisSelectSymptoms =>
      'What symptoms do you see on your plant? (select at least one)';

  @override
  String get diagnosisSymptomRequired => 'Please select at least one symptom';

  @override
  String get diagnosisEnvironmentTitle =>
      'Tell us about your plant\'s environment';

  @override
  String get diagnosisWateringFrequency => 'Watering Frequency';

  @override
  String get diagnosisLightExposure => 'Light Exposure';

  @override
  String get diagnosisHumidityLevel => 'Humidity Level';

  @override
  String get diagnosisPotType => 'Pot Type';

  @override
  String get diagnosisSoilType => 'Soil Type';

  @override
  String get diagnosisAdditionalInfo => 'Additional information';

  @override
  String get diagnosisPlantSpecies => 'Plant Species (optional)';

  @override
  String get diagnosisPlantSpeciesHint =>
      'e.g. Monstera deliciosa, Snake Plant';

  @override
  String get diagnosisRecentFertilizing => 'Recent Fertilizing';

  @override
  String get diagnosisRecentFertilizingHint =>
      'Have you fertilized in the last 3 months?';

  @override
  String get diagnosisPestSigns => 'Pest Signs';

  @override
  String get diagnosisPestSignsHint =>
      'Have you noticed any insects, webs, or sticky residue?';

  @override
  String get diagnosisReviewTitle => 'Review your answers';

  @override
  String get diagnosisReviewSymptoms => 'Symptoms';

  @override
  String get diagnosisReviewWatering => 'Watering';

  @override
  String get diagnosisReviewLight => 'Light';

  @override
  String get diagnosisReviewHumidity => 'Humidity';

  @override
  String get diagnosisReviewPotType => 'Pot Type';

  @override
  String get diagnosisReviewSoil => 'Soil';

  @override
  String get diagnosisReviewSpecies => 'Species';

  @override
  String get diagnosisReviewRecentlyFertilized => 'Fertilized recently';

  @override
  String get diagnosisReviewPestSigns => 'Pest signs';

  @override
  String get diagnosisAnswerYes => 'Yes';

  @override
  String get diagnosisAnswerNo => 'No';

  @override
  String get diagnosisAnswerUnknown => 'Unknown';

  @override
  String get diagnosisStartDiagnosis => 'Start Diagnosis';

  @override
  String get diagnosisEvaluating => 'Evaluating...';

  @override
  String get diagnosisResultsTitle => 'Diagnosis Results';

  @override
  String get diagnosisNoClearMatch => 'No Clear Match';

  @override
  String get diagnosisNoClearMatchDesc =>
      'Based on the information provided, we couldn\'t identify a specific cause. This doesn\'t mean your plant is fine — it may need attention for a reason not covered by this questionnaire.';

  @override
  String get diagnosisGeneralSuggestions => 'General Suggestions:';

  @override
  String get diagnosisSuggestionAppropriateLight =>
      'Ensure your plant receives appropriate light for its species.';

  @override
  String get diagnosisSuggestionCheckSoilMoisture =>
      'Check the soil moisture before watering — over- and under-watering are the most common issues.';

  @override
  String get diagnosisSuggestionInspectPlant =>
      'Inspect the leaves and stems closely for any unusual spots, pests, or texture changes.';

  @override
  String get diagnosisSuggestionConsiderRepotting =>
      'Consider repotting if the plant has been in the same soil for over a year.';

  @override
  String get diagnosisTryAgain => 'Try Again with More Details';

  @override
  String get diagnosisStartOver => 'Start Over';

  @override
  String get diagnosisEmptyInputTitle => 'No Symptoms Selected';

  @override
  String get diagnosisEmptyInputDesc =>
      'Select at least one symptom before starting a diagnosis.';

  @override
  String get diagnosisDisclaimer =>
      'This is a suggestion based on the information you provided. It is not a definitive diagnosis. Consult a plant care expert for serious concerns.';

  @override
  String get diagnosisRecommendedActions => 'Recommended Actions';

  @override
  String get diagnosisFollowUpChecks => 'Follow-up Checks';

  @override
  String get diagnosisCauseOverwatering => 'Overwatering';

  @override
  String get diagnosisCauseUnderwatering => 'Underwatering';

  @override
  String get diagnosisCauseLowLight => 'Insufficient Light';

  @override
  String get diagnosisCauseSunburn => 'Sunburn / Light Damage';

  @override
  String get diagnosisCauseLowHumidity => 'Low Humidity';

  @override
  String get diagnosisCauseNutrientProblem => 'Nutrient Deficiency';

  @override
  String get diagnosisCauseRootIssue => 'Root Problems';

  @override
  String get diagnosisCausePests => 'Pest Infestation';

  @override
  String get diagnosisCauseNoClearMatch => 'No Clear Match';

  @override
  String get diagnosisConfidenceHigh => 'High';

  @override
  String get diagnosisConfidenceMedium => 'Medium';

  @override
  String get diagnosisConfidenceLow => 'Low';

  @override
  String get diagnosisWateringFrequent => 'Frequent';

  @override
  String get diagnosisWateringNormal => 'Normal';

  @override
  String get diagnosisWateringInfrequent => 'Infrequent';

  @override
  String get diagnosisLightLow => 'Low Light';

  @override
  String get diagnosisLightIndirect => 'Indirect Light';

  @override
  String get diagnosisLightDirect => 'Direct Sun';

  @override
  String get diagnosisHumidityLow => 'Low';

  @override
  String get diagnosisHumidityModerate => 'Moderate';

  @override
  String get diagnosisHumidityHigh => 'High';

  @override
  String get diagnosisPotStandard => 'Standard';

  @override
  String get diagnosisPotSelfWatering => 'Self-Watering';

  @override
  String get diagnosisPotNoDrainage => 'No Drainage';

  @override
  String get diagnosisSoilStandard => 'Standard Potting Mix';

  @override
  String get diagnosisSoilSucculent => 'Succulent Mix';

  @override
  String get diagnosisSoilOrchid => 'Orchid Mix';

  @override
  String get diagnosisSoilCactus => 'Cactus Mix';

  @override
  String get diagnosisSymptomYellowingLeaves => 'Yellowing Leaves';

  @override
  String get diagnosisSymptomDroopingWilt => 'Drooping / Wilting';

  @override
  String get diagnosisSymptomBrownTips => 'Brown Tips / Crispy Edges';

  @override
  String get diagnosisSymptomBrownPatches => 'Brown Patches / Scorched Spots';

  @override
  String get diagnosisSymptomPaleLeaves => 'Pale Leaves';

  @override
  String get diagnosisSymptomLeggyGrowth => 'Leggy Growth';

  @override
  String get diagnosisSymptomVisibleInsects => 'Visible Insects / Webs';

  @override
  String get diagnosisSymptomStickyResidue => 'Sticky Residue';

  @override
  String get diagnosisSymptomMoldOnSoil => 'Mold on Soil';

  @override
  String get diagnosisSymptomFoulSmell => 'Foul Smell';

  @override
  String get diagnosisSymptomStuntedGrowth => 'Stunted Growth';

  @override
  String get diagnosisSymptomLeafCurling => 'Leaf Curling';

  @override
  String get diagnosisSymptomLeafDrop => 'Leaf Drop';

  @override
  String get diagnosisSymptomSoftStems => 'Soft Stems';

  @override
  String get diagnosisSymptomDrySoil => 'Dry Soil';

  @override
  String get diagnosisSymptomWetSoil => 'Wet Soil';

  @override
  String get diagnosisSymptomLeafSpots => 'Leaf Spots';

  @override
  String get diagnosisDiagnoseThisPlant => 'Diagnose this plant';

  @override
  String get healthTimelineTitle => 'Health Timeline';

  @override
  String get healthTimelineFilterAll => 'All';

  @override
  String get healthTimelineFilterActive => 'Active';

  @override
  String get healthTimelineEmpty => 'No health events yet';

  @override
  String get healthTimelineEmptyHint =>
      'Symptom logs and diagnoses will appear here.';

  @override
  String get healthTimelineSymptomEntry => 'Symptom logged';

  @override
  String get healthTimelineDiagnosisEntry => 'Diagnosis result';

  @override
  String get healthTimelineBadge => 'Latest Diagnosis';

  @override
  String get healthTimelineLogSymptom => 'Log Symptom';

  @override
  String get healthTimelineDiagnose => 'Diagnose';

  @override
  String get healthTimelineMarkResolved => 'Mark Resolved';

  @override
  String get healthTimelineResolved => 'Resolved';

  @override
  String get healthTimelineViewDiagnosis => 'View Diagnosis';

  @override
  String get healthTimelineViewLinkedSymptom => 'View linked symptom';

  @override
  String healthTimelineTodayAt(String time) {
    return 'Today at $time';
  }

  @override
  String healthTimelineYesterdayAt(String time) {
    return 'Yesterday at $time';
  }

  @override
  String healthTimelineDateAt(String date, String time) {
    return '$date at $time';
  }

  @override
  String get diagnosisSaveToPlantHistory => 'Save to plant history';

  @override
  String get diagnosisSavedToPlantHistory => 'Saved to plant history';

  @override
  String get diagnosisSourceAuto => 'Auto-diagnosis';

  @override
  String get diagnosisSourceManual => 'Manual diagnosis';

  @override
  String diagnosisSourceLabel(String source) {
    return 'Source: $source';
  }

  @override
  String get viewHealthTimeline => 'View Health Timeline';

  @override
  String diagnosisEvidenceReportedSymptoms(String symptoms) {
    return 'You reported $symptoms.';
  }

  @override
  String get diagnosisEvidenceFrequentWateringTooWet =>
      'You water frequently, which can keep the soil too wet.';

  @override
  String get diagnosisEvidenceNoDrainage =>
      'Your pot has no drainage holes, which traps excess water.';

  @override
  String get diagnosisEvidenceOverwateringSigns =>
      'These are common signs of overwatering.';

  @override
  String get diagnosisEvidenceInfrequentWateringTooDry =>
      'You water infrequently, which may leave the soil too dry.';

  @override
  String get diagnosisEvidenceUnderwateringSigns =>
      'These are common signs of underwatering.';

  @override
  String get diagnosisEvidenceLowLightExposure =>
      'Your plant receives low light.';

  @override
  String get diagnosisEvidenceLowLightSigns =>
      'Leggy growth and pale leaves are typical signs of insufficient light.';

  @override
  String get diagnosisEvidenceDirectSunlight =>
      'Your plant receives direct sunlight.';

  @override
  String get diagnosisEvidenceSunburnSigns =>
      'Brown scorched patches can indicate sun damage.';

  @override
  String get diagnosisEvidenceLowHumidityEnvironment =>
      'The humidity in your environment is low.';

  @override
  String get diagnosisEvidenceLowHumiditySigns =>
      'Brown leaf tips and curling are common in dry indoor air.';

  @override
  String get diagnosisEvidenceNotFertilizedRecently =>
      'You haven\'t fertilized recently.';

  @override
  String get diagnosisEvidenceNutrientSigns =>
      'Pale or yellowing growth can indicate nutrient deficiency.';

  @override
  String get diagnosisEvidenceFrequentWateringRootProblems =>
      'Frequent watering can lead to root problems.';

  @override
  String get diagnosisEvidenceRootProblemSigns =>
      'Wilting despite moist soil and foul smell are signs of root issues.';

  @override
  String get diagnosisEvidencePestSignsObserved =>
      'You\'ve noticed signs of pests.';

  @override
  String get diagnosisEvidencePestInfestationSigns =>
      'Visible insects, sticky residue, and leaf damage can indicate pest infestation.';

  @override
  String get diagnosisEvidenceDefault =>
      'Based on your answers, this cause was identified as a possibility.';

  @override
  String get diagnosisFallbackEvidence =>
      'No single cause stood out based on the information provided. This could mean the issue is caused by factors not covered by the questionnaire.';

  @override
  String get diagnosisActionOverwateringDrySoil =>
      'Allow the top 2-3 inches of soil to dry before watering again.';

  @override
  String get diagnosisActionOverwateringDrainage =>
      'Check that your pot has drainage holes and empty the saucer after watering.';

  @override
  String get diagnosisActionOverwateringTrimRoots =>
      'If root rot is suspected, remove the plant and trim any brown, mushy roots.';

  @override
  String get diagnosisActionUnderwateringWaterThoroughly =>
      'Water the plant thoroughly until water drains from the bottom.';

  @override
  String get diagnosisActionUnderwateringSchedule =>
      'Establish a regular watering schedule based on the plant\'s needs.';

  @override
  String get diagnosisActionUnderwateringBottomWater =>
      'Consider bottom-watering to encourage deeper root growth.';

  @override
  String get diagnosisActionLowLightMovePlant =>
      'Move the plant closer to a window or to a brighter location.';

  @override
  String get diagnosisActionLowLightGrowLight =>
      'Consider adding a grow light if natural light is limited.';

  @override
  String get diagnosisActionLowLightRotate =>
      'Rotate the plant regularly so all sides receive light.';

  @override
  String get diagnosisActionSunburnIndirectLight =>
      'Move the plant to a spot with indirect or filtered light.';

  @override
  String get diagnosisActionSunburnCurtain =>
      'Use a sheer curtain to diffuse direct sunlight.';

  @override
  String get diagnosisActionSunburnRemoveLeaves =>
      'Remove severely burned leaves once the plant has adjusted.';

  @override
  String get diagnosisActionLowHumidityMist =>
      'Mist the plant regularly or place a humidifier nearby.';

  @override
  String get diagnosisActionLowHumidityGroupPlants =>
      'Group humidity-loving plants together to create a microclimate.';

  @override
  String get diagnosisActionLowHumidityPebbleTray =>
      'Place the pot on a pebble tray with water (pot sitting above the water line).';

  @override
  String get diagnosisActionNutrientsFertilize =>
      'Apply a balanced liquid fertilizer at half strength during the growing season.';

  @override
  String get diagnosisActionNutrientsRepot =>
      'Check if the plant is root-bound and needs repotting with fresh soil.';

  @override
  String get diagnosisActionNutrientsCheckPh =>
      'Ensure the soil pH is appropriate for the plant species.';

  @override
  String get diagnosisActionRootsInspect =>
      'Remove the plant from the pot and inspect the roots.';

  @override
  String get diagnosisActionRootsTrim =>
      'Trim any brown, mushy, or foul-smelling roots with sterile scissors.';

  @override
  String get diagnosisActionRootsRepot =>
      'Repot in fresh, well-draining soil and reduce watering frequency.';

  @override
  String get diagnosisActionPestsIsolate =>
      'Isolate the affected plant to prevent spreading.';

  @override
  String get diagnosisActionPestsTreat =>
      'Wipe leaves with a damp cloth or spray with neem oil solution.';

  @override
  String get diagnosisActionPestsInspect =>
      'Check under leaves and in leaf joints where pests often hide.';

  @override
  String get diagnosisActionDefaultCare =>
      'Ensure your plant receives appropriate light and water for its species.';

  @override
  String get diagnosisActionDefaultMoisture =>
      'Check the soil moisture before watering.';

  @override
  String get diagnosisCheckOverwateringRoots =>
      'Check the roots: healthy roots are firm and white, rotten roots are brown and mushy.';

  @override
  String get diagnosisCheckOverwateringMoisture =>
      'Monitor soil moisture — it should dry out between waterings.';

  @override
  String get diagnosisCheckUnderwateringRootBall =>
      'Check the root ball: if it has pulled away from the pot edges, the soil is too dry.';

  @override
  String get diagnosisCheckUnderwateringSoil =>
      'Feel the soil 2 inches down — it should be slightly moist, not bone dry.';

  @override
  String get diagnosisCheckLowLightGrowth =>
      'Observe if new growth is still leggy after moving to a brighter spot.';

  @override
  String get diagnosisCheckLowLightHours =>
      'Note how many hours of light the plant receives daily.';

  @override
  String get diagnosisCheckSunburnPatches =>
      'Check if the brown patches stop spreading after moving the plant.';

  @override
  String get diagnosisCheckSunburnNewLeaves =>
      'Monitor for new leaves — they should grow without brown spots.';

  @override
  String get diagnosisCheckLowHumidityTips =>
      'Check if brown tips stop appearing after increasing humidity.';

  @override
  String get diagnosisCheckLowHumidityMeasure =>
      'Use a hygrometer to measure the actual humidity level near the plant.';

  @override
  String get diagnosisCheckNutrientsGrowth =>
      'After fertilizing, observe if new growth appears healthier within 2-3 weeks.';

  @override
  String get diagnosisCheckNutrientsRoots =>
      'Check if the soil is compacted or the plant is root-bound.';

  @override
  String get diagnosisCheckRootsHealthy =>
      'Healthy roots are firm and white or light tan. Rotten roots are brown, black, or mushy.';

  @override
  String get diagnosisCheckRootsRecovery =>
      'After repotting, wait a week before watering to let roots recover.';

  @override
  String get diagnosisCheckPestsWeekly =>
      'Inspect the plant weekly for 3-4 weeks to ensure the pest problem is resolved.';

  @override
  String get diagnosisCheckPestsNearbyPlants =>
      'Check nearby plants for signs of spreading.';

  @override
  String get diagnosisCheckDefaultMoreDetails =>
      'Try the questionnaire again with more details.';

  @override
  String get diagnosisCheckDefaultExpert =>
      'Consult a plant care expert for species-specific advice.';

  @override
  String get diagnosisFallbackActionLight =>
      'Ensure your plant receives appropriate light for its species.';

  @override
  String get diagnosisFallbackActionMoisture =>
      'Check the soil moisture before watering — over- and under-watering are the most common issues.';

  @override
  String get diagnosisFallbackActionInspect =>
      'Inspect the leaves and stems closely for any unusual spots, pests, or texture changes.';

  @override
  String get diagnosisFallbackCheckMoreDetails =>
      'Try the questionnaire again with more details about your plant\'s environment.';

  @override
  String get diagnosisFallbackCheckCommunity =>
      'Consult a local plant shop or online community for species-specific advice.';

  @override
  String get plantIdentificationTitle => 'Plant ID';

  @override
  String get speciesLibrarySearchHint => 'Search species...';

  @override
  String get speciesLibraryEasy => 'Easy';

  @override
  String get speciesLibraryModerate => 'Moderate';

  @override
  String get speciesLibraryChallenging => 'Challenging';

  @override
  String get speciesLibraryToxicOnly => 'Toxic';

  @override
  String get speciesLibraryEmpty => 'No species found';

  @override
  String get speciesLibraryCarePlan => 'Care Plan';

  @override
  String get speciesLibraryWatering => 'Watering';

  @override
  String get speciesLibraryLight => 'Light';

  @override
  String get speciesLibraryHumidity => 'Humidity';

  @override
  String get speciesLibrarySoil => 'Soil';

  @override
  String get speciesLibraryRepotting => 'Repotting';

  @override
  String get speciesLibraryQuickFacts => 'Quick Facts';

  @override
  String get speciesLibraryLightNeeds => 'Light Needs';

  @override
  String get speciesLibraryWaterNeeds => 'Water Needs';

  @override
  String get speciesLibraryHumidityPref => 'Humidity';

  @override
  String get speciesLibrarySoilType => 'Soil Type';

  @override
  String get speciesLibraryRepottingInterval => 'Repotting';

  @override
  String speciesLibraryMonths(Object months) {
    return '$months months';
  }

  @override
  String get speciesLibraryLightLow => 'Low light';

  @override
  String get speciesLibraryLightMedium => 'Medium indirect';

  @override
  String get speciesLibraryLightBright => 'Bright indirect';

  @override
  String get speciesLibraryLightDirect => 'Direct sun';

  @override
  String get speciesLibraryWaterLow => 'Low (drought-tolerant)';

  @override
  String get speciesLibraryWaterModerate => 'Moderate';

  @override
  String get speciesLibraryWaterFrequent => 'Frequent';

  @override
  String get speciesLibraryHumidityLow => 'Low (30-40%)';

  @override
  String get speciesLibraryHumidityModerate => 'Moderate (40-60%)';

  @override
  String get speciesLibraryHumidityHigh => 'High (60%+)';

  @override
  String get speciesLibraryToxicToHumans => 'Toxic to humans';

  @override
  String get speciesLibraryToxicToPets => 'Toxic to pets';

  @override
  String get speciesLibraryToxicityWarning => 'Toxicity Warning';

  @override
  String get speciesLibraryViewDetails => 'View Species Details';
}
