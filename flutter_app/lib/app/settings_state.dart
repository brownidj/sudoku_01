class SettingsState {
  final bool notesMode;
  final String difficulty;
  final bool canChangeDifficulty;
  final bool canChangePuzzleMode;
  final String styleName;
  final String contentMode;
  final String animalStyle;
  final String puzzleMode;

  const SettingsState({
    required this.notesMode,
    required this.difficulty,
    required this.canChangeDifficulty,
    required this.canChangePuzzleMode,
    required this.styleName,
    required this.contentMode,
    required this.animalStyle,
    required this.puzzleMode,
  });

  SettingsState copyWith({
    bool? notesMode,
    String? difficulty,
    bool? canChangeDifficulty,
    bool? canChangePuzzleMode,
    String? styleName,
    String? contentMode,
    String? animalStyle,
    String? puzzleMode,
  }) {
    return SettingsState(
      notesMode: notesMode ?? this.notesMode,
      difficulty: difficulty ?? this.difficulty,
      canChangeDifficulty: canChangeDifficulty ?? this.canChangeDifficulty,
      canChangePuzzleMode: canChangePuzzleMode ?? this.canChangePuzzleMode,
      styleName: styleName ?? this.styleName,
      contentMode: contentMode ?? this.contentMode,
      animalStyle: animalStyle ?? this.animalStyle,
      puzzleMode: puzzleMode ?? this.puzzleMode,
    );
  }
}
