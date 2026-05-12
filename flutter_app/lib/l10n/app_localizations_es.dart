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
  String get actionNewGame => 'Nuevo juego';

  @override
  String get actionPlay => 'Jugar';

  @override
  String get actionResume => 'Continuar';

  @override
  String get actionStartNewGame => 'Nuevo juego';

  @override
  String get actionPleaseWait => 'Espera...';

  @override
  String get tooltipNewGame => 'Pulsa para empezar un nuevo juego.';

  @override
  String get tooltipUndo => 'Usa Deshacer para retroceder y borrar selecciones anteriores. También puedes usarlo si te quedas sin correcciones.';

  @override
  String get tooltipClear => 'Borra la casilla seleccionada. Solo puedes borrar casillas que hayas rellenado tú.';

  @override
  String get tooltipNotes => 'Notas te permite guardar posibles opciones cuando no estás seguro. Las opciones se muestran en verde. Pulsa Notas otra vez para ocultarlas.';

  @override
  String get tooltipDifficulty => 'Elige el nivel de dificultad que te permita avanzar de forma constante.';

  @override
  String labelCorrections(int count) {
    return 'Correcciones: $count';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'Tienes $limit correcciones automáticas para este puzzle. Si un movimiento anterior bloquea tu progreso, puedes usar una corrección para continuar. Si se acaban, usa Deshacer.';
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
  String get helpBody => 'Hay ***algunas cosas*** en la pantalla del juego que pueden parecer misteriosas.\n\nPrueba a **mantener el dedo pulsado** unos segundos sobre ellas para ver una explicación.\n\nPor ejemplo, **Correcciones** muestra cuántas correcciones automáticas te quedan. Si un movimiento anterior deja el tablero sin opción válida, Correcciones puede arreglar ese bloqueo automáticamente para que sigas jugando.\n\nUsa **Deshacer** para retroceder por tus selecciones anteriores, una por una. También sirve si te quedas sin correcciones.';

  @override
  String get startInstruction => 'Para empezar, selecciona una casilla a la que quieras añadir un icono.\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies te traen';

  @override
  String get launchTitle => 'SuDoKu Playtime';

  @override
  String get launchSubtitle => 'Tómate tu tiempo, disfruta cada puzzle y mantén tu mente activa.';

  @override
  String get launchErrorOpenGame => 'No se pudo abrir el juego. Inténtalo de nuevo.';

  @override
  String get launchHintsTitle => 'Consejos';

  @override
  String get tooltipPrevHint => 'Consejo anterior';

  @override
  String get tooltipNextHint => 'Siguiente consejo';

  @override
  String get launchHint1 => 'Notas te permite guardar posibles opciones cuando no estás seguro. Las opciones aparecen en verde. Pulsa Notas otra vez para ocultarlas.';

  @override
  String get launchHint2 => 'Usa una pulsación larga (mantén el dedo unos segundos) para entender qué hace cada elemento. Pruébalo también en una casilla rellenada.';

  @override
  String get launchHint3 => 'Si tu elección vuelve rosas dos o más casillas, en algún momento hubo un error. Tienes un número limitado de autocorrecciones.';

  @override
  String get launchHint4 => 'Cambiar la dificultad durante una partida iniciará una nueva partida.';

  @override
  String get launchHint5 => 'Pulsa Ayuda para ver información sobre cómo jugar.';

  @override
  String get launchHint6 => 'Al pulsar ☰ (arriba a la derecha) se abre un menú con varias opciones.';

  @override
  String get launchHint7 => 'Si los sonidos te molestan o quieres jugar en silencio, puedes desactivar Audio en el menú (☰).';

  @override
  String get launchHint8 => 'Pulsa el icono de música una vez para apagar la música de fondo o dos veces seguidas para encenderla.';

  @override
  String get launchHint9 => 'El dado inicia una partida nueva.';

  @override
  String get launchHint10 => 'Si compraste la versión completa y no aparece tras una actualización, usa « Restaurar compras » desde el menú.';

  @override
  String get dialogActionCancel => 'Cancelar';

  @override
  String get dialogActionStartNewGame => 'Iniciar juego nuevo';

  @override
  String get dialogActionUseCorrection => 'Usar corrección';

  @override
  String get dialogUnlockSettingsTitle => '¿Desbloquear ajustes?';

  @override
  String get dialogUnlockSettingsMessage => 'Desbloquear la dificultad iniciará una nueva partida y reiniciará este tablero. ¿Continuar?';

  @override
  String get dialogStartNewGameTitle => '¿Iniciar juego nuevo?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return '¿Cambiar la dificultad a $difficultyLabel e iniciar un nuevo juego?';
  }

  @override
  String get dialogStartNewGameResetBoard => '¿Iniciar una partida nueva y reiniciar este tablero?';

  @override
  String get labelLockedSettingsTitle => 'Ajustes del tablero bloqueados';

  @override
  String get labelLockedSettingsMessage => 'La dificultad está bloqueada durante una partida. Para desbloquearla, toca dos veces el icono de candado o inicia un \'Nuevo juego\'.';

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
  String get progressResetDialogMessage => 'Tus datos de «¿Cómo voy?» se perderán.';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile => 'El audio todavía no está disponible para esta casilla.';

  @override
  String get correctionPromptMessage => 'Este tablero es irresoluble por un movimiento anterior. ¿Usar 1 corrección?';

  @override
  String get premiumFeatureIntroGeneric => 'La versión completa te da la experiencia Sudoku completa en una sola compra.';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel está disponible en la versión completa.';
  }

  @override
  String get premiumSheetTitle => 'Desbloquear versión completa';

  @override
  String get premiumIncludesTitle => 'La versión completa incluye:';

  @override
  String get premiumIncludesHardDifficulties => '• Dificultades Difícil y Casi imposible';

  @override
  String get premiumIncludesProgress => '• Seguimiento de progreso y mejores marcas personales';

  @override
  String get premiumIncludesThemesSounds => '• Temas, sonidos y celebraciones extra';

  @override
  String get premiumOneTimePurchase => 'Compra única. Sin suscripción.';

  @override
  String get premiumActionNotNow => 'Ahora no';

  @override
  String get premiumActionUnlock => 'Desbloquear versión completa';

  @override
  String get purchaseStartedMessage => 'Confirma la compra en el diálogo de App Store para desbloquear la versión completa.';

  @override
  String get restoreStartedMessage => 'Restauración iniciada. Tus compras reaparecerán en breve.';

  @override
  String get billingUnavailable => 'Las compras no están disponibles en este dispositivo ahora mismo.';

  @override
  String get billingProductNotConfigured => 'La versión completa todavía no está configurada. Inténtalo más tarde.';

  @override
  String get billingProductUnavailable => 'No se pudieron cargar los detalles del producto versión completa. Inténtalo de nuevo.';

  @override
  String get billingFailed => 'No funcionó. Inténtalo de nuevo.';

  @override
  String get drawerTitle => 'SuDoKu Playtime';

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
  String get drawerBackgroundMusicSubtitle => 'Sonidos para amantes del SuDoKu';

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
  String get drawerPremiumProgressSubtitle => 'Sigue puzzles completados e hitos.';

  @override
  String get drawerPremiumThemesTitle => 'Temas extra 🔒';

  @override
  String get drawerPremiumThemesSubtitle => 'Desbloquea estilos visuales adicionales.';

  @override
  String get drawerPremiumSoundsTitle => 'Sonidos y celebraciones 🔒';

  @override
  String get drawerPremiumSoundsSubtitle => 'Desbloquea sonidos y celebraciones extra.';

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
    return 'Versión: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\nasesor técnico - Icy';
  }

  @override
  String get drawerDebugTitle => 'Debug';

  @override
  String get drawerDebugLoadCorrectionTitle => 'Cargar escenario de corrección';

  @override
  String get drawerDebugLoadCorrectionSubtitle => 'Control temporal para pruebas de recuperación asistida.';

  @override
  String get drawerDebugLoadExhaustedTitle => 'Cargar escenario sin correcciones';

  @override
  String get drawerDebugLoadExhaustedSubtitle => 'Control temporal para pruebas de recuperación solo con deshacer.';

  @override
  String get drawerDebugResetEntitlementTitle => 'Reiniciar versión completa (Debug)';

  @override
  String get drawerDebugResetEntitlementSubtitle => 'Establece el entitlement local en Free para volver a probar compras.';

  @override
  String get contentModeAnimals => 'Animales (fácil)';

  @override
  String get contentModeInstruments => 'Instrumentos (difícil)';

  @override
  String get contentModeButterflies => 'Mariposas (bonito)';

  @override
  String get contentModeOpera => 'Ópera (sorprendente)';

  @override
  String get contentModeNumbers => 'Números (clásico)';

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
  String get statusDifficultyChangeBlocked => 'Termina o inicia un nuevo juego antes de cambiar la dificultad';

  @override
  String get statusDifficultyPremiumOnly => 'Esta dificultad está disponible en la versión completa.';

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
  String get statusContradictionUseUndo => 'Contradicción detectada. Usa Undo para recuperar.';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'Nuevo juego ($difficulty): $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count casilla(s) corregida(s).';
  }
}
