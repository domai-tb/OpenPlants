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
  String get plantIdentificationTitle => 'Plant ID';

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
  String get navigationLabel => 'Navigation';

  @override
  String get navigationOrderHint => 'Drag to reorder menu items.';

  @override
  String get navigationVisibilityLabel => 'Show in navigation';

  @override
  String get navigationSettingsAlwaysVisibleHint =>
      'More stays visible so settings remain reachable.';

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
  String get speciesLibraryTitle => 'Species Library';

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
  String get careScheduleGoToCollection => 'Go to Plant Collection';
}
