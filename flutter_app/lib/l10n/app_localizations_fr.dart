// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get actionUndo => 'Annuler';

  @override
  String get actionClear => 'Effacer';

  @override
  String get actionNotes => 'Notes';

  @override
  String get actionNewGame => 'Nouveau jeu';

  @override
  String get actionPlay => 'Jouer';

  @override
  String get actionResume => 'Reprendre';

  @override
  String get actionStartNewGame => 'Nouveau jeu';

  @override
  String get actionPleaseWait => 'Veuillez patienter...';

  @override
  String get tooltipNewGame => 'Appuyez ici pour démarrer une nouvelle partie.';

  @override
  String get tooltipUndo => 'Annuler permet de revenir en arrière et d’effacer vos sélections précédentes. Vous pouvez aussi l’utiliser si vous n’avez plus de correctifs.';

  @override
  String get tooltipClear => 'Efface la case actuellement sélectionnée. Vous ne pouvez effacer que les cases que vous avez remplies.';

  @override
  String get tooltipNotes => 'Notes vous permet d’ajouter de petits rappels de possibilités en cas d’hésitation. Les options s’affichent en vert. Appuyez à nouveau sur Notes pour les masquer.';

  @override
  String get tooltipDifficulty => 'Choisissez le niveau de difficulté qui vous permet de progresser régulièrement.';

  @override
  String labelCorrections(int count) {
    return 'Correctifs : $count';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'Vous disposez de $limit corrections automatiques pour cette grille. Si un coup précédent bloque votre progression, utilisez une correction pour continuer. Si vous n’en avez plus, utilisez Annuler.';
  }

  @override
  String get difficultyEasy => 'FACILE';

  @override
  String get difficultyMedium => 'UN PEU PLUS DIFFICILE';

  @override
  String get difficultyHard => 'BEAUCOUP PLUS DIFFICILE';

  @override
  String get difficultyVeryHard => 'QUASI IMPOSSIBLE';

  @override
  String get helpTitle => 'Aide';

  @override
  String get helpDismiss => 'OK';

  @override
  String get helpBody => 'Sur l’écran de jeu, ***certains éléments*** peuvent sembler un peu mystérieux.\n\nEssayez de **maintenir le doigt** dessus pendant quelques secondes pour afficher une explication.\n\nPar exemple, **Correctifs** indique le nombre de corrections automatiques qu’il vous reste. Si un coup précédent rend la grille bloquée, les correctifs peuvent réparer automatiquement cette impasse et vous permettre de continuer.\n\nUtilisez **Annuler** pour revenir sur vos sélections précédentes, une par une. Cela aide aussi si vous n’avez plus de correctifs.';

  @override
  String get startInstruction => 'Pour commencer, sélectionnez une case dans laquelle vous souhaitez ajouter une icône.\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies vous présentent';

  @override
  String get launchTitle => 'SuDoKu Playtime';

  @override
  String get launchSubtitle => 'Prenez votre temps, profitez de chaque grille et gardez l’esprit actif.';

  @override
  String get launchErrorOpenGame => 'Impossible d’ouvrir la partie. Veuillez réessayer.';

  @override
  String get launchHintsTitle => 'Astuces';

  @override
  String get tooltipPrevHint => 'Astuce précédente';

  @override
  String get tooltipNextHint => 'Astuce suivante';

  @override
  String get launchHint1 => 'Notes vous permet de mémoriser les possibilités en cas d’hésitation. Elles s’affichent en vert. Appuyez à nouveau sur Notes pour les masquer.';

  @override
  String get launchHint2 => 'Utilisez un appui long (quelques secondes) pour comprendre l’utilité de certains éléments. Essayez aussi sur une case déjà remplie.';

  @override
  String get launchHint3 => 'Si votre choix colore deux cases ou plus en rose, une erreur a été commise. Vous disposez d’un nombre limité de corrections automatiques.';

  @override
  String get launchHint4 => 'Changer la difficulté pendant une partie démarre une nouvelle partie.';

  @override
  String get launchHint5 => 'Appuyez sur Aide pour obtenir des informations de jeu.';

  @override
  String get launchHint6 => 'Appuyer sur ☰ (en haut à droite) ouvre le menu avec plusieurs options.';

  @override
  String get launchHint7 => 'Si les sons vous gênent ou si vous préférez jouer au calme, vous pouvez désactiver l’audio dans le menu (☰).';

  @override
  String get launchHint8 => 'Appuyez une fois sur l’icône musique pour couper la musique de fond, ou deux fois rapidement pour la remettre.';

  @override
  String get launchHint9 => 'Le dé démarre une nouvelle partie.';

  @override
  String get launchHint10 => 'Si vous avez acheté la version complète et qu’elle n’apparaît pas après une mise à jour, utilisez « Restaurer les achats » dans le menu.';

  @override
  String get dialogActionCancel => 'Annuler';

  @override
  String get dialogActionStartNewGame => 'Démarrer une partie';

  @override
  String get dialogActionUseCorrection => 'Utiliser une correction';

  @override
  String get dialogUnlockSettingsTitle => 'Déverrouiller les réglages ?';

  @override
  String get dialogUnlockSettingsMessage => 'Déverrouiller la difficulté démarrera une nouvelle partie et réinitialisera cette grille. Continuer ?';

  @override
  String get dialogStartNewGameTitle => 'Démarrer une nouvelle partie ?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return 'Passer la difficulté à $difficultyLabel et démarrer une nouvelle partie ?';
  }

  @override
  String get dialogStartNewGameResetBoard => 'Démarrer une nouvelle partie et réinitialiser cette grille ?';

  @override
  String get labelLockedSettingsTitle => 'Réglages de grille verrouillés';

  @override
  String get labelLockedSettingsMessage => 'La difficulté est verrouillée pendant une partie. Pour la déverrouiller, touchez deux fois l’icône de verrouillage ou démarrez une « Nouvelle partie ».';

  @override
  String get progressSheetTitle => 'Votre progression';

  @override
  String progressSheetBody(int completedPuzzles) {
    return 'Grilles terminées : $completedPuzzles\nJours joués : bientôt disponible\nSérie : bientôt disponible';
  }

  @override
  String progressCompletedPuzzles(int count) {
    return 'Grilles terminées : $count';
  }

  @override
  String progressDaysPlayed(int count) {
    return 'Jours joués : $count';
  }

  @override
  String progressStreak(int count) {
    return 'Série : $count';
  }

  @override
  String get progressBestSolveTimesTitle => 'Meilleurs temps :';

  @override
  String progressBestSolveTimeRow(String difficulty, String time) {
    return '• $difficulty : $time';
  }

  @override
  String get progressBestSolveTimeMissing => '--';

  @override
  String get progressResetAction => 'Réinitialiser';

  @override
  String get progressResetDialogTitle => 'Réinitialiser la progression ?';

  @override
  String get progressResetDialogMessage => 'Vos données « Où j’en suis ? » seront perdues.';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile => 'L’audio n’est pas encore disponible pour cette case.';

  @override
  String get correctionPromptMessage => 'Cette grille est bloquée à cause d’un coup précédent. Utiliser 1 correction ?';

  @override
  String get premiumFeatureIntroGeneric => 'La version complète vous offre toute l’expérience Sudoku en un seul achat.';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel est disponible dans la version complète.';
  }

  @override
  String get premiumSheetTitle => 'Déverrouiller la version complète';

  @override
  String get premiumIncludesTitle => 'La version complète inclut :';

  @override
  String get premiumIncludesHardDifficulties => '• Difficultés Difficile et Quasi impossible';

  @override
  String get premiumIncludesProgress => '• Suivi de progression et records personnels';

  @override
  String get premiumIncludesThemesSounds => '• Thèmes, sons et animations supplémentaires';

  @override
  String get premiumOneTimePurchase => 'Achat unique. Aucun abonnement.';

  @override
  String get premiumActionNotNow => 'Plus tard';

  @override
  String get premiumActionUnlock => 'Déverrouiller la version complète';

  @override
  String get purchaseStartedMessage => 'Confirmez l’achat dans la fenêtre App Store pour débloquer la version complète.';

  @override
  String get restoreStartedMessage => 'Restauration lancée. Les éléments achetés réapparaîtront bientôt.';

  @override
  String get billingUnavailable => 'Les achats sont indisponibles sur cet appareil pour le moment.';

  @override
  String get billingProductNotConfigured => 'La version complète n’est pas encore configurée. Veuillez réessayer plus tard.';

  @override
  String get billingProductUnavailable => 'Impossible de charger les détails du produit version complète. Veuillez réessayer.';

  @override
  String get billingFailed => 'Échec de l’opération. Veuillez réessayer.';

  @override
  String get drawerTitle => 'SuDoKu Playtime';

  @override
  String get drawerPuzzleStyleTitle => 'Style de puzzle';

  @override
  String get styleModern => 'Moderne';

  @override
  String get styleClassic => 'Classique';

  @override
  String get styleHighContrast => 'Contraste élevé';

  @override
  String get drawerAudioTitle => 'Audio';

  @override
  String get labelOn => 'Activé';

  @override
  String get labelOff => 'Désactivé';

  @override
  String get drawerBackgroundMusicTitle => 'Musique de fond';

  @override
  String get drawerBackgroundMusicSubtitle => 'Des sons pour les passionnés de Sudoku';

  @override
  String get drawerVolumeTitle => 'Volume';

  @override
  String get drawerVersionTitle => 'Version';

  @override
  String get drawerVersionFull => 'Complet';

  @override
  String get drawerVersionFree => 'Gratuit';

  @override
  String get drawerPremiumProgressTitle => 'Suivi de progression 🔒';

  @override
  String get drawerPremiumProgressSubtitle => 'Suivez les grilles terminées et vos étapes clés.';

  @override
  String get drawerPremiumThemesTitle => 'Thèmes supplémentaires 🔒';

  @override
  String get drawerPremiumThemesSubtitle => 'Débloquez des styles visuels additionnels.';

  @override
  String get drawerPremiumSoundsTitle => 'Sons et animations 🔒';

  @override
  String get drawerPremiumSoundsSubtitle => 'Débloquez des sons et animations supplémentaires.';

  @override
  String get drawerUnlockFullVersion => 'Déverrouiller la version complète';

  @override
  String get drawerRestorePurchases => 'Restaurer les achats';

  @override
  String get drawerAboutChip => 'À propos';

  @override
  String get drawerAboutTitle => 'À propos';

  @override
  String drawerAboutMessage(String versionLabel) {
    return 'Version: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy';
  }

  @override
  String get drawerDebugTitle => 'Debug';

  @override
  String get drawerDebugLoadCorrectionTitle => 'Charger un scénario de correction';

  @override
  String get drawerDebugLoadCorrectionSubtitle => 'Contrôle temporaire pour tester la récupération assistée.';

  @override
  String get drawerDebugLoadExhaustedTitle => 'Charger un scénario sans correction';

  @override
  String get drawerDebugLoadExhaustedSubtitle => 'Contrôle temporaire pour tester la récupération avec Annuler uniquement.';

  @override
  String get drawerDebugResetEntitlementTitle => 'Réinitialiser la version complète (Debug)';

  @override
  String get drawerDebugResetEntitlementSubtitle => 'Remet l’accès local en version gratuite pour retester les achats.';

  @override
  String get contentModeAnimals => 'Animaux (facile)';

  @override
  String get contentModeInstruments => 'Instruments (corsé)';

  @override
  String get contentModeButterflies => 'Papillons (joli)';

  @override
  String get contentModeOpera => 'Opéra (surprenant)';

  @override
  String get contentModeNumbers => 'Nombres (classique)';

  @override
  String get topControlsProgress => 'Où j’en suis ?';

  @override
  String get topControlsHelp => 'Aide';

  @override
  String get infoSheetDismiss => 'Compris';

  @override
  String get drawerLanguageTitle => 'Langue';

  @override
  String get drawerLanguageReset => 'Revenir à la langue système';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languagePortuguese => 'Portugais';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String statusUnknownDifficulty(String difficulty) {
    return 'Difficulté inconnue : $difficulty';
  }

  @override
  String get statusDifficultyChangeBlocked => 'Terminez ou démarrez une nouvelle partie avant de changer la difficulté';

  @override
  String get statusDifficultyPremiumOnly => 'Cette difficulté est disponible dans la version complète.';

  @override
  String get statusPuzzleModeUnique => 'Mode puzzle : unique';

  @override
  String get statusSessionRestored => 'Session restaurée';

  @override
  String get statusCellSelected => 'Case sélectionnée';

  @override
  String get statusEntitlementRefreshed => 'Droit d’accès actualisé';

  @override
  String get statusEntitlementUpdated => 'Droit d’accès mis à jour';

  @override
  String get statusCheckComplete => 'Vérification terminée';

  @override
  String get statusSolution => 'Solution';

  @override
  String get statusSolved => 'Résolu.';

  @override
  String get statusContradictionUseUndo => 'Contradiction détectée. Utilisez Annuler pour récupérer.';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'Nouvelle partie ($difficulty) : $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count case(s) corrigée(s).';
  }
}
