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

  /// No description provided for @page1Title.
  ///
  /// In en, this message translates to:
  /// **'Page 1'**
  String get page1Title;

  /// No description provided for @page2Title.
  ///
  /// In en, this message translates to:
  /// **'Page 2'**
  String get page2Title;

  /// No description provided for @plantIdentificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant ID'**
  String get plantIdentificationTitle;

  /// No description provided for @page4Title.
  ///
  /// In en, this message translates to:
  /// **'Page 4'**
  String get page4Title;

  /// No description provided for @page5Title.
  ///
  /// In en, this message translates to:
  /// **'Page 5'**
  String get page5Title;

  /// No description provided for @page6Title.
  ///
  /// In en, this message translates to:
  /// **'Page 6'**
  String get page6Title;

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
  /// **'Page 6 stays visible so settings remain reachable.'**
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
