// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get helloWorld => 'Hallo Welt!';

  @override
  String get appTitle => 'OpenPlant';

  @override
  String get todayDashboardTitle => 'Heute';

  @override
  String get page1Title => 'Seite 1';

  @override
  String get dueToday => 'Heute fällig';

  @override
  String get overdue => 'Überfällig';

  @override
  String get recentPlants => 'Aktuelle Pflanzen';

  @override
  String get noPlantsYet => 'Noch keine Pflanzen';

  @override
  String get addYourFirstPlant => 'Füge deine erste Pflanze hinzu!';

  @override
  String get quickAddPlant => 'Pflanze hinzuf.';

  @override
  String get quickIdentify => 'Bestimmen';

  @override
  String get quickDiagnose => 'Diagnose';

  @override
  String get daysOverdue => ' T überf.';

  @override
  String get taskDueToday => 'Heute fällig';

  @override
  String get taskTypeWater => 'Gießen';

  @override
  String get taskTypeFertilize => 'Düngen';

  @override
  String get taskTypeMist => 'Besprühen';

  @override
  String get taskTypePrune => 'Schneiden';

  @override
  String get taskTypeRotate => 'Drehen';

  @override
  String get taskTypeRepot => 'Umtopfen';

  @override
  String get taskTypeClean => 'Reinigen';

  @override
  String get taskTypeInspect => 'Untersuchen';

  @override
  String get page2Title => 'Seite 2';

  @override
  String get plantIdentificationTitle => 'Pflanzen-ID';

  @override
  String get page4Title => 'Seite 4';

  @override
  String get page5Title => 'Seite 5';

  @override
  String get page6Title => 'Seite 6';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get aboutTitle => 'Ueber';

  @override
  String get detailTitle => 'Details';

  @override
  String get searchLabel => 'Suchen';

  @override
  String get back => 'Zurueck';

  @override
  String get next => 'Weiter';

  @override
  String get finish => 'Fertig';

  @override
  String get onboardingIntroBody =>
      'Willkommen bei OpenPlant — deine Open-Source & datenschutzfreundliche Pflanzen-App.';

  @override
  String get onboardingIntroHint =>
      'Erfasse deine Pflanzen, setze Erinnerungen und beobachte ihr Wachstum.';

  @override
  String get onboardingPrivacyTitle => 'Dein Datenschutz ist uns wichtig';

  @override
  String get onboardingPrivacyWorksLocally => 'Lokal';

  @override
  String get onboardingPrivacyWorksLocallyBody =>
      'Alle Daten und Verarbeitungen finden auf dem Gerät statt. Keine Internetverbindung nötig.';

  @override
  String get onboardingPrivacyNoAccount => 'Kein Konto nötig';

  @override
  String get onboardingPrivacyNoAccountBody =>
      'Keine Anmeldung, kein Login, kein Konto. Einfach öffnen und nutzen.';

  @override
  String get onboardingPrivacyPhotosPrivate => 'Fotos bleiben privat';

  @override
  String get onboardingPrivacyPhotosPrivateBody =>
      'Pflanzenfotos werden auf dem Gerät verarbeitet und nie hochgeladen.';

  @override
  String get onboardingPrivacyNoThirdParties => 'Keine Drittanbieter';

  @override
  String get onboardingPrivacyNoThirdPartiesBody =>
      'Keine Analytics-SDKs, keine Werbe-Tracker, keine externen Dienste.';

  @override
  String get onboardingPrivacyBadgeLocal => 'Lokal';

  @override
  String get onboardingPrivacyBadgeNoAccount => 'Kein Konto';

  @override
  String get onboardingPrivacyBadgePhotos => 'Private Fotos';

  @override
  String get onboardingPrivacyBadgeNoTrackers => 'Keine Tracker';

  @override
  String get onboardingPreferencesTitle => 'Einstellungen';

  @override
  String get themeLabel => 'Theme';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get accessibilityLabel => 'Barrierefreiheit';

  @override
  String get useSystemTextScaling => 'System-Textskalierung verwenden';

  @override
  String get navigationLabel => 'Navigation';

  @override
  String get navigationOrderHint =>
      'Menuepunkte per Drag-and-drop neu anordnen.';

  @override
  String get navigationVisibilityLabel => 'In der Navigation anzeigen';

  @override
  String get navigationSettingsAlwaysVisibleHint =>
      'Seite 6 bleibt sichtbar, damit Einstellungen erreichbar bleiben.';

  @override
  String get walletPlaceholderBody =>
      'Platzhalter fuer eine Wallet-aehnliche Funktion.';

  @override
  String get primaryAction => 'Primaere Aktion';

  @override
  String get secondaryAction => 'Sekundaere Aktion';

  @override
  String get primaryActionSnack => 'Ersetze das durch deine echte Aktion';

  @override
  String get secondaryActionSnack => 'Noch eine Platzhalter-Aktion';

  @override
  String get menuSettingsSubtitle => 'OpenPlant-Einstellungen';

  @override
  String get menuAboutSubtitle => 'Ueber OpenPlant';

  @override
  String get aboutBody =>
      'OpenPlant ist eine Open-Source & datenschutzfreundliche Begleiter-App fuer deine Pflanzen.\n\nErfasse deine Pflanzenpflege, setze Giesserinnerungen und halte deinen Garten gesund — alles ohne dein Privatschutz zu kompromittieren.';

  @override
  String get serverFailureMessage =>
      'Serverdaten konnten nicht geladen werden.';

  @override
  String get generalFailureMessage => 'Ein Fehler ist aufgetreten.';

  @override
  String get errorMessage => 'Fehler.';

  @override
  String get unexpectedError => 'Ein unerwarteter Fehler ist aufgetreten...';

  @override
  String get invalid2FATokenFailureMessage =>
      'Dein Einmalcode (TOTP) is ungültig. Bitte versuche es erneut!';

  @override
  String get invalidLoginIDAndPasswordFailureMessage =>
      'Die Anmeldedaten sind ungültig!';

  @override
  String get welcome => 'Willkommen!';

  @override
  String get login_prompt =>
      'Bitte melde dich mit deinem Benutzernamen und deinem Passwort an.';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get login => 'Anmelden';

  @override
  String get empty_input_field => 'Bitte gib deine Anmeldedaten ein!';

  @override
  String get login_error => 'Ungültige Eingabe!';

  @override
  String get login_success => 'Erfolgreich angemeldet!';

  @override
  String get login_already => 'Du bist bereits angemeldet.';

  @override
  String get enter_totp => 'Bitte gib deinen Einmalcode (TOTP) ein.';

  @override
  String get plantIdCapturePrompt =>
      'Mache ein Foto einer Pflanze, um sie zu erkennen';

  @override
  String get plantIdCamera => 'Kamera';

  @override
  String get plantIdGallery => 'Galerie';

  @override
  String get plantIdResults => 'Ergebnisse';

  @override
  String get plantIdRetake => 'Neu aufnehmen';

  @override
  String get plantIdBestMatch => 'Bester Treffer';

  @override
  String get plantIdCouldNotIdentify => 'Pflanze konnte nicht erkannt werden';

  @override
  String get plantIdFailedToCapture => 'Fotoaufnahme fehlgeschlagen';

  @override
  String get plantIdFailedToPick => 'Auswahl fehlgeschlagen';

  @override
  String get plantIdIdentificationFailed => 'Erkennung fehlgeschlagen';

  @override
  String get plantIdTryAgain => 'Erneut versuchen';

  @override
  String get plantCollectionTitle => 'Pflanzensammlung';

  @override
  String get plantCollectionEmpty => 'Noch keine Pflanzen';

  @override
  String get plantCollectionTapToAdd =>
      'Tippe auf + um deine erste Pflanze hinzuzufuegen';

  @override
  String get addPlant => 'Pflanze hinzufuegen';

  @override
  String get editPlant => 'Pflanze bearbeiten';

  @override
  String get deletePlant => 'Pflanze loeschen';

  @override
  String get deletePlantTitle => 'Pflanze loeschen';

  @override
  String deletePlantConfirm(Object plantName) {
    return 'Moechtest du $plantName wirklich loeschen?';
  }

  @override
  String get careStatus => 'Pflegezustand';

  @override
  String get careStatusHappy => 'Gluecklich';

  @override
  String get careStatusNeedsWater => 'Braucht Wasser';

  @override
  String get careStatusNeedsFertilizer => 'Braucht Duenger';

  @override
  String get markAsWatered => 'Als gegossen markieren';

  @override
  String get markAsFertilized => 'Als geduengt markieren';

  @override
  String get lastWatered => 'Zuletzt gegossen';

  @override
  String get lastFertilized => 'Zuletzt geduengt';

  @override
  String get confirmDelete => 'Moechtest du diese Pflanze wirklich loeschen?';

  @override
  String get searchPlants => 'Pflanzen suchen';

  @override
  String get filterAll => 'Alle';

  @override
  String get room => 'Raum';

  @override
  String get species => 'Art';

  @override
  String get notes => 'Notizen';

  @override
  String get photo => 'Foto';

  @override
  String get addPhoto => 'Foto hinzufuegen';

  @override
  String get changePhoto => 'Foto aendern';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestaetigen';

  @override
  String get nameRequired => 'Name *';

  @override
  String get nameIsRequired => 'Name ist erforderlich';

  @override
  String errorSavingPlant(Object error) {
    return 'Fehler beim Speichern der Pflanze: $error';
  }

  @override
  String get never => 'Nie';

  @override
  String get speciesLibraryTitle => 'Artenbibliothek';

  @override
  String get speciesLibrarySearchHint => 'Arten suchen...';

  @override
  String get speciesLibraryEasy => 'Einfach';

  @override
  String get speciesLibraryModerate => 'Mäßig';

  @override
  String get speciesLibraryChallenging => 'Anspruchsvoll';

  @override
  String get speciesLibraryToxicOnly => 'Giftig';

  @override
  String get speciesLibraryEmpty => 'Keine Arten gefunden';

  @override
  String get speciesLibraryCarePlan => 'Pflegeplan';

  @override
  String get speciesLibraryWatering => 'Bewässerung';

  @override
  String get speciesLibraryLight => 'Licht';

  @override
  String get speciesLibraryHumidity => 'Luftfeuchtigkeit';

  @override
  String get speciesLibrarySoil => 'Erde';

  @override
  String get speciesLibraryRepotting => 'Umtopfen';

  @override
  String get speciesLibraryQuickFacts => 'Kurzinfos';

  @override
  String get speciesLibraryLightNeeds => 'Lichtbedarf';

  @override
  String get speciesLibraryWaterNeeds => 'Wasserbedarf';

  @override
  String get speciesLibraryHumidityPref => 'Luftfeuchtigkeit';

  @override
  String get speciesLibrarySoilType => 'Erdart';

  @override
  String get speciesLibraryRepottingInterval => 'Umtopfen';

  @override
  String speciesLibraryMonths(Object months) {
    return '$months Monate';
  }

  @override
  String get speciesLibraryLightLow => 'Wenig Licht';

  @override
  String get speciesLibraryLightMedium => 'Mittel indirekt';

  @override
  String get speciesLibraryLightBright => 'Hell indirekt';

  @override
  String get speciesLibraryLightDirect => 'Direkte Sonne';

  @override
  String get speciesLibraryWaterLow => 'Wenig (trockenheitsresistent)';

  @override
  String get speciesLibraryWaterModerate => 'Mäßig';

  @override
  String get speciesLibraryWaterFrequent => 'Häufig';

  @override
  String get speciesLibraryHumidityLow => 'Niedrig (30-40%)';

  @override
  String get speciesLibraryHumidityModerate => 'Mäßig (40-60%)';

  @override
  String get speciesLibraryHumidityHigh => 'Hoch (60%+)';

  @override
  String get speciesLibraryToxicToHumans => 'Giftig für Menschen';

  @override
  String get speciesLibraryToxicToPets => 'Giftig für Haustiere';

  @override
  String get speciesLibraryToxicityWarning => 'Giftigkeitswarnung';

  @override
  String get speciesLibraryViewDetails => 'Arten-Details anzeigen';

  @override
  String get careScheduleTitle => 'Pflegeplan';

  @override
  String get careScheduleOverdue => 'Überfällig';

  @override
  String get careScheduleDueToday => 'Heute fällig';

  @override
  String get careScheduleUpcoming => 'Bevorstehend';

  @override
  String get careScheduleMarkDone => 'Erledigt';

  @override
  String get careScheduleSnooze => 'Aufschieben';

  @override
  String get careScheduleSkip => 'Überspringen';

  @override
  String get careScheduleAllPlants => 'Alle Pflanzen';

  @override
  String get careScheduleAllTypes => 'Alle Typen';

  @override
  String get careScheduleEmpty =>
      'Fügen Sie Pflanzen hinzu, um Pflegeaufgaben zu sehen';
}
