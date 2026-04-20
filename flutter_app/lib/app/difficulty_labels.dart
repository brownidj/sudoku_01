String difficultyDisplayLabel(String difficulty) {
  switch (difficulty.trim().toLowerCase()) {
    case 'easy':
      return 'EASY';
    case 'medium':
      return 'A BIT HARDER';
    case 'hard':
      return 'MUCH HARDER';
    case 'very_hard':
      return 'NIGH IMPOSSIBLE';
    default:
      return difficulty;
  }
}
