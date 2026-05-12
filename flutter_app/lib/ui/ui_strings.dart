import 'package:flutter/widgets.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class UiStrings {
  static AppLocalizations _l10n(BuildContext context) =>
      AppLocalizations.of(context) ??
      lookupAppLocalizations(const Locale('en'));

  static String actionUndo(BuildContext context) => _l10n(context).actionUndo;
  static String actionClear(BuildContext context) => _l10n(context).actionClear;
  static String actionNotes(BuildContext context) => _l10n(context).actionNotes;
  static String actionNewGame(BuildContext context) =>
      _l10n(context).actionNewGame;
  static String actionPlay(BuildContext context) => _l10n(context).actionPlay;
  static String actionResume(BuildContext context) =>
      _l10n(context).actionResume;
  static String actionStartNewGame(BuildContext context) =>
      _l10n(context).actionStartNewGame;
  static String actionPleaseWait(BuildContext context) =>
      _l10n(context).actionPleaseWait;

  static String tooltipNewGame(BuildContext context) =>
      _l10n(context).tooltipNewGame;
  static String tooltipUndo(BuildContext context) => _l10n(context).tooltipUndo;
  static String tooltipClear(BuildContext context) =>
      _l10n(context).tooltipClear;
  static String tooltipNotes(BuildContext context) =>
      _l10n(context).tooltipNotes;
  static String tooltipDifficulty(BuildContext context) =>
      _l10n(context).tooltipDifficulty;

  static String correctionsLabel(BuildContext context, int count) =>
      _l10n(context).labelCorrections(count);

  static String correctionsTooltip(BuildContext context, int correctionLimit) =>
      _l10n(context).tooltipCorrections(correctionLimit);

  static String difficultyEasy(BuildContext context) =>
      _l10n(context).difficultyEasy;
  static String difficultyMedium(BuildContext context) =>
      _l10n(context).difficultyMedium;
  static String difficultyHard(BuildContext context) =>
      _l10n(context).difficultyHard;
  static String difficultyVeryHard(BuildContext context) =>
      _l10n(context).difficultyVeryHard;

  static String helpTitle(BuildContext context) => _l10n(context).helpTitle;
  static String helpDismiss(BuildContext context) => _l10n(context).helpDismiss;
  static String helpBody(BuildContext context) => _l10n(context).helpBody;

  static String startInstruction(BuildContext context) =>
      _l10n(context).startInstruction;

  static String launchTitlePrefix(BuildContext context) =>
      _l10n(context).launchTitlePrefix;
  static String launchTitle(BuildContext context) => _l10n(context).launchTitle;
  static String launchSubtitle(BuildContext context) =>
      _l10n(context).launchSubtitle;
  static String launchErrorOpenGame(BuildContext context) =>
      _l10n(context).launchErrorOpenGame;

  static String launchHintsTitle(BuildContext context) =>
      _l10n(context).launchHintsTitle;
  static String tooltipPrevHint(BuildContext context) =>
      _l10n(context).tooltipPrevHint;
  static String tooltipNextHint(BuildContext context) =>
      _l10n(context).tooltipNextHint;

  static List<String> launchHints(BuildContext context) => [
    _l10n(context).launchHint1,
    _l10n(context).launchHint2,
    _l10n(context).launchHint3,
    _l10n(context).launchHint4,
    _l10n(context).launchHint5,
    _l10n(context).launchHint6,
    _l10n(context).launchHint7,
    _l10n(context).launchHint8,
    _l10n(context).launchHint9,
    _l10n(context).launchHint10,
  ];

  static String dialogActionCancel(BuildContext context) =>
      _l10n(context).dialogActionCancel;
  static String dialogActionStartNewGame(BuildContext context) =>
      _l10n(context).dialogActionStartNewGame;
  static String dialogActionUseCorrection(BuildContext context) =>
      _l10n(context).dialogActionUseCorrection;
  static String dialogUnlockSettingsTitle(BuildContext context) =>
      _l10n(context).dialogUnlockSettingsTitle;
  static String dialogUnlockSettingsMessage(BuildContext context) =>
      _l10n(context).dialogUnlockSettingsMessage;
  static String dialogStartNewGameTitle(BuildContext context) =>
      _l10n(context).dialogStartNewGameTitle;
  static String dialogStartNewGameForDifficulty(
    BuildContext context,
    String difficultyLabel,
  ) => _l10n(context).dialogStartNewGameForDifficulty(difficultyLabel);
  static String dialogStartNewGameResetBoard(BuildContext context) =>
      _l10n(context).dialogStartNewGameResetBoard;

  static String lockedSettingsTitle(BuildContext context) =>
      _l10n(context).labelLockedSettingsTitle;
  static String lockedSettingsMessage(BuildContext context) =>
      _l10n(context).labelLockedSettingsMessage;
  static String progressSheetTitle(BuildContext context) =>
      _l10n(context).progressSheetTitle;
  static String progressSheetBody(
    BuildContext context, {
    required int completedPuzzles,
    required int daysPlayed,
    required int streak,
    required Map<String, int> bestSolveTimeSecondsByDifficulty,
  }) {
    final lines = <String>[
      _l10n(context).progressCompletedPuzzles(completedPuzzles),
      _l10n(context).progressDaysPlayed(daysPlayed),
      _l10n(context).progressStreak(streak),
      _l10n(context).progressBestSolveTimesTitle,
      _l10n(context).progressBestSolveTimeRow(
        difficultyEasy(context),
        _formatDuration(context, bestSolveTimeSecondsByDifficulty['easy']),
      ),
      _l10n(context).progressBestSolveTimeRow(
        difficultyMedium(context),
        _formatDuration(context, bestSolveTimeSecondsByDifficulty['medium']),
      ),
      _l10n(context).progressBestSolveTimeRow(
        difficultyHard(context),
        _formatDuration(context, bestSolveTimeSecondsByDifficulty['hard']),
      ),
      _l10n(context).progressBestSolveTimeRow(
        difficultyVeryHard(context),
        _formatDuration(context, bestSolveTimeSecondsByDifficulty['very_hard']),
      ),
    ];
    return lines.join('\n');
  }

  static String _formatDuration(BuildContext context, int? seconds) {
    if (seconds == null) {
      return _l10n(context).progressBestSolveTimeMissing;
    }
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }

  static String progressResetAction(BuildContext context) =>
      _l10n(context).progressResetAction;
  static String progressResetDialogTitle(BuildContext context) =>
      _l10n(context).progressResetDialogTitle;
  static String progressResetDialogMessage(BuildContext context) =>
      _l10n(context).progressResetDialogMessage;
  static String dialogActionOk(BuildContext context) => _l10n(context).dialogActionOk;

  static String audioUnavailableTile(BuildContext context) =>
      _l10n(context).audioUnavailableTile;
  static String correctionPromptMessage(BuildContext context) =>
      _l10n(context).correctionPromptMessage;

  static String premiumFeatureIntroGeneric(BuildContext context) =>
      _l10n(context).premiumFeatureIntroGeneric;
  static String premiumFeatureIntroNamed(
    BuildContext context,
    String featureLabel,
  ) => _l10n(context).premiumFeatureIntroNamed(featureLabel);
  static String premiumSheetTitle(BuildContext context) =>
      _l10n(context).premiumSheetTitle;
  static String premiumIncludesTitle(BuildContext context) =>
      _l10n(context).premiumIncludesTitle;
  static String premiumIncludesHardDifficulties(BuildContext context) =>
      _l10n(context).premiumIncludesHardDifficulties;
  static String premiumIncludesProgress(BuildContext context) =>
      _l10n(context).premiumIncludesProgress;
  static String premiumIncludesThemesSounds(BuildContext context) =>
      _l10n(context).premiumIncludesThemesSounds;
  static String premiumOneTimePurchase(BuildContext context) =>
      _l10n(context).premiumOneTimePurchase;
  static String premiumActionNotNow(BuildContext context) =>
      _l10n(context).premiumActionNotNow;
  static String premiumActionUnlock(BuildContext context) =>
      _l10n(context).premiumActionUnlock;

  static String purchaseStartedMessage(BuildContext context) =>
      _l10n(context).purchaseStartedMessage;
  static String restoreStartedMessage(BuildContext context) =>
      _l10n(context).restoreStartedMessage;
  static String billingUnavailable(BuildContext context) =>
      _l10n(context).billingUnavailable;
  static String billingProductNotConfigured(BuildContext context) =>
      _l10n(context).billingProductNotConfigured;
  static String billingProductUnavailable(BuildContext context) =>
      _l10n(context).billingProductUnavailable;
  static String billingFailed(BuildContext context) => _l10n(context).billingFailed;

  static String drawerTitle(BuildContext context) => _l10n(context).drawerTitle;
  static String drawerPuzzleStyleTitle(BuildContext context) =>
      _l10n(context).drawerPuzzleStyleTitle;
  static String styleModern(BuildContext context) => _l10n(context).styleModern;
  static String styleClassic(BuildContext context) => _l10n(context).styleClassic;
  static String styleHighContrast(BuildContext context) =>
      _l10n(context).styleHighContrast;
  static String drawerAudioTitle(BuildContext context) =>
      _l10n(context).drawerAudioTitle;
  static String labelOn(BuildContext context) => _l10n(context).labelOn;
  static String labelOff(BuildContext context) => _l10n(context).labelOff;
  static String drawerBackgroundMusicTitle(BuildContext context) =>
      _l10n(context).drawerBackgroundMusicTitle;
  static String drawerBackgroundMusicSubtitle(BuildContext context) =>
      _l10n(context).drawerBackgroundMusicSubtitle;
  static String drawerVolumeTitle(BuildContext context) =>
      _l10n(context).drawerVolumeTitle;
  static String drawerVersionTitle(BuildContext context) =>
      _l10n(context).drawerVersionTitle;
  static String drawerVersionFull(BuildContext context) =>
      _l10n(context).drawerVersionFull;
  static String drawerVersionFree(BuildContext context) =>
      _l10n(context).drawerVersionFree;
  static String drawerPremiumProgressTitle(BuildContext context) =>
      _l10n(context).drawerPremiumProgressTitle;
  static String drawerPremiumProgressSubtitle(BuildContext context) =>
      _l10n(context).drawerPremiumProgressSubtitle;
  static String drawerPremiumThemesTitle(BuildContext context) =>
      _l10n(context).drawerPremiumThemesTitle;
  static String drawerPremiumThemesSubtitle(BuildContext context) =>
      _l10n(context).drawerPremiumThemesSubtitle;
  static String drawerPremiumSoundsTitle(BuildContext context) =>
      _l10n(context).drawerPremiumSoundsTitle;
  static String drawerPremiumSoundsSubtitle(BuildContext context) =>
      _l10n(context).drawerPremiumSoundsSubtitle;
  static String drawerUnlockFullVersion(BuildContext context) =>
      _l10n(context).drawerUnlockFullVersion;
  static String drawerRestorePurchases(BuildContext context) =>
      _l10n(context).drawerRestorePurchases;
  static String drawerAboutChip(BuildContext context) =>
      _l10n(context).drawerAboutChip;
  static String drawerAboutTitle(BuildContext context) =>
      _l10n(context).drawerAboutTitle;
  static String drawerAboutMessage(BuildContext context, String versionLabel) =>
      _l10n(context).drawerAboutMessage(versionLabel);
  static String drawerDebugTitle(BuildContext context) =>
      _l10n(context).drawerDebugTitle;
  static String drawerDebugLoadCorrectionTitle(BuildContext context) =>
      _l10n(context).drawerDebugLoadCorrectionTitle;
  static String drawerDebugLoadCorrectionSubtitle(BuildContext context) =>
      _l10n(context).drawerDebugLoadCorrectionSubtitle;
  static String drawerDebugLoadExhaustedTitle(BuildContext context) =>
      _l10n(context).drawerDebugLoadExhaustedTitle;
  static String drawerDebugLoadExhaustedSubtitle(BuildContext context) =>
      _l10n(context).drawerDebugLoadExhaustedSubtitle;
  static String drawerDebugResetEntitlementTitle(BuildContext context) =>
      _l10n(context).drawerDebugResetEntitlementTitle;
  static String drawerDebugResetEntitlementSubtitle(BuildContext context) =>
      _l10n(context).drawerDebugResetEntitlementSubtitle;
  static String contentModeAnimals(BuildContext context) =>
      _l10n(context).contentModeAnimals;
  static String contentModeInstruments(BuildContext context) =>
      _l10n(context).contentModeInstruments;
  static String contentModeButterflies(BuildContext context) =>
      _l10n(context).contentModeButterflies;
  static String contentModeOpera(BuildContext context) =>
      _l10n(context).contentModeOpera;
  static String contentModeNumbers(BuildContext context) =>
      _l10n(context).contentModeNumbers;
  static String topControlsProgress(BuildContext context) =>
      _l10n(context).topControlsProgress;
  static String topControlsHelp(BuildContext context) =>
      _l10n(context).topControlsHelp;
  static String infoSheetDismiss(BuildContext context) =>
      _l10n(context).infoSheetDismiss;
  static String drawerLanguageTitle(BuildContext context) =>
      _l10n(context).drawerLanguageTitle;
  static String drawerLanguageReset(BuildContext context) =>
      _l10n(context).drawerLanguageReset;
  static String languageEnglish(BuildContext context) =>
      _l10n(context).languageEnglish;
  static String languageJapanese(BuildContext context) =>
      _l10n(context).languageJapanese;
  static String languageGerman(BuildContext context) =>
      _l10n(context).languageGerman;
  static String languageFrench(BuildContext context) =>
      _l10n(context).languageFrench;
  static String languageItalian(BuildContext context) =>
      _l10n(context).languageItalian;
  static String languagePortuguese(BuildContext context) =>
      _l10n(context).languagePortuguese;
  static String languageHindi(BuildContext context) =>
      _l10n(context).languageHindi;
  static String languageSpanish(BuildContext context) =>
      _l10n(context).languageSpanish;
}
