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
  String get actionNewGame => 'Nuova partita';

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
  String get tooltipUndo => 'Usa Annulla per tornare indietro e cancellare le selezioni precedenti. Puoi usarlo anche se hai finito le Correzioni.';

  @override
  String get tooltipClear => 'Cancella la casella attualmente selezionata. Puoi cancellare solo le caselle che hai compilato tu.';

  @override
  String get tooltipNotes => 'Le Note ti permettono di aggiungere piccoli promemoria sulle possibilità quando non sei sicuro. Le opzioni sono mostrate in verde. Premi di nuovo Note per disattivarle.';

  @override
  String get tooltipDifficulty => 'Scegli il livello di sfida che ti consente di fare progressi regolari.';

  @override
  String labelCorrections(int count) {
    return 'Correzioni: $count';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'Hai $limit correzioni automatiche disponibili per questo puzzle. Se una mossa precedente blocca i tuoi progressi, puoi usare una correzione per continuare. Se finiscono, usa Annulla.';
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
  String get helpBody => 'Nella schermata di gioco ci sono ***alcuni elementi*** che possono sembrare un po’ misteriosi.\n\nProva a **tenere premuto** per un paio di secondi per vedere una spiegazione.\n\nPer esempio, **Correzioni** mostra quante correzioni automatiche ti restano. Se una mossa precedente porta a una situazione senza opzioni valide, Correzioni può sistemare automaticamente quel vicolo cieco e permetterti di continuare.\n\nUsa **Annulla** per tornare indietro sulle selezioni fatte in precedenza, una alla volta. Puoi farlo anche se hai esaurito le Correzioni.';

  @override
  String get startInstruction => 'Per iniziare, seleziona una casella in cui vuoi aggiungere un’icona.\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies presentano';

  @override
  String get launchTitle => 'SuDoKu Playtime';

  @override
  String get launchSubtitle => 'Prenditi il tuo tempo, goditi ogni puzzle e tieni la mente allenata.';

  @override
  String get launchErrorOpenGame => 'Impossibile aprire la partita. Riprova.';

  @override
  String get launchHintsTitle => 'Suggerimenti';

  @override
  String get tooltipPrevHint => 'Suggerimento precedente';

  @override
  String get tooltipNextHint => 'Suggerimento successivo';

  @override
  String get launchHint1 => 'Le Note ti permettono di salvare promemoria delle possibilità quando non sei sicuro. Le opzioni appaiono in verde. Premi di nuovo Note per disattivarle.';

  @override
  String get launchHint2 => 'Usa una pressione prolungata (tieni premuto per un paio di secondi) per capire a cosa servono alcuni elementi. Provala anche su una casella già compilata.';

  @override
  String get launchHint3 => 'Se la tua scelta rende rosa due o più caselle, c’è un errore in qualche mossa precedente. Hai un numero limitato di auto-correzioni.';

  @override
  String get launchHint4 => 'Cambiare difficoltà durante una partita avvia una nuova partita.';

  @override
  String get launchHint5 => 'Premi Aiuto per vedere informazioni su come giocare.';

  @override
  String get launchHint6 => 'Premendo ☰ (in alto a destra) apri il menu con varie impostazioni.';

  @override
  String get launchHint7 => 'Se i suoni ti danno fastidio o vuoi giocare in silenzio, puoi disattivare l’audio dal menu (☰).';

  @override
  String get launchHint8 => 'Premi una volta l’icona della musica per spegnere la musica di sottofondo, oppure due volte rapidamente per riaccenderla.';

  @override
  String get launchHint9 => 'Il dado avvia una nuova partita.';

  @override
  String get launchHint10 => 'Se hai acquistato la versione completa e non appare dopo un aggiornamento, usa « Ripristina acquisti » dal menu.';

  @override
  String get dialogActionCancel => 'Annulla';

  @override
  String get dialogActionStartNewGame => 'Avvia nuova partita';

  @override
  String get dialogActionUseCorrection => 'Usa correzione';

  @override
  String get dialogUnlockSettingsTitle => 'Sbloccare le impostazioni?';

  @override
  String get dialogUnlockSettingsMessage => 'Sbloccare la difficoltà avvierà una nuova partita e resetterà questa griglia. Continuare?';

  @override
  String get dialogStartNewGameTitle => 'Avviare una nuova partita?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return 'Cambiare la difficoltà in $difficultyLabel e avviare una nuova partita?';
  }

  @override
  String get dialogStartNewGameResetBoard => 'Avviare una nuova partita e resettare questa griglia?';

  @override
  String get labelLockedSettingsTitle => 'Impostazioni griglia bloccate';

  @override
  String get labelLockedSettingsMessage => 'La difficoltà è bloccata durante una partita. Per sbloccarla, tocca due volte l’icona del lucchetto oppure avvia una \'Nuova partita\'.';

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
  String get progressResetDialogMessage => 'I tuoi dati «Come sto andando?» andranno persi.';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile => 'L’audio non è ancora disponibile per questa casella.';

  @override
  String get correctionPromptMessage => 'Questa griglia è irrisolvibile a causa di una mossa precedente. Usare 1 correzione?';

  @override
  String get premiumFeatureIntroGeneric => 'La versione completa offre l’esperienza Sudoku completa con un unico acquisto.';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel è disponibile nella versione completa.';
  }

  @override
  String get premiumSheetTitle => 'Sblocca versione completa';

  @override
  String get premiumIncludesTitle => 'La versione completa include:';

  @override
  String get premiumIncludesHardDifficulties => '• Difficoltà Difficile e Quasi impossibile';

  @override
  String get premiumIncludesProgress => '• Monitoraggio progressi e record personali';

  @override
  String get premiumIncludesThemesSounds => '• Temi, suoni e animazioni extra';

  @override
  String get premiumOneTimePurchase => 'Acquisto una tantum. Nessun abbonamento.';

  @override
  String get premiumActionNotNow => 'Non ora';

  @override
  String get premiumActionUnlock => 'Sblocca versione completa';

  @override
  String get purchaseStartedMessage => 'Conferma l’acquisto nella finestra dell’App Store per sbloccare la versione completa.';

  @override
  String get restoreStartedMessage => 'Ripristino avviato. Gli acquisti ricompariranno a breve.';

  @override
  String get billingUnavailable => 'Gli acquisti non sono disponibili su questo dispositivo al momento.';

  @override
  String get billingProductNotConfigured => 'La versione completa non è ancora configurata. Riprova più tardi.';

  @override
  String get billingProductUnavailable => 'Impossibile caricare i dettagli del prodotto versione completa. Riprova.';

  @override
  String get billingFailed => 'Operazione non riuscita. Riprova.';

  @override
  String get drawerTitle => 'SuDoKu Playtime';

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
  String get drawerBackgroundMusicSubtitle => 'Suoni per gli amanti del Sudoku';

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
  String get drawerPremiumProgressSubtitle => 'Tieni traccia dei puzzle completati e dei traguardi.';

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
    return 'Version: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy';
  }

  @override
  String get drawerDebugTitle => 'Debug';

  @override
  String get drawerDebugLoadCorrectionTitle => 'Carica scenario correzione';

  @override
  String get drawerDebugLoadCorrectionSubtitle => 'Controllo temporaneo per test di recupero assistito.';

  @override
  String get drawerDebugLoadExhaustedTitle => 'Carica scenario correzioni esaurite';

  @override
  String get drawerDebugLoadExhaustedSubtitle => 'Controllo temporaneo per test di recupero con solo Annulla.';

  @override
  String get drawerDebugResetEntitlementTitle => 'Reimposta versione completa (Debug)';

  @override
  String get drawerDebugResetEntitlementSubtitle => 'Imposta il diritto locale su Gratis per ritestare gli acquisti.';

  @override
  String get contentModeAnimals => 'Animali (facile)';

  @override
  String get contentModeInstruments => 'Strumenti (impegnativo)';

  @override
  String get contentModeButterflies => 'Farfalle (carino)';

  @override
  String get contentModeOpera => 'Opera (particolare)';

  @override
  String get contentModeNumbers => 'Numeri (classico)';

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
  String get statusDifficultyChangeBlocked => 'Termina o avvia una nuova partita prima di cambiare difficoltà';

  @override
  String get statusDifficultyPremiumOnly => 'Questa difficoltà è disponibile nella versione completa.';

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
  String get statusContradictionUseUndo => 'Contraddizione rilevata. Usa Annulla per recuperare.';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'Nuova partita ($difficulty): $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count casella/e corretta/e.';
  }
}
