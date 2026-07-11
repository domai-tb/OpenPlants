import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_de.dart';
import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenPlant'**
  String get appTitle;

  /// No description provided for @todayDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayDashboardTitle;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @recentPlants.
  ///
  /// In en, this message translates to:
  /// **'Recent Plants'**
  String get recentPlants;

  /// No description provided for @noPlantsYet.
  ///
  /// In en, this message translates to:
  /// **'No plants yet'**
  String get noPlantsYet;

  /// No description provided for @addYourFirstPlant.
  ///
  /// In en, this message translates to:
  /// **'Add your first plant to get started!'**
  String get addYourFirstPlant;

  /// No description provided for @quickAddPlant.
  ///
  /// In en, this message translates to:
  /// **'Add Plant'**
  String get quickAddPlant;

  /// No description provided for @quickIdentify.
  ///
  /// In en, this message translates to:
  /// **'Identify'**
  String get quickIdentify;

  /// No description provided for @quickDiagnose.
  ///
  /// In en, this message translates to:
  /// **'Diagnose'**
  String get quickDiagnose;

  /// No description provided for @daysOverdue.
  ///
  /// In en, this message translates to:
  /// **'d overdue'**
  String get daysOverdue;

  /// No description provided for @taskDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get taskDueToday;

  /// No description provided for @taskTypeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get taskTypeWater;

  /// No description provided for @taskTypeFertilize.
  ///
  /// In en, this message translates to:
  /// **'Fertilize'**
  String get taskTypeFertilize;

  /// No description provided for @taskTypeMist.
  ///
  /// In en, this message translates to:
  /// **'Mist'**
  String get taskTypeMist;

  /// No description provided for @taskTypePrune.
  ///
  /// In en, this message translates to:
  /// **'Prune'**
  String get taskTypePrune;

  /// No description provided for @taskTypeRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get taskTypeRotate;

  /// No description provided for @taskTypeRepot.
  ///
  /// In en, this message translates to:
  /// **'Repot'**
  String get taskTypeRepot;

  /// No description provided for @taskTypeClean.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get taskTypeClean;

  /// No description provided for @taskTypeInspect.
  ///
  /// In en, this message translates to:
  /// **'Inspect'**
  String get taskTypeInspect;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detailTitle;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @onboardingIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Welcome to OpenPlant — your open-source & privacy-friendly plant companion.'**
  String get onboardingIntroBody;

  /// No description provided for @onboardingIntroHint.
  ///
  /// In en, this message translates to:
  /// **'Track your plants, set reminders, and watch them thrive.'**
  String get onboardingIntroHint;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Privacy Matters'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyWorksLocally.
  ///
  /// In en, this message translates to:
  /// **'Works Locally'**
  String get onboardingPrivacyWorksLocally;

  /// No description provided for @onboardingPrivacyWorksLocallyBody.
  ///
  /// In en, this message translates to:
  /// **'All data and processing happen on-device. No internet connection needed.'**
  String get onboardingPrivacyWorksLocallyBody;

  /// No description provided for @onboardingPrivacyNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No Account Required'**
  String get onboardingPrivacyNoAccount;

  /// No description provided for @onboardingPrivacyNoAccountBody.
  ///
  /// In en, this message translates to:
  /// **'No sign-up, login, or account creation. Just open and use.'**
  String get onboardingPrivacyNoAccountBody;

  /// No description provided for @onboardingPrivacyPhotosPrivate.
  ///
  /// In en, this message translates to:
  /// **'Photos Stay Private'**
  String get onboardingPrivacyPhotosPrivate;

  /// No description provided for @onboardingPrivacyPhotosPrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Plant photos are processed on-device and never uploaded.'**
  String get onboardingPrivacyPhotosPrivateBody;

  /// No description provided for @onboardingPrivacyNoThirdParties.
  ///
  /// In en, this message translates to:
  /// **'No Third Parties'**
  String get onboardingPrivacyNoThirdParties;

  /// No description provided for @onboardingPrivacyNoThirdPartiesBody.
  ///
  /// In en, this message translates to:
  /// **'No analytics SDKs, no ad trackers, no external services.'**
  String get onboardingPrivacyNoThirdPartiesBody;

  /// No description provided for @onboardingPrivacyBadgeLocal.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get onboardingPrivacyBadgeLocal;

  /// No description provided for @onboardingPrivacyBadgeNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account'**
  String get onboardingPrivacyBadgeNoAccount;

  /// No description provided for @onboardingPrivacyBadgePhotos.
  ///
  /// In en, this message translates to:
  /// **'Private photos'**
  String get onboardingPrivacyBadgePhotos;

  /// No description provided for @onboardingPrivacyBadgeNoTrackers.
  ///
  /// In en, this message translates to:
  /// **'No trackers'**
  String get onboardingPrivacyBadgeNoTrackers;

  /// No description provided for @onboardingPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get onboardingPreferencesTitle;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @accessibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibilityLabel;

  /// No description provided for @useSystemTextScaling.
  ///
  /// In en, this message translates to:
  /// **'Use system text scaling'**
  String get useSystemTextScaling;

  /// No description provided for @temperatureUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature Unit'**
  String get temperatureUnitLabel;

  /// No description provided for @temperatureCelsius.
  ///
  /// In en, this message translates to:
  /// **'Celsius'**
  String get temperatureCelsius;

  /// No description provided for @temperatureFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'Fahrenheit'**
  String get temperatureFahrenheit;

  /// No description provided for @plantNamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant Names'**
  String get plantNamesTitle;

  /// No description provided for @plantNamesDescription.
  ///
  /// In en, this message translates to:
  /// **'Localized plant name lookup service.'**
  String get plantNamesDescription;

  /// No description provided for @walletPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Placeholder for a wallet-style feature.'**
  String get walletPlaceholderBody;

  /// No description provided for @primaryAction.
  ///
  /// In en, this message translates to:
  /// **'Primary Action'**
  String get primaryAction;

  /// No description provided for @secondaryAction.
  ///
  /// In en, this message translates to:
  /// **'Secondary Action'**
  String get secondaryAction;

  /// No description provided for @primaryActionSnack.
  ///
  /// In en, this message translates to:
  /// **'Replace this with your real action'**
  String get primaryActionSnack;

  /// No description provided for @secondaryActionSnack.
  ///
  /// In en, this message translates to:
  /// **'Another placeholder action'**
  String get secondaryActionSnack;

  /// No description provided for @menuSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'OpenPlant settings'**
  String get menuSettingsSubtitle;

  /// No description provided for @menuAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'About OpenPlant'**
  String get menuAboutSubtitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'OpenPlant is an open-source & privacy-friendly companion app for your plants.\n\nTrack your plant care, set watering reminders, and keep your garden healthy — all without compromising your privacy.'**
  String get aboutBody;

  /// No description provided for @serverFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not load server data.'**
  String get serverFailureMessage;

  /// No description provided for @generalFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred.'**
  String get generalFailureMessage;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error.'**
  String get errorMessage;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occured...'**
  String get unexpectedError;

  /// No description provided for @invalid2FATokenFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Your TOTP is incorrect. Please try again!'**
  String get invalid2FATokenFailureMessage;

  /// No description provided for @invalidLoginIDAndPasswordFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'The credentials are invalid!'**
  String get invalidLoginIDAndPasswordFailureMessage;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @login_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please login with your username and password.'**
  String get login_prompt;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @empty_input_field.
  ///
  /// In en, this message translates to:
  /// **'Please enter your credentials!'**
  String get empty_input_field;

  /// No description provided for @login_error.
  ///
  /// In en, this message translates to:
  /// **'Invalid input!'**
  String get login_error;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Successfully logged in!'**
  String get login_success;

  /// No description provided for @login_already.
  ///
  /// In en, this message translates to:
  /// **'Allready logged in.'**
  String get login_already;

  /// No description provided for @enter_totp.
  ///
  /// In en, this message translates to:
  /// **'Please enter your TOTP.'**
  String get enter_totp;

  /// No description provided for @plantIdCapturePrompt.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of a plant to identify it'**
  String get plantIdCapturePrompt;

  /// No description provided for @plantIdCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get plantIdCamera;

  /// No description provided for @plantIdGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get plantIdGallery;

  /// No description provided for @plantIdResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get plantIdResults;

  /// No description provided for @plantIdRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get plantIdRetake;

  /// No description provided for @plantIdBestMatch.
  ///
  /// In en, this message translates to:
  /// **'Best match'**
  String get plantIdBestMatch;

  /// No description provided for @plantIdCouldNotIdentify.
  ///
  /// In en, this message translates to:
  /// **'Could not identify plant'**
  String get plantIdCouldNotIdentify;

  /// No description provided for @plantIdFailedToCapture.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture image'**
  String get plantIdFailedToCapture;

  /// No description provided for @plantIdFailedToPick.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get plantIdFailedToPick;

  /// No description provided for @plantIdIdentificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Identification failed'**
  String get plantIdIdentificationFailed;

  /// No description provided for @plantIdTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get plantIdTryAgain;

  /// No description provided for @plantIdIdentifying.
  ///
  /// In en, this message translates to:
  /// **'Identifying species...'**
  String get plantIdIdentifying;

  /// No description provided for @plantIdSelectSpecies.
  ///
  /// In en, this message translates to:
  /// **'Select a species'**
  String get plantIdSelectSpecies;

  /// No description provided for @plantIdCouldNotIdentifyEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Could not identify species. Enter manually below.'**
  String get plantIdCouldNotIdentifyEnterManually;

  /// No description provided for @plantIdEnterSpeciesManually.
  ///
  /// In en, this message translates to:
  /// **'Enter species manually'**
  String get plantIdEnterSpeciesManually;

  /// No description provided for @plantIdSkipIdentification.
  ///
  /// In en, this message translates to:
  /// **'Skip identification / enter manually'**
  String get plantIdSkipIdentification;

  /// No description provided for @plantIdIdentificationErrorWithManual.
  ///
  /// In en, this message translates to:
  /// **'Identification failed. You can still enter the species manually.'**
  String get plantIdIdentificationErrorWithManual;

  /// No description provided for @plantCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant Collection'**
  String get plantCollectionTitle;

  /// No description provided for @plantCollectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No plants yet'**
  String get plantCollectionEmpty;

  /// No description provided for @plantCollectionTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first plant'**
  String get plantCollectionTapToAdd;

  /// No description provided for @addPlant.
  ///
  /// In en, this message translates to:
  /// **'Add Plant'**
  String get addPlant;

  /// No description provided for @editPlant.
  ///
  /// In en, this message translates to:
  /// **'Edit Plant'**
  String get editPlant;

  /// No description provided for @deletePlant.
  ///
  /// In en, this message translates to:
  /// **'Delete Plant'**
  String get deletePlant;

  /// No description provided for @deletePlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Plant'**
  String get deletePlantTitle;

  /// No description provided for @deletePlantConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {plantName}?'**
  String deletePlantConfirm(Object plantName);

  /// No description provided for @careStatus.
  ///
  /// In en, this message translates to:
  /// **'Care Status'**
  String get careStatus;

  /// No description provided for @careStatusHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get careStatusHappy;

  /// No description provided for @careStatusNeedsWater.
  ///
  /// In en, this message translates to:
  /// **'Needs Water'**
  String get careStatusNeedsWater;

  /// No description provided for @careStatusNeedsFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Needs Fertilizer'**
  String get careStatusNeedsFertilizer;

  /// No description provided for @markAsWatered.
  ///
  /// In en, this message translates to:
  /// **'Mark as Watered'**
  String get markAsWatered;

  /// No description provided for @markAsFertilized.
  ///
  /// In en, this message translates to:
  /// **'Mark as Fertilized'**
  String get markAsFertilized;

  /// No description provided for @lastWatered.
  ///
  /// In en, this message translates to:
  /// **'Last Watered'**
  String get lastWatered;

  /// No description provided for @lastFertilized.
  ///
  /// In en, this message translates to:
  /// **'Last Fertilized'**
  String get lastFertilized;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this plant?'**
  String get confirmDelete;

  /// No description provided for @searchPlants.
  ///
  /// In en, this message translates to:
  /// **'Search plants'**
  String get searchPlants;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @species.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameRequired;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @errorSavingPlant.
  ///
  /// In en, this message translates to:
  /// **'Error saving plant: {error}'**
  String errorSavingPlant(Object error);

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @careScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Schedule'**
  String get careScheduleTitle;

  /// No description provided for @careScheduleOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get careScheduleOverdue;

  /// No description provided for @careScheduleDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get careScheduleDueToday;

  /// No description provided for @careScheduleUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get careScheduleUpcoming;

  /// No description provided for @careScheduleMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get careScheduleMarkDone;

  /// No description provided for @careScheduleSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get careScheduleSnooze;

  /// No description provided for @careScheduleSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get careScheduleSkip;

  /// No description provided for @careScheduleAllPlants.
  ///
  /// In en, this message translates to:
  /// **'All plants'**
  String get careScheduleAllPlants;

  /// No description provided for @careScheduleAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get careScheduleAllTypes;

  /// No description provided for @careScheduleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add plants to see care tasks'**
  String get careScheduleEmpty;

  /// Auto-generated journal entry when a care task is completed
  ///
  /// In en, this message translates to:
  /// **'{taskType} completed'**
  String careTaskCompleted(String taskType);

  /// Auto-generated journal entry with user note when a care task is completed
  ///
  /// In en, this message translates to:
  /// **'{taskType} completed — {note}'**
  String careTaskCompletedWithNote(String taskType, String note);

  /// No description provided for @symptomLoggerTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Symptom'**
  String get symptomLoggerTitle;

  /// No description provided for @symptomLoggerLogSymptom.
  ///
  /// In en, this message translates to:
  /// **'Log Symptom'**
  String get symptomLoggerLogSymptom;

  /// No description provided for @symptomLoggerSaved.
  ///
  /// In en, this message translates to:
  /// **'Symptom logged successfully!'**
  String get symptomLoggerSaved;

  /// No description provided for @symptomLoggerStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get symptomLoggerStep;

  /// No description provided for @symptomLoggerStepSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptomLoggerStepSymptoms;

  /// No description provided for @symptomLoggerStepSeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get symptomLoggerStepSeverity;

  /// No description provided for @symptomLoggerStepParts.
  ///
  /// In en, this message translates to:
  /// **'Affected Parts'**
  String get symptomLoggerStepParts;

  /// No description provided for @symptomLoggerStepOnset.
  ///
  /// In en, this message translates to:
  /// **'When did it start?'**
  String get symptomLoggerStepOnset;

  /// No description provided for @symptomLoggerStepEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get symptomLoggerStepEnvironment;

  /// No description provided for @symptomLoggerStepNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes & Photo'**
  String get symptomLoggerStepNotes;

  /// No description provided for @symptomLoggerStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get symptomLoggerStepReview;

  /// No description provided for @symptomLoggerSelectSymptoms.
  ///
  /// In en, this message translates to:
  /// **'What symptoms do you see? (select at least one)'**
  String get symptomLoggerSelectSymptoms;

  /// No description provided for @symptomLoggerSelectSeverity.
  ///
  /// In en, this message translates to:
  /// **'How severe is the problem?'**
  String get symptomLoggerSelectSeverity;

  /// No description provided for @symptomLoggerSelectParts.
  ///
  /// In en, this message translates to:
  /// **'Which parts are affected?'**
  String get symptomLoggerSelectParts;

  /// No description provided for @symptomLoggerSelectOnset.
  ///
  /// In en, this message translates to:
  /// **'When did you first notice?'**
  String get symptomLoggerSelectOnset;

  /// No description provided for @symptomLoggerSoilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture'**
  String get symptomLoggerSoilMoisture;

  /// No description provided for @symptomLoggerLightCondition.
  ///
  /// In en, this message translates to:
  /// **'Light Condition'**
  String get symptomLoggerLightCondition;

  /// No description provided for @symptomLoggerNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get symptomLoggerNotesLabel;

  /// No description provided for @symptomLoggerNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add any observations (optional, max 500 characters)'**
  String get symptomLoggerNotesHint;

  /// No description provided for @symptomLoggerPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get symptomLoggerPhotoLabel;

  /// No description provided for @symptomLoggerAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get symptomLoggerAddPhoto;

  /// No description provided for @symptomLoggerRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get symptomLoggerRemovePhoto;

  /// No description provided for @symptomLoggerPhotoAttached.
  ///
  /// In en, this message translates to:
  /// **'Photo attached'**
  String get symptomLoggerPhotoAttached;

  /// No description provided for @symptomLoggerReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your entry'**
  String get symptomLoggerReviewTitle;

  /// No description provided for @symptomLoggerSave.
  ///
  /// In en, this message translates to:
  /// **'Save Entry'**
  String get symptomLoggerSave;

  /// No description provided for @symptomLoggerSelectRequired.
  ///
  /// In en, this message translates to:
  /// **'Please make a selection before proceeding'**
  String get symptomLoggerSelectRequired;

  /// No description provided for @symptomLoggerSelectPlant.
  ///
  /// In en, this message translates to:
  /// **'Select a plant'**
  String get symptomLoggerSelectPlant;

  /// No description provided for @symptomTypeYellowLeaves.
  ///
  /// In en, this message translates to:
  /// **'Yellow Leaves'**
  String get symptomTypeYellowLeaves;

  /// No description provided for @symptomTypeBrownTips.
  ///
  /// In en, this message translates to:
  /// **'Brown Tips'**
  String get symptomTypeBrownTips;

  /// No description provided for @symptomTypeDrooping.
  ///
  /// In en, this message translates to:
  /// **'Drooping'**
  String get symptomTypeDrooping;

  /// No description provided for @symptomTypePests.
  ///
  /// In en, this message translates to:
  /// **'Pests'**
  String get symptomTypePests;

  /// No description provided for @symptomTypeMold.
  ///
  /// In en, this message translates to:
  /// **'Mold'**
  String get symptomTypeMold;

  /// No description provided for @symptomTypeSoftStems.
  ///
  /// In en, this message translates to:
  /// **'Soft Stems'**
  String get symptomTypeSoftStems;

  /// No description provided for @symptomTypeDrySoil.
  ///
  /// In en, this message translates to:
  /// **'Dry Soil'**
  String get symptomTypeDrySoil;

  /// No description provided for @symptomTypeWetSoil.
  ///
  /// In en, this message translates to:
  /// **'Wet Soil'**
  String get symptomTypeWetSoil;

  /// No description provided for @symptomTypeLeafSpots.
  ///
  /// In en, this message translates to:
  /// **'Leaf Spots'**
  String get symptomTypeLeafSpots;

  /// No description provided for @symptomSeverityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get symptomSeverityMild;

  /// No description provided for @symptomSeverityMildDesc.
  ///
  /// In en, this message translates to:
  /// **'Minor issue, plant looks mostly healthy'**
  String get symptomSeverityMildDesc;

  /// No description provided for @symptomSeverityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get symptomSeverityModerate;

  /// No description provided for @symptomSeverityModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Noticeable problem, needs attention soon'**
  String get symptomSeverityModerateDesc;

  /// No description provided for @symptomSeveritySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get symptomSeveritySevere;

  /// No description provided for @symptomSeveritySevereDesc.
  ///
  /// In en, this message translates to:
  /// **'Serious issue, requires immediate action'**
  String get symptomSeveritySevereDesc;

  /// No description provided for @symptomPartLeaves.
  ///
  /// In en, this message translates to:
  /// **'Leaves'**
  String get symptomPartLeaves;

  /// No description provided for @symptomPartStems.
  ///
  /// In en, this message translates to:
  /// **'Stems'**
  String get symptomPartStems;

  /// No description provided for @symptomPartRoots.
  ///
  /// In en, this message translates to:
  /// **'Roots'**
  String get symptomPartRoots;

  /// No description provided for @symptomPartSoil.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get symptomPartSoil;

  /// No description provided for @symptomPartFlowers.
  ///
  /// In en, this message translates to:
  /// **'Flowers'**
  String get symptomPartFlowers;

  /// No description provided for @symptomPartMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple Areas'**
  String get symptomPartMultiple;

  /// No description provided for @symptomOnsetToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get symptomOnsetToday;

  /// No description provided for @symptomOnsetFewDays.
  ///
  /// In en, this message translates to:
  /// **'A few days ago'**
  String get symptomOnsetFewDays;

  /// No description provided for @symptomOnsetAboutWeek.
  ///
  /// In en, this message translates to:
  /// **'About a week ago'**
  String get symptomOnsetAboutWeek;

  /// No description provided for @symptomOnsetMoreThanWeek.
  ///
  /// In en, this message translates to:
  /// **'More than a week ago'**
  String get symptomOnsetMoreThanWeek;

  /// No description provided for @symptomSoilDry.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get symptomSoilDry;

  /// No description provided for @symptomSoilMoist.
  ///
  /// In en, this message translates to:
  /// **'Moist'**
  String get symptomSoilMoist;

  /// No description provided for @symptomSoilWet.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get symptomSoilWet;

  /// No description provided for @symptomSoilSoggy.
  ///
  /// In en, this message translates to:
  /// **'Soggy'**
  String get symptomSoilSoggy;

  /// No description provided for @symptomLightFullSun.
  ///
  /// In en, this message translates to:
  /// **'Full Sun'**
  String get symptomLightFullSun;

  /// No description provided for @symptomLightPartialShade.
  ///
  /// In en, this message translates to:
  /// **'Partial Shade'**
  String get symptomLightPartialShade;

  /// No description provided for @symptomLightLowLight.
  ///
  /// In en, this message translates to:
  /// **'Low Light'**
  String get symptomLightLowLight;

  /// No description provided for @symptomLightUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get symptomLightUnknown;

  /// No description provided for @symptomLoggerHistory.
  ///
  /// In en, this message translates to:
  /// **'Symptom History'**
  String get symptomLoggerHistory;

  /// No description provided for @symptomLoggerNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged yet'**
  String get symptomLoggerNoEntries;

  /// No description provided for @symptomLoggerMarkResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark Resolved'**
  String get symptomLoggerMarkResolved;

  /// No description provided for @symptomLoggerMarkResolvedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark this symptom as resolved?'**
  String get symptomLoggerMarkResolvedConfirm;

  /// No description provided for @symptomLoggerRecentEvents.
  ///
  /// In en, this message translates to:
  /// **'Recent Health Events'**
  String get symptomLoggerRecentEvents;

  /// No description provided for @careStatusNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get careStatusNeedsAttention;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @journalPageTitle.
  ///
  /// In en, this message translates to:
  /// **'{plantName} — Journal'**
  String journalPageTitle(Object plantName);

  /// No description provided for @journalEmpty.
  ///
  /// In en, this message translates to:
  /// **'No journal entries yet'**
  String get journalEmpty;

  /// No description provided for @journalTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first entry'**
  String get journalTapToAdd;

  /// No description provided for @journalNewEntry.
  ///
  /// In en, this message translates to:
  /// **'New Journal Entry'**
  String get journalNewEntry;

  /// No description provided for @journalEditEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get journalEditEntry;

  /// No description provided for @journalDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get journalDeleteEntry;

  /// No description provided for @journalDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this journal entry?'**
  String get journalDeleteConfirm;

  /// No description provided for @journalEntryType.
  ///
  /// In en, this message translates to:
  /// **'Entry Type'**
  String get journalEntryType;

  /// No description provided for @journalTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text Note'**
  String get journalTypeText;

  /// No description provided for @journalTypePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get journalTypePhoto;

  /// No description provided for @journalTypeTask.
  ///
  /// In en, this message translates to:
  /// **'Completed Task'**
  String get journalTypeTask;

  /// No description provided for @journalTypeGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth Update'**
  String get journalTypeGrowth;

  /// No description provided for @journalTypeRepotting.
  ///
  /// In en, this message translates to:
  /// **'Repotting'**
  String get journalTypeRepotting;

  /// No description provided for @journalTypePest.
  ///
  /// In en, this message translates to:
  /// **'Pest Observation'**
  String get journalTypePest;

  /// No description provided for @journalTypeDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get journalTypeDiagnosis;

  /// No description provided for @journalNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get journalNotes;

  /// No description provided for @journalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add your observations...'**
  String get journalNotesHint;

  /// No description provided for @journalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get journalPhoto;

  /// No description provided for @journalAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get journalAddPhoto;

  /// No description provided for @journalTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get journalTakePhoto;

  /// No description provided for @journalChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get journalChooseFromGallery;

  /// No description provided for @growthPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Growth Photos'**
  String get growthPhotosTitle;

  /// No description provided for @growthPhotosAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get growthPhotosAdd;

  /// No description provided for @growthPhotosEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add your first growth photo'**
  String get growthPhotosEmpty;

  /// No description provided for @growthPhotosEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add photos from the plant detail page'**
  String get growthPhotosEmptyHint;

  /// No description provided for @growthPhotosNoTimeline.
  ///
  /// In en, this message translates to:
  /// **'No growth photos yet'**
  String get growthPhotosNoTimeline;

  /// No description provided for @growthPhotosNoTimelineHint.
  ///
  /// In en, this message translates to:
  /// **'Add photos from the plant detail page'**
  String get growthPhotosNoTimelineHint;

  /// No description provided for @growthPhotoDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get growthPhotoDeleteTitle;

  /// No description provided for @growthPhotoDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo?'**
  String get growthPhotoDeleteConfirm;

  /// No description provided for @growthPhotoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Photo not found'**
  String get growthPhotoNotFound;

  /// No description provided for @growthPhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get growthPhotoCamera;

  /// No description provided for @growthPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get growthPhotoGallery;

  /// No description provided for @careRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Care Rules'**
  String get careRulesTitle;

  /// No description provided for @careRulesManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get careRulesManage;

  /// No description provided for @careRulesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom rules'**
  String get careRulesEmpty;

  /// No description provided for @careRulesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add a rule to override the computed schedule'**
  String get careRulesEmptyHint;

  /// No description provided for @careRulesActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active rule} other{{count} active rules}}'**
  String careRulesActiveCount(num count);

  /// No description provided for @careRulesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Rule'**
  String get careRulesDeleteTitle;

  /// No description provided for @careRulesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{ruleType}\" rule?'**
  String careRulesDeleteConfirm(Object ruleType);

  /// No description provided for @careRulesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Rule'**
  String get careRulesAdd;

  /// No description provided for @careRulesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Rule'**
  String get careRulesEdit;

  /// No description provided for @careRulesTaskType.
  ///
  /// In en, this message translates to:
  /// **'Task Type'**
  String get careRulesTaskType;

  /// No description provided for @careRulesBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get careRulesBuiltIn;

  /// No description provided for @careRulesCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get careRulesCustom;

  /// No description provided for @careRulesSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select task type'**
  String get careRulesSelectType;

  /// No description provided for @careRulesCustomType.
  ///
  /// In en, this message translates to:
  /// **'Custom task type'**
  String get careRulesCustomType;

  /// No description provided for @careRulesCustomTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Check for flowers'**
  String get careRulesCustomTypeHint;

  /// No description provided for @careRulesSelectTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a task type'**
  String get careRulesSelectTypeRequired;

  /// No description provided for @careRulesCustomTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a task type'**
  String get careRulesCustomTypeRequired;

  /// No description provided for @careRulesInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval (days)'**
  String get careRulesInterval;

  /// No description provided for @careRulesIntervalHint.
  ///
  /// In en, this message translates to:
  /// **'Days between tasks'**
  String get careRulesIntervalHint;

  /// No description provided for @careRulesIntervalRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an interval'**
  String get careRulesIntervalRequired;

  /// No description provided for @careRulesIntervalPositive.
  ///
  /// In en, this message translates to:
  /// **'Please enter a positive number'**
  String get careRulesIntervalPositive;

  /// No description provided for @careRulesEnableReminder.
  ///
  /// In en, this message translates to:
  /// **'Enable Reminder'**
  String get careRulesEnableReminder;

  /// No description provided for @careRulesReminderTimeHint.
  ///
  /// In en, this message translates to:
  /// **'09:00'**
  String get careRulesReminderTimeHint;

  /// No description provided for @careRulesReminderDays.
  ///
  /// In en, this message translates to:
  /// **'Reminder days'**
  String get careRulesReminderDays;

  /// No description provided for @careRulesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save rule: {error}'**
  String careRulesSaveFailed(Object error);

  /// No description provided for @diagnosisTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant Diagnosis'**
  String get diagnosisTitle;

  /// No description provided for @diagnosisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnose plant problems'**
  String get diagnosisSubtitle;

  /// No description provided for @diagnosisStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get diagnosisStep;

  /// Current position in the diagnosis questionnaire
  ///
  /// In en, this message translates to:
  /// **'Step {currentStep}/{totalSteps}'**
  String diagnosisStepProgress(int currentStep, int totalSteps);

  /// No description provided for @diagnosisStepSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get diagnosisStepSymptoms;

  /// No description provided for @diagnosisStepContext.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get diagnosisStepContext;

  /// No description provided for @diagnosisStepDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get diagnosisStepDetails;

  /// No description provided for @diagnosisStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get diagnosisStepReview;

  /// No description provided for @diagnosisSelectSymptoms.
  ///
  /// In en, this message translates to:
  /// **'What symptoms do you see on your plant? (select at least one)'**
  String get diagnosisSelectSymptoms;

  /// No description provided for @diagnosisSymptomRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one symptom'**
  String get diagnosisSymptomRequired;

  /// No description provided for @diagnosisEnvironmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your plant\'s environment'**
  String get diagnosisEnvironmentTitle;

  /// No description provided for @diagnosisWateringFrequency.
  ///
  /// In en, this message translates to:
  /// **'Watering Frequency'**
  String get diagnosisWateringFrequency;

  /// No description provided for @diagnosisLightExposure.
  ///
  /// In en, this message translates to:
  /// **'Light Exposure'**
  String get diagnosisLightExposure;

  /// No description provided for @diagnosisHumidityLevel.
  ///
  /// In en, this message translates to:
  /// **'Humidity Level'**
  String get diagnosisHumidityLevel;

  /// No description provided for @diagnosisPotType.
  ///
  /// In en, this message translates to:
  /// **'Pot Type'**
  String get diagnosisPotType;

  /// No description provided for @diagnosisSoilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get diagnosisSoilType;

  /// No description provided for @diagnosisAdditionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get diagnosisAdditionalInfo;

  /// No description provided for @diagnosisPlantSpecies.
  ///
  /// In en, this message translates to:
  /// **'Plant Species (optional)'**
  String get diagnosisPlantSpecies;

  /// No description provided for @diagnosisPlantSpeciesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Monstera deliciosa, Snake Plant'**
  String get diagnosisPlantSpeciesHint;

  /// No description provided for @diagnosisRecentFertilizing.
  ///
  /// In en, this message translates to:
  /// **'Recent Fertilizing'**
  String get diagnosisRecentFertilizing;

  /// No description provided for @diagnosisRecentFertilizingHint.
  ///
  /// In en, this message translates to:
  /// **'Have you fertilized in the last 3 months?'**
  String get diagnosisRecentFertilizingHint;

  /// No description provided for @diagnosisPestSigns.
  ///
  /// In en, this message translates to:
  /// **'Pest Signs'**
  String get diagnosisPestSigns;

  /// No description provided for @diagnosisPestSignsHint.
  ///
  /// In en, this message translates to:
  /// **'Have you noticed any insects, webs, or sticky residue?'**
  String get diagnosisPestSignsHint;

  /// No description provided for @diagnosisReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your answers'**
  String get diagnosisReviewTitle;

  /// No description provided for @diagnosisReviewSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get diagnosisReviewSymptoms;

  /// No description provided for @diagnosisReviewWatering.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get diagnosisReviewWatering;

  /// No description provided for @diagnosisReviewLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get diagnosisReviewLight;

  /// No description provided for @diagnosisReviewHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get diagnosisReviewHumidity;

  /// No description provided for @diagnosisReviewPotType.
  ///
  /// In en, this message translates to:
  /// **'Pot Type'**
  String get diagnosisReviewPotType;

  /// No description provided for @diagnosisReviewSoil.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get diagnosisReviewSoil;

  /// No description provided for @diagnosisReviewSpecies.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get diagnosisReviewSpecies;

  /// No description provided for @diagnosisReviewRecentlyFertilized.
  ///
  /// In en, this message translates to:
  /// **'Fertilized recently'**
  String get diagnosisReviewRecentlyFertilized;

  /// No description provided for @diagnosisReviewPestSigns.
  ///
  /// In en, this message translates to:
  /// **'Pest signs'**
  String get diagnosisReviewPestSigns;

  /// No description provided for @diagnosisAnswerYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get diagnosisAnswerYes;

  /// No description provided for @diagnosisAnswerNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get diagnosisAnswerNo;

  /// No description provided for @diagnosisAnswerUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get diagnosisAnswerUnknown;

  /// No description provided for @diagnosisStartDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Start Diagnosis'**
  String get diagnosisStartDiagnosis;

  /// No description provided for @diagnosisEvaluating.
  ///
  /// In en, this message translates to:
  /// **'Evaluating...'**
  String get diagnosisEvaluating;

  /// No description provided for @diagnosisResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Results'**
  String get diagnosisResultsTitle;

  /// No description provided for @diagnosisNoClearMatch.
  ///
  /// In en, this message translates to:
  /// **'No Clear Match'**
  String get diagnosisNoClearMatch;

  /// No description provided for @diagnosisNoClearMatchDesc.
  ///
  /// In en, this message translates to:
  /// **'Based on the information provided, we couldn\'t identify a specific cause. This doesn\'t mean your plant is fine — it may need attention for a reason not covered by this questionnaire.'**
  String get diagnosisNoClearMatchDesc;

  /// No description provided for @diagnosisGeneralSuggestions.
  ///
  /// In en, this message translates to:
  /// **'General Suggestions:'**
  String get diagnosisGeneralSuggestions;

  /// No description provided for @diagnosisSuggestionAppropriateLight.
  ///
  /// In en, this message translates to:
  /// **'Ensure your plant receives appropriate light for its species.'**
  String get diagnosisSuggestionAppropriateLight;

  /// No description provided for @diagnosisSuggestionCheckSoilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Check the soil moisture before watering — over- and under-watering are the most common issues.'**
  String get diagnosisSuggestionCheckSoilMoisture;

  /// No description provided for @diagnosisSuggestionInspectPlant.
  ///
  /// In en, this message translates to:
  /// **'Inspect the leaves and stems closely for any unusual spots, pests, or texture changes.'**
  String get diagnosisSuggestionInspectPlant;

  /// No description provided for @diagnosisSuggestionConsiderRepotting.
  ///
  /// In en, this message translates to:
  /// **'Consider repotting if the plant has been in the same soil for over a year.'**
  String get diagnosisSuggestionConsiderRepotting;

  /// No description provided for @diagnosisTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again with More Details'**
  String get diagnosisTryAgain;

  /// No description provided for @diagnosisStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start Over'**
  String get diagnosisStartOver;

  /// No description provided for @diagnosisEmptyInputTitle.
  ///
  /// In en, this message translates to:
  /// **'No Symptoms Selected'**
  String get diagnosisEmptyInputTitle;

  /// No description provided for @diagnosisEmptyInputDesc.
  ///
  /// In en, this message translates to:
  /// **'Select at least one symptom before starting a diagnosis.'**
  String get diagnosisEmptyInputDesc;

  /// No description provided for @diagnosisDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is a suggestion based on the information you provided. It is not a definitive diagnosis. Consult a plant care expert for serious concerns.'**
  String get diagnosisDisclaimer;

  /// No description provided for @diagnosisRecommendedActions.
  ///
  /// In en, this message translates to:
  /// **'Recommended Actions'**
  String get diagnosisRecommendedActions;

  /// No description provided for @diagnosisFollowUpChecks.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Checks'**
  String get diagnosisFollowUpChecks;

  /// No description provided for @diagnosisCauseOverwatering.
  ///
  /// In en, this message translates to:
  /// **'Overwatering'**
  String get diagnosisCauseOverwatering;

  /// No description provided for @diagnosisCauseUnderwatering.
  ///
  /// In en, this message translates to:
  /// **'Underwatering'**
  String get diagnosisCauseUnderwatering;

  /// No description provided for @diagnosisCauseLowLight.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Light'**
  String get diagnosisCauseLowLight;

  /// No description provided for @diagnosisCauseSunburn.
  ///
  /// In en, this message translates to:
  /// **'Sunburn / Light Damage'**
  String get diagnosisCauseSunburn;

  /// No description provided for @diagnosisCauseLowHumidity.
  ///
  /// In en, this message translates to:
  /// **'Low Humidity'**
  String get diagnosisCauseLowHumidity;

  /// No description provided for @diagnosisCauseNutrientProblem.
  ///
  /// In en, this message translates to:
  /// **'Nutrient Deficiency'**
  String get diagnosisCauseNutrientProblem;

  /// No description provided for @diagnosisCauseRootIssue.
  ///
  /// In en, this message translates to:
  /// **'Root Problems'**
  String get diagnosisCauseRootIssue;

  /// No description provided for @diagnosisCausePests.
  ///
  /// In en, this message translates to:
  /// **'Pest Infestation'**
  String get diagnosisCausePests;

  /// No description provided for @diagnosisCauseNoClearMatch.
  ///
  /// In en, this message translates to:
  /// **'No Clear Match'**
  String get diagnosisCauseNoClearMatch;

  /// No description provided for @diagnosisConfidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get diagnosisConfidenceHigh;

  /// No description provided for @diagnosisConfidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get diagnosisConfidenceMedium;

  /// No description provided for @diagnosisConfidenceLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get diagnosisConfidenceLow;

  /// No description provided for @diagnosisWateringFrequent.
  ///
  /// In en, this message translates to:
  /// **'Frequent'**
  String get diagnosisWateringFrequent;

  /// No description provided for @diagnosisWateringNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get diagnosisWateringNormal;

  /// No description provided for @diagnosisWateringInfrequent.
  ///
  /// In en, this message translates to:
  /// **'Infrequent'**
  String get diagnosisWateringInfrequent;

  /// No description provided for @diagnosisLightLow.
  ///
  /// In en, this message translates to:
  /// **'Low Light'**
  String get diagnosisLightLow;

  /// No description provided for @diagnosisLightIndirect.
  ///
  /// In en, this message translates to:
  /// **'Indirect Light'**
  String get diagnosisLightIndirect;

  /// No description provided for @diagnosisLightDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct Sun'**
  String get diagnosisLightDirect;

  /// No description provided for @diagnosisHumidityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get diagnosisHumidityLow;

  /// No description provided for @diagnosisHumidityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get diagnosisHumidityModerate;

  /// No description provided for @diagnosisHumidityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get diagnosisHumidityHigh;

  /// No description provided for @diagnosisPotStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get diagnosisPotStandard;

  /// No description provided for @diagnosisPotSelfWatering.
  ///
  /// In en, this message translates to:
  /// **'Self-Watering'**
  String get diagnosisPotSelfWatering;

  /// No description provided for @diagnosisPotNoDrainage.
  ///
  /// In en, this message translates to:
  /// **'No Drainage'**
  String get diagnosisPotNoDrainage;

  /// No description provided for @diagnosisSoilStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard Potting Mix'**
  String get diagnosisSoilStandard;

  /// No description provided for @diagnosisSoilSucculent.
  ///
  /// In en, this message translates to:
  /// **'Succulent Mix'**
  String get diagnosisSoilSucculent;

  /// No description provided for @diagnosisSoilOrchid.
  ///
  /// In en, this message translates to:
  /// **'Orchid Mix'**
  String get diagnosisSoilOrchid;

  /// No description provided for @diagnosisSoilCactus.
  ///
  /// In en, this message translates to:
  /// **'Cactus Mix'**
  String get diagnosisSoilCactus;

  /// No description provided for @diagnosisSymptomYellowingLeaves.
  ///
  /// In en, this message translates to:
  /// **'Yellowing Leaves'**
  String get diagnosisSymptomYellowingLeaves;

  /// No description provided for @diagnosisSymptomDroopingWilt.
  ///
  /// In en, this message translates to:
  /// **'Drooping / Wilting'**
  String get diagnosisSymptomDroopingWilt;

  /// No description provided for @diagnosisSymptomBrownTips.
  ///
  /// In en, this message translates to:
  /// **'Brown Tips / Crispy Edges'**
  String get diagnosisSymptomBrownTips;

  /// No description provided for @diagnosisSymptomBrownPatches.
  ///
  /// In en, this message translates to:
  /// **'Brown Patches / Scorched Spots'**
  String get diagnosisSymptomBrownPatches;

  /// No description provided for @diagnosisSymptomPaleLeaves.
  ///
  /// In en, this message translates to:
  /// **'Pale Leaves'**
  String get diagnosisSymptomPaleLeaves;

  /// No description provided for @diagnosisSymptomLeggyGrowth.
  ///
  /// In en, this message translates to:
  /// **'Leggy Growth'**
  String get diagnosisSymptomLeggyGrowth;

  /// No description provided for @diagnosisSymptomVisibleInsects.
  ///
  /// In en, this message translates to:
  /// **'Visible Insects / Webs'**
  String get diagnosisSymptomVisibleInsects;

  /// No description provided for @diagnosisSymptomStickyResidue.
  ///
  /// In en, this message translates to:
  /// **'Sticky Residue'**
  String get diagnosisSymptomStickyResidue;

  /// No description provided for @diagnosisSymptomMoldOnSoil.
  ///
  /// In en, this message translates to:
  /// **'Mold on Soil'**
  String get diagnosisSymptomMoldOnSoil;

  /// No description provided for @diagnosisSymptomFoulSmell.
  ///
  /// In en, this message translates to:
  /// **'Foul Smell'**
  String get diagnosisSymptomFoulSmell;

  /// No description provided for @diagnosisSymptomStuntedGrowth.
  ///
  /// In en, this message translates to:
  /// **'Stunted Growth'**
  String get diagnosisSymptomStuntedGrowth;

  /// No description provided for @diagnosisSymptomLeafCurling.
  ///
  /// In en, this message translates to:
  /// **'Leaf Curling'**
  String get diagnosisSymptomLeafCurling;

  /// No description provided for @diagnosisSymptomLeafDrop.
  ///
  /// In en, this message translates to:
  /// **'Leaf Drop'**
  String get diagnosisSymptomLeafDrop;

  /// No description provided for @diagnosisSymptomSoftStems.
  ///
  /// In en, this message translates to:
  /// **'Soft Stems'**
  String get diagnosisSymptomSoftStems;

  /// No description provided for @diagnosisSymptomDrySoil.
  ///
  /// In en, this message translates to:
  /// **'Dry Soil'**
  String get diagnosisSymptomDrySoil;

  /// No description provided for @diagnosisSymptomWetSoil.
  ///
  /// In en, this message translates to:
  /// **'Wet Soil'**
  String get diagnosisSymptomWetSoil;

  /// No description provided for @diagnosisSymptomLeafSpots.
  ///
  /// In en, this message translates to:
  /// **'Leaf Spots'**
  String get diagnosisSymptomLeafSpots;

  /// No description provided for @diagnosisDiagnoseThisPlant.
  ///
  /// In en, this message translates to:
  /// **'Diagnose this plant'**
  String get diagnosisDiagnoseThisPlant;

  /// No description provided for @healthTimelineSymptomEntry.
  ///
  /// In en, this message translates to:
  /// **'Symptom logged'**
  String get healthTimelineSymptomEntry;

  /// No description provided for @healthTimelineDiagnosisEntry.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis result'**
  String get healthTimelineDiagnosisEntry;

  /// No description provided for @healthTimelineBadge.
  ///
  /// In en, this message translates to:
  /// **'Latest Diagnosis'**
  String get healthTimelineBadge;

  /// No description provided for @healthTimelineLogSymptom.
  ///
  /// In en, this message translates to:
  /// **'Log Symptom'**
  String get healthTimelineLogSymptom;

  /// No description provided for @healthTimelineDiagnose.
  ///
  /// In en, this message translates to:
  /// **'Diagnose'**
  String get healthTimelineDiagnose;

  /// No description provided for @healthTimelineMarkResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark Resolved'**
  String get healthTimelineMarkResolved;

  /// No description provided for @healthTimelineResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get healthTimelineResolved;

  /// No description provided for @healthTimelineViewLinkedSymptom.
  ///
  /// In en, this message translates to:
  /// **'View linked symptom'**
  String get healthTimelineViewLinkedSymptom;

  /// No description provided for @healthTimelineTodayAt.
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String healthTimelineTodayAt(String time);

  /// No description provided for @healthTimelineYesterdayAt.
  ///
  /// In en, this message translates to:
  /// **'Yesterday at {time}'**
  String healthTimelineYesterdayAt(String time);

  /// No description provided for @healthTimelineDateAt.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String healthTimelineDateAt(String date, String time);

  /// No description provided for @diagnosisSaveToPlantHistory.
  ///
  /// In en, this message translates to:
  /// **'Save to plant history'**
  String get diagnosisSaveToPlantHistory;

  /// No description provided for @diagnosisSavedToPlantHistory.
  ///
  /// In en, this message translates to:
  /// **'Saved to plant history'**
  String get diagnosisSavedToPlantHistory;

  /// No description provided for @diagnosisSourceAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto-diagnosis'**
  String get diagnosisSourceAuto;

  /// No description provided for @diagnosisSourceManual.
  ///
  /// In en, this message translates to:
  /// **'Manual diagnosis'**
  String get diagnosisSourceManual;

  /// No description provided for @diagnosisSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String diagnosisSourceLabel(String source);

  /// No description provided for @viewHealthTimeline.
  ///
  /// In en, this message translates to:
  /// **'View Health Timeline'**
  String get viewHealthTimeline;

  /// Introduces the symptoms that contributed to a diagnosis result
  ///
  /// In en, this message translates to:
  /// **'You reported {symptoms}.'**
  String diagnosisEvidenceReportedSymptoms(String symptoms);

  /// No description provided for @diagnosisEvidenceFrequentWateringTooWet.
  ///
  /// In en, this message translates to:
  /// **'You water frequently, which can keep the soil too wet.'**
  String get diagnosisEvidenceFrequentWateringTooWet;

  /// No description provided for @diagnosisEvidenceNoDrainage.
  ///
  /// In en, this message translates to:
  /// **'Your pot has no drainage holes, which traps excess water.'**
  String get diagnosisEvidenceNoDrainage;

  /// No description provided for @diagnosisEvidenceOverwateringSigns.
  ///
  /// In en, this message translates to:
  /// **'These are common signs of overwatering.'**
  String get diagnosisEvidenceOverwateringSigns;

  /// No description provided for @diagnosisEvidenceInfrequentWateringTooDry.
  ///
  /// In en, this message translates to:
  /// **'You water infrequently, which may leave the soil too dry.'**
  String get diagnosisEvidenceInfrequentWateringTooDry;

  /// No description provided for @diagnosisEvidenceUnderwateringSigns.
  ///
  /// In en, this message translates to:
  /// **'These are common signs of underwatering.'**
  String get diagnosisEvidenceUnderwateringSigns;

  /// No description provided for @diagnosisEvidenceLowLightExposure.
  ///
  /// In en, this message translates to:
  /// **'Your plant receives low light.'**
  String get diagnosisEvidenceLowLightExposure;

  /// No description provided for @diagnosisEvidenceLowLightSigns.
  ///
  /// In en, this message translates to:
  /// **'Leggy growth and pale leaves are typical signs of insufficient light.'**
  String get diagnosisEvidenceLowLightSigns;

  /// No description provided for @diagnosisEvidenceDirectSunlight.
  ///
  /// In en, this message translates to:
  /// **'Your plant receives direct sunlight.'**
  String get diagnosisEvidenceDirectSunlight;

  /// No description provided for @diagnosisEvidenceSunburnSigns.
  ///
  /// In en, this message translates to:
  /// **'Brown scorched patches can indicate sun damage.'**
  String get diagnosisEvidenceSunburnSigns;

  /// No description provided for @diagnosisEvidenceLowHumidityEnvironment.
  ///
  /// In en, this message translates to:
  /// **'The humidity in your environment is low.'**
  String get diagnosisEvidenceLowHumidityEnvironment;

  /// No description provided for @diagnosisEvidenceLowHumiditySigns.
  ///
  /// In en, this message translates to:
  /// **'Brown leaf tips and curling are common in dry indoor air.'**
  String get diagnosisEvidenceLowHumiditySigns;

  /// No description provided for @diagnosisEvidenceNotFertilizedRecently.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t fertilized recently.'**
  String get diagnosisEvidenceNotFertilizedRecently;

  /// No description provided for @diagnosisEvidenceNutrientSigns.
  ///
  /// In en, this message translates to:
  /// **'Pale or yellowing growth can indicate nutrient deficiency.'**
  String get diagnosisEvidenceNutrientSigns;

  /// No description provided for @diagnosisEvidenceFrequentWateringRootProblems.
  ///
  /// In en, this message translates to:
  /// **'Frequent watering can lead to root problems.'**
  String get diagnosisEvidenceFrequentWateringRootProblems;

  /// No description provided for @diagnosisEvidenceRootProblemSigns.
  ///
  /// In en, this message translates to:
  /// **'Wilting despite moist soil and foul smell are signs of root issues.'**
  String get diagnosisEvidenceRootProblemSigns;

  /// No description provided for @diagnosisEvidencePestSignsObserved.
  ///
  /// In en, this message translates to:
  /// **'You\'ve noticed signs of pests.'**
  String get diagnosisEvidencePestSignsObserved;

  /// No description provided for @diagnosisEvidencePestInfestationSigns.
  ///
  /// In en, this message translates to:
  /// **'Visible insects, sticky residue, and leaf damage can indicate pest infestation.'**
  String get diagnosisEvidencePestInfestationSigns;

  /// No description provided for @diagnosisEvidenceDefault.
  ///
  /// In en, this message translates to:
  /// **'Based on your answers, this cause was identified as a possibility.'**
  String get diagnosisEvidenceDefault;

  /// No description provided for @diagnosisFallbackEvidence.
  ///
  /// In en, this message translates to:
  /// **'No single cause stood out based on the information provided. This could mean the issue is caused by factors not covered by the questionnaire.'**
  String get diagnosisFallbackEvidence;

  /// No description provided for @diagnosisActionOverwateringDrySoil.
  ///
  /// In en, this message translates to:
  /// **'Allow the top 2-3 inches of soil to dry before watering again.'**
  String get diagnosisActionOverwateringDrySoil;

  /// No description provided for @diagnosisActionOverwateringDrainage.
  ///
  /// In en, this message translates to:
  /// **'Check that your pot has drainage holes and empty the saucer after watering.'**
  String get diagnosisActionOverwateringDrainage;

  /// No description provided for @diagnosisActionOverwateringTrimRoots.
  ///
  /// In en, this message translates to:
  /// **'If root rot is suspected, remove the plant and trim any brown, mushy roots.'**
  String get diagnosisActionOverwateringTrimRoots;

  /// No description provided for @diagnosisActionUnderwateringWaterThoroughly.
  ///
  /// In en, this message translates to:
  /// **'Water the plant thoroughly until water drains from the bottom.'**
  String get diagnosisActionUnderwateringWaterThoroughly;

  /// No description provided for @diagnosisActionUnderwateringSchedule.
  ///
  /// In en, this message translates to:
  /// **'Establish a regular watering schedule based on the plant\'s needs.'**
  String get diagnosisActionUnderwateringSchedule;

  /// No description provided for @diagnosisActionUnderwateringBottomWater.
  ///
  /// In en, this message translates to:
  /// **'Consider bottom-watering to encourage deeper root growth.'**
  String get diagnosisActionUnderwateringBottomWater;

  /// No description provided for @diagnosisActionLowLightMovePlant.
  ///
  /// In en, this message translates to:
  /// **'Move the plant closer to a window or to a brighter location.'**
  String get diagnosisActionLowLightMovePlant;

  /// No description provided for @diagnosisActionLowLightGrowLight.
  ///
  /// In en, this message translates to:
  /// **'Consider adding a grow light if natural light is limited.'**
  String get diagnosisActionLowLightGrowLight;

  /// No description provided for @diagnosisActionLowLightRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate the plant regularly so all sides receive light.'**
  String get diagnosisActionLowLightRotate;

  /// No description provided for @diagnosisActionSunburnIndirectLight.
  ///
  /// In en, this message translates to:
  /// **'Move the plant to a spot with indirect or filtered light.'**
  String get diagnosisActionSunburnIndirectLight;

  /// No description provided for @diagnosisActionSunburnCurtain.
  ///
  /// In en, this message translates to:
  /// **'Use a sheer curtain to diffuse direct sunlight.'**
  String get diagnosisActionSunburnCurtain;

  /// No description provided for @diagnosisActionSunburnRemoveLeaves.
  ///
  /// In en, this message translates to:
  /// **'Remove severely burned leaves once the plant has adjusted.'**
  String get diagnosisActionSunburnRemoveLeaves;

  /// No description provided for @diagnosisActionLowHumidityMist.
  ///
  /// In en, this message translates to:
  /// **'Mist the plant regularly or place a humidifier nearby.'**
  String get diagnosisActionLowHumidityMist;

  /// No description provided for @diagnosisActionLowHumidityGroupPlants.
  ///
  /// In en, this message translates to:
  /// **'Group humidity-loving plants together to create a microclimate.'**
  String get diagnosisActionLowHumidityGroupPlants;

  /// No description provided for @diagnosisActionLowHumidityPebbleTray.
  ///
  /// In en, this message translates to:
  /// **'Place the pot on a pebble tray with water (pot sitting above the water line).'**
  String get diagnosisActionLowHumidityPebbleTray;

  /// No description provided for @diagnosisActionNutrientsFertilize.
  ///
  /// In en, this message translates to:
  /// **'Apply a balanced liquid fertilizer at half strength during the growing season.'**
  String get diagnosisActionNutrientsFertilize;

  /// No description provided for @diagnosisActionNutrientsRepot.
  ///
  /// In en, this message translates to:
  /// **'Check if the plant is root-bound and needs repotting with fresh soil.'**
  String get diagnosisActionNutrientsRepot;

  /// No description provided for @diagnosisActionNutrientsCheckPh.
  ///
  /// In en, this message translates to:
  /// **'Ensure the soil pH is appropriate for the plant species.'**
  String get diagnosisActionNutrientsCheckPh;

  /// No description provided for @diagnosisActionRootsInspect.
  ///
  /// In en, this message translates to:
  /// **'Remove the plant from the pot and inspect the roots.'**
  String get diagnosisActionRootsInspect;

  /// No description provided for @diagnosisActionRootsTrim.
  ///
  /// In en, this message translates to:
  /// **'Trim any brown, mushy, or foul-smelling roots with sterile scissors.'**
  String get diagnosisActionRootsTrim;

  /// No description provided for @diagnosisActionRootsRepot.
  ///
  /// In en, this message translates to:
  /// **'Repot in fresh, well-draining soil and reduce watering frequency.'**
  String get diagnosisActionRootsRepot;

  /// No description provided for @diagnosisActionPestsIsolate.
  ///
  /// In en, this message translates to:
  /// **'Isolate the affected plant to prevent spreading.'**
  String get diagnosisActionPestsIsolate;

  /// No description provided for @diagnosisActionPestsTreat.
  ///
  /// In en, this message translates to:
  /// **'Wipe leaves with a damp cloth or spray with neem oil solution.'**
  String get diagnosisActionPestsTreat;

  /// No description provided for @diagnosisActionPestsInspect.
  ///
  /// In en, this message translates to:
  /// **'Check under leaves and in leaf joints where pests often hide.'**
  String get diagnosisActionPestsInspect;

  /// No description provided for @diagnosisActionDefaultCare.
  ///
  /// In en, this message translates to:
  /// **'Ensure your plant receives appropriate light and water for its species.'**
  String get diagnosisActionDefaultCare;

  /// No description provided for @diagnosisActionDefaultMoisture.
  ///
  /// In en, this message translates to:
  /// **'Check the soil moisture before watering.'**
  String get diagnosisActionDefaultMoisture;

  /// No description provided for @diagnosisCheckOverwateringRoots.
  ///
  /// In en, this message translates to:
  /// **'Check the roots: healthy roots are firm and white, rotten roots are brown and mushy.'**
  String get diagnosisCheckOverwateringRoots;

  /// No description provided for @diagnosisCheckOverwateringMoisture.
  ///
  /// In en, this message translates to:
  /// **'Monitor soil moisture — it should dry out between waterings.'**
  String get diagnosisCheckOverwateringMoisture;

  /// No description provided for @diagnosisCheckUnderwateringRootBall.
  ///
  /// In en, this message translates to:
  /// **'Check the root ball: if it has pulled away from the pot edges, the soil is too dry.'**
  String get diagnosisCheckUnderwateringRootBall;

  /// No description provided for @diagnosisCheckUnderwateringSoil.
  ///
  /// In en, this message translates to:
  /// **'Feel the soil 2 inches down — it should be slightly moist, not bone dry.'**
  String get diagnosisCheckUnderwateringSoil;

  /// No description provided for @diagnosisCheckLowLightGrowth.
  ///
  /// In en, this message translates to:
  /// **'Observe if new growth is still leggy after moving to a brighter spot.'**
  String get diagnosisCheckLowLightGrowth;

  /// No description provided for @diagnosisCheckLowLightHours.
  ///
  /// In en, this message translates to:
  /// **'Note how many hours of light the plant receives daily.'**
  String get diagnosisCheckLowLightHours;

  /// No description provided for @diagnosisCheckSunburnPatches.
  ///
  /// In en, this message translates to:
  /// **'Check if the brown patches stop spreading after moving the plant.'**
  String get diagnosisCheckSunburnPatches;

  /// No description provided for @diagnosisCheckSunburnNewLeaves.
  ///
  /// In en, this message translates to:
  /// **'Monitor for new leaves — they should grow without brown spots.'**
  String get diagnosisCheckSunburnNewLeaves;

  /// No description provided for @diagnosisCheckLowHumidityTips.
  ///
  /// In en, this message translates to:
  /// **'Check if brown tips stop appearing after increasing humidity.'**
  String get diagnosisCheckLowHumidityTips;

  /// No description provided for @diagnosisCheckLowHumidityMeasure.
  ///
  /// In en, this message translates to:
  /// **'Use a hygrometer to measure the actual humidity level near the plant.'**
  String get diagnosisCheckLowHumidityMeasure;

  /// No description provided for @diagnosisCheckNutrientsGrowth.
  ///
  /// In en, this message translates to:
  /// **'After fertilizing, observe if new growth appears healthier within 2-3 weeks.'**
  String get diagnosisCheckNutrientsGrowth;

  /// No description provided for @diagnosisCheckNutrientsRoots.
  ///
  /// In en, this message translates to:
  /// **'Check if the soil is compacted or the plant is root-bound.'**
  String get diagnosisCheckNutrientsRoots;

  /// No description provided for @diagnosisCheckRootsHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy roots are firm and white or light tan. Rotten roots are brown, black, or mushy.'**
  String get diagnosisCheckRootsHealthy;

  /// No description provided for @diagnosisCheckRootsRecovery.
  ///
  /// In en, this message translates to:
  /// **'After repotting, wait a week before watering to let roots recover.'**
  String get diagnosisCheckRootsRecovery;

  /// No description provided for @diagnosisCheckPestsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Inspect the plant weekly for 3-4 weeks to ensure the pest problem is resolved.'**
  String get diagnosisCheckPestsWeekly;

  /// No description provided for @diagnosisCheckPestsNearbyPlants.
  ///
  /// In en, this message translates to:
  /// **'Check nearby plants for signs of spreading.'**
  String get diagnosisCheckPestsNearbyPlants;

  /// No description provided for @diagnosisCheckDefaultMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Try the questionnaire again with more details.'**
  String get diagnosisCheckDefaultMoreDetails;

  /// No description provided for @diagnosisCheckDefaultExpert.
  ///
  /// In en, this message translates to:
  /// **'Consult a plant care expert for species-specific advice.'**
  String get diagnosisCheckDefaultExpert;

  /// No description provided for @diagnosisFallbackActionLight.
  ///
  /// In en, this message translates to:
  /// **'Ensure your plant receives appropriate light for its species.'**
  String get diagnosisFallbackActionLight;

  /// No description provided for @diagnosisFallbackActionMoisture.
  ///
  /// In en, this message translates to:
  /// **'Check the soil moisture before watering — over- and under-watering are the most common issues.'**
  String get diagnosisFallbackActionMoisture;

  /// No description provided for @diagnosisFallbackActionInspect.
  ///
  /// In en, this message translates to:
  /// **'Inspect the leaves and stems closely for any unusual spots, pests, or texture changes.'**
  String get diagnosisFallbackActionInspect;

  /// No description provided for @diagnosisFallbackCheckMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Try the questionnaire again with more details about your plant\'s environment.'**
  String get diagnosisFallbackCheckMoreDetails;

  /// No description provided for @diagnosisFallbackCheckCommunity.
  ///
  /// In en, this message translates to:
  /// **'Consult a local plant shop or online community for species-specific advice.'**
  String get diagnosisFallbackCheckCommunity;

  /// No description provided for @plantIdentificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant ID'**
  String get plantIdentificationTitle;

  /// No description provided for @speciesLibrarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search species...'**
  String get speciesLibrarySearchHint;

  /// No description provided for @speciesLibraryEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get speciesLibraryEasy;

  /// No description provided for @speciesLibraryModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get speciesLibraryModerate;

  /// No description provided for @speciesLibraryChallenging.
  ///
  /// In en, this message translates to:
  /// **'Challenging'**
  String get speciesLibraryChallenging;

  /// No description provided for @speciesLibraryToxicOnly.
  ///
  /// In en, this message translates to:
  /// **'Toxic'**
  String get speciesLibraryToxicOnly;

  /// No description provided for @speciesLibraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No species found'**
  String get speciesLibraryEmpty;

  /// No description provided for @speciesLibraryCarePlan.
  ///
  /// In en, this message translates to:
  /// **'Care Plan'**
  String get speciesLibraryCarePlan;

  /// No description provided for @speciesLibraryWatering.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get speciesLibraryWatering;

  /// No description provided for @speciesLibraryLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get speciesLibraryLight;

  /// No description provided for @speciesLibraryHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get speciesLibraryHumidity;

  /// No description provided for @speciesLibrarySoil.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get speciesLibrarySoil;

  /// No description provided for @speciesLibraryRepotting.
  ///
  /// In en, this message translates to:
  /// **'Repotting'**
  String get speciesLibraryRepotting;

  /// No description provided for @speciesLibraryQuickFacts.
  ///
  /// In en, this message translates to:
  /// **'Quick Facts'**
  String get speciesLibraryQuickFacts;

  /// No description provided for @speciesLibraryLightNeeds.
  ///
  /// In en, this message translates to:
  /// **'Light Needs'**
  String get speciesLibraryLightNeeds;

  /// No description provided for @speciesLibraryWaterNeeds.
  ///
  /// In en, this message translates to:
  /// **'Water Needs'**
  String get speciesLibraryWaterNeeds;

  /// No description provided for @speciesLibraryHumidityPref.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get speciesLibraryHumidityPref;

  /// No description provided for @speciesLibrarySoilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get speciesLibrarySoilType;

  /// No description provided for @speciesLibraryRepottingInterval.
  ///
  /// In en, this message translates to:
  /// **'Repotting'**
  String get speciesLibraryRepottingInterval;

  /// No description provided for @speciesLibraryMonths.
  ///
  /// In en, this message translates to:
  /// **'{months} months'**
  String speciesLibraryMonths(Object months);

  /// No description provided for @speciesLibraryLightLow.
  ///
  /// In en, this message translates to:
  /// **'Low light'**
  String get speciesLibraryLightLow;

  /// No description provided for @speciesLibraryLightMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium indirect'**
  String get speciesLibraryLightMedium;

  /// No description provided for @speciesLibraryLightBright.
  ///
  /// In en, this message translates to:
  /// **'Bright indirect'**
  String get speciesLibraryLightBright;

  /// No description provided for @speciesLibraryLightDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct sun'**
  String get speciesLibraryLightDirect;

  /// No description provided for @speciesLibraryWaterLow.
  ///
  /// In en, this message translates to:
  /// **'Low (drought-tolerant)'**
  String get speciesLibraryWaterLow;

  /// No description provided for @speciesLibraryWaterModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get speciesLibraryWaterModerate;

  /// No description provided for @speciesLibraryWaterFrequent.
  ///
  /// In en, this message translates to:
  /// **'Frequent'**
  String get speciesLibraryWaterFrequent;

  /// No description provided for @speciesLibraryHumidityLow.
  ///
  /// In en, this message translates to:
  /// **'Low (30-40%)'**
  String get speciesLibraryHumidityLow;

  /// No description provided for @speciesLibraryHumidityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate (40-60%)'**
  String get speciesLibraryHumidityModerate;

  /// No description provided for @speciesLibraryHumidityHigh.
  ///
  /// In en, this message translates to:
  /// **'High (60%+)'**
  String get speciesLibraryHumidityHigh;

  /// No description provided for @speciesLibraryToxicToHumans.
  ///
  /// In en, this message translates to:
  /// **'Toxic to humans'**
  String get speciesLibraryToxicToHumans;

  /// No description provided for @speciesLibraryToxicToPets.
  ///
  /// In en, this message translates to:
  /// **'Toxic to pets'**
  String get speciesLibraryToxicToPets;

  /// No description provided for @speciesLibraryToxicityWarning.
  ///
  /// In en, this message translates to:
  /// **'Toxicity Warning'**
  String get speciesLibraryToxicityWarning;

  /// No description provided for @speciesLibraryViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Species Details'**
  String get speciesLibraryViewDetails;

  /// No description provided for @speciesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Species Library'**
  String get speciesListTitle;

  /// No description provided for @speciesListSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search species...'**
  String get speciesListSearchHint;

  /// No description provided for @speciesListEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No species found'**
  String get speciesListEmptyState;

  /// No description provided for @moreSpeciesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Species List'**
  String get moreSpeciesListTitle;

  /// No description provided for @moreSpeciesListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse all plant species'**
  String get moreSpeciesListSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
