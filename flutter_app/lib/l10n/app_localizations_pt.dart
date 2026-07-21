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
  String get actionNewShort => 'Novo';

  @override
  String get actionNewGame => 'Novo\njogo';

  @override
  String get actionPlay => 'Jogar';

  @override
  String get actionResume => 'Retomar';

  @override
  String get actionStartNewGame => 'Novo jogo';

  @override
  String get actionPleaseWait => 'Aguarde...';

  @override
  String get tooltipNewGame => 'Toque aqui para começar um novo jogo.';

  @override
  String get tooltipUndo =>
      'Use Desfazer para tirar as últimas jogadas. Também ajuda se ficar sem Correções.';

  @override
  String get tooltipClear =>
      'Use isto para limpar a casa atualmente selecionada. Só pode limpar casas que você preencheu.';

  @override
  String get tooltipNotes =>
      'Notas ajuda a marcar possibilidades quando ainda não tem a certeza. Elas aparecem a verde. Toque em Notas outra vez para as tirar.';

  @override
  String get tooltipDifficulty =>
      'Escolha a dificuldade que lhe souber melhor.';

  @override
  String candidateLongPressToast(int digit) {
    return 'Candidato $digit';
  }

  @override
  String labelCorrections(int count) {
    return 'Correções: $count';
  }

  @override
  String labelElapsedTime(String time) {
    return 'Tempo: $time';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'Tem $limit correções automáticas para este puzzle. Se uma jogada anterior o deixar preso, use uma correção para continuar. Se acabarem, use Desfazer.';
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
  String get helpBody =>
      'Há ***algumas coisas*** no ecrã do jogo que podem não ser logo óbvias.\n\nDeixe o dedo **pressionado durante alguns segundos** para ver a explicação.\n\nPor exemplo, **Correções** mostra quantas correções automáticas ainda tem. Se uma jogada anterior o deixar sem saída, uma correção pode resolver isso para continuar a jogar.\n\nCom **Desfazer**, pode tirar as últimas jogadas uma a uma. Também dá jeito quando ficar sem Correções.';

  @override
  String get startInstruction =>
      'Para começar, selecione uma casa onde quer adicionar um ícone.\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies apresentam';

  @override
  String get launchTitle => 'SuDoKu Fresh';

  @override
  String get appBrandIos => 'SuDoKu Playtime';

  @override
  String get appBrandAndroid => 'SuDoKu Fresh';

  @override
  String get launchSubtitle => 'Sudoku relaxante com imagens';

  @override
  String get launchErrorOpenGame =>
      'Não foi possível abrir o jogo. Tente novamente.';

  @override
  String get launchHintsTitle => 'Dicas';

  @override
  String get tooltipPrevHint => 'Dica anterior';

  @override
  String get tooltipNextHint => 'Próxima dica';

  @override
  String get launchHint1 =>
      'Com Notas, pode guardar possibilidades. Toque em Notas outra vez para as tirar.';

  @override
  String get launchHint2 =>
      'Faça um toque longo, cerca de dois segundos, para perceber o que algumas coisas fazem. Experimente numa casa.';

  @override
  String get launchHint3 =>
      'Se a sua escolha deixar duas ou mais casas cor-de-rosa, houve um erro antes. Pode corrigir automaticamente.';

  @override
  String get launchHint4 =>
      'Mudar a dificuldade durante um jogo inicia um novo jogo.';

  @override
  String get launchHint5 => 'Toque em Ajuda para ver como o jogo funciona.';

  @override
  String get launchHint6 =>
      'Toque em ☰ no canto superior direito para abrir o menu.';

  @override
  String get launchHint7 =>
      'Se os sons incomodarem ou se quiser jogar em silêncio, pode desligar o Áudio no menu (☰).';

  @override
  String get launchHint8 =>
      'Pressione o ícone de música uma vez para desligar a música de fundo, ou duas vezes rapidamente para ligar novamente.';

  @override
  String get launchHint9 => 'O dado inicia um novo jogo.';

  @override
  String get launchHint10 =>
      'Se comprou a versão completa e ela não aparecer, use «Restaurar compras» no menu.';

  @override
  String get victoryMessage1 => 'Muito bem! Jogue outra vez!';

  @override
  String get victoryMessage2 => 'Boa! Jogue outra vez!';

  @override
  String get victoryMessage3 => 'Conseguiu! Jogue outra vez!';

  @override
  String get victoryMessage4 => 'Excelente! Jogue outra vez!';

  @override
  String get victoryMessage5 => 'Muito bom! Jogue outra vez!';

  @override
  String get victoryMessage6 => 'Boa jogada! Jogue outra vez!';

  @override
  String get victoryMessage7 => 'Conseguiu mesmo! Jogue outra vez!';

  @override
  String get victoryMessage8 => 'Muito bem jogado! Jogue outra vez!';

  @override
  String get victoryMessage9 => 'Pode ter orgulho! Jogue outra vez!';

  @override
  String get victoryMessage10 => 'Continue assim! Jogue outra vez!';

  @override
  String get victoryMessage11 => 'Espetacular! Jogue outra vez!';

  @override
  String get victoryMessage12 => 'Fantástico! Jogue outra vez!';

  @override
  String get victoryMessage13 => 'Perfeito! Jogue outra vez!';

  @override
  String get victoryMessage14 => 'Grande final! Jogue outra vez!';

  @override
  String get victoryMessage15 => 'Que boa ideia! Jogue outra vez!';

  @override
  String get victoryMessage16 => 'Vitória! Jogue outra vez!';

  @override
  String get victoryMessage17 => 'Grande esforço! Jogue outra vez!';

  @override
  String get victoryMessage18 => 'Que jogaço! Jogue outra vez!';

  @override
  String get victoryMessage19 => 'Mentalidade vencedora! Jogue outra vez!';

  @override
  String get victoryMessage20 => 'Resultado excelente! Jogue outra vez!';

  @override
  String get dialogActionCancel => 'Cancelar';

  @override
  String get dialogActionStartNewGame => 'Iniciar novo jogo';

  @override
  String get dialogActionUseCorrection => 'Usar correção';

  @override
  String get dialogUnlockSettingsTitle => 'Desbloquear configurações?';

  @override
  String get dialogUnlockSettingsMessage =>
      'Se desbloquear a dificuldade, vai começar um novo jogo e este tabuleiro será reposto. Continuar?';

  @override
  String get dialogStartNewGameTitle => 'Iniciar novo jogo?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return 'Mudar a dificuldade para $difficultyLabel e iniciar um novo jogo?';
  }

  @override
  String get dialogStartNewGameResetBoard =>
      'Iniciar um novo jogo e repor o tabuleiro atual?';

  @override
  String get labelLockedSettingsTitle =>
      'Configurações do tabuleiro bloqueadas';

  @override
  String get labelLockedSettingsMessage =>
      'A dificuldade fica bloqueada durante o jogo. Para desbloquear, toque duas vezes no cadeado ou inicie um novo jogo.';

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
  String get progressResetDialogMessage => 'Vai perder todo o seu progresso.';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile =>
      'O áudio ainda não está disponível para esta casa.';

  @override
  String get correctionPromptMessage =>
      'Este tabuleiro está sem solução devido a uma jogada anterior. Usar 1 correção?';

  @override
  String get premiumFeatureIntroGeneric =>
      'A Versão Completa dá-lhe toda a experiência SuDoKu numa só compra.';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel está incluído na Versão Completa.';
  }

  @override
  String get premiumSheetTitle => 'Desbloquear versão completa';

  @override
  String get premiumIncludesTitle => 'A versão completa inclui:';

  @override
  String get premiumIncludesHardDifficulties =>
      '• Dificuldades Difícil e Quase impossível';

  @override
  String get premiumIncludesProgress =>
      '• Acompanhamento de progresso e melhores marcas';

  @override
  String get premiumIncludesThemesSounds => '• Temas, sons e celebrações extra';

  @override
  String get premiumOneTimePurchase => 'Compra única. Sem subscrição.';

  @override
  String get premiumActionNotNow => 'Agora não';

  @override
  String get premiumActionUnlock => 'Desbloquear versão completa';

  @override
  String get purchaseStartedMessage =>
      'Confirme a compra na janela da App Store para desbloquear a Versão Completa.';

  @override
  String get restoreStartedMessage =>
      'Restauro iniciado. As suas compras devem voltar a aparecer já a seguir.';

  @override
  String get redeemCodeStartedMessage =>
      'Introduza o código na janela da App Store para desbloquear a Versão Completa.';

  @override
  String get billingUnavailable =>
      'As compras não estão disponíveis neste dispositivo neste momento.';

  @override
  String get billingProductNotConfigured =>
      'A Versão Completa ainda não está disponível. Tente outra vez mais tarde.';

  @override
  String get billingProductUnavailable =>
      'Não foi possível carregar os detalhes da Versão Completa. Tente outra vez.';

  @override
  String get billingFailed => 'Não foi possível concluir. Tente novamente.';

  @override
  String get drawerTitle => 'SuDoKu Fresh';

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
  String get drawerBackgroundMusicSubtitle => 'Música para jogar com calma';

  @override
  String get musicControlsTooltip =>
      'Aqui pode controlar a música de fundo. Toque uma vez para desligar e duas vezes rapidamente para voltar a ligar. Use < e > para ir para a faixa anterior ou seguinte.';

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
  String get drawerPremiumProgressSubtitle =>
      'Acompanhe puzzles concluídos e marcos.';

  @override
  String get drawerPremiumThemesTitle => 'Temas extra 🔒';

  @override
  String get drawerPremiumThemesSubtitle =>
      'Desbloqueie estilos visuais adicionais.';

  @override
  String get drawerPremiumSoundsTitle => 'Sons e celebrações 🔒';

  @override
  String get drawerPremiumSoundsSubtitle =>
      'Desbloqueie sons e celebrações extra.';

  @override
  String get drawerUnlockFullVersion => 'Desbloquear versão completa';

  @override
  String get drawerRestorePurchases => 'Restaurar compras';

  @override
  String get drawerRedeemCode => 'Resgatar código';

  @override
  String get drawerAboutChip => 'Sobre';

  @override
  String get drawerAboutTitle => 'Sobre';

  @override
  String drawerAboutMessage(String versionLabel) {
    return 'Versão: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy\n\nNenhum membro da equipa de desenvolvimento e artista ou musico. Admitimos livremente que usamos IA para criar este conteudo. Somos todos muito velhos; valorizamos a oportunidade de expressar a nossa criatividade ate onde ela conseguir chegar!';
  }

  @override
  String get drawerDebugTitle => 'Debug';

  @override
  String get drawerDebugLoadCorrectionTitle => 'Carregar cenário de correção';

  @override
  String get drawerDebugLoadCorrectionSubtitle =>
      'Controlo temporário para testes de recuperação assistida.';

  @override
  String get drawerDebugLoadExhaustedTitle => 'Carregar cenário sem correções';

  @override
  String get drawerDebugLoadExhaustedSubtitle =>
      'Controlo temporário para testes de recuperação apenas com Desfazer.';

  @override
  String get drawerDebugResetEntitlementTitle =>
      'Repor Versão Completa (Debug)';

  @override
  String get drawerDebugResetEntitlementSubtitle =>
      'Define o direito local como Gratuito para retestar compras.';

  @override
  String get contentModeAnimals => 'Animais (fácil)';

  @override
  String get contentModeInstruments => 'Instrumentos (difícil)';

  @override
  String get contentModeButterflies => 'Borboletas (bonito)';

  @override
  String get contentModeShells => 'Conchas (novo)';

  @override
  String get contentModeOpera => 'Ópera (surpreendente)';

  @override
  String get contentModeNumbers => 'Números (clássico)';

  @override
  String get appBarMenuTooltip =>
      'Pressione aqui para abrir a gaveta. Use o menu para mudar animais e estilo.';

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
  String get statusDifficultyChangeBlocked =>
      'Termine ou inicie um novo jogo antes de alterar a dificuldade';

  @override
  String get statusDifficultyPremiumOnly =>
      'Esta dificuldade está disponível na Versão Completa.';

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
  String get statusContradictionUseUndo =>
      'Contradição detetada. Use Desfazer para recuperar.';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'Novo jogo ($difficulty): $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count casa(s) corrigida(s).';
  }
}
