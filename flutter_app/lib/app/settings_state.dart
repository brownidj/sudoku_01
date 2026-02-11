class SettingsState {
  final bool notesMode;
  final String difficulty;
  final bool canChangeDifficulty;
  final String styleName;
  final String contentMode;
  final String animalStyle;

  const SettingsState({
    required this.notesMode,
    required this.difficulty,
    required this.canChangeDifficulty,
    required this.styleName,
    required this.contentMode,
    required this.animalStyle,
  });

  SettingsState copyWith({
    bool? notesMode,
    String? difficulty,
    bool? canChangeDifficulty,
    String? styleName,
    String? contentMode,
    String? animalStyle,
  }) {
    return SettingsState(
      notesMode: notesMode ?? this.notesMode,
      difficulty: difficulty ?? this.difficulty,
      canChangeDifficulty: canChangeDifficulty ?? this.canChangeDifficulty,
      styleName: styleName ?? this.styleName,
      contentMode: contentMode ?? this.contentMode,
      animalStyle: animalStyle ?? this.animalStyle,
    );
  }
}
