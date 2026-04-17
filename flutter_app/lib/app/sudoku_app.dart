import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/sudoku_controller.dart';
import 'package:flutter_app/ui/launch_screen.dart';

class SudokuApp extends StatefulWidget {
  const SudokuApp({super.key});

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> with WidgetsBindingObserver {
  late final SudokuController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = SudokuController();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(useMaterial3: true);
    return MaterialApp(
      title: 'Sudoku',
      theme: baseTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        textTheme: baseTheme.textTheme.copyWith(
          bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            height: 1.35,
          ),
          bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            height: 1.35,
          ),
          bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
            fontSize: 14,
            height: 1.3,
          ),
          titleMedium: baseTheme.textTheme.titleMedium?.copyWith(fontSize: 18),
          labelMedium: baseTheme.textTheme.labelMedium?.copyWith(fontSize: 14),
          labelSmall: baseTheme.textTheme.labelSmall?.copyWith(fontSize: 13),
        ),
        listTileTheme: const ListTileThemeData(minVerticalPadding: 6),
        tooltipTheme: TooltipThemeData(
          waitDuration: const Duration(milliseconds: 300),
          showDuration: const Duration(seconds: 8),
          preferBelow: false,
          verticalOffset: 16,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.all(10),
          textStyle: baseTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade700,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: LaunchScreen(controller: _controller),
    );
  }
}
