// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get actionUndo => 'Annulla';

  @override
  String get actionClear => 'Cancella';

  @override
  String get actionNotes => 'Note';

  @override
  String get actionNewShort => 'Nuova';

  @override
  String get actionNewGame => 'Nuova\npartita';

  @override
  String get actionPlay => 'Gioca';

  @override
  String get actionResume => 'Riprendi';

  @override
  String get actionStartNewGame => 'Nuova partita';

  @override
  String get actionPleaseWait => 'Attendere...';

  @override
  String get tooltipNewGame => 'Premi qui per iniziare una nuova partita.';

  @override
  String get tooltipUndo =>
      'Usa Annulla per togliere le ultime mosse. Ti aiuta anche se hai finito le Correzioni.';

  @override
  String get tooltipClear =>
      'Cancella la casella attualmente selezionata. Puoi cancellare solo le caselle che hai compilato tu.';

  @override
  String get tooltipNotes =>
      'Con le Note puoi segnare le possibilità quando non sei ancora sicuro. Le vedrai in verde. Premi di nuovo Note per toglierle.';

  @override
  String get tooltipDifficulty =>
      'Scegli la difficoltà che ti sembra più adatta.';

  @override
  String candidateLongPressToast(int digit) {
    return 'Candidato $digit';
  }

  @override
  String labelCorrections(int count) {
    return 'Correzioni: $count';
  }

  @override
  String labelElapsedTime(String time) {
    return 'Tempo: $time';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'Hai $limit correzioni automatiche per questo puzzle. Se una mossa precedente ti blocca, usa una correzione per andare avanti. Se finiscono, usa Annulla.';
  }

  @override
  String get difficultyEasy => 'FACILE';

  @override
  String get difficultyMedium => 'UN PO\' PIÙ DIFFICILE';

  @override
  String get difficultyHard => 'MOLTO PIÙ DIFFICILE';

  @override
  String get difficultyVeryHard => 'QUASI IMPOSSIBILE';

  @override
  String get helpTitle => 'Aiuto';

  @override
  String get helpDismiss => 'OK';

  @override
  String get helpBody =>
      'Nella schermata di gioco ci sono ***alcune cose*** che magari non sono subito chiarissime.\n\nTieni premuto **per un paio di secondi** e comparirà una spiegazione.\n\nPer esempio, **Correzioni** ti dice quante correzioni automatiche ti restano. Se una mossa precedente ti lascia bloccato, una correzione può sistemare la situazione e farti continuare.\n\nCon **Annulla** puoi togliere le ultime mosse una alla volta. È utile anche quando hai finito le Correzioni.';

  @override
  String get startInstruction =>
      'Per iniziare, seleziona una casella in cui vuoi aggiungere un’icona.\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies presentano';

  @override
  String get launchTitle => 'SuDoKu Fresh';

  @override
  String get appBrandIos => 'SuDoKu Playtime';

  @override
  String get appBrandAndroid => 'SuDoKu Fresh';

  @override
  String get launchSubtitle => 'Sudoku rilassante con immagini';

  @override
  String get launchErrorOpenGame => 'Impossibile aprire la partita. Riprova.';

  @override
  String get launchHintsTitle => 'Suggerimenti';

  @override
  String get tooltipPrevHint => 'Suggerimento precedente';

  @override
  String get tooltipNextHint => 'Suggerimento successivo';

  @override
  String get launchHint1 =>
      'Con Note puoi segnarti le possibilità. Premi di nuovo Note per toglierle.';

  @override
  String get launchHint2 =>
      'Tieni premuto per circa due secondi per capire cosa fanno alcune cose. Provalo su una casella.';

  @override
  String get launchHint3 =>
      'Se dopo la tua scelta diventano rosa due o più caselle, prima c’è stato un errore. Puoi correggere automaticamente.';

  @override
  String get launchHint4 =>
      'Cambiare difficoltà durante una partita avvia una nuova partita.';

  @override
  String get launchHint5 =>
      'Premi Aiuto se vuoi vedere come funziona il gioco.';

  @override
  String get launchHint6 => 'Premi ☰ in alto a destra per aprire il menu.';

  @override
  String get launchHint7 =>
      'Se i suoni ti danno fastidio o vuoi giocare in silenzio, puoi disattivare l’audio dal menu (☰).';

  @override
  String get launchHint8 =>
      'Premi una volta l’icona della musica per spegnere la musica di sottofondo, oppure due volte rapidamente per riaccenderla.';

  @override
  String get launchHint9 => 'Il dado avvia una nuova partita.';

  @override
  String get launchHint10 =>
      'Se hai acquistato la versione completa e non compare, usa «Ripristina acquisti» dal menu.';

  @override
  String get victoryMessage1 => 'Ben fatto! Gioca ancora!';

  @override
  String get victoryMessage2 => 'Grande! Gioca ancora!';

  @override
  String get victoryMessage3 => 'Ce l\'hai fatta! Gioca ancora!';

  @override
  String get victoryMessage4 => 'Ottimo! Gioca ancora!';

  @override
  String get victoryMessage5 => 'Bravo! Gioca ancora!';

  @override
  String get victoryMessage6 => 'Molto bene! Gioca ancora!';

  @override
  String get victoryMessage7 => 'Ci sei riuscito! Gioca ancora!';

  @override
  String get victoryMessage8 => 'Che bella giocata! Gioca ancora!';

  @override
  String get victoryMessage9 => 'Puoi esserne fiero! Gioca ancora!';

  @override
  String get victoryMessage10 => 'Continua cosi! Gioca ancora!';

  @override
  String get victoryMessage11 => 'Fantastico! Gioca ancora!';

  @override
  String get victoryMessage12 => 'Super! Gioca ancora!';

  @override
  String get victoryMessage13 => 'Perfetto! Gioca ancora!';

  @override
  String get victoryMessage14 => 'Bella chiusura! Gioca ancora!';

  @override
  String get victoryMessage15 => 'Che intuito! Gioca ancora!';

  @override
  String get victoryMessage16 => 'Vittoria! Gioca ancora!';

  @override
  String get victoryMessage17 => 'Grande impegno! Gioca ancora!';

  @override
  String get victoryMessage18 => 'Che partita! Gioca ancora!';

  @override
  String get victoryMessage19 => 'Mentalita vincente! Gioca ancora!';

  @override
  String get victoryMessage20 => 'Risultato super! Gioca ancora!';

  @override
  String get dialogActionCancel => 'Annulla';

  @override
  String get dialogActionStartNewGame => 'Avvia nuova partita';

  @override
  String get dialogActionUseCorrection => 'Usa correzione';

  @override
  String get dialogUnlockSettingsTitle => 'Sbloccare le impostazioni?';

  @override
  String get dialogUnlockSettingsMessage =>
      'Se sblocchi la difficoltà, partirà una nuova partita e questa griglia verrà azzerata. Continuare?';

  @override
  String get dialogStartNewGameTitle => 'Avviare una nuova partita?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return 'Cambiare la difficoltà in $difficultyLabel e avviare una nuova partita?';
  }

  @override
  String get dialogStartNewGameResetBoard =>
      'Avviare una nuova partita e azzerare la griglia attuale?';

  @override
  String get labelLockedSettingsTitle => 'Impostazioni griglia bloccate';

  @override
  String get labelLockedSettingsMessage =>
      'La difficoltà resta bloccata durante la partita. Per sbloccarla, tocca due volte il lucchetto oppure avvia una nuova partita.';

  @override
  String get progressSheetTitle => 'I tuoi progressi';

  @override
  String progressSheetBody(int completedPuzzles) {
    return 'Puzzle completati: $completedPuzzles\nGiorni giocati: in arrivo\nSerie: in arrivo';
  }

  @override
  String progressCompletedPuzzles(int count) {
    return 'Puzzle completati: $count';
  }

  @override
  String progressDaysPlayed(int count) {
    return 'Giorni giocati: $count';
  }

  @override
  String progressStreak(int count) {
    return 'Serie: $count';
  }

  @override
  String get progressBestSolveTimesTitle => 'Migliori tempi:';

  @override
  String progressBestSolveTimeRow(String difficulty, String time) {
    return '• $difficulty: $time';
  }

  @override
  String get progressBestSolveTimeMissing => '--';

  @override
  String get progressResetAction => 'Reimposta';

  @override
  String get progressResetDialogTitle => 'Reimpostare i progressi?';

  @override
  String get progressResetDialogMessage => 'Perderai tutti i tuoi progressi.';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile =>
      'L’audio non è ancora disponibile per questa casella.';

  @override
  String get correctionPromptMessage =>
      'Questa griglia è irrisolvibile a causa di una mossa precedente. Usare 1 correzione?';

  @override
  String get premiumFeatureIntroGeneric =>
      'La versione completa ti dà tutta l’esperienza SuDoKu con un solo acquisto.';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel è incluso nella versione completa.';
  }

  @override
  String get premiumSheetTitle => 'Sblocca versione completa';

  @override
  String get premiumIncludesTitle => 'La versione completa include:';

  @override
  String get premiumIncludesHardDifficulties =>
      '• Difficoltà Difficile e Quasi impossibile';

  @override
  String get premiumIncludesProgress =>
      '• Monitoraggio progressi e record personali';

  @override
  String get premiumIncludesThemesSounds => '• Temi, suoni e animazioni extra';

  @override
  String get premiumOneTimePurchase =>
      'Acquisto una tantum. Nessun abbonamento.';

  @override
  String get premiumActionNotNow => 'Non ora';

  @override
  String get premiumActionUnlock => 'Sblocca versione completa';

  @override
  String get purchaseStartedMessage =>
      'Conferma l’acquisto nella finestra dell’App Store per sbloccare la versione completa.';

  @override
  String get restoreStartedMessage =>
      'Ripristino avviato. I tuoi acquisti torneranno tra poco.';

  @override
  String get billingUnavailable =>
      'Gli acquisti non sono disponibili su questo dispositivo in questo momento.';

  @override
  String get billingProductNotConfigured =>
      'La versione completa non è ancora disponibile. Riprova più tardi.';

  @override
  String get billingProductUnavailable =>
      'Impossibile caricare i dettagli della versione completa. Riprova.';

  @override
  String get billingFailed => 'Operazione non riuscita. Riprova.';

  @override
  String get drawerTitle => 'SuDoKu Fresh';

  @override
  String get drawerPuzzleStyleTitle => 'Stile puzzle';

  @override
  String get styleModern => 'Moderno';

  @override
  String get styleClassic => 'Classico';

  @override
  String get styleHighContrast => 'Alto contrasto';

  @override
  String get drawerAudioTitle => 'Audio';

  @override
  String get labelOn => 'Attivo';

  @override
  String get labelOff => 'Disattivo';

  @override
  String get drawerBackgroundMusicTitle => 'Musica di sottofondo';

  @override
  String get drawerBackgroundMusicSubtitle =>
      'Musica per una partita rilassata';

  @override
  String get musicControlsTooltip =>
      'Qui puoi gestire la musica di sottofondo. Premi una volta per spegnerla e due volte rapidamente per riaccenderla. Usa < e > per passare al brano precedente o successivo.';

  @override
  String get drawerVolumeTitle => 'Volume';

  @override
  String get drawerVersionTitle => 'Version';

  @override
  String get drawerVersionFull => 'Completa';

  @override
  String get drawerVersionFree => 'Gratis';

  @override
  String get drawerPremiumProgressTitle => 'Tracker progressi 🔒';

  @override
  String get drawerPremiumProgressSubtitle =>
      'Tieni traccia dei puzzle completati e dei traguardi.';

  @override
  String get drawerPremiumThemesTitle => 'Temi extra 🔒';

  @override
  String get drawerPremiumThemesSubtitle => 'Sblocca stili visivi aggiuntivi.';

  @override
  String get drawerPremiumSoundsTitle => 'Suoni e animazioni 🔒';

  @override
  String get drawerPremiumSoundsSubtitle => 'Sblocca suoni e animazioni extra.';

  @override
  String get drawerUnlockFullVersion => 'Sblocca versione completa';

  @override
  String get drawerRestorePurchases => 'Ripristina acquisti';

  @override
  String get drawerAboutChip => 'Info';

  @override
  String get drawerAboutTitle => 'Info';

  @override
  String drawerAboutMessage(String versionLabel) {
    return 'Versione: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy\n\nNessuno del team di sviluppo e artista o musicista. Ammettiamo senza problemi di aver usato l\'IA per creare questi contenuti. Siamo tutti molto anziani; apprezziamo la possibilita di esprimere la nostra creativita fin dove riesce ad arrivare!';
  }

  @override
  String get drawerDebugTitle => 'Debug';

  @override
  String get drawerDebugLoadCorrectionTitle => 'Carica scenario correzione';

  @override
  String get drawerDebugLoadCorrectionSubtitle =>
      'Controllo temporaneo per test di recupero assistito.';

  @override
  String get drawerDebugLoadExhaustedTitle =>
      'Carica scenario correzioni esaurite';

  @override
  String get drawerDebugLoadExhaustedSubtitle =>
      'Controllo temporaneo per test di recupero con solo Annulla.';

  @override
  String get drawerDebugResetEntitlementTitle =>
      'Reimposta versione completa (Debug)';

  @override
  String get drawerDebugResetEntitlementSubtitle =>
      'Imposta il diritto locale su Gratis per ritestare gli acquisti.';

  @override
  String get contentModeAnimals => 'Animali (facile)';

  @override
  String get contentModeInstruments => 'Strumenti (impegnativo)';

  @override
  String get contentModeButterflies => 'Farfalle (carino)';

  @override
  String get contentModeShells => 'Conchiglie (nuovo)';

  @override
  String get contentModeOpera => 'Opera (particolare)';

  @override
  String get contentModeNumbers => 'Numeri (classico)';

  @override
  String get appBarMenuTooltip =>
      'Premi qui per aprire il menu laterale. Usa il menu per cambiare animali e stile.';

  @override
  String get topControlsProgress => 'Come sto andando?';

  @override
  String get topControlsHelp => 'Aiuto';

  @override
  String get infoSheetDismiss => 'Ho capito';

  @override
  String get drawerLanguageTitle => 'Lingua';

  @override
  String get drawerLanguageReset => 'Ripristina lingua di sistema';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageJapanese => 'Giapponese';

  @override
  String get languageGerman => 'Tedesco';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Portoghese';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String statusUnknownDifficulty(String difficulty) {
    return 'Difficoltà sconosciuta: $difficulty';
  }

  @override
  String get statusDifficultyChangeBlocked =>
      'Termina o avvia una nuova partita prima di cambiare difficoltà';

  @override
  String get statusDifficultyPremiumOnly =>
      'Questa difficoltà è disponibile nella versione completa.';

  @override
  String get statusPuzzleModeUnique => 'Modalità puzzle: unica';

  @override
  String get statusSessionRestored => 'Sessione ripristinata';

  @override
  String get statusCellSelected => 'Casella selezionata';

  @override
  String get statusEntitlementRefreshed => 'Diritto aggiornato';

  @override
  String get statusEntitlementUpdated => 'Diritto modificato';

  @override
  String get statusCheckComplete => 'Controllo completato';

  @override
  String get statusSolution => 'Soluzione';

  @override
  String get statusSolved => 'Risolto.';

  @override
  String get statusContradictionUseUndo =>
      'Contraddizione rilevata. Usa Annulla per recuperare.';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'Nuova partita ($difficulty): $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count casella/e corretta/e.';
  }
}
