// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get actionUndo => 'Deshacer';

  @override
  String get actionClear => 'Borrar';

  @override
  String get actionNotes => 'Notas';

  @override
  String get actionNewShort => 'Nuevo';

  @override
  String get actionNewGame => 'Nuevo\njuego';

  @override
  String get actionPlay => 'Jugar';

  @override
  String get actionResume => 'Continuar';

  @override
  String get actionStartNewGame => 'Nuevo juego';

  @override
  String get actionPleaseWait => 'Espera...';

  @override
  String get tooltipNewGame => 'Pulsa aquí para empezar una partida nueva.';

  @override
  String get tooltipUndo =>
      'Usa Deshacer para quitar tus últimas jugadas. También te sirve si te quedas sin correcciones.';

  @override
  String get tooltipClear =>
      'Borra la casilla seleccionada. Solo puedes borrar casillas que hayas rellenado tú.';

  @override
  String get tooltipNotes =>
      'Notas te ayuda a marcar opciones posibles cuando aún no lo tienes claro. Se verán en verde. Pulsa Notas otra vez para quitarlas.';

  @override
  String get tooltipDifficulty =>
      'Elige la dificultad que te resulte más cómoda.';

  @override
  String candidateLongPressToast(int digit) {
    return 'Candidato $digit';
  }

  @override
  String labelCorrections(int count) {
    return 'Correcciones: $count';
  }

  @override
  String labelElapsedTime(String time) {
    return 'Tiempo: $time';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'Tienes $limit correcciones automáticas para este puzzle. Si una jugada anterior te deja atascado, usa una corrección para seguir. Si se te acaban, usa Deshacer.';
  }

  @override
  String get difficultyEasy => 'FÁCIL';

  @override
  String get difficultyMedium => 'UN POCO MÁS DIFÍCIL';

  @override
  String get difficultyHard => 'MUCHO MÁS DIFÍCIL';

  @override
  String get difficultyVeryHard => 'CASI IMPOSIBLE';

  @override
  String get helpTitle => 'Ayuda';

  @override
  String get helpDismiss => 'OK';

  @override
  String get helpBody =>
      'En la pantalla del juego hay ***algunas cosas*** que quizá no se entienden a la primera.\n\nDéjalas **pulsadas unos segundos** y verás una explicación.\n\nPor ejemplo, **Correcciones** te dice cuántas correcciones automáticas te quedan. Si una jugada anterior te deja sin opciones válidas, una corrección puede arreglar ese atasco para que sigas jugando.\n\nCon **Deshacer** puedes quitar tus últimas jugadas una a una. También viene bien si te quedas sin correcciones.';

  @override
  String get startInstruction =>
      'Para empezar, selecciona una casilla a la que quieras añadir un icono.\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies te traen';

  @override
  String get launchTitle => 'SuDoKu Fresh';

  @override
  String get appBrandIos => 'SuDoKu Playtime';

  @override
  String get appBrandAndroid => 'SuDoKu Fresh';

  @override
  String get launchSubtitle => 'Sudoku relajante con imágenes';

  @override
  String get launchErrorOpenGame =>
      'No se pudo abrir el juego. Inténtalo de nuevo.';

  @override
  String get launchHintsTitle => 'Consejos';

  @override
  String get tooltipPrevHint => 'Consejo anterior';

  @override
  String get tooltipNextHint => 'Siguiente consejo';

  @override
  String get launchHint1 =>
      'Con Notas puedes apuntar opciones posibles. Pulsa Notas otra vez para quitarlas.';

  @override
  String get launchHint2 =>
      'Mantén pulsado unos dos segundos para ver qué hace cada cosa. Pruébalo en una casilla con imagen.';

  @override
  String get launchHint3 =>
      'Si al elegir aparecen dos o más casillas rosas, antes hubo un error. Puedes autocorregir.';

  @override
  String get launchHint4 =>
      'Cambiar la dificultad durante una partida iniciará una nueva partida.';

  @override
  String get launchHint5 =>
      'Pulsa Ayuda si quieres ver cómo funciona el juego.';

  @override
  String get launchHint6 => 'Pulsa ☰ arriba a la derecha para abrir el menú.';

  @override
  String get launchHint7 =>
      'Si los sonidos te molestan o quieres jugar en silencio, puedes desactivar Audio en el menú (☰).';

  @override
  String get launchHint8 =>
      'Pulsa el icono de música una vez para apagarla o dos veces seguidas para volver a encenderla.';

  @override
  String get launchHint9 => 'El dado inicia una partida nueva.';

  @override
  String get launchHint10 =>
      'Si compraste la versión completa y no aparece, usa «Restaurar compras» en el menú.';

  @override
  String get victoryMessage1 => '¡Muy bien! ¡Juega otra vez!';

  @override
  String get victoryMessage2 => '¡Genial! ¡Juega otra vez!';

  @override
  String get victoryMessage3 => '¡Lo lograste! ¡Juega otra vez!';

  @override
  String get victoryMessage4 => '¡Qué bien! ¡Juega otra vez!';

  @override
  String get victoryMessage5 => '¡Buen trabajo! ¡Juega otra vez!';

  @override
  String get victoryMessage6 => '¡Bien hecho! ¡Juega otra vez!';

  @override
  String get victoryMessage7 => '¡Lo conseguiste! ¡Juega otra vez!';

  @override
  String get victoryMessage8 => '¡Qué bueno! ¡Juega otra vez!';

  @override
  String get victoryMessage9 => '¡Para estar orgulloso! ¡Juega otra vez!';

  @override
  String get victoryMessage10 => '¡Sigue así! ¡Juega otra vez!';

  @override
  String get victoryMessage11 => '¡Qué pasada! ¡Juega otra vez!';

  @override
  String get victoryMessage12 => '¡Fantástico! ¡Juega otra vez!';

  @override
  String get victoryMessage13 => '¡Perfecto! ¡Juega otra vez!';

  @override
  String get victoryMessage14 => '¡Muy buena partida! ¡Juega otra vez!';

  @override
  String get victoryMessage15 => '¡Qué bien pensado! ¡Juega otra vez!';

  @override
  String get victoryMessage16 => '¡Victoria! ¡Juega otra vez!';

  @override
  String get victoryMessage17 => '¡Muy bien jugado! ¡Juega otra vez!';

  @override
  String get victoryMessage18 => '¡Partidaza! ¡Juega otra vez!';

  @override
  String get victoryMessage19 => '¡Mentalidad ganadora! ¡Juega otra vez!';

  @override
  String get victoryMessage20 => '¡Resultado genial! ¡Juega otra vez!';

  @override
  String get dialogActionCancel => 'Cancelar';

  @override
  String get dialogActionStartNewGame => 'Iniciar juego nuevo';

  @override
  String get dialogActionUseCorrection => 'Usar corrección';

  @override
  String get dialogUnlockSettingsTitle => '¿Desbloquear ajustes?';

  @override
  String get dialogUnlockSettingsMessage =>
      'Si desbloqueas la dificultad, empezará una partida nueva y este tablero se reiniciará. ¿Continuar?';

  @override
  String get dialogStartNewGameTitle => '¿Iniciar juego nuevo?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return '¿Cambiar la dificultad a $difficultyLabel e iniciar un nuevo juego?';
  }

  @override
  String get dialogStartNewGameResetBoard =>
      '¿Empezar una partida nueva y reiniciar el tablero actual?';

  @override
  String get labelLockedSettingsTitle => 'Ajustes del tablero bloqueados';

  @override
  String get labelLockedSettingsMessage =>
      'La dificultad está bloqueada durante la partida. Para desbloquearla, toca dos veces el candado o empieza una partida nueva.';

  @override
  String get progressSheetTitle => 'Tu progreso';

  @override
  String progressSheetBody(int completedPuzzles) {
    return 'Puzzles completados: $completedPuzzles\nDías jugados: próximamente\nRacha: próximamente';
  }

  @override
  String progressCompletedPuzzles(int count) {
    return 'Puzzles completados: $count';
  }

  @override
  String progressDaysPlayed(int count) {
    return 'Días jugados: $count';
  }

  @override
  String progressStreak(int count) {
    return 'Racha: $count';
  }

  @override
  String get progressBestSolveTimesTitle => 'Mejores tiempos:';

  @override
  String progressBestSolveTimeRow(String difficulty, String time) {
    return '• $difficulty: $time';
  }

  @override
  String get progressBestSolveTimeMissing => '--';

  @override
  String get progressResetAction => 'Restablecer';

  @override
  String get progressResetDialogTitle => '¿Restablecer progreso?';

  @override
  String get progressResetDialogMessage => 'Se perderá todo tu progreso.';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile =>
      'El audio todavía no está disponible para esta casilla.';

  @override
  String get correctionPromptMessage =>
      'Este tablero es irresoluble por un movimiento anterior. ¿Usar 1 corrección?';

  @override
  String get premiumFeatureIntroGeneric =>
      'La versión completa te da toda la experiencia SuDoKu en una sola compra.';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel está en la versión completa.';
  }

  @override
  String get premiumSheetTitle => 'Desbloquear versión completa';

  @override
  String get premiumIncludesTitle => 'La versión completa incluye:';

  @override
  String get premiumIncludesHardDifficulties =>
      '• Dificultades Difícil y Casi imposible';

  @override
  String get premiumIncludesProgress =>
      '• Seguimiento de progreso y mejores marcas personales';

  @override
  String get premiumIncludesThemesSounds =>
      '• Temas, sonidos y celebraciones extra';

  @override
  String get premiumOneTimePurchase => 'Compra única. Sin suscripción.';

  @override
  String get premiumActionNotNow => 'Ahora no';

  @override
  String get premiumActionUnlock => 'Desbloquear versión completa';

  @override
  String get purchaseStartedMessage =>
      'Confirma la compra en el diálogo de App Store para desbloquear la versión completa.';

  @override
  String get restoreStartedMessage =>
      'Restauración iniciada. Tus compras volverán a aparecer en un momento.';

  @override
  String get billingUnavailable =>
      'Ahora mismo no se pueden hacer compras en este dispositivo.';

  @override
  String get billingProductNotConfigured =>
      'La versión completa todavía no está disponible. Inténtalo más tarde.';

  @override
  String get billingProductUnavailable =>
      'No se pudieron cargar los datos de la versión completa. Inténtalo de nuevo.';

  @override
  String get billingFailed => 'No funcionó. Inténtalo de nuevo.';

  @override
  String get drawerTitle => 'SuDoKu Fresh';

  @override
  String get drawerPuzzleStyleTitle => 'Estilo de puzzle';

  @override
  String get styleModern => 'Moderno';

  @override
  String get styleClassic => 'Clásico';

  @override
  String get styleHighContrast => 'Alto contraste';

  @override
  String get drawerAudioTitle => 'Audio';

  @override
  String get labelOn => 'On';

  @override
  String get labelOff => 'Off';

  @override
  String get drawerBackgroundMusicTitle => 'Música de fondo';

  @override
  String get drawerBackgroundMusicSubtitle =>
      'Música para una partida tranquila';

  @override
  String get musicControlsTooltip =>
      'Aquí puedes controlar la música de fondo. Pulsa una vez para apagarla y dos veces seguidas para volver a encenderla. Usa < y > para ir a la anterior o a la siguiente.';

  @override
  String get drawerVolumeTitle => 'Volumen';

  @override
  String get drawerVersionTitle => 'Versión';

  @override
  String get drawerVersionFull => 'Completa';

  @override
  String get drawerVersionFree => 'Gratis';

  @override
  String get drawerPremiumProgressTitle => 'Seguimiento de progreso 🔒';

  @override
  String get drawerPremiumProgressSubtitle =>
      'Sigue puzzles completados e hitos.';

  @override
  String get drawerPremiumThemesTitle => 'Temas extra 🔒';

  @override
  String get drawerPremiumThemesSubtitle =>
      'Desbloquea estilos visuales adicionales.';

  @override
  String get drawerPremiumSoundsTitle => 'Sonidos y celebraciones 🔒';

  @override
  String get drawerPremiumSoundsSubtitle =>
      'Desbloquea sonidos y celebraciones extra.';

  @override
  String get drawerUnlockFullVersion => 'Desbloquear versión completa';

  @override
  String get drawerRestorePurchases => 'Restaurar compras';

  @override
  String get drawerAboutChip => 'Acerca de';

  @override
  String get drawerAboutTitle => 'Acerca de';

  @override
  String drawerAboutMessage(String versionLabel) {
    return 'Versión: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\nasesor técnico - Icy\n\nNingún miembro del equipo de desarrollo es artista ni músico. Admitimos sin rodeos que hemos utilizado IA para crear este contenido. Todos somos muy mayores; valoramos la oportunidad de expresar nuestra creatividad hasta donde llegue.';
  }

  @override
  String get drawerDebugTitle => 'Debug';

  @override
  String get drawerDebugLoadCorrectionTitle => 'Cargar escenario de corrección';

  @override
  String get drawerDebugLoadCorrectionSubtitle =>
      'Control temporal para pruebas de recuperación asistida.';

  @override
  String get drawerDebugLoadExhaustedTitle =>
      'Cargar escenario sin correcciones';

  @override
  String get drawerDebugLoadExhaustedSubtitle =>
      'Control temporal para pruebas de recuperación solo con deshacer.';

  @override
  String get drawerDebugResetEntitlementTitle =>
      'Reiniciar versión completa (Debug)';

  @override
  String get drawerDebugResetEntitlementSubtitle =>
      'Establece el entitlement local en Free para volver a probar compras.';

  @override
  String get contentModeAnimals => 'Animales (fácil)';

  @override
  String get contentModeInstruments => 'Instrumentos (difícil)';

  @override
  String get contentModeButterflies => 'Mariposas (bonito)';

  @override
  String get contentModeShells => 'Conchas (nuevo)';

  @override
  String get contentModeOpera => 'Ópera (sorprendente)';

  @override
  String get contentModeNumbers => 'Números (clásico)';

  @override
  String get appBarMenuTooltip =>
      'Pulsa aquí para abrir el panel. Usa el menú para cambiar animales y estilo.';

  @override
  String get topControlsProgress => '¿Cómo voy?';

  @override
  String get topControlsHelp => 'Ayuda';

  @override
  String get infoSheetDismiss => 'Entendido';

  @override
  String get drawerLanguageTitle => 'Idioma';

  @override
  String get drawerLanguageReset => 'Restablecer al idioma del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageSpanish => 'Español';

  @override
  String statusUnknownDifficulty(String difficulty) {
    return 'Dificultad desconocida: $difficulty';
  }

  @override
  String get statusDifficultyChangeBlocked =>
      'Termina o inicia un nuevo juego antes de cambiar la dificultad';

  @override
  String get statusDifficultyPremiumOnly =>
      'Esta dificultad está disponible en la versión completa.';

  @override
  String get statusPuzzleModeUnique => 'Modo puzzle: unique';

  @override
  String get statusSessionRestored => 'Sesión restaurada';

  @override
  String get statusCellSelected => 'Casilla seleccionada';

  @override
  String get statusEntitlementRefreshed => 'Entitlement actualizado';

  @override
  String get statusEntitlementUpdated => 'Entitlement modificado';

  @override
  String get statusCheckComplete => 'Comprobación completada';

  @override
  String get statusSolution => 'Solución';

  @override
  String get statusSolved => 'Resuelto.';

  @override
  String get statusContradictionUseUndo =>
      'Contradicción detectada. Usa Undo para recuperar.';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'Nuevo juego ($difficulty): $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count casilla(s) corregida(s).';
  }
}
