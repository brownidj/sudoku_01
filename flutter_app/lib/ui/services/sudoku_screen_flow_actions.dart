import 'package:flutter/material.dart';
import 'package:flutter_app/app/billing_service.dart';
import 'package:flutter_app/app/difficulty_labels.dart';
import 'package:flutter_app/app/premium_policy_service.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/services/premium_explainer_sheet_service.dart';
import 'package:flutter_app/ui/services/sudoku_configuration_flow_service.dart';
import 'package:flutter_app/ui/widgets/info_sheet.dart';
import 'package:flutter_app/ui/widgets/premium_explainer_sheet.dart';

class SudokuScreenFlowActions {
  final SudokuConfigurationFlowService _configurationFlowService;
  final PremiumExplainerSheetService _premiumExplainerSheetService;
  final PremiumPolicyService _premiumPolicyService;

  const SudokuScreenFlowActions({
    SudokuConfigurationFlowService configurationFlowService =
        const SudokuConfigurationFlowService(),
    PremiumExplainerSheetService premiumExplainerSheetService =
        const PremiumExplainerSheetService(),
    PremiumPolicyService premiumPolicyService = const PremiumPolicyService(),
  }) : _configurationFlowService = configurationFlowService,
       _premiumExplainerSheetService = premiumExplainerSheetService,
       _premiumPolicyService = premiumPolicyService;

  Future<void> requestNewGame({
    required BuildContext context,
    required bool Function() isMounted,
    required SudokuController controller,
  }) {
    return _configurationFlowService.requestNewGame(
      context: context,
      isMounted: isMounted,
      state: controller.state,
      isCurrentGameResumed: false,
      onConfirmNewGame: controller.onNewGame,
    );
  }

  Future<void> showProgressSheet({
    required BuildContext context,
    required int completedPuzzles,
  }) {
    return showInfoSheet(
      context: context,
      title: 'Your Progress',
      message:
          'Completed puzzles: $completedPuzzles\n'
          'Days played: coming soon\n'
          'Streak: coming soon',
    );
  }

  Future<void> showLockedSettingsSheet({
    required BuildContext context,
    required SudokuController controller,
  }) {
    final message = _configurationFlowService.lockedSettingsMessage(
      controller.state,
    );
    return showInfoSheet(
      context: context,
      title: 'Board Settings Locked',
      message: message,
    );
  }

  Future<void> requestUnlockByStartingNewGame({
    required BuildContext context,
    required bool Function() isMounted,
    required SudokuController controller,
  }) {
    return _configurationFlowService.requestUnlockByStartingNewGame(
      context: context,
      isMounted: isMounted,
      state: controller.state,
      onConfirmNewGame: controller.onNewGame,
    );
  }

  Future<void> requestPuzzleModeChange({
    required BuildContext context,
    required bool Function() isMounted,
    required SudokuController controller,
    required String mode,
  }) {
    return _configurationFlowService.requestPuzzleModeChange(
      context: context,
      isMounted: isMounted,
      state: controller.state,
      mode: mode,
      onConfirmChange: controller.onPuzzleModeChanged,
    );
  }

  Future<void> requestDifficultyChange({
    required BuildContext context,
    required bool Function() isMounted,
    required SudokuController controller,
    required String difficulty,
  }) async {
    if (!controller.isDifficultyUnlocked(difficulty)) {
      await showPremiumFeatureLockedSheet(
        context: context,
        featureLabel: difficultyDisplayLabel(difficulty),
        onUnlockPremium: () =>
            requestPremiumUnlock(context: context, controller: controller),
      );
      return;
    }
    return _configurationFlowService.requestDifficultyChange(
      context: context,
      isMounted: isMounted,
      state: controller.state,
      difficulty: difficulty,
      onConfirmChange: controller.onSetDifficulty,
    );
  }

  Future<void> showPremiumFeatureLockedSheet({
    required BuildContext context,
    required String featureLabel,
    Future<void> Function()? onUnlockPremium,
  }) async {
    final action = await _premiumExplainerSheetService.show(
      context: context,
      featureLabel: featureLabel,
    );
    if (action == PremiumExplainerAction.unlock) {
      await onUnlockPremium?.call();
    }
  }

  Future<void> showPremiumFeatureLockedByKeySheet({
    required BuildContext context,
    required String featureKey,
    Future<void> Function()? onUnlockPremium,
  }) {
    return showPremiumFeatureLockedSheet(
      context: context,
      featureLabel: _premiumPolicyService.labelForFeatureKey(featureKey),
      onUnlockPremium: onUnlockPremium,
    );
  }

  Future<void> requestPremiumUnlock({
    required BuildContext context,
    required SudokuController controller,
  }) async {
    final result = await controller.buyPremium();
    _showBillingResultMessage(
      context: context,
      result: result,
      startedMessage:
          'Purchase started. Complete it in the store to unlock Premium.',
    );
  }

  Future<void> requestRestorePurchases({
    required BuildContext context,
    required SudokuController controller,
  }) async {
    final result = await controller.restorePurchases();
    _showBillingResultMessage(
      context: context,
      result: result,
      startedMessage: 'Restore started. Purchased items will reappear shortly.',
    );
  }

  void _showBillingResultMessage({
    required BuildContext context,
    required BillingActionResult result,
    required String startedMessage,
  }) {
    final message = switch (result) {
      BillingActionResult.started => startedMessage,
      BillingActionResult.unavailable =>
        'Purchases are unavailable on this device right now.',
      BillingActionResult.productNotConfigured =>
        'Premium is not configured yet. Please try again later.',
      BillingActionResult.productUnavailable =>
        'Premium product details could not be loaded. Please try again.',
      BillingActionResult.failed => 'That did not work. Please try again.',
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
