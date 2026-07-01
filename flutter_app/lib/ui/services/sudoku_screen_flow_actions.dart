import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/billing_service.dart';
import 'package:flutter_app/app/difficulty_labels.dart';
import 'package:flutter_app/app/premium_policy_service.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/domain/types.dart';
import 'package:flutter_app/ui/services/premium_explainer_sheet_service.dart';
import 'package:flutter_app/ui/services/sudoku_configuration_flow_service.dart';
import 'package:flutter_app/ui/ui_strings.dart';
import 'package:flutter_app/ui/widgets/info_sheet.dart';
import 'package:flutter_app/ui/widgets/progress_sheet.dart';
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
    VoidCallback? onConfirmed,
  }) {
    return _configurationFlowService.requestNewGame(
      context: context,
      isMounted: isMounted,
      state: controller.state,
      isCurrentGameResumed: false,
      onConfirmNewGame: controller.onNewGame,
      onConfirmed: onConfirmed,
    );
  }

  Future<void> showProgressSheet({
    required BuildContext context,
    required bool showExtendedMetrics,
    required int completedPuzzles,
    required int daysPlayed,
    required int streak,
    required Map<String, int> bestSolveTimeSecondsByDifficulty,
    required Future<void> Function() onResetProgressMetrics,
  }) {
    return showProgressSheetModal(
      context: context,
      showExtendedMetrics: showExtendedMetrics,
      completedPuzzles: completedPuzzles,
      daysPlayed: daysPlayed,
      streak: streak,
      bestSolveTimeSecondsByDifficulty: bestSolveTimeSecondsByDifficulty,
      onResetProgressMetrics: onResetProgressMetrics,
    );
  }

  Future<void> showLockedSettingsSheet({
    required BuildContext context,
    required SudokuController controller,
  }) {
    final message = _configurationFlowService.lockedSettingsMessage(context);
    return showInfoSheet(
      context: context,
      title: UiStrings.lockedSettingsTitle(context),
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

  Future<void> requestContentModeChange({
    required BuildContext context,
    required SudokuController controller,
    required String contentMode,
  }) async {
    if (!controller.isContentModeUnlocked(contentMode)) {
      await showPremiumFeatureLockedSheet(
        context: context,
        featureLabel: _premiumPolicyService.labelForFeatureKey('extra_themes'),
        onUnlockPremium: () =>
            requestPremiumUnlock(context: context, controller: controller),
      );
      return;
    }
    controller.onContentModeChanged(contentMode);
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
    if (!context.mounted) {
      return;
    }
    if (kDebugMode && result == BillingActionResult.productUnavailable) {
      controller.onSetEntitlement(Entitlement.premium);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debug fallback: premium unlocked locally (store product unavailable).',
          ),
        ),
      );
      return;
    }
    _showBillingResultMessage(
      context: context,
      result: result,
      diagnostics: controller.lastBillingDiagnostics,
      startedMessage: UiStrings.purchaseStartedMessage(context),
    );
  }

  Future<void> requestRestorePurchases({
    required BuildContext context,
    required SudokuController controller,
  }) async {
    final result = await controller.restorePurchases();
    if (!context.mounted) {
      return;
    }
    _showBillingResultMessage(
      context: context,
      result: result,
      diagnostics: controller.lastBillingDiagnostics,
      startedMessage: UiStrings.restoreStartedMessage(context),
    );
  }

  void _showBillingResultMessage({
    required BuildContext context,
    required BillingActionResult result,
    required String startedMessage,
    String? diagnostics,
  }) {
    final normalizedDiagnostics = diagnostics?.toLowerCase() ?? '';
    final suggestRestore =
        result == BillingActionResult.failed &&
        (normalizedDiagnostics.contains('already own') ||
            normalizedDiagnostics.contains('already owned') ||
            normalizedDiagnostics.contains('item already owned') ||
            normalizedDiagnostics.contains('duplicate product object') ||
            normalizedDiagnostics.contains(
              'storekit_duplicate_product_object',
            ));
    final baseMessage = switch (result) {
      BillingActionResult.started => startedMessage,
      BillingActionResult.unavailable => UiStrings.billingUnavailable(context),
      BillingActionResult.productNotConfigured =>
        UiStrings.billingProductNotConfigured(context),
      BillingActionResult.productUnavailable =>
        UiStrings.billingProductUnavailable(context),
      BillingActionResult.failed =>
        suggestRestore
            ? '${UiStrings.billingFailed(context)} If you already own Full Version, use Restore Purchases.'
            : UiStrings.billingFailed(context),
    };
    final includeDiagnostics =
        result == BillingActionResult.productUnavailable ||
        result == BillingActionResult.unavailable;
    final message =
        includeDiagnostics &&
            diagnostics != null &&
            diagnostics.trim().isNotEmpty
        ? '$baseMessage [$diagnostics]'
        : baseMessage;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
