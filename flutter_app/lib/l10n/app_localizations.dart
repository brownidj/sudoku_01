import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get appTitle;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get actionNotes;

  /// No description provided for @actionNewGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get actionNewGame;

  /// No description provided for @actionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get actionPlay;

  /// No description provided for @actionResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get actionResume;

  /// No description provided for @actionStartNewGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get actionStartNewGame;

  /// No description provided for @actionPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get actionPleaseWait;

  /// No description provided for @tooltipNewGame.
  ///
  /// In en, this message translates to:
  /// **'Press this to start a new game.'**
  String get tooltipNewGame;

  /// No description provided for @tooltipUndo.
  ///
  /// In en, this message translates to:
  /// **'Use Undo to step back and clear selections you made previously. You can also use this if you run out of Corrections'**
  String get tooltipUndo;

  /// No description provided for @tooltipClear.
  ///
  /// In en, this message translates to:
  /// **'Use this to clear a currently selected tile. You can only clear tiles that you have filled.'**
  String get tooltipClear;

  /// No description provided for @tooltipNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes allows you to add little reminders of possibilities if you\'re not sure. Your options are shown in green. Press Notes again to switch them off.'**
  String get tooltipNotes;

  /// No description provided for @tooltipDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Choose the challenge level that allows you to make steady daily progress.'**
  String get tooltipDifficulty;

  /// No description provided for @labelCorrections.
  ///
  /// In en, this message translates to:
  /// **'Corrections: {count}'**
  String labelCorrections(int count);

  /// No description provided for @tooltipCorrections.
  ///
  /// In en, this message translates to:
  /// **'You have {limit} automatic corrections available for this puzzle. If an earlier move blocks your progress, you can use a correction to keep going. If you run out of corrections, use Undo.'**
  String tooltipCorrections(int limit);

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'EASY'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'A BIT HARDER'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'MUCH HARDER'**
  String get difficultyHard;

  /// No description provided for @difficultyVeryHard.
  ///
  /// In en, this message translates to:
  /// **'NIGH IMPOSSIBLE'**
  String get difficultyVeryHard;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @helpDismiss.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get helpDismiss;

  /// No description provided for @helpBody.
  ///
  /// In en, this message translates to:
  /// **'There are ***some things*** on the game screen that are a bit mysterious.\n\nTry **holding your finger** for a couple of seconds on those to see an explanation.\n\nFor example, **Corrections** shows the number of automatic corrections you have left. If an earlier move results in there being no valid option, Corrections can automatically fix that dead end and let you keep playing.\n\nUse **Undo** to step back through the selections you made previously. Doing so clears those, one at a time. You can also do this if you run out of Corrections.'**
  String get helpBody;

  /// No description provided for @startInstruction.
  ///
  /// In en, this message translates to:
  /// **'To start, select a square you want to add an icon to.\n'**
  String get startInstruction;

  /// No description provided for @launchTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'The Angry Grannies bring you'**
  String get launchTitlePrefix;

  /// No description provided for @launchTitle.
  ///
  /// In en, this message translates to:
  /// **'SuDoKu Playtime'**
  String get launchTitle;

  /// No description provided for @launchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take your time, enjoy each puzzle and keep your mind active.'**
  String get launchSubtitle;

  /// No description provided for @launchErrorOpenGame.
  ///
  /// In en, this message translates to:
  /// **'Could not open game. Please try again.'**
  String get launchErrorOpenGame;

  /// No description provided for @launchHintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get launchHintsTitle;

  /// No description provided for @tooltipPrevHint.
  ///
  /// In en, this message translates to:
  /// **'Previous hint'**
  String get tooltipPrevHint;

  /// No description provided for @tooltipNextHint.
  ///
  /// In en, this message translates to:
  /// **'Next hint'**
  String get tooltipNextHint;

  /// No description provided for @launchHint1.
  ///
  /// In en, this message translates to:
  /// **'Notes allows you to add little reminders of possibilities if you\'re not sure. Your options are shown in green. Press Notes again to switch them off.'**
  String get launchHint1;

  /// No description provided for @launchHint2.
  ///
  /// In en, this message translates to:
  /// **'Use a long-press, (hold your finger down for a couple of seconds), to understand what somethings do. Also, try it on a tile that has been filled in.'**
  String get launchHint2;

  /// No description provided for @launchHint3.
  ///
  /// In en, this message translates to:
  /// **'If your choice leads to two or more tiles being coloured pink, you\'ve made a mistake at some point. You have a limited number of auto-corrections.'**
  String get launchHint3;

  /// No description provided for @launchHint4.
  ///
  /// In en, this message translates to:
  /// **'Changing difficulty during a game will start a new game.'**
  String get launchHint4;

  /// No description provided for @launchHint5.
  ///
  /// In en, this message translates to:
  /// **'Press Help to get some information about how to play the game.'**
  String get launchHint5;

  /// No description provided for @launchHint6.
  ///
  /// In en, this message translates to:
  /// **'Pressing ☰ (top right) opens a drawer that allows you to make some selections.'**
  String get launchHint6;

  /// No description provided for @launchHint7.
  ///
  /// In en, this message translates to:
  /// **'If the sounds annoy you or you just want to play the game in a quiet environment you can switch the Audio off in the drawer (☰).'**
  String get launchHint7;

  /// No description provided for @launchHint8.
  ///
  /// In en, this message translates to:
  /// **'Press the music icon once to turn the background music off or twice, in quick succession, to turn it on.'**
  String get launchHint8;

  /// No description provided for @launchHint9.
  ///
  /// In en, this message translates to:
  /// **'The dice starts a new game.'**
  String get launchHint9;

  /// No description provided for @launchHint10.
  ///
  /// In en, this message translates to:
  /// **'If you\'ve purchased the full version and it doesn\'t show up after an update, use \'Restore Purchases\' from the drawer.'**
  String get launchHint10;

  /// No description provided for @dialogActionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogActionCancel;

  /// No description provided for @dialogActionStartNewGame.
  ///
  /// In en, this message translates to:
  /// **'Start New Game'**
  String get dialogActionStartNewGame;

  /// No description provided for @dialogActionUseCorrection.
  ///
  /// In en, this message translates to:
  /// **'Use correction'**
  String get dialogActionUseCorrection;

  /// No description provided for @dialogUnlockSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Settings?'**
  String get dialogUnlockSettingsTitle;

  /// No description provided for @dialogUnlockSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Unlocking difficulty will start a new game and reset this board. Continue?'**
  String get dialogUnlockSettingsMessage;

  /// No description provided for @dialogStartNewGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Start New Game?'**
  String get dialogStartNewGameTitle;

  /// No description provided for @dialogStartNewGameForDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Change difficulty to {difficultyLabel} and start a new game?'**
  String dialogStartNewGameForDifficulty(String difficultyLabel);

  /// No description provided for @dialogStartNewGameResetBoard.
  ///
  /// In en, this message translates to:
  /// **'Start a fresh game and reset this board?'**
  String get dialogStartNewGameResetBoard;

  /// No description provided for @labelLockedSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Board Settings Locked'**
  String get labelLockedSettingsTitle;

  /// No description provided for @labelLockedSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Difficulty is locked during a game. To unlock it, either double-tap the lock icon or start a \'New Game\''**
  String get labelLockedSettingsMessage;

  /// No description provided for @progressSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get progressSheetTitle;

  /// No description provided for @progressSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Completed puzzles: {completedPuzzles}\nDays played: coming soon\nStreak: coming soon'**
  String progressSheetBody(int completedPuzzles);

  /// No description provided for @progressCompletedPuzzles.
  ///
  /// In en, this message translates to:
  /// **'Completed puzzles: {count}'**
  String progressCompletedPuzzles(int count);

  /// No description provided for @progressDaysPlayed.
  ///
  /// In en, this message translates to:
  /// **'Days played: {count}'**
  String progressDaysPlayed(int count);

  /// No description provided for @progressStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak: {count}'**
  String progressStreak(int count);

  /// No description provided for @progressBestSolveTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'Best solve times:'**
  String get progressBestSolveTimesTitle;

  /// No description provided for @progressBestSolveTimeRow.
  ///
  /// In en, this message translates to:
  /// **'• {difficulty}: {time}'**
  String progressBestSolveTimeRow(String difficulty, String time);

  /// No description provided for @progressBestSolveTimeMissing.
  ///
  /// In en, this message translates to:
  /// **'--'**
  String get progressBestSolveTimeMissing;

  /// No description provided for @progressResetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get progressResetAction;

  /// No description provided for @progressResetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset progress?'**
  String get progressResetDialogTitle;

  /// No description provided for @progressResetDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Your \'How am I doing?\' data will be lost.'**
  String get progressResetDialogMessage;

  /// No description provided for @dialogActionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogActionOk;

  /// No description provided for @audioUnavailableTile.
  ///
  /// In en, this message translates to:
  /// **'Audio is not available for this tile yet.'**
  String get audioUnavailableTile;

  /// No description provided for @correctionPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'This board is unsatisfiable from an earlier move. Use 1 correction?'**
  String get correctionPromptMessage;

  /// No description provided for @premiumFeatureIntroGeneric.
  ///
  /// In en, this message translates to:
  /// **'Full Version gives you the full Sudoku experience in one purchase.'**
  String get premiumFeatureIntroGeneric;

  /// No description provided for @premiumFeatureIntroNamed.
  ///
  /// In en, this message translates to:
  /// **'{featureLabel} is available in Full Version.'**
  String premiumFeatureIntroNamed(String featureLabel);

  /// No description provided for @premiumSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Full Version'**
  String get premiumSheetTitle;

  /// No description provided for @premiumIncludesTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Version includes:'**
  String get premiumIncludesTitle;

  /// No description provided for @premiumIncludesHardDifficulties.
  ///
  /// In en, this message translates to:
  /// **'• Hard and Nigh Impossible difficulties'**
  String get premiumIncludesHardDifficulties;

  /// No description provided for @premiumIncludesProgress.
  ///
  /// In en, this message translates to:
  /// **'• Progress tracking and personal bests'**
  String get premiumIncludesProgress;

  /// No description provided for @premiumIncludesThemesSounds.
  ///
  /// In en, this message translates to:
  /// **'• Extra themes, sounds, and celebrations'**
  String get premiumIncludesThemesSounds;

  /// No description provided for @premiumOneTimePurchase.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase. No subscription.'**
  String get premiumOneTimePurchase;

  /// No description provided for @premiumActionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get premiumActionNotNow;

  /// No description provided for @premiumActionUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock Full Version'**
  String get premiumActionUnlock;

  /// No description provided for @purchaseStartedMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm the purchase in the App Store dialog to unlock Full Version.'**
  String get purchaseStartedMessage;

  /// No description provided for @restoreStartedMessage.
  ///
  /// In en, this message translates to:
  /// **'Restore started. Purchased items will reappear shortly.'**
  String get restoreStartedMessage;

  /// No description provided for @billingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases are unavailable on this device right now.'**
  String get billingUnavailable;

  /// No description provided for @billingProductNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Full Version is not configured yet. Please try again later.'**
  String get billingProductNotConfigured;

  /// No description provided for @billingProductUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Full Version product details could not be loaded. Please try again.'**
  String get billingProductUnavailable;

  /// No description provided for @billingFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Please try again.'**
  String get billingFailed;

  /// No description provided for @drawerTitle.
  ///
  /// In en, this message translates to:
  /// **'SuDoKu Playtime'**
  String get drawerTitle;

  /// No description provided for @drawerPuzzleStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Puzzle Style'**
  String get drawerPuzzleStyleTitle;

  /// No description provided for @styleModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get styleModern;

  /// No description provided for @styleClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get styleClassic;

  /// No description provided for @styleHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get styleHighContrast;

  /// No description provided for @drawerAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get drawerAudioTitle;

  /// No description provided for @labelOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get labelOn;

  /// No description provided for @labelOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get labelOff;

  /// No description provided for @drawerBackgroundMusicTitle.
  ///
  /// In en, this message translates to:
  /// **'Background music'**
  String get drawerBackgroundMusicTitle;

  /// No description provided for @drawerBackgroundMusicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sounds for SuDoKu lovers'**
  String get drawerBackgroundMusicSubtitle;

  /// No description provided for @drawerVolumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get drawerVolumeTitle;

  /// No description provided for @drawerVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get drawerVersionTitle;

  /// No description provided for @drawerVersionFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get drawerVersionFull;

  /// No description provided for @drawerVersionFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get drawerVersionFree;

  /// No description provided for @drawerPremiumProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress Tracker 🔒'**
  String get drawerPremiumProgressTitle;

  /// No description provided for @drawerPremiumProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track completed puzzles and milestones.'**
  String get drawerPremiumProgressSubtitle;

  /// No description provided for @drawerPremiumThemesTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra Themes 🔒'**
  String get drawerPremiumThemesTitle;

  /// No description provided for @drawerPremiumThemesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock additional visual styles.'**
  String get drawerPremiumThemesSubtitle;

  /// No description provided for @drawerPremiumSoundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sounds & Celebrations 🔒'**
  String get drawerPremiumSoundsTitle;

  /// No description provided for @drawerPremiumSoundsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock extra sounds and celebrations.'**
  String get drawerPremiumSoundsSubtitle;

  /// No description provided for @drawerUnlockFullVersion.
  ///
  /// In en, this message translates to:
  /// **'Unlock Full Version'**
  String get drawerUnlockFullVersion;

  /// No description provided for @drawerRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get drawerRestorePurchases;

  /// No description provided for @drawerAboutChip.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get drawerAboutChip;

  /// No description provided for @drawerAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get drawerAboutTitle;

  /// No description provided for @drawerAboutMessage.
  ///
  /// In en, this message translates to:
  /// **'Version: {versionLabel}\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy'**
  String drawerAboutMessage(String versionLabel);

  /// No description provided for @drawerDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get drawerDebugTitle;

  /// No description provided for @drawerDebugLoadCorrectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Load Correction Scenario'**
  String get drawerDebugLoadCorrectionTitle;

  /// No description provided for @drawerDebugLoadCorrectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Temporary control for assisted-recovery testing.'**
  String get drawerDebugLoadCorrectionSubtitle;

  /// No description provided for @drawerDebugLoadExhaustedTitle.
  ///
  /// In en, this message translates to:
  /// **'Load Exhausted Correction Scenario'**
  String get drawerDebugLoadExhaustedTitle;

  /// No description provided for @drawerDebugLoadExhaustedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Temporary control for undo-only recovery testing.'**
  String get drawerDebugLoadExhaustedSubtitle;

  /// No description provided for @drawerDebugResetEntitlementTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Full Version (Debug)'**
  String get drawerDebugResetEntitlementTitle;

  /// No description provided for @drawerDebugResetEntitlementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sets local entitlement to Free for purchase retesting.'**
  String get drawerDebugResetEntitlementSubtitle;

  /// No description provided for @contentModeAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals (easy)'**
  String get contentModeAnimals;

  /// No description provided for @contentModeInstruments.
  ///
  /// In en, this message translates to:
  /// **'Instruments (tricky)'**
  String get contentModeInstruments;

  /// No description provided for @contentModeButterflies.
  ///
  /// In en, this message translates to:
  /// **'Butterflies (pretty!)'**
  String get contentModeButterflies;

  /// No description provided for @contentModeOpera.
  ///
  /// In en, this message translates to:
  /// **'Opera (unreal!)'**
  String get contentModeOpera;

  /// No description provided for @contentModeNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers (old-school)'**
  String get contentModeNumbers;

  /// No description provided for @topControlsProgress.
  ///
  /// In en, this message translates to:
  /// **'How am I doing?'**
  String get topControlsProgress;

  /// No description provided for @topControlsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get topControlsHelp;

  /// No description provided for @infoSheetDismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get infoSheetDismiss;

  /// No description provided for @drawerLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get drawerLanguageTitle;

  /// No description provided for @drawerLanguageReset.
  ///
  /// In en, this message translates to:
  /// **'Reset to System Language'**
  String get drawerLanguageReset;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @statusUnknownDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Unknown difficulty: {difficulty}'**
  String statusUnknownDifficulty(String difficulty);

  /// No description provided for @statusDifficultyChangeBlocked.
  ///
  /// In en, this message translates to:
  /// **'Finish or start a new game before changing difficulty'**
  String get statusDifficultyChangeBlocked;

  /// No description provided for @statusDifficultyPremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'This difficulty is available in Full Version.'**
  String get statusDifficultyPremiumOnly;

  /// No description provided for @statusPuzzleModeUnique.
  ///
  /// In en, this message translates to:
  /// **'Puzzle mode: unique'**
  String get statusPuzzleModeUnique;

  /// No description provided for @statusSessionRestored.
  ///
  /// In en, this message translates to:
  /// **'Session restored'**
  String get statusSessionRestored;

  /// No description provided for @statusCellSelected.
  ///
  /// In en, this message translates to:
  /// **'Cell selected'**
  String get statusCellSelected;

  /// No description provided for @statusEntitlementRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Entitlement refreshed'**
  String get statusEntitlementRefreshed;

  /// No description provided for @statusEntitlementUpdated.
  ///
  /// In en, this message translates to:
  /// **'Entitlement updated'**
  String get statusEntitlementUpdated;

  /// No description provided for @statusCheckComplete.
  ///
  /// In en, this message translates to:
  /// **'Check complete'**
  String get statusCheckComplete;

  /// No description provided for @statusSolution.
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get statusSolution;

  /// No description provided for @statusSolved.
  ///
  /// In en, this message translates to:
  /// **'Solved.'**
  String get statusSolved;

  /// No description provided for @statusContradictionUseUndo.
  ///
  /// In en, this message translates to:
  /// **'Contradiction detected. Use Undo to recover.'**
  String get statusContradictionUseUndo;

  /// No description provided for @statusNewGame.
  ///
  /// In en, this message translates to:
  /// **'New game ({difficulty}): {puzzleId}'**
  String statusNewGame(String difficulty, String puzzleId);

  /// No description provided for @statusTilesCorrected.
  ///
  /// In en, this message translates to:
  /// **'{count} tile(s) corrected.'**
  String statusTilesCorrected(int count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
