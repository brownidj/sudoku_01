import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_app/app/in_app_purchase_billing_service.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/ui/launch_screen.dart';

class SudokuApp extends StatefulWidget {
  final SudokuController? controller;

  const SudokuApp({super.key, this.controller});

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> with WidgetsBindingObserver {
  late final SudokuController _controller;
  static const Locale _fallbackLocale = Locale('en');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller =
        widget.controller ??
        SudokuController(billingService: InAppPurchaseBillingService());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_controller.flushGameSession());
      return;
    }
    if (state == AppLifecycleState.resumed) {
      unawaited(_controller.refreshEntitlement());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _controller.preferredLanguageCode == null
            ? null
            : Locale(_controller.preferredLanguageCode!),
        localeListResolutionCallback: (locales, supportedLocales) {
          if (_controller.preferredLanguageCode != null) {
            final preferredCode = _controller.preferredLanguageCode!;
            for (final supported in supportedLocales) {
              if (supported.languageCode == preferredCode) {
                return supported;
              }
            }
          }
          if (locales == null || locales.isEmpty) {
            return _fallbackLocale;
          }
          for (final deviceLocale in locales) {
            for (final supported in supportedLocales) {
              if (supported.languageCode == deviceLocale.languageCode) {
                return supported;
              }
            }
          }
          return _fallbackLocale;
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: LaunchScreen(controller: _controller),
      ),
    );
  }
}
