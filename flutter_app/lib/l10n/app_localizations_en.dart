// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionNotes => 'Notes';

  @override
  String get actionNewGame => 'New Game';

  @override
  String get actionPlay => 'Play';

  @override
  String get actionResume => 'Resume';

  @override
  String get actionStartNewGame => 'New game';

  @override
  String get actionPleaseWait => 'Please wait...';

  @override
  String get tooltipNewGame => 'Press this to start a new game.';

  @override
  String get tooltipUndo => 'Use Undo to step back and clear selections you made previously. You can also use this if you run out of Corrections';

  @override
  String get tooltipClear => 'Use this to clear a currently selected tile. You can only clear tiles that you have filled.';

  @override
  String get tooltipNotes => 'Notes allows you to add little reminders of possibilities if you\'re not sure. Your options are shown in green. Press Notes again to switch them off.';

  @override
  String get tooltipDifficulty => 'Choose the challenge level that allows you to make steady daily progress.';

  @override
  String labelCorrections(int count) {
    return 'Corrections: $count';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'You have $limit automatic corrections available for this puzzle. If an earlier move blocks your progress, you can use a correction to keep going. If you run out of corrections, use Undo.';
  }

  @override
  String get difficultyEasy => 'EASY';

  @override
  String get difficultyMedium => 'A BIT HARDER';

  @override
  String get difficultyHard => 'MUCH HARDER';

  @override
  String get difficultyVeryHard => 'NIGH IMPOSSIBLE';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpDismiss => 'OK';

  @override
  String get helpBody => 'There are ***some things*** on the game screen that are a bit mysterious.\n\nTry **holding your finger** for a couple of seconds on those to see an explanation.\n\nFor example, **Corrections** shows the number of automatic corrections you have left. If an earlier move results in there being no valid option, Corrections can automatically fix that dead end and let you keep playing.\n\nUse **Undo** to step back through the selections you made previously. Doing so clears those, one at a time. You can also do this if you run out of Corrections.';

  @override
  String get startInstruction => 'To start, select a square you want to add an icon to.\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies bring you';

  @override
  String get launchTitle => 'SuDoKu Playtime';

  @override
  String get launchSubtitle => 'Take your time, enjoy each puzzle and keep your mind active.';

  @override
  String get launchErrorOpenGame => 'Could not open game. Please try again.';

  @override
  String get launchHintsTitle => 'Hints';

  @override
  String get tooltipPrevHint => 'Previous hint';

  @override
  String get tooltipNextHint => 'Next hint';

  @override
  String get launchHint1 => 'Notes allows you to add little reminders of possibilities if you\'re not sure. Your options are shown in green. Press Notes again to switch them off.';

  @override
  String get launchHint2 => 'Use a long-press, (hold your finger down for a couple of seconds), to understand what somethings do. Also, try it on a tile that has been filled in.';

  @override
  String get launchHint3 => 'If your choice leads to two or more tiles being coloured pink, you\'ve made a mistake at some point. You have a limited number of auto-corrections.';

  @override
  String get launchHint4 => 'Changing difficulty during a game will start a new game.';

  @override
  String get launchHint5 => 'Press Help to get some information about how to play the game.';

  @override
  String get launchHint6 => 'Pressing ☰ (top right) opens a drawer that allows you to make some selections.';

  @override
  String get launchHint7 => 'If the sounds annoy you or you just want to play the game in a quiet environment you can switch the Audio off in the drawer (☰).';

  @override
  String get launchHint8 => 'Press the music icon once to turn the background music off or twice, in quick succession, to turn it on.';

  @override
  String get launchHint9 => 'The dice starts a new game.';

  @override
  String get launchHint10 => 'If you\'ve purchased the full version and it doesn\'t show up after an update, use \'Restore Purchases\' from the drawer.';

  @override
  String get dialogActionCancel => 'Cancel';

  @override
  String get dialogActionStartNewGame => 'Start New Game';

  @override
  String get dialogActionUseCorrection => 'Use correction';

  @override
  String get dialogUnlockSettingsTitle => 'Unlock Settings?';

  @override
  String get dialogUnlockSettingsMessage => 'Unlocking difficulty will start a new game and reset this board. Continue?';

  @override
  String get dialogStartNewGameTitle => 'Start New Game?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return 'Change difficulty to $difficultyLabel and start a new game?';
  }

  @override
  String get dialogStartNewGameResetBoard => 'Start a fresh game and reset this board?';

  @override
  String get labelLockedSettingsTitle => 'Board Settings Locked';

  @override
  String get labelLockedSettingsMessage => 'Difficulty is locked during a game. To unlock it, either double-tap the lock icon or start a \'New Game\'';

  @override
  String get progressSheetTitle => 'Your Progress';

  @override
  String progressSheetBody(int completedPuzzles) {
    return 'Completed puzzles: $completedPuzzles\nDays played: coming soon\nStreak: coming soon';
  }

  @override
  String progressCompletedPuzzles(int count) {
    return 'Completed puzzles: $count';
  }

  @override
  String progressDaysPlayed(int count) {
    return 'Days played: $count';
  }

  @override
  String progressStreak(int count) {
    return 'Streak: $count';
  }

  @override
  String get progressBestSolveTimesTitle => 'Best solve times:';

  @override
  String progressBestSolveTimeRow(String difficulty, String time) {
    return '• $difficulty: $time';
  }

  @override
  String get progressBestSolveTimeMissing => '--';

  @override
  String get progressResetAction => 'Reset';

  @override
  String get progressResetDialogTitle => 'Reset progress?';

  @override
  String get progressResetDialogMessage => 'Your \'How am I doing?\' data will be lost.';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile => 'Audio is not available for this tile yet.';

  @override
  String get correctionPromptMessage => 'This board is unsatisfiable from an earlier move. Use 1 correction?';

  @override
  String get premiumFeatureIntroGeneric => 'Full Version gives you the full Sudoku experience in one purchase.';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel is available in Full Version.';
  }

  @override
  String get premiumSheetTitle => 'Unlock Full Version';

  @override
  String get premiumIncludesTitle => 'Full Version includes:';

  @override
  String get premiumIncludesHardDifficulties => '• Hard and Nigh Impossible difficulties';

  @override
  String get premiumIncludesProgress => '• Progress tracking and personal bests';

  @override
  String get premiumIncludesThemesSounds => '• Extra themes, sounds, and celebrations';

  @override
  String get premiumOneTimePurchase => 'One-time purchase. No subscription.';

  @override
  String get premiumActionNotNow => 'Not now';

  @override
  String get premiumActionUnlock => 'Unlock Full Version';

  @override
  String get purchaseStartedMessage => 'Confirm the purchase in the App Store dialog to unlock Full Version.';

  @override
  String get restoreStartedMessage => 'Restore started. Purchased items will reappear shortly.';

  @override
  String get billingUnavailable => 'Purchases are unavailable on this device right now.';

  @override
  String get billingProductNotConfigured => 'Full Version is not configured yet. Please try again later.';

  @override
  String get billingProductUnavailable => 'Full Version product details could not be loaded. Please try again.';

  @override
  String get billingFailed => 'That did not work. Please try again.';

  @override
  String get drawerTitle => 'SuDoKu Playtime';

  @override
  String get drawerPuzzleStyleTitle => 'Puzzle Style';

  @override
  String get styleModern => 'Modern';

  @override
  String get styleClassic => 'Classic';

  @override
  String get styleHighContrast => 'High Contrast';

  @override
  String get drawerAudioTitle => 'Audio';

  @override
  String get labelOn => 'On';

  @override
  String get labelOff => 'Off';

  @override
  String get drawerBackgroundMusicTitle => 'Background music';

  @override
  String get drawerBackgroundMusicSubtitle => 'Sounds for SuDoKu lovers';

  @override
  String get drawerVolumeTitle => 'Volume';

  @override
  String get drawerVersionTitle => 'Version';

  @override
  String get drawerVersionFull => 'Full';

  @override
  String get drawerVersionFree => 'Free';

  @override
  String get drawerPremiumProgressTitle => 'Progress Tracker 🔒';

  @override
  String get drawerPremiumProgressSubtitle => 'Track completed puzzles and milestones.';

  @override
  String get drawerPremiumThemesTitle => 'Extra Themes 🔒';

  @override
  String get drawerPremiumThemesSubtitle => 'Unlock additional visual styles.';

  @override
  String get drawerPremiumSoundsTitle => 'Sounds & Celebrations 🔒';

  @override
  String get drawerPremiumSoundsSubtitle => 'Unlock extra sounds and celebrations.';

  @override
  String get drawerUnlockFullVersion => 'Unlock Full Version';

  @override
  String get drawerRestorePurchases => 'Restore Purchases';

  @override
  String get drawerAboutChip => 'About';

  @override
  String get drawerAboutTitle => 'About';

  @override
  String drawerAboutMessage(String versionLabel) {
    return 'Version: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy';
  }

  @override
  String get drawerDebugTitle => 'Debug';

  @override
  String get drawerDebugLoadCorrectionTitle => 'Load Correction Scenario';

  @override
  String get drawerDebugLoadCorrectionSubtitle => 'Temporary control for assisted-recovery testing.';

  @override
  String get drawerDebugLoadExhaustedTitle => 'Load Exhausted Correction Scenario';

  @override
  String get drawerDebugLoadExhaustedSubtitle => 'Temporary control for undo-only recovery testing.';

  @override
  String get drawerDebugResetEntitlementTitle => 'Reset Full Version (Debug)';

  @override
  String get drawerDebugResetEntitlementSubtitle => 'Sets local entitlement to Free for purchase retesting.';

  @override
  String get contentModeAnimals => 'Animals (easy)';

  @override
  String get contentModeInstruments => 'Instruments (tricky)';

  @override
  String get contentModeButterflies => 'Butterflies (pretty!)';

  @override
  String get contentModeOpera => 'Opera (unreal!)';

  @override
  String get contentModeNumbers => 'Numbers (old-school)';

  @override
  String get topControlsProgress => 'How am I doing?';

  @override
  String get topControlsHelp => 'Help';

  @override
  String get infoSheetDismiss => 'Got it';

  @override
  String get drawerLanguageTitle => 'Language';

  @override
  String get drawerLanguageReset => 'Reset to System Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageGerman => 'German';

  @override
  String get languageFrench => 'French';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String statusUnknownDifficulty(String difficulty) {
    return 'Unknown difficulty: $difficulty';
  }

  @override
  String get statusDifficultyChangeBlocked => 'Finish or start a new game before changing difficulty';

  @override
  String get statusDifficultyPremiumOnly => 'This difficulty is available in Full Version.';

  @override
  String get statusPuzzleModeUnique => 'Puzzle mode: unique';

  @override
  String get statusSessionRestored => 'Session restored';

  @override
  String get statusCellSelected => 'Cell selected';

  @override
  String get statusEntitlementRefreshed => 'Entitlement refreshed';

  @override
  String get statusEntitlementUpdated => 'Entitlement updated';

  @override
  String get statusCheckComplete => 'Check complete';

  @override
  String get statusSolution => 'Solution';

  @override
  String get statusSolved => 'Solved.';

  @override
  String get statusContradictionUseUndo => 'Contradiction detected. Use Undo to recover.';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'New game ($difficulty): $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count tile(s) corrected.';
  }
}
