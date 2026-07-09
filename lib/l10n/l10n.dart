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

  /// No description provided for @plantIdentificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant ID'**
  String get plantIdentificationTitle;

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

  /// No description provided for @navigationLabel.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigationLabel;

  /// No description provided for @navigationOrderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder menu items.'**
  String get navigationOrderHint;

  /// No description provided for @navigationVisibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Show in navigation'**
  String get navigationVisibilityLabel;

  /// No description provided for @navigationSettingsAlwaysVisibleHint.
  ///
  /// In en, this message translates to:
  /// **'More stays visible so settings remain reachable.'**
  String get navigationSettingsAlwaysVisibleHint;

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

  /// No description provided for @speciesLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Species Library'**
  String get speciesLibraryTitle;

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

  /// No description provided for @careScheduleGoToCollection.
  ///
  /// In en, this message translates to:
  /// **'Go to Plant Collection'**
  String get careScheduleGoToCollection;

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
