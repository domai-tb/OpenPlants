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
  String get plantIdentificationTitle => 'Pflanzen-ID';

  @override
  String get moreTitle => 'Mehr';

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
  String get temperatureUnitLabel => 'Temperatureinheit';

  @override
  String get temperatureCelsius => 'Celsius';

  @override
  String get temperatureFahrenheit => 'Fahrenheit';

  @override
  String get plantNamesTitle => 'Pflanzennamen';

  @override
  String get plantNamesDescription => 'Lokalisierter Dienst für Pflanzennamen.';

  @override
  String get navigationLabel => 'Navigation';

  @override
  String get navigationOrderHint =>
      'Menuepunkte per Drag-and-drop neu anordnen.';

  @override
  String get navigationVisibilityLabel => 'In der Navigation anzeigen';

  @override
  String get navigationSettingsAlwaysVisibleHint =>
      'Mehr bleibt sichtbar, damit Einstellungen erreichbar bleiben.';

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

  @override
  String get careScheduleGoToCollection => 'Zur Pflanzensammlung';

  @override
  String careTaskCompleted(String taskType) {
    return '$taskType abgeschlossen';
  }

  @override
  String careTaskCompletedWithNote(String taskType, String note) {
    return '$taskType abgeschlossen — $note';
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
  String get journalTitle => 'Tagebuch';

  @override
  String journalPageTitle(Object plantName) {
    return '$plantName — Tagebuch';
  }

  @override
  String get journalEmpty => 'Noch keine Tagebucheinträge';

  @override
  String get journalTapToAdd =>
      'Tippe auf + um deinen ersten Eintrag hinzuzufügen';

  @override
  String get journalNewEntry => 'Neuer Tagebucheintrag';

  @override
  String get journalEditEntry => 'Eintrag bearbeiten';

  @override
  String get journalDeleteEntry => 'Eintrag löschen';

  @override
  String get journalDeleteConfirm =>
      'Möchtest du diesen Tagebucheintrag wirklich löschen?';

  @override
  String get journalEntryType => 'Eintragstyp';

  @override
  String get journalTypeText => 'Textnotiz';

  @override
  String get journalTypePhoto => 'Foto';

  @override
  String get journalTypeTask => 'Erledigte Aufgabe';

  @override
  String get journalTypeGrowth => 'Wachstumsupdate';

  @override
  String get journalTypeRepotting => 'Umtopfen';

  @override
  String get journalTypePest => 'Schädlingsbeobachtung';

  @override
  String get journalTypeDiagnosis => 'Diagnose';

  @override
  String get journalNotes => 'Notizen';

  @override
  String get journalNotesHint => 'Füge deine Beobachtungen hinzu...';

  @override
  String get journalPhoto => 'Foto';

  @override
  String get journalAddPhoto => 'Foto hinzufügen';

  @override
  String get journalTakePhoto => 'Foto aufnehmen';

  @override
  String get journalChooseFromGallery => 'Aus Galerie auswählen';

  @override
  String get growthPhotosTitle => 'Wachstumsfotos';

  @override
  String get growthPhotosAdd => 'Hinzufügen';

  @override
  String get growthPhotosEmpty => 'Füge dein erstes Wachstumsfoto hinzu';

  @override
  String get growthPhotosEmptyHint =>
      'Füge Fotos von der Pflanzendetailseite hinzu';

  @override
  String get growthPhotosNoTimeline => 'Noch keine Wachstumsfotos';

  @override
  String get growthPhotosNoTimelineHint =>
      'Füge Fotos von der Pflanzendetailseite hinzu';

  @override
  String get growthPhotoDeleteTitle => 'Foto löschen';

  @override
  String get growthPhotoDeleteConfirm =>
      'Möchtest du dieses Foto wirklich löschen?';

  @override
  String get growthPhotoNotFound => 'Foto nicht gefunden';

  @override
  String get growthPhotoCamera => 'Kamera';

  @override
  String get growthPhotoGallery => 'Galerie';

  @override
  String get careRulesTitle => 'Pflegeregeln';

  @override
  String get careRulesManage => 'Verwalten';

  @override
  String get careRulesEmpty => 'Keine benutzerdefinierten Regeln';

  @override
  String get careRulesEmptyHint =>
      'Füge eine Regel hinzu, um den berechneten Plan zu überschreiben';

  @override
  String careRulesActiveCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktive Regeln',
      one: '1 aktive Regel',
    );
    return '$_temp0';
  }

  @override
  String get careRulesDeleteTitle => 'Regel löschen';

  @override
  String careRulesDeleteConfirm(Object ruleType) {
    return 'Regel \"$ruleType\" löschen?';
  }

  @override
  String get careRulesAdd => 'Regel hinzufügen';

  @override
  String get careRulesEdit => 'Regel bearbeiten';

  @override
  String get careRulesTaskType => 'Aufgabentyp';

  @override
  String get careRulesBuiltIn => 'Integriert';

  @override
  String get careRulesCustom => 'Benutzerdefiniert';

  @override
  String get careRulesSelectType => 'Aufgabentyp auswählen';

  @override
  String get careRulesCustomType => 'Benutzerdefinierter Typ';

  @override
  String get careRulesCustomTypeHint => 'z.B. Auf Blüten prüfen';

  @override
  String get careRulesSelectTypeRequired => 'Bitte wähle einen Aufgabentyp aus';

  @override
  String get careRulesCustomTypeRequired => 'Bitte gib einen Aufgabentyp ein';

  @override
  String get careRulesInterval => 'Intervall (Tage)';

  @override
  String get careRulesIntervalHint => 'Tage zwischen den Aufgaben';

  @override
  String get careRulesIntervalRequired => 'Bitte gib ein Intervall ein';

  @override
  String get careRulesIntervalPositive => 'Bitte gib eine positive Zahl ein';

  @override
  String get careRulesEnableReminder => 'Erinnerung aktivieren';

  @override
  String get careRulesReminderTimeHint => '09:00';

  @override
  String get careRulesReminderDays => 'Erinnerungstage';

  @override
  String careRulesSaveFailed(Object error) {
    return 'Regel konnte nicht gespeichert werden: $error';
  }

  @override
  String get diagnosisTitle => 'Pflanzendiagnose';

  @override
  String get diagnosisSubtitle => 'Pflanzenprobleme diagnostizieren';

  @override
  String get diagnosisStep => 'Schritt';

  @override
  String diagnosisStepProgress(int currentStep, int totalSteps) {
    return 'Schritt $currentStep/$totalSteps';
  }

  @override
  String get diagnosisStepSymptoms => 'Symptome';

  @override
  String get diagnosisStepContext => 'Umgebung';

  @override
  String get diagnosisStepDetails => 'Details';

  @override
  String get diagnosisStepReview => 'Überprüfung';

  @override
  String get diagnosisSelectSymptoms =>
      'Welche Symptome siehst du an deiner Pflanze? (mindestens eines auswählen)';

  @override
  String get diagnosisSymptomRequired =>
      'Bitte wähle mindestens ein Symptom aus';

  @override
  String get diagnosisEnvironmentTitle =>
      'Erzähle uns von der Umgebung deiner Pflanze';

  @override
  String get diagnosisWateringFrequency => 'Gießhäufigkeit';

  @override
  String get diagnosisLightExposure => 'Lichtverhältnisse';

  @override
  String get diagnosisHumidityLevel => 'Luftfeuchtigkeit';

  @override
  String get diagnosisPotType => 'Topfart';

  @override
  String get diagnosisSoilType => 'Erdart';

  @override
  String get diagnosisAdditionalInfo => 'Zusätzliche Informationen';

  @override
  String get diagnosisPlantSpecies => 'Pflanzenart (optional)';

  @override
  String get diagnosisPlantSpeciesHint => 'z. B. Monstera deliciosa, Bogenhanf';

  @override
  String get diagnosisRecentFertilizing => 'Kürzlich gedüngt';

  @override
  String get diagnosisRecentFertilizingHint =>
      'Hast du in den letzten 3 Monaten gedüngt?';

  @override
  String get diagnosisPestSigns => 'Anzeichen für Schädlinge';

  @override
  String get diagnosisPestSignsHint =>
      'Hast du Insekten, Gespinste oder klebrige Rückstände bemerkt?';

  @override
  String get diagnosisReviewTitle => 'Überprüfe deine Antworten';

  @override
  String get diagnosisReviewSymptoms => 'Symptome';

  @override
  String get diagnosisReviewWatering => 'Gießen';

  @override
  String get diagnosisReviewLight => 'Licht';

  @override
  String get diagnosisReviewHumidity => 'Luftfeuchtigkeit';

  @override
  String get diagnosisReviewPotType => 'Topfart';

  @override
  String get diagnosisReviewSoil => 'Erde';

  @override
  String get diagnosisReviewSpecies => 'Art';

  @override
  String get diagnosisReviewRecentlyFertilized => 'Kürzlich gedüngt';

  @override
  String get diagnosisReviewPestSigns => 'Anzeichen für Schädlinge';

  @override
  String get diagnosisAnswerYes => 'Ja';

  @override
  String get diagnosisAnswerNo => 'Nein';

  @override
  String get diagnosisAnswerUnknown => 'Unbekannt';

  @override
  String get diagnosisStartDiagnosis => 'Diagnose starten';

  @override
  String get diagnosisEvaluating => 'Wird ausgewertet...';

  @override
  String get diagnosisResultsTitle => 'Diagnoseergebnisse';

  @override
  String get diagnosisNoClearMatch => 'Keine eindeutige Übereinstimmung';

  @override
  String get diagnosisNoClearMatchDesc =>
      'Anhand der bereitgestellten Informationen konnten wir keine bestimmte Ursache ermitteln. Das bedeutet nicht, dass deine Pflanze gesund ist — möglicherweise benötigt sie aus einem Grund Aufmerksamkeit, den dieser Fragebogen nicht abdeckt.';

  @override
  String get diagnosisGeneralSuggestions => 'Allgemeine Empfehlungen:';

  @override
  String get diagnosisSuggestionAppropriateLight =>
      'Stelle sicher, dass deine Pflanze für ihre Art geeignete Lichtverhältnisse erhält.';

  @override
  String get diagnosisSuggestionCheckSoilMoisture =>
      'Prüfe die Bodenfeuchtigkeit vor dem Gießen — zu viel und zu wenig Wasser sind die häufigsten Probleme.';

  @override
  String get diagnosisSuggestionInspectPlant =>
      'Untersuche Blätter und Stängel sorgfältig auf ungewöhnliche Flecken, Schädlinge oder Veränderungen der Oberfläche.';

  @override
  String get diagnosisSuggestionConsiderRepotting =>
      'Ziehe ein Umtopfen in Betracht, wenn die Pflanze seit über einem Jahr in derselben Erde steht.';

  @override
  String get diagnosisTryAgain => 'Mit weiteren Details erneut versuchen';

  @override
  String get diagnosisStartOver => 'Neu beginnen';

  @override
  String get diagnosisEmptyInputTitle => 'Keine Symptome ausgewählt';

  @override
  String get diagnosisEmptyInputDesc =>
      'Wähle mindestens ein Symptom aus, bevor du eine Diagnose startest.';

  @override
  String get diagnosisDisclaimer =>
      'Dies ist eine Empfehlung auf Grundlage deiner Angaben und keine endgültige Diagnose. Wende dich bei ernsthaften Problemen an eine Fachperson für Pflanzenpflege.';

  @override
  String get diagnosisRecommendedActions => 'Empfohlene Maßnahmen';

  @override
  String get diagnosisFollowUpChecks => 'Weitere Prüfungen';

  @override
  String get diagnosisCauseOverwatering => 'Überwässerung';

  @override
  String get diagnosisCauseUnderwatering => 'Wassermangel';

  @override
  String get diagnosisCauseLowLight => 'Zu wenig Licht';

  @override
  String get diagnosisCauseSunburn => 'Sonnenbrand / Lichtschaden';

  @override
  String get diagnosisCauseLowHumidity => 'Niedrige Luftfeuchtigkeit';

  @override
  String get diagnosisCauseNutrientProblem => 'Nährstoffmangel';

  @override
  String get diagnosisCauseRootIssue => 'Wurzelprobleme';

  @override
  String get diagnosisCausePests => 'Schädlingsbefall';

  @override
  String get diagnosisCauseNoClearMatch => 'Keine eindeutige Übereinstimmung';

  @override
  String get diagnosisConfidenceHigh => 'Hoch';

  @override
  String get diagnosisConfidenceMedium => 'Mittel';

  @override
  String get diagnosisConfidenceLow => 'Niedrig';

  @override
  String get diagnosisWateringFrequent => 'Häufig';

  @override
  String get diagnosisWateringNormal => 'Normal';

  @override
  String get diagnosisWateringInfrequent => 'Selten';

  @override
  String get diagnosisLightLow => 'Wenig Licht';

  @override
  String get diagnosisLightIndirect => 'Indirektes Licht';

  @override
  String get diagnosisLightDirect => 'Direkte Sonne';

  @override
  String get diagnosisHumidityLow => 'Niedrig';

  @override
  String get diagnosisHumidityModerate => 'Mittel';

  @override
  String get diagnosisHumidityHigh => 'Hoch';

  @override
  String get diagnosisPotStandard => 'Standardtopf';

  @override
  String get diagnosisPotSelfWatering => 'Selbstbewässerungstopf';

  @override
  String get diagnosisPotNoDrainage => 'Ohne Abfluss';

  @override
  String get diagnosisSoilStandard => 'Standard-Blumenerde';

  @override
  String get diagnosisSoilSucculent => 'Sukkulentenerde';

  @override
  String get diagnosisSoilOrchid => 'Orchideenerde';

  @override
  String get diagnosisSoilCactus => 'Kakteenerde';

  @override
  String get diagnosisSymptomYellowingLeaves => 'Vergilbende Blätter';

  @override
  String get diagnosisSymptomDroopingWilt => 'Hängende / welkende Blätter';

  @override
  String get diagnosisSymptomBrownTips => 'Braune Spitzen / trockene Ränder';

  @override
  String get diagnosisSymptomBrownPatches =>
      'Braune Flecken / verbrannte Stellen';

  @override
  String get diagnosisSymptomPaleLeaves => 'Blasse Blätter';

  @override
  String get diagnosisSymptomLeggyGrowth => 'Vergeiltes Wachstum';

  @override
  String get diagnosisSymptomVisibleInsects => 'Sichtbare Insekten / Gespinste';

  @override
  String get diagnosisSymptomStickyResidue => 'Klebrige Rückstände';

  @override
  String get diagnosisSymptomMoldOnSoil => 'Schimmel auf der Erde';

  @override
  String get diagnosisSymptomFoulSmell => 'Fauliger Geruch';

  @override
  String get diagnosisSymptomStuntedGrowth => 'Gehemmtes Wachstum';

  @override
  String get diagnosisSymptomLeafCurling => 'Eingerollte Blätter';

  @override
  String get diagnosisSymptomLeafDrop => 'Blattfall';

  @override
  String get diagnosisDiagnoseThisPlant => 'Diese Pflanze diagnostizieren';

  @override
  String diagnosisEvidenceReportedSymptoms(String symptoms) {
    return 'Du hast $symptoms angegeben.';
  }

  @override
  String get diagnosisEvidenceFrequentWateringTooWet =>
      'Du gießt häufig, wodurch die Erde zu nass bleiben kann.';

  @override
  String get diagnosisEvidenceNoDrainage =>
      'Dein Topf hat keine Abflusslöcher, sodass überschüssiges Wasser nicht ablaufen kann.';

  @override
  String get diagnosisEvidenceOverwateringSigns =>
      'Dies sind häufige Anzeichen für Überwässerung.';

  @override
  String get diagnosisEvidenceInfrequentWateringTooDry =>
      'Du gießt selten, wodurch die Erde zu trocken werden kann.';

  @override
  String get diagnosisEvidenceUnderwateringSigns =>
      'Dies sind häufige Anzeichen für Wassermangel.';

  @override
  String get diagnosisEvidenceLowLightExposure =>
      'Deine Pflanze erhält wenig Licht.';

  @override
  String get diagnosisEvidenceLowLightSigns =>
      'Vergeiltes Wachstum und blasse Blätter sind typische Anzeichen für Lichtmangel.';

  @override
  String get diagnosisEvidenceDirectSunlight =>
      'Deine Pflanze erhält direktes Sonnenlicht.';

  @override
  String get diagnosisEvidenceSunburnSigns =>
      'Braune, verbrannte Flecken können auf Sonnenschäden hinweisen.';

  @override
  String get diagnosisEvidenceLowHumidityEnvironment =>
      'Die Luftfeuchtigkeit in der Umgebung ist niedrig.';

  @override
  String get diagnosisEvidenceLowHumiditySigns =>
      'Braune Blattspitzen und eingerollte Blätter treten häufig bei trockener Raumluft auf.';

  @override
  String get diagnosisEvidenceNotFertilizedRecently =>
      'Du hast in letzter Zeit nicht gedüngt.';

  @override
  String get diagnosisEvidenceNutrientSigns =>
      'Blasses oder vergilbendes Wachstum kann auf einen Nährstoffmangel hinweisen.';

  @override
  String get diagnosisEvidenceFrequentWateringRootProblems =>
      'Häufiges Gießen kann zu Wurzelproblemen führen.';

  @override
  String get diagnosisEvidenceRootProblemSigns =>
      'Welken trotz feuchter Erde und fauliger Geruch sind Anzeichen für Wurzelprobleme.';

  @override
  String get diagnosisEvidencePestSignsObserved =>
      'Du hast Anzeichen für Schädlinge bemerkt.';

  @override
  String get diagnosisEvidencePestInfestationSigns =>
      'Sichtbare Insekten, klebrige Rückstände und Blattschäden können auf Schädlingsbefall hinweisen.';

  @override
  String get diagnosisEvidenceDefault =>
      'Auf Grundlage deiner Antworten wurde diese Ursache als Möglichkeit erkannt.';

  @override
  String get diagnosisFallbackEvidence =>
      'Anhand der bereitgestellten Informationen stach keine einzelne Ursache hervor. Das Problem könnte durch Faktoren verursacht werden, die der Fragebogen nicht abdeckt.';

  @override
  String get diagnosisActionOverwateringDrySoil =>
      'Lass die oberen 5–8 cm der Erde trocknen, bevor du erneut gießt.';

  @override
  String get diagnosisActionOverwateringDrainage =>
      'Prüfe, ob der Topf Abflusslöcher hat, und leere den Untersetzer nach dem Gießen.';

  @override
  String get diagnosisActionOverwateringTrimRoots =>
      'Nimm die Pflanze bei Verdacht auf Wurzelfäule heraus und entferne braune, weiche Wurzeln.';

  @override
  String get diagnosisActionUnderwateringWaterThoroughly =>
      'Gieße die Pflanze gründlich, bis Wasser unten aus dem Topf läuft.';

  @override
  String get diagnosisActionUnderwateringSchedule =>
      'Lege einen regelmäßigen, an den Bedarf der Pflanze angepassten Gießplan fest.';

  @override
  String get diagnosisActionUnderwateringBottomWater =>
      'Ziehe eine Bewässerung von unten in Betracht, um tieferes Wurzelwachstum zu fördern.';

  @override
  String get diagnosisActionLowLightMovePlant =>
      'Stelle die Pflanze näher an ein Fenster oder an einen helleren Standort.';

  @override
  String get diagnosisActionLowLightGrowLight =>
      'Erwäge eine Pflanzenlampe, wenn nur wenig natürliches Licht vorhanden ist.';

  @override
  String get diagnosisActionLowLightRotate =>
      'Drehe die Pflanze regelmäßig, damit alle Seiten Licht erhalten.';

  @override
  String get diagnosisActionSunburnIndirectLight =>
      'Stelle die Pflanze an einen Ort mit indirektem oder gefiltertem Licht.';

  @override
  String get diagnosisActionSunburnCurtain =>
      'Verwende einen lichtdurchlässigen Vorhang, um direktes Sonnenlicht abzumildern.';

  @override
  String get diagnosisActionSunburnRemoveLeaves =>
      'Entferne stark verbrannte Blätter, sobald sich die Pflanze angepasst hat.';

  @override
  String get diagnosisActionLowHumidityMist =>
      'Besprühe die Pflanze regelmäßig oder stelle einen Luftbefeuchter in die Nähe.';

  @override
  String get diagnosisActionLowHumidityGroupPlants =>
      'Gruppiere Pflanzen mit hohem Feuchtigkeitsbedarf, um ein Mikroklima zu schaffen.';

  @override
  String get diagnosisActionLowHumidityPebbleTray =>
      'Stelle den Topf auf eine mit Wasser gefüllte Kieselschale; der Topf darf nicht im Wasser stehen.';

  @override
  String get diagnosisActionNutrientsFertilize =>
      'Verwende während der Wachstumszeit einen ausgewogenen Flüssigdünger in halber Konzentration.';

  @override
  String get diagnosisActionNutrientsRepot =>
      'Prüfe, ob die Pflanze stark durchwurzelt ist und in frische Erde umgetopft werden muss.';

  @override
  String get diagnosisActionNutrientsCheckPh =>
      'Stelle sicher, dass der pH-Wert der Erde für die Pflanzenart geeignet ist.';

  @override
  String get diagnosisActionRootsInspect =>
      'Nimm die Pflanze aus dem Topf und untersuche die Wurzeln.';

  @override
  String get diagnosisActionRootsTrim =>
      'Entferne braune, weiche oder übel riechende Wurzeln mit einer sterilen Schere.';

  @override
  String get diagnosisActionRootsRepot =>
      'Topfe die Pflanze in frische, gut durchlässige Erde um und gieße seltener.';

  @override
  String get diagnosisActionPestsIsolate =>
      'Isoliere die betroffene Pflanze, damit sich die Schädlinge nicht ausbreiten.';

  @override
  String get diagnosisActionPestsTreat =>
      'Wische die Blätter mit einem feuchten Tuch ab oder besprühe sie mit einer Neemöllösung.';

  @override
  String get diagnosisActionPestsInspect =>
      'Prüfe Blattunterseiten und Blattachseln, wo sich Schädlinge häufig verstecken.';

  @override
  String get diagnosisActionDefaultCare =>
      'Stelle sicher, dass deine Pflanze für ihre Art geeignete Licht- und Wassermengen erhält.';

  @override
  String get diagnosisActionDefaultMoisture =>
      'Prüfe die Bodenfeuchtigkeit vor dem Gießen.';

  @override
  String get diagnosisCheckOverwateringRoots =>
      'Prüfe die Wurzeln: Gesunde Wurzeln sind fest und weiß, faule Wurzeln braun und weich.';

  @override
  String get diagnosisCheckOverwateringMoisture =>
      'Beobachte die Bodenfeuchtigkeit — die Erde sollte zwischen dem Gießen trocknen.';

  @override
  String get diagnosisCheckUnderwateringRootBall =>
      'Prüfe den Wurzelballen: Hat er sich vom Topfrand gelöst, ist die Erde zu trocken.';

  @override
  String get diagnosisCheckUnderwateringSoil =>
      'Fühle etwa 5 cm tief in die Erde — sie sollte leicht feucht und nicht völlig trocken sein.';

  @override
  String get diagnosisCheckLowLightGrowth =>
      'Beobachte, ob neues Wachstum nach dem Umstellen an einen helleren Ort weiterhin vergeilt.';

  @override
  String get diagnosisCheckLowLightHours =>
      'Notiere, wie viele Stunden Licht die Pflanze täglich erhält.';

  @override
  String get diagnosisCheckSunburnPatches =>
      'Prüfe, ob sich die braunen Flecken nach dem Umstellen nicht weiter ausbreiten.';

  @override
  String get diagnosisCheckSunburnNewLeaves =>
      'Beobachte neue Blätter — sie sollten ohne braune Flecken wachsen.';

  @override
  String get diagnosisCheckLowHumidityTips =>
      'Prüfe, ob nach dem Erhöhen der Luftfeuchtigkeit keine neuen braunen Spitzen entstehen.';

  @override
  String get diagnosisCheckLowHumidityMeasure =>
      'Miss die tatsächliche Luftfeuchtigkeit in Pflanzennähe mit einem Hygrometer.';

  @override
  String get diagnosisCheckNutrientsGrowth =>
      'Beobachte nach dem Düngen, ob neues Wachstum innerhalb von 2–3 Wochen gesünder aussieht.';

  @override
  String get diagnosisCheckNutrientsRoots =>
      'Prüfe, ob die Erde verdichtet oder die Pflanze stark durchwurzelt ist.';

  @override
  String get diagnosisCheckRootsHealthy =>
      'Gesunde Wurzeln sind fest und weiß oder hellbraun. Faule Wurzeln sind braun, schwarz oder weich.';

  @override
  String get diagnosisCheckRootsRecovery =>
      'Warte nach dem Umtopfen eine Woche mit dem Gießen, damit sich die Wurzeln erholen können.';

  @override
  String get diagnosisCheckPestsWeekly =>
      'Untersuche die Pflanze 3–4 Wochen lang wöchentlich, um sicherzustellen, dass der Befall beseitigt ist.';

  @override
  String get diagnosisCheckPestsNearbyPlants =>
      'Prüfe Pflanzen in der Nähe auf Anzeichen einer Ausbreitung.';

  @override
  String get diagnosisCheckDefaultMoreDetails =>
      'Fülle den Fragebogen erneut mit weiteren Details aus.';

  @override
  String get diagnosisCheckDefaultExpert =>
      'Wende dich für artspezifische Beratung an eine Fachperson für Pflanzenpflege.';

  @override
  String get diagnosisFallbackActionLight =>
      'Stelle sicher, dass deine Pflanze für ihre Art geeignete Lichtverhältnisse erhält.';

  @override
  String get diagnosisFallbackActionMoisture =>
      'Prüfe die Bodenfeuchtigkeit vor dem Gießen — zu viel und zu wenig Wasser sind die häufigsten Probleme.';

  @override
  String get diagnosisFallbackActionInspect =>
      'Untersuche Blätter und Stängel sorgfältig auf ungewöhnliche Flecken, Schädlinge oder Veränderungen der Oberfläche.';

  @override
  String get diagnosisFallbackCheckMoreDetails =>
      'Fülle den Fragebogen erneut mit weiteren Angaben zur Umgebung deiner Pflanze aus.';

  @override
  String get diagnosisFallbackCheckCommunity =>
      'Wende dich für artspezifische Beratung an ein Pflanzengeschäft vor Ort oder eine Online-Community.';
}
