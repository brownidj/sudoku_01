import 'package:flutter/material.dart';

class BoardStyle {
  final Color boardBg;
  final Color cellDefault;
  final Color cellSelected;
  final Color cellPeerRowCol;
  final Color cellPeerBox;
  final Color cellConflict;
  final Color outlineSelected;
  final Color outlineConflict;
  final Color gridThin;
  final Color gridThick;
  final Color valueColor;
  final Color givenColor;
  final Color notesColor;
  final Color notesMiniBg;
  final Color statusBg;
  final Color notesBadgeBg;
  final Color notesBadgeOutline;
  final Color outlineGiven;
  final Color outlineCorrect;
  final Color outlineSolution;
  final Color highlightIncorrect;
  final Color highlightCorrect;
  final Color highlightGiven;
  final Color highlightSolution;

  const BoardStyle({
    required this.boardBg,
    required this.cellDefault,
    required this.cellSelected,
    required this.cellPeerRowCol,
    required this.cellPeerBox,
    required this.cellConflict,
    required this.outlineSelected,
    required this.outlineConflict,
    required this.gridThin,
    required this.gridThick,
    required this.valueColor,
    required this.givenColor,
    required this.notesColor,
    required this.notesMiniBg,
    required this.statusBg,
    required this.notesBadgeBg,
    required this.notesBadgeOutline,
    required this.outlineGiven,
    required this.outlineCorrect,
    required this.outlineSolution,
    required this.highlightIncorrect,
    required this.highlightCorrect,
    required this.highlightGiven,
    required this.highlightSolution,
  });
}

const BoardStyle styleModern = BoardStyle(
  boardBg: Colors.white,
  cellDefault: Colors.white,
  cellSelected: Color(0xFFCFE8FF),
  cellPeerRowCol: Color(0xFFEEF7FF),
  cellPeerBox: Color(0xFFF2F0FF),
  cellConflict: Color(0xFFF6A5A5),
  outlineSelected: Color(0xFF1E5AA8),
  outlineConflict: Color(0xFFA00000),
  gridThin: Color(0xFFB0B0B0),
  gridThick: Color(0xFF404040),
  valueColor: Color(0xFF222222),
  givenColor: Color(0xFF111111),
  notesColor: Color(0xFF555555),
  notesMiniBg: Color(0xFFF0E6FF),
  statusBg: Color(0xFFF5F5F5),
  notesBadgeBg: Color(0xFFCFE8FF),
  notesBadgeOutline: Color(0xFF1E5AA8),
  outlineGiven: Color(0xFFFFD54F),
  outlineCorrect: Color(0xFF2E8B57),
  outlineSolution: Color(0xFF1976D2),
  highlightIncorrect: Color(0xFFFFCDD2),
  highlightCorrect: Color(0xFFC8E6C9),
  highlightGiven: Color(0xFFFFF3C0),
  highlightSolution: Color(0xFFBBDEFB),
);

const BoardStyle styleClassic = BoardStyle(
  boardBg: Color(0xFFFAF7F2),
  cellDefault: Color(0xFFFAF7F2),
  cellSelected: Color(0xFFE6DDC6),
  cellPeerRowCol: Color(0xFFF1EAD9),
  cellPeerBox: Color(0xFFEDE4CF),
  cellConflict: Color(0xFFE6A0A0),
  outlineSelected: Color(0xFF6B5B3E),
  outlineConflict: Color(0xFF8B0000),
  gridThin: Color(0xFF8C7B5A),
  gridThick: Color(0xFF3E3626),
  valueColor: Color(0xFF2B2B2B),
  givenColor: Color(0xFF1A1A1A),
  notesColor: Color(0xFF6B6B6B),
  notesMiniBg: Color(0xFFF0E6FF),
  statusBg: Color(0xFFEFE9DC),
  notesBadgeBg: Color(0xFFE6DDC6),
  notesBadgeOutline: Color(0xFF6B5B3E),
  outlineGiven: Color(0xFFFFD54F),
  outlineCorrect: Color(0xFF2E8B57),
  outlineSolution: Color(0xFF1976D2),
  highlightIncorrect: Color(0xFFFFCDD2),
  highlightCorrect: Color(0xFFC8E6C9),
  highlightGiven: Color(0xFFFFF3C0),
  highlightSolution: Color(0xFFBBDEFB),
);

const BoardStyle styleHighContrast = BoardStyle(
  boardBg: Colors.white,
  cellDefault: Colors.white,
  cellSelected: Color(0xFFFFFF99),
  cellPeerRowCol: Color(0xFFE0E0E0),
  cellPeerBox: Color(0xFFD0D0D0),
  cellConflict: Color(0xFFFF6666),
  outlineSelected: Colors.black,
  outlineConflict: Colors.black,
  gridThin: Colors.black,
  gridThick: Colors.black,
  valueColor: Colors.black,
  givenColor: Colors.black,
  notesColor: Color(0xFF333333),
  notesMiniBg: Color(0xFFF0E6FF),
  statusBg: Color(0xFFE0E0E0),
  notesBadgeBg: Color(0xFFFFFF99),
  notesBadgeOutline: Colors.black,
  outlineGiven: Color(0xFFFFD54F),
  outlineCorrect: Color(0xFF2E8B57),
  outlineSolution: Color(0xFF1976D2),
  highlightIncorrect: Color(0xFFFFCDD2),
  highlightCorrect: Color(0xFFC8E6C9),
  highlightGiven: Color(0xFFFFF3C0),
  highlightSolution: Color(0xFFBBDEFB),
);

BoardStyle styleForName(String name) {
  switch (name) {
    case 'Classic':
      return styleClassic;
    case 'High Contrast':
      return styleHighContrast;
    default:
      return styleModern;
  }
}
