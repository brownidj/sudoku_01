// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get actionUndo => 'Desfazer';

  @override
  String get actionClear => 'Limpar';

  @override
  String get actionNotes => 'Notas';

  @override
  String get actionNewGame => 'Novo jogo';

  @override
  String get actionPlay => 'Jogar';

  @override
  String get actionResume => 'Retomar';

  @override
  String get actionStartNewGame => 'Novo jogo';

  @override
  String get actionPleaseWait => 'Aguarde...';

  @override
  String get tooltipNewGame => 'Pressione para iniciar um novo jogo.';

  @override
  String get tooltipUndo => 'Use Desfazer para voltar um passo e limpar seleções anteriores. Também pode usar isto se ficar sem Correções.';

  @override
  String get tooltipClear => 'Use isto para limpar a casa atualmente selecionada. Só pode limpar casas que você preencheu.';

  @override
  String get tooltipNotes => 'Notas permite adicionar lembretes de possibilidades quando não tem certeza. As opções aparecem em verde. Pressione Notas novamente para desativá-las.';

  @override
  String get tooltipDifficulty => 'Escolha o nível de desafio que permita progresso diário consistente.';

  @override
  String labelCorrections(int count) {
    return 'Correções: $count';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'Tem $limit correções automáticas disponíveis para este puzzle. Se uma jogada anterior bloquear o seu progresso, pode usar uma correção para continuar. Se acabarem, use Desfazer.';
  }

  @override
  String get difficultyEasy => 'FÁCIL';

  @override
  String get difficultyMedium => 'UM POUCO MAIS DIFÍCIL';

  @override
  String get difficultyHard => 'MUITO MAIS DIFÍCIL';

  @override
  String get difficultyVeryHard => 'QUASE IMPOSSÍVEL';

  @override
  String get helpTitle => 'Ajuda';

  @override
  String get helpDismiss => 'OK';

  @override
  String get helpBody => 'Há ***algumas coisas*** no ecrã do jogo que podem parecer um pouco misteriosas.\n\nTente **manter o dedo pressionado** por alguns segundos para ver uma explicação.\n\nPor exemplo, **Correções** mostra quantas correções automáticas ainda tem. Se uma jogada anterior criar um bloqueio sem opções válidas, Correções pode resolver esse impasse automaticamente e permitir que continue.\n\nUse **Desfazer** para voltar pelas seleções anteriores, uma de cada vez. Isto também ajuda quando ficar sem Correções.';

  @override
  String get startInstruction => 'Para começar, selecione uma casa onde quer adicionar um ícone.\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies apresentam';

  @override
  String get launchTitle => 'SuDoKu Playtime';

  @override
  String get launchSubtitle => 'Vá com calma, aproveite cada puzzle e mantenha a mente ativa.';

  @override
  String get launchErrorOpenGame => 'Não foi possível abrir o jogo. Tente novamente.';

  @override
  String get launchHintsTitle => 'Dicas';

  @override
  String get tooltipPrevHint => 'Dica anterior';

  @override
  String get tooltipNextHint => 'Próxima dica';

  @override
  String get launchHint1 => 'Notas permite guardar lembretes de possibilidades quando não tem certeza. As opções aparecem em verde. Pressione Notas novamente para desativá-las.';

  @override
  String get launchHint2 => 'Use um toque longo (mantenha o dedo por alguns segundos) para entender o que alguns elementos fazem. Experimente também numa casa já preenchida.';

  @override
  String get launchHint3 => 'Se a sua escolha deixar duas ou mais casas cor-de-rosa, houve um erro em algum momento. Tem um número limitado de auto-correções.';

  @override
  String get launchHint4 => 'Mudar a dificuldade durante um jogo inicia um novo jogo.';

  @override
  String get launchHint5 => 'Pressione Ajuda para obter informações sobre como jogar.';

  @override
  String get launchHint6 => 'Ao pressionar ☰ (canto superior direito), abre um menu com várias opções.';

  @override
  String get launchHint7 => 'Se os sons incomodarem ou se quiser jogar em silêncio, pode desligar o Áudio no menu (☰).';

  @override
  String get launchHint8 => 'Pressione o ícone de música uma vez para desligar a música de fundo, ou duas vezes rapidamente para ligar novamente.';

  @override
  String get launchHint9 => 'O dado inicia um novo jogo.';

  @override
  String get launchHint10 => 'Se comprou a versão completa e ela não aparecer após uma atualização, use « Restaurar compras » no menu.';

  @override
  String get dialogActionCancel => 'Cancelar';

  @override
  String get dialogActionStartNewGame => 'Iniciar novo jogo';

  @override
  String get dialogActionUseCorrection => 'Usar correção';

  @override
  String get dialogUnlockSettingsTitle => 'Desbloquear configurações?';

  @override
  String get dialogUnlockSettingsMessage => 'Desbloquear a dificuldade iniciará um novo jogo e redefinirá este tabuleiro. Continuar?';

  @override
  String get dialogStartNewGameTitle => 'Iniciar novo jogo?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return 'Mudar a dificuldade para $difficultyLabel e iniciar um novo jogo?';
  }

  @override
  String get dialogStartNewGameResetBoard => 'Iniciar um novo jogo e redefinir este tabuleiro?';

  @override
  String get labelLockedSettingsTitle => 'Configurações do tabuleiro bloqueadas';

  @override
  String get labelLockedSettingsMessage => 'A dificuldade fica bloqueada durante um jogo. Para desbloquear, toque duas vezes no ícone de cadeado ou inicie um \'Novo jogo\'.';

  @override
  String get progressSheetTitle => 'Seu progresso';

  @override
  String progressSheetBody(int completedPuzzles) {
    return 'Puzzles concluídos: $completedPuzzles\nDias jogados: em breve\nSequência: em breve';
  }

  @override
  String progressCompletedPuzzles(int count) {
    return 'Puzzles concluídos: $count';
  }

  @override
  String progressDaysPlayed(int count) {
    return 'Dias jogados: $count';
  }

  @override
  String progressStreak(int count) {
    return 'Sequência: $count';
  }

  @override
  String get progressBestSolveTimesTitle => 'Melhores tempos:';

  @override
  String progressBestSolveTimeRow(String difficulty, String time) {
    return '• $difficulty: $time';
  }

  @override
  String get progressBestSolveTimeMissing => '--';

  @override
  String get progressResetAction => 'Repor';

  @override
  String get progressResetDialogTitle => 'Repor progresso?';

  @override
  String get progressResetDialogMessage => 'Os seus dados de «Como estou indo?» serão perdidos.';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile => 'O áudio ainda não está disponível para esta casa.';

  @override
  String get correctionPromptMessage => 'Este tabuleiro está sem solução devido a uma jogada anterior. Usar 1 correção?';

  @override
  String get premiumFeatureIntroGeneric => 'A Versão Completa oferece a experiência Sudoku completa numa única compra.';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel está disponível na Versão Completa.';
  }

  @override
  String get premiumSheetTitle => 'Desbloquear versão completa';

  @override
  String get premiumIncludesTitle => 'A versão completa inclui:';

  @override
  String get premiumIncludesHardDifficulties => '• Dificuldades Difícil e Quase impossível';

  @override
  String get premiumIncludesProgress => '• Acompanhamento de progresso e melhores marcas';

  @override
  String get premiumIncludesThemesSounds => '• Temas, sons e celebrações extra';

  @override
  String get premiumOneTimePurchase => 'Compra única. Sem subscrição.';

  @override
  String get premiumActionNotNow => 'Agora não';

  @override
  String get premiumActionUnlock => 'Desbloquear versão completa';

  @override
  String get purchaseStartedMessage => 'Confirme a compra na janela da App Store para desbloquear a Versão Completa.';

  @override
  String get restoreStartedMessage => 'Restauro iniciado. Os itens comprados voltarão a aparecer em breve.';

  @override
  String get billingUnavailable => 'As compras estão indisponíveis neste dispositivo neste momento.';

  @override
  String get billingProductNotConfigured => 'A Versão Completa ainda não está configurada. Tente novamente mais tarde.';

  @override
  String get billingProductUnavailable => 'Não foi possível carregar os detalhes do produto da Versão Completa. Tente novamente.';

  @override
  String get billingFailed => 'Não foi possível concluir. Tente novamente.';

  @override
  String get drawerTitle => 'SuDoKu Playtime';

  @override
  String get drawerPuzzleStyleTitle => 'Estilo do puzzle';

  @override
  String get styleModern => 'Moderno';

  @override
  String get styleClassic => 'Clássico';

  @override
  String get styleHighContrast => 'Alto contraste';

  @override
  String get drawerAudioTitle => 'Audio';

  @override
  String get labelOn => 'Ligado';

  @override
  String get labelOff => 'Desligado';

  @override
  String get drawerBackgroundMusicTitle => 'Música de fundo';

  @override
  String get drawerBackgroundMusicSubtitle => 'Sons para amantes de Sudoku';

  @override
  String get drawerVolumeTitle => 'Volume';

  @override
  String get drawerVersionTitle => 'Version';

  @override
  String get drawerVersionFull => 'Completa';

  @override
  String get drawerVersionFree => 'Grátis';

  @override
  String get drawerPremiumProgressTitle => 'Acompanhamento de progresso 🔒';

  @override
  String get drawerPremiumProgressSubtitle => 'Acompanhe puzzles concluídos e marcos.';

  @override
  String get drawerPremiumThemesTitle => 'Temas extra 🔒';

  @override
  String get drawerPremiumThemesSubtitle => 'Desbloqueie estilos visuais adicionais.';

  @override
  String get drawerPremiumSoundsTitle => 'Sons e celebrações 🔒';

  @override
  String get drawerPremiumSoundsSubtitle => 'Desbloqueie sons e celebrações extra.';

  @override
  String get drawerUnlockFullVersion => 'Desbloquear versão completa';

  @override
  String get drawerRestorePurchases => 'Restaurar compras';

  @override
  String get drawerAboutChip => 'Sobre';

  @override
  String get drawerAboutTitle => 'Sobre';

  @override
  String drawerAboutMessage(String versionLabel) {
    return 'Version: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy';
  }

  @override
  String get drawerDebugTitle => 'Debug';

  @override
  String get drawerDebugLoadCorrectionTitle => 'Carregar cenário de correção';

  @override
  String get drawerDebugLoadCorrectionSubtitle => 'Controlo temporário para testes de recuperação assistida.';

  @override
  String get drawerDebugLoadExhaustedTitle => 'Carregar cenário sem correções';

  @override
  String get drawerDebugLoadExhaustedSubtitle => 'Controlo temporário para testes de recuperação apenas com Desfazer.';

  @override
  String get drawerDebugResetEntitlementTitle => 'Repor Versão Completa (Debug)';

  @override
  String get drawerDebugResetEntitlementSubtitle => 'Define o direito local como Gratuito para retestar compras.';

  @override
  String get contentModeAnimals => 'Animais (fácil)';

  @override
  String get contentModeInstruments => 'Instrumentos (difícil)';

  @override
  String get contentModeButterflies => 'Borboletas (bonito)';

  @override
  String get contentModeOpera => 'Ópera (surpreendente)';

  @override
  String get contentModeNumbers => 'Números (clássico)';

  @override
  String get topControlsProgress => 'Como estou indo?';

  @override
  String get topControlsHelp => 'Ajuda';

  @override
  String get infoSheetDismiss => 'Entendi';

  @override
  String get drawerLanguageTitle => 'Idioma';

  @override
  String get drawerLanguageReset => 'Redefinir para o idioma do sistema';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageJapanese => 'Japonês';

  @override
  String get languageGerman => 'Alemão';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String statusUnknownDifficulty(String difficulty) {
    return 'Dificuldade desconhecida: $difficulty';
  }

  @override
  String get statusDifficultyChangeBlocked => 'Termine ou inicie um novo jogo antes de alterar a dificuldade';

  @override
  String get statusDifficultyPremiumOnly => 'Esta dificuldade está disponível na Versão Completa.';

  @override
  String get statusPuzzleModeUnique => 'Modo puzzle: único';

  @override
  String get statusSessionRestored => 'Sessão restaurada';

  @override
  String get statusCellSelected => 'Casa selecionada';

  @override
  String get statusEntitlementRefreshed => 'Direito atualizado';

  @override
  String get statusEntitlementUpdated => 'Direito alterado';

  @override
  String get statusCheckComplete => 'Verificação concluída';

  @override
  String get statusSolution => 'Solução';

  @override
  String get statusSolved => 'Resolvido.';

  @override
  String get statusContradictionUseUndo => 'Contradição detetada. Use Desfazer para recuperar.';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'Novo jogo ($difficulty): $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count casa(s) corrigida(s).';
  }
}
