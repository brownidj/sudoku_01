// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get actionUndo => 'Rückgängig';

  @override
  String get actionClear => 'Löschen';

  @override
  String get actionNotes => 'Notizen';

  @override
  String get actionNewShort => 'Neu';

  @override
  String get actionNewGame => 'Neues\nSpiel';

  @override
  String get actionPlay => 'Spielen';

  @override
  String get actionResume => 'Fortsetzen';

  @override
  String get actionStartNewGame => 'Neues Spiel';

  @override
  String get actionPleaseWait => 'Bitte warten...';

  @override
  String get tooltipNewGame => 'Tippe hier für ein neues Spiel.';

  @override
  String get tooltipUndo =>
      'Mit Rückgängig nimmst du deine letzten Eingaben zurück. Das hilft auch, wenn dir die Korrekturen ausgehen.';

  @override
  String get tooltipClear =>
      'Löscht die aktuell ausgewählte Zelle. Du kannst nur Zellen löschen, die du selbst ausgefüllt hast.';

  @override
  String get tooltipNotes =>
      'Mit Notizen kannst du mögliche Felder markieren, wenn du dir noch nicht sicher bist. Die Hinweise werden grün angezeigt. Tippe nochmal auf Notizen, um sie auszuschalten.';

  @override
  String get tooltipDifficulty =>
      'Wähle den Schwierigkeitsgrad, der sich für dich gut anfühlt.';

  @override
  String candidateLongPressToast(int digit) {
    return 'Kandidat $digit';
  }

  @override
  String labelCorrections(int count) {
    return 'Korrekturen: $count';
  }

  @override
  String labelElapsedTime(String time) {
    return 'Zeit: $time';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'Für dieses Rätsel hast du $limit automatische Korrekturen. Wenn dich ein früherer Zug blockiert, hilft dir eine Korrektur weiter. Sind keine mehr übrig, nutze Rückgängig.';
  }

  @override
  String get difficultyEasy => 'LEICHT';

  @override
  String get difficultyMedium => 'ETWAS SCHWIERIGER';

  @override
  String get difficultyHard => 'VIEL SCHWIERIGER';

  @override
  String get difficultyVeryHard => 'FAST UNMÖGLICH';

  @override
  String get helpTitle => 'Hilfe';

  @override
  String get helpDismiss => 'OK';

  @override
  String get helpBody =>
      'Auf dem Spielbildschirm gibt es ***ein paar Dinge***, die nicht sofort selbsterklärend sind.\n\nHalte den Finger **ein paar Sekunden** darauf, dann bekommst du eine kurze Erklärung.\n\n**Korrekturen** zeigt dir zum Beispiel, wie viele automatische Korrekturen du noch hast. Wenn dich ein früherer Zug in eine Sackgasse gebracht hat, bringt dich eine Korrektur wieder weiter.\n\nMit **Rückgängig** nimmst du deine letzten Eingaben Schritt für Schritt zurück. Das ist auch praktisch, wenn deine Korrekturen aufgebraucht sind.';

  @override
  String get startInstruction =>
      'Wähle zum Start ein Feld aus, in das du ein Symbol setzen möchtest.\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies präsentieren';

  @override
  String get launchTitle => 'SuDoKu Fresh';

  @override
  String get appBrandIos => 'SuDoKu Playtime';

  @override
  String get appBrandAndroid => 'SuDoKu Fresh';

  @override
  String get launchSubtitle => 'Entspannende Sudoku-Bilderrätsel';

  @override
  String get launchErrorOpenGame =>
      'Spiel konnte nicht geöffnet werden. Bitte versuche es erneut.';

  @override
  String get launchHintsTitle => 'Hinweise';

  @override
  String get tooltipPrevHint => 'Vorheriger Hinweis';

  @override
  String get tooltipNextHint => 'Nächster Hinweis';

  @override
  String get launchHint1 =>
      'Mit Notizen kannst du dir mögliche Optionen merken. Tippe nochmal auf Notizen, um sie auszuschalten.';

  @override
  String get launchHint2 =>
      'Mit langem Drücken, also etwa zwei Sekunden, erfährst du, was manche Dinge machen. Probier es mal auf einer Kachel aus.';

  @override
  String get launchHint3 =>
      'Wenn durch deine Auswahl zwei oder mehr pinke Felder auftauchen, ist dir vorher ein Fehler passiert. Du kannst automatisch korrigieren.';

  @override
  String get launchHint4 =>
      'Wenn du den Schwierigkeitsgrad während eines Spiels änderst, startet ein neues Spiel.';

  @override
  String get launchHint5 =>
      'Tippe auf Hilfe, wenn du wissen willst, wie etwas funktioniert.';

  @override
  String get launchHint6 =>
      'Mit ☰ oben rechts öffnest du das Menü mit weiteren Einstellungen.';

  @override
  String get launchHint7 =>
      'Wenn dich die Töne stören oder du ruhig spielen möchtest, kannst du Audio im Menü (☰) ausschalten.';

  @override
  String get launchHint8 =>
      'Tippe einmal auf das Musik-Symbol, um die Hintergrundmusik auszuschalten, oder zweimal schnell hintereinander, um sie wieder einzuschalten.';

  @override
  String get launchHint9 => 'Der Würfel startet ein neues Spiel.';

  @override
  String get launchHint10 =>
      'Wenn du die Vollversion gekauft hast und sie nicht auftaucht, nutze im Menü „Käufe wiederherstellen“.';

  @override
  String get victoryMessage1 => 'Gut gemacht! Nochmal spielen!';

  @override
  String get victoryMessage2 => 'Klasse! Nochmal spielen!';

  @override
  String get victoryMessage3 => 'Perfekt gelöst! Nochmal spielen!';

  @override
  String get victoryMessage4 => 'Stark gemacht! Nochmal spielen!';

  @override
  String get victoryMessage5 => 'Super gelöst! Nochmal spielen!';

  @override
  String get victoryMessage6 => 'Sehr schön! Nochmal spielen!';

  @override
  String get victoryMessage7 => 'Du hast es geschafft! Nochmal spielen!';

  @override
  String get victoryMessage8 => 'Richtig gut! Nochmal spielen!';

  @override
  String get victoryMessage9 => 'Darauf kannst du stolz sein! Nochmal spielen!';

  @override
  String get victoryMessage10 => 'Weiter so! Nochmal spielen!';

  @override
  String get victoryMessage11 => 'Fantastisch! Nochmal spielen!';

  @override
  String get victoryMessage12 => 'Echt stark! Nochmal spielen!';

  @override
  String get victoryMessage13 => 'Perfekt gelöst! Nochmal spielen!';

  @override
  String get victoryMessage14 => 'Sauber gelöst! Nochmal spielen!';

  @override
  String get victoryMessage15 => 'Clever gelöst! Nochmal spielen!';

  @override
  String get victoryMessage16 => 'Geschafft! Nochmal spielen!';

  @override
  String get victoryMessage17 => 'Top! Nochmal spielen!';

  @override
  String get victoryMessage18 => 'Meisterhaft gelöst! Nochmal spielen!';

  @override
  String get victoryMessage19 => 'Richtig stark! Nochmal spielen!';

  @override
  String get victoryMessage20 => 'Hervorragend! Nochmal spielen!';

  @override
  String get dialogActionCancel => 'Abbrechen';

  @override
  String get dialogActionStartNewGame => 'Neues Spiel starten';

  @override
  String get dialogActionUseCorrection => 'Korrektur verwenden';

  @override
  String get dialogUnlockSettingsTitle => 'Einstellungen entsperren?';

  @override
  String get dialogUnlockSettingsMessage =>
      'Wenn du den Schwierigkeitsgrad entsperrst, startet ein neues Spiel und dieses Brett wird zurückgesetzt. Weiter?';

  @override
  String get dialogStartNewGameTitle => 'Neues Spiel starten?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return 'Schwierigkeitsgrad auf $difficultyLabel ändern und ein neues Spiel starten?';
  }

  @override
  String get dialogStartNewGameResetBoard =>
      'Neues Spiel starten und das aktuelle Brett zurücksetzen?';

  @override
  String get labelLockedSettingsTitle => 'Bretteinstellungen gesperrt';

  @override
  String get labelLockedSettingsMessage =>
      'Der Schwierigkeitsgrad ist während eines Spiels gesperrt. Zum Entsperren doppelt auf das Schloss tippen oder ein neues Spiel starten.';

  @override
  String get progressSheetTitle => 'Dein Fortschritt';

  @override
  String progressSheetBody(int completedPuzzles) {
    return 'Abgeschlossene Rätsel: $completedPuzzles\nGespielte Tage: kommt bald\nSerie: kommt bald';
  }

  @override
  String progressCompletedPuzzles(int count) {
    return 'Abgeschlossene Rätsel: $count';
  }

  @override
  String progressDaysPlayed(int count) {
    return 'Gespielte Tage: $count';
  }

  @override
  String progressStreak(int count) {
    return 'Serie: $count';
  }

  @override
  String get progressBestSolveTimesTitle => 'Beste Lösungszeiten:';

  @override
  String progressBestSolveTimeRow(String difficulty, String time) {
    return '• $difficulty: $time';
  }

  @override
  String get progressBestSolveTimeMissing => '--';

  @override
  String get progressResetAction => 'Zurücksetzen';

  @override
  String get progressResetDialogTitle => 'Fortschritt zurücksetzen?';

  @override
  String get progressResetDialogMessage =>
      'Dein bisheriger Fortschritt geht dabei verloren.';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile =>
      'Für dieses Feld ist noch kein Audio verfügbar.';

  @override
  String get correctionPromptMessage =>
      'Dieses Brett ist wegen eines früheren Zugs unlösbar. 1 Korrektur verwenden?';

  @override
  String get premiumFeatureIntroGeneric =>
      'Mit der Vollversion bekommst du das komplette Sudoku-Erlebnis per einmaligem Kauf.';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel gibt es in der Vollversion.';
  }

  @override
  String get premiumSheetTitle => 'Vollversion freischalten';

  @override
  String get premiumIncludesTitle => 'Die Vollversion enthält:';

  @override
  String get premiumIncludesHardDifficulties =>
      '• Schwere und nahezu unmögliche Schwierigkeitsgrade';

  @override
  String get premiumIncludesProgress =>
      '• Fortschrittsverfolgung und persönliche Bestwerte';

  @override
  String get premiumIncludesThemesSounds =>
      '• Zusätzliche Designs, Sounds und Animationen';

  @override
  String get premiumOneTimePurchase => 'Einmaliger Kauf. Kein Abo.';

  @override
  String get premiumActionNotNow => 'Jetzt nicht';

  @override
  String get premiumActionUnlock => 'Vollversion freischalten';

  @override
  String get purchaseStartedMessage =>
      'Bestätige den Kauf im App-Store-Dialog, um die Vollversion freizuschalten.';

  @override
  String get restoreStartedMessage =>
      'Wiederherstellung gestartet. Deine Käufe sollten gleich wieder da sein.';

  @override
  String get redeemCodeStartedMessage =>
      'Gib deinen Code im App-Store-Fenster ein, um die Vollversion freizuschalten.';

  @override
  String get billingUnavailable =>
      'Käufe sind auf diesem Gerät gerade nicht verfügbar.';

  @override
  String get billingProductNotConfigured =>
      'Die Vollversion ist gerade noch nicht verfügbar. Bitte versuche es später nochmal.';

  @override
  String get billingProductUnavailable =>
      'Die Details zur Vollversion konnten nicht geladen werden. Bitte versuche es nochmal.';

  @override
  String get billingFailed =>
      'Das hat nicht funktioniert. Bitte versuche es erneut.';

  @override
  String get drawerTitle => 'SuDoKu Fresh';

  @override
  String get drawerPuzzleStyleTitle => 'Puzzle-Stil';

  @override
  String get styleModern => 'Modern';

  @override
  String get styleClassic => 'Klassisch';

  @override
  String get styleHighContrast => 'Hoher Kontrast';

  @override
  String get drawerAudioTitle => 'Audio';

  @override
  String get labelOn => 'An';

  @override
  String get labelOff => 'Aus';

  @override
  String get drawerBackgroundMusicTitle => 'Hintergrundmusik';

  @override
  String get drawerBackgroundMusicSubtitle =>
      'Musik für entspannte Sudoku-Runden';

  @override
  String get musicControlsTooltip =>
      'Hier kannst du die Hintergrundmusik steuern. Einmal tippen schaltet sie aus, zweimal schnell hintereinander wieder ein. Mit < und > wechselst du zum vorherigen oder nächsten Stück.';

  @override
  String get drawerVolumeTitle => 'Lautstärke';

  @override
  String get drawerVersionTitle => 'Version';

  @override
  String get drawerVersionFull => 'Voll';

  @override
  String get drawerVersionFree => 'Gratis';

  @override
  String get drawerPremiumProgressTitle => 'Fortschritts-Tracker 🔒';

  @override
  String get drawerPremiumProgressSubtitle =>
      'Verfolge gelöste Rätsel und Meilensteine.';

  @override
  String get drawerPremiumThemesTitle => 'Zusätzliche Designs 🔒';

  @override
  String get drawerPremiumThemesSubtitle =>
      'Schalte weitere visuelle Stile frei.';

  @override
  String get drawerPremiumSoundsTitle => 'Sounds & Animationen 🔒';

  @override
  String get drawerPremiumSoundsSubtitle =>
      'Schalte zusätzliche Sounds und Animationen frei.';

  @override
  String get drawerUnlockFullVersion => 'Vollversion freischalten';

  @override
  String get drawerRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get drawerRedeemCode => 'Code einlösen';

  @override
  String get drawerAboutChip => 'Info';

  @override
  String get drawerAboutTitle => 'Info';

  @override
  String drawerAboutMessage(String versionLabel) {
    return 'Version: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy\n\nKeiner aus dem Dev Team ist Künstler oder Musiker. Wir geben offen zu, dass wir KI genutzt haben, um diese Inhalte zu erstellen. Wir sind alle uralt; wir schätzen die Möglichkeit, unsere Kreativität auszudrücken, so weit sie eben reicht!';
  }

  @override
  String get drawerDebugTitle => 'Debug';

  @override
  String get drawerDebugLoadCorrectionTitle => 'Korrekturszenario laden';

  @override
  String get drawerDebugLoadCorrectionSubtitle =>
      'Temporäre Steuerung für Tests mit unterstützter Wiederherstellung.';

  @override
  String get drawerDebugLoadExhaustedTitle => 'Szenario ohne Korrekturen laden';

  @override
  String get drawerDebugLoadExhaustedSubtitle =>
      'Temporäre Steuerung für Tests mit nur Rückgängig.';

  @override
  String get drawerDebugResetEntitlementTitle =>
      'Vollversion zurücksetzen (Debug)';

  @override
  String get drawerDebugResetEntitlementSubtitle =>
      'Setzt die lokale Berechtigung auf Gratis für erneute Kauf-Tests.';

  @override
  String get contentModeAnimals => 'Tiere (einfach)';

  @override
  String get contentModeInstruments => 'Instrumente (knifflig)';

  @override
  String get contentModeButterflies => 'Schmetterlinge (hübsch)';

  @override
  String get contentModeShells => 'Muscheln (neu)';

  @override
  String get contentModeOpera => 'Oper (ungewöhnlich)';

  @override
  String get contentModeNumbers => 'Zahlen (klassisch)';

  @override
  String get appBarMenuTooltip =>
      'Drücke hier, um die Seitenleiste zu öffnen. Dort kannst du Tiere und Stil ändern.';

  @override
  String get topControlsProgress => 'Wie läuft’s?';

  @override
  String get topControlsHelp => 'Hilfe';

  @override
  String get infoSheetDismiss => 'Verstanden';

  @override
  String get drawerLanguageTitle => 'Sprache';

  @override
  String get drawerLanguageReset => 'Auf Systemsprache zurücksetzen';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageJapanese => 'Japanisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String get languagePortuguese => 'Portugiesisch';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String statusUnknownDifficulty(String difficulty) {
    return 'Unbekannter Schwierigkeitsgrad: $difficulty';
  }

  @override
  String get statusDifficultyChangeBlocked =>
      'Beende das Spiel oder starte ein neues, bevor du den Schwierigkeitsgrad änderst';

  @override
  String get statusDifficultyPremiumOnly =>
      'Dieser Schwierigkeitsgrad ist in der Vollversion verfügbar.';

  @override
  String get statusPuzzleModeUnique => 'Puzzle-Modus: eindeutig';

  @override
  String get statusSessionRestored => 'Sitzung wiederhergestellt';

  @override
  String get statusCellSelected => 'Feld ausgewählt';

  @override
  String get statusEntitlementRefreshed => 'Berechtigung aktualisiert';

  @override
  String get statusEntitlementUpdated => 'Berechtigung geändert';

  @override
  String get statusCheckComplete => 'Prüfung abgeschlossen';

  @override
  String get statusSolution => 'Lösung';

  @override
  String get statusSolved => 'Gelöst.';

  @override
  String get statusContradictionUseUndo =>
      'Widerspruch erkannt. Nutze Rückgängig zur Wiederherstellung.';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'Neues Spiel ($difficulty): $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count Feld(er) korrigiert.';
  }
}
