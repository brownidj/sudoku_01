import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/screenshot_mode.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/ui/ui_string_helpers.dart';

class UiStrings {
  static AppLocalizations l10n(BuildContext context) =>
      AppLocalizations.of(context) ??
      lookupAppLocalizations(const Locale('en'));

  static String actionUndo(BuildContext context) => l10n(context).actionUndo;
  static String actionClear(BuildContext context) => l10n(context).actionClear;
  static String actionNotes(BuildContext context) => l10n(context).actionNotes;
  static String actionNewShort(BuildContext context) =>
      l10n(context).actionNewShort;
  static String actionNewGame(BuildContext context) =>
      l10n(context).actionNewGame;
  static String actionPlay(BuildContext context) => l10n(context).actionPlay;
  static String actionResume(BuildContext context) =>
      l10n(context).actionResume;
  static String actionStartNewGame(BuildContext context) =>
      l10n(context).actionStartNewGame;
  static String actionPleaseWait(BuildContext context) =>
      l10n(context).actionPleaseWait;
  static String tooltipNewGame(BuildContext context) =>
      l10n(context).tooltipNewGame;
  static String tooltipUndo(BuildContext context) => l10n(context).tooltipUndo;
  static String tooltipClear(BuildContext context) =>
      l10n(context).tooltipClear;
  static String tooltipNotes(BuildContext context) =>
      l10n(context).tooltipNotes;
  static String tooltipDifficulty(BuildContext context) =>
      l10n(context).tooltipDifficulty;
  static String candidateLongPressToast(BuildContext context, int digit) =>
      l10n(context).candidateLongPressToast(digit);
  static String correctionsLabel(BuildContext context, int count) =>
      l10n(context).labelCorrections(count);
  static String correctionsTooltip(BuildContext context, int correctionLimit) =>
      l10n(context).tooltipCorrections(correctionLimit);
  static String elapsedTimeLabel(BuildContext context, String time) =>
      l10n(context).labelElapsedTime(time);
  static String difficultyEasy(BuildContext context) =>
      l10n(context).difficultyEasy;
  static String difficultyMedium(BuildContext context) =>
      l10n(context).difficultyMedium;
  static String difficultyHard(BuildContext context) =>
      l10n(context).difficultyHard;
  static String difficultyVeryHard(BuildContext context) =>
      l10n(context).difficultyVeryHard;
  static String helpTitle(BuildContext context) => l10n(context).helpTitle;
  static String helpDismiss(BuildContext context) => l10n(context).helpDismiss;
  static String helpBody(BuildContext context) => l10n(context).helpBody;
  static String startInstruction(BuildContext context) =>
      l10n(context).startInstruction;
  static String launchTitlePrefix(BuildContext context) =>
      l10n(context).launchTitlePrefix;
  static String launchTitle(BuildContext context) => _brandForPlatform(context);
  static String launchSubtitle(BuildContext context) =>
      l10n(context).launchSubtitle;
  static String launchErrorOpenGame(BuildContext context) =>
      l10n(context).launchErrorOpenGame;
  static String launchHintsTitle(BuildContext context) =>
      l10n(context).launchHintsTitle;
  static String tooltipPrevHint(BuildContext context) =>
      l10n(context).tooltipPrevHint;
  static String tooltipNextHint(BuildContext context) =>
      l10n(context).tooltipNextHint;
  static List<String> launchHints(BuildContext context) =>
      UiStringHelpers.launchHints(context);
  static List<String> victoryCelebrationMessages(BuildContext context) =>
      UiStringHelpers.victoryCelebrationMessages(context);
  static String dialogActionCancel(BuildContext context) =>
      l10n(context).dialogActionCancel;
  static String dialogActionStartNewGame(BuildContext context) =>
      l10n(context).dialogActionStartNewGame;
  static String dialogActionUseCorrection(BuildContext context) =>
      l10n(context).dialogActionUseCorrection;
  static String dialogUnlockSettingsTitle(BuildContext context) =>
      l10n(context).dialogUnlockSettingsTitle;
  static String dialogUnlockSettingsMessage(BuildContext context) =>
      l10n(context).dialogUnlockSettingsMessage;
  static String dialogStartNewGameTitle(BuildContext context) =>
      l10n(context).dialogStartNewGameTitle;
  static String dialogStartNewGameForDifficulty(
    BuildContext context,
    String difficultyLabel,
  ) => l10n(context).dialogStartNewGameForDifficulty(difficultyLabel);
  static String dialogStartNewGameResetBoard(BuildContext context) =>
      l10n(context).dialogStartNewGameResetBoard;
  static String lockedSettingsTitle(BuildContext context) =>
      l10n(context).labelLockedSettingsTitle;
  static String lockedSettingsMessage(BuildContext context) =>
      l10n(context).labelLockedSettingsMessage;
  static String progressSheetTitle(BuildContext context) =>
      l10n(context).progressSheetTitle;
  static String progressSheetBody(
    BuildContext context, {
    required int completedPuzzles,
    required int daysPlayed,
    required int streak,
    required int? currentGameElapsedSeconds,
    required Map<String, int> bestSolveTimeSecondsByDifficulty,
  }) => UiStringHelpers.progressSheetBody(
    context,
    completedPuzzles: completedPuzzles,
    daysPlayed: daysPlayed,
    streak: streak,
    currentGameElapsedSeconds: currentGameElapsedSeconds,
    bestSolveTimeSecondsByDifficulty: bestSolveTimeSecondsByDifficulty,
  );

  static String progressSheetBodyFree(
    BuildContext context, {
    required int completedPuzzles,
  }) => UiStringHelpers.progressSheetBodyFree(
    context,
    completedPuzzles: completedPuzzles,
  );

  static String progressResetAction(BuildContext context) =>
      l10n(context).progressResetAction;
  static String progressResetDialogTitle(BuildContext context) =>
      l10n(context).progressResetDialogTitle;
  static String progressResetDialogMessage(BuildContext context) =>
      l10n(context).progressResetDialogMessage;
  static String dialogActionOk(BuildContext context) =>
      l10n(context).dialogActionOk;
  static String audioUnavailableTile(BuildContext context) =>
      l10n(context).audioUnavailableTile;
  static String correctionPromptMessage(BuildContext context) =>
      l10n(context).correctionPromptMessage;

  static String premiumFeatureIntroGeneric(BuildContext context) =>
      l10n(context).premiumFeatureIntroGeneric;
  static String premiumFeatureIntroNamed(
    BuildContext context,
    String featureLabel,
  ) => l10n(context).premiumFeatureIntroNamed(featureLabel);
  static String premiumSheetTitle(BuildContext context) =>
      l10n(context).premiumSheetTitle;
  static String premiumIncludesTitle(BuildContext context) =>
      l10n(context).premiumIncludesTitle;
  static String premiumIncludesHardDifficulties(BuildContext context) =>
      l10n(context).premiumIncludesHardDifficulties;
  static String premiumIncludesProgress(BuildContext context) =>
      l10n(context).premiumIncludesProgress;
  static String premiumIncludesThemesSounds(BuildContext context) =>
      l10n(context).premiumIncludesThemesSounds;
  static String premiumOneTimePurchase(BuildContext context) =>
      l10n(context).premiumOneTimePurchase;
  static String premiumActionNotNow(BuildContext context) =>
      l10n(context).premiumActionNotNow;
  static String premiumActionUnlock(BuildContext context) =>
      l10n(context).premiumActionUnlock;
  static String purchaseStartedMessage(BuildContext context) =>
      l10n(context).purchaseStartedMessage;
  static String restoreStartedMessage(BuildContext context) =>
      l10n(context).restoreStartedMessage;
  static String billingUnavailable(BuildContext context) =>
      l10n(context).billingUnavailable;
  static String billingProductNotConfigured(BuildContext context) =>
      l10n(context).billingProductNotConfigured;
  static String billingProductUnavailable(BuildContext context) =>
      l10n(context).billingProductUnavailable;
  static String billingFailed(BuildContext context) =>
      l10n(context).billingFailed;

  static String drawerTitle(BuildContext context) => _brandForPlatform(context);
  static String drawerPuzzleStyleTitle(BuildContext context) =>
      l10n(context).drawerPuzzleStyleTitle;
  static String styleModern(BuildContext context) => l10n(context).styleModern;
  static String styleClassic(BuildContext context) =>
      l10n(context).styleClassic;
  static String styleHighContrast(BuildContext context) =>
      l10n(context).styleHighContrast;
  static String drawerAudioTitle(BuildContext context) =>
      l10n(context).drawerAudioTitle;
  static String labelOn(BuildContext context) => l10n(context).labelOn;
  static String labelOff(BuildContext context) => l10n(context).labelOff;
  static String drawerBackgroundMusicTitle(BuildContext context) =>
      l10n(context).drawerBackgroundMusicTitle;
  static String drawerBackgroundMusicSubtitle(BuildContext context) =>
      l10n(context).drawerBackgroundMusicSubtitle;
  static String musicControlsTooltip(BuildContext context) =>
      l10n(context).musicControlsTooltip;
  static String drawerVolumeTitle(BuildContext context) =>
      l10n(context).drawerVolumeTitle;
  static String drawerVersionTitle(BuildContext context) =>
      l10n(context).drawerVersionTitle;
  static String drawerVersionFull(BuildContext context) =>
      l10n(context).drawerVersionFull;
  static String drawerVersionFree(BuildContext context) =>
      l10n(context).drawerVersionFree;
  static String drawerPremiumProgressTitle(BuildContext context) =>
      l10n(context).drawerPremiumProgressTitle;
  static String drawerPremiumProgressSubtitle(BuildContext context) =>
      l10n(context).drawerPremiumProgressSubtitle;
  static String drawerPremiumThemesTitle(BuildContext context) =>
      l10n(context).drawerPremiumThemesTitle;
  static String drawerPremiumThemesSubtitle(BuildContext context) =>
      l10n(context).drawerPremiumThemesSubtitle;
  static String drawerPremiumSoundsTitle(BuildContext context) =>
      l10n(context).drawerPremiumSoundsTitle;
  static String drawerPremiumSoundsSubtitle(BuildContext context) =>
      l10n(context).drawerPremiumSoundsSubtitle;
  static String drawerUnlockFullVersion(BuildContext context) =>
      l10n(context).drawerUnlockFullVersion;
  static String drawerRestorePurchases(BuildContext context) =>
      l10n(context).drawerRestorePurchases;
  static String drawerAboutChip(BuildContext context) =>
      l10n(context).drawerAboutChip;
  static String drawerAboutTitle(BuildContext context) =>
      l10n(context).drawerAboutTitle;
  static String drawerAboutMessage(BuildContext context, String versionLabel) =>
      l10n(context).drawerAboutMessage(versionLabel);
  static String drawerDebugTitle(BuildContext context) =>
      l10n(context).drawerDebugTitle;
  static String drawerDebugLoadCorrectionTitle(BuildContext context) =>
      l10n(context).drawerDebugLoadCorrectionTitle;
  static String drawerDebugLoadCorrectionSubtitle(BuildContext context) =>
      l10n(context).drawerDebugLoadCorrectionSubtitle;
  static String drawerDebugLoadExhaustedTitle(BuildContext context) =>
      l10n(context).drawerDebugLoadExhaustedTitle;
  static String drawerDebugLoadExhaustedSubtitle(BuildContext context) =>
      l10n(context).drawerDebugLoadExhaustedSubtitle;
  static String drawerDebugResetEntitlementTitle(BuildContext context) =>
      l10n(context).drawerDebugResetEntitlementTitle;
  static String drawerDebugResetEntitlementSubtitle(BuildContext context) =>
      l10n(context).drawerDebugResetEntitlementSubtitle;
  static String contentModeAnimals(BuildContext context) =>
      l10n(context).contentModeAnimals;
  static String contentModeInstruments(BuildContext context) =>
      l10n(context).contentModeInstruments;
  static String contentModeButterflies(BuildContext context) =>
      l10n(context).contentModeButterflies;
  static String contentModeShells(BuildContext context) =>
      l10n(context).contentModeShells;
  static String contentModeOpera(BuildContext context) =>
      l10n(context).contentModeOpera;
  static String contentModeNumbers(BuildContext context) =>
      l10n(context).contentModeNumbers;
  static String topControlsProgress(BuildContext context) =>
      l10n(context).topControlsProgress;
  static String topControlsHelp(BuildContext context) =>
      l10n(context).topControlsHelp;
  static String appBarMenuTooltip(BuildContext context) =>
      l10n(context).appBarMenuTooltip;
  static String infoSheetDismiss(BuildContext context) =>
      l10n(context).infoSheetDismiss;
  static String drawerLanguageTitle(BuildContext context) =>
      l10n(context).drawerLanguageTitle;
  static String drawerLanguageReset(BuildContext context) =>
      l10n(context).drawerLanguageReset;
  static String languageEnglish(BuildContext context) =>
      l10n(context).languageEnglish;
  static String languageJapanese(BuildContext context) =>
      l10n(context).languageJapanese;

  static String _brandForPlatform(BuildContext context) {
    switch (ScreenshotMode.brandPlatform) {
      case 'ios':
        return l10n(context).appBrandIos;
      case 'android':
        return l10n(context).appBrandAndroid;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => l10n(context).appBrandIos,
      _ => l10n(context).appBrandAndroid,
    };
  }

  static String languageGerman(BuildContext context) =>
      l10n(context).languageGerman;
  static String languageFrench(BuildContext context) =>
      l10n(context).languageFrench;
  static String languageItalian(BuildContext context) =>
      l10n(context).languageItalian;
  static String languagePortuguese(BuildContext context) =>
      l10n(context).languagePortuguese;
  static String languageHindi(BuildContext context) =>
      l10n(context).languageHindi;
  static String languageSpanish(BuildContext context) =>
      l10n(context).languageSpanish;
}
