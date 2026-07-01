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
  String get actionNewShort => 'Nouveau';

  @override
  String get actionNewGame => 'Nouveau\njeu';

  @override
  String get actionPlay => 'Jouer';

  @override
  String get actionResume => 'Reprendre';

  @override
  String get actionStartNewGame => 'Nouveau jeu';

  @override
  String get actionPleaseWait => 'Veuillez patienter...';

  @override
  String get tooltipNewGame => 'Appuyez ici pour lancer une nouvelle partie.';

  @override
  String get tooltipUndo =>
      'Annuler retire vos derniers coups. Vous pouvez aussi l’utiliser si vous n’avez plus de correctifs.';

  @override
  String get tooltipClear =>
      'Efface la case actuellement sélectionnée. Vous ne pouvez effacer que les cases que vous avez remplies.';

  @override
  String get tooltipNotes =>
      'Notes vous aide à marquer les possibilités quand vous hésitez. Elles s’affichent en vert. Appuyez de nouveau sur Notes pour les enlever.';

  @override
  String get tooltipDifficulty =>
      'Choisissez la difficulté qui vous convient le mieux.';

  @override
  String candidateLongPressToast(int digit) {
    return 'Candidat $digit';
  }

  @override
  String labelCorrections(int count) {
    return 'Correctifs : $count';
  }

  @override
  String labelElapsedTime(String time) {
    return 'Temps : $time';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'Vous avez $limit corrections automatiques pour cette grille. Si un coup précédent vous bloque, utilisez une correction pour continuer. S’il n’y en a plus, utilisez Annuler.';
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
  String get helpBody =>
      'Sur l’écran de jeu, ***certaines choses*** ne sont pas forcément claires tout de suite.\n\nLaissez votre doigt **appuyé quelques secondes** dessus pour voir une explication.\n\nPar exemple, **Correctifs** vous montre combien de corrections automatiques il vous reste. Si un coup précédent vous bloque, une correction peut vous sortir de l’impasse pour continuer.\n\nAvec **Annuler**, vous retirez vos derniers coups un par un. C’est aussi pratique quand vous n’avez plus de correctifs.';

  @override
  String get startInstruction =>
      'Pour commencer, sélectionnez une case dans laquelle vous souhaitez ajouter une icône.\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies vous présentent';

  @override
  String get launchTitle => 'SuDoKu Fresh';

  @override
  String get appBrandIos => 'SuDoKu Playtime';

  @override
  String get appBrandAndroid => 'SuDoKu Fresh';

  @override
  String get launchSubtitle => 'Sudoku relaxant en images';

  @override
  String get launchErrorOpenGame =>
      'Impossible d’ouvrir la partie. Veuillez réessayer.';

  @override
  String get launchHintsTitle => 'Astuces';

  @override
  String get tooltipPrevHint => 'Astuce précédente';

  @override
  String get tooltipNextHint => 'Astuce suivante';

  @override
  String get launchHint1 =>
      'Avec Notes, vous pouvez garder en mémoire les possibilités. Appuyez de nouveau sur Notes pour les enlever.';

  @override
  String get launchHint2 =>
      'Faites un appui long, environ deux secondes, pour voir à quoi servent certains éléments. Essayez sur une tuile.';

  @override
  String get launchHint3 =>
      'Si votre choix fait apparaître deux cases roses ou plus, il y a eu une erreur plus tôt. Vous pouvez corriger automatiquement.';

  @override
  String get launchHint4 =>
      'Changer la difficulté pendant une partie démarre une nouvelle partie.';

  @override
  String get launchHint5 =>
      'Appuyez sur Aide si vous voulez voir comment ça marche.';

  @override
  String get launchHint6 =>
      'Appuyez sur ☰ en haut à droite pour ouvrir le menu.';

  @override
  String get launchHint7 =>
      'Si les sons vous gênent ou si vous préférez jouer au calme, vous pouvez désactiver l’audio dans le menu (☰).';

  @override
  String get launchHint8 =>
      'Appuyez une fois sur l’icône musique pour couper le fond sonore, ou deux fois rapidement pour le remettre.';

  @override
  String get launchHint9 => 'Le dé démarre une nouvelle partie.';

  @override
  String get launchHint10 =>
      'Si vous avez acheté la version complète et qu’elle n’apparaît pas, utilisez « Restaurer les achats » dans le menu.';

  @override
  String get victoryMessage1 => 'Bravo ! Rejoue !';

  @override
  String get victoryMessage2 => 'Super ! Rejoue !';

  @override
  String get victoryMessage3 => 'Tu l’as fait ! Rejoue !';

  @override
  String get victoryMessage4 => 'Bien joué ! Rejoue !';

  @override
  String get victoryMessage5 => 'Joli coup ! Rejoue !';

  @override
  String get victoryMessage6 => 'Top ! Rejoue !';

  @override
  String get victoryMessage7 => 'C’est réussi ! Rejoue !';

  @override
  String get victoryMessage8 => 'Très bien joué ! Rejoue !';

  @override
  String get victoryMessage9 => 'Tu peux être fier ! Rejoue !';

  @override
  String get victoryMessage10 => 'Continue comme ça ! Rejoue !';

  @override
  String get victoryMessage11 => 'Excellent ! Rejoue !';

  @override
  String get victoryMessage12 => 'Fantastique ! Rejoue !';

  @override
  String get victoryMessage13 => 'Parfait ! Rejoue !';

  @override
  String get victoryMessage14 => 'Belle partie ! Rejoue !';

  @override
  String get victoryMessage15 => 'Bien vu ! Rejoue !';

  @override
  String get victoryMessage16 => 'Victoire ! Rejoue !';

  @override
  String get victoryMessage17 => 'Bravo pour l’effort ! Rejoue !';

  @override
  String get victoryMessage18 => 'Quel niveau ! Rejoue !';

  @override
  String get victoryMessage19 => 'Esprit gagnant ! Rejoue !';

  @override
  String get victoryMessage20 => 'Super résultat ! Rejoue !';

  @override
  String get dialogActionCancel => 'Annuler';

  @override
  String get dialogActionStartNewGame => 'Démarrer une partie';

  @override
  String get dialogActionUseCorrection => 'Utiliser une correction';

  @override
  String get dialogUnlockSettingsTitle => 'Déverrouiller les réglages ?';

  @override
  String get dialogUnlockSettingsMessage =>
      'Si vous déverrouillez la difficulté, une nouvelle partie démarre et cette grille sera remise à zéro. Continuer ?';

  @override
  String get dialogStartNewGameTitle => 'Démarrer une nouvelle partie ?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return 'Passer la difficulté à $difficultyLabel et démarrer une nouvelle partie ?';
  }

  @override
  String get dialogStartNewGameResetBoard =>
      'Démarrer une nouvelle partie et remettre la grille actuelle à zéro ?';

  @override
  String get labelLockedSettingsTitle => 'Réglages de grille verrouillés';

  @override
  String get labelLockedSettingsMessage =>
      'La difficulté reste verrouillée pendant la partie. Pour la déverrouiller, touchez deux fois le cadenas ou lancez une nouvelle partie.';

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
  String get progressResetDialogMessage =>
      'Toute votre progression sera perdue.';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile =>
      'L’audio n’est pas encore disponible pour cette case.';

  @override
  String get correctionPromptMessage =>
      'Cette grille est bloquée à cause d’un coup précédent. Utiliser 1 correction ?';

  @override
  String get premiumFeatureIntroGeneric =>
      'La version complète vous donne toute l’expérience SuDoKu en un seul achat.';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel est inclus dans la version complète.';
  }

  @override
  String get premiumSheetTitle => 'Déverrouiller la version complète';

  @override
  String get premiumIncludesTitle => 'La version complète inclut :';

  @override
  String get premiumIncludesHardDifficulties =>
      '• Difficultés Difficile et Quasi impossible';

  @override
  String get premiumIncludesProgress =>
      '• Suivi de progression et records personnels';

  @override
  String get premiumIncludesThemesSounds =>
      '• Thèmes, sons et animations supplémentaires';

  @override
  String get premiumOneTimePurchase => 'Achat unique. Aucun abonnement.';

  @override
  String get premiumActionNotNow => 'Plus tard';

  @override
  String get premiumActionUnlock => 'Déverrouiller la version complète';

  @override
  String get purchaseStartedMessage =>
      'Confirmez l’achat dans la fenêtre App Store pour débloquer la version complète.';

  @override
  String get restoreStartedMessage =>
      'Restauration lancée. Vos achats devraient réapparaître dans un instant.';

  @override
  String get billingUnavailable =>
      'Les achats ne sont pas disponibles sur cet appareil pour le moment.';

  @override
  String get billingProductNotConfigured =>
      'La version complète n’est pas encore disponible. Réessayez plus tard.';

  @override
  String get billingProductUnavailable =>
      'Impossible de charger les infos de la version complète. Réessayez.';

  @override
  String get billingFailed => 'Échec de l’opération. Veuillez réessayer.';

  @override
  String get drawerTitle => 'SuDoKu Fresh';

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
  String get drawerBackgroundMusicSubtitle =>
      'De la musique pour jouer au calme';

  @override
  String get musicControlsTooltip =>
      'Ici, vous pouvez gérer la musique de fond. Appuyez une fois pour la couper, deux fois rapidement pour la remettre. Utilisez < et > pour passer au morceau précédent ou suivant.';

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
  String get drawerPremiumProgressSubtitle =>
      'Suivez les grilles terminées et vos étapes clés.';

  @override
  String get drawerPremiumThemesTitle => 'Thèmes supplémentaires 🔒';

  @override
  String get drawerPremiumThemesSubtitle =>
      'Débloquez des styles visuels additionnels.';

  @override
  String get drawerPremiumSoundsTitle => 'Sons et animations 🔒';

  @override
  String get drawerPremiumSoundsSubtitle =>
      'Débloquez des sons et animations supplémentaires.';

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
    return 'Version : $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy\n\nAucun membre de l\'équipe de développement n\'est artiste ni musicien. Nous reconnaissons volontiers avoir utilisé l\'IA pour créer ce contenu. Nous sommes tous très âgés ; nous apprécions la possibilité d\'exprimer notre créativité, aussi loin qu\'elle puisse aller !';
  }

  @override
  String get drawerDebugTitle => 'Debug';

  @override
  String get drawerDebugLoadCorrectionTitle =>
      'Charger un scénario de correction';

  @override
  String get drawerDebugLoadCorrectionSubtitle =>
      'Contrôle temporaire pour tester la récupération assistée.';

  @override
  String get drawerDebugLoadExhaustedTitle =>
      'Charger un scénario sans correction';

  @override
  String get drawerDebugLoadExhaustedSubtitle =>
      'Contrôle temporaire pour tester la récupération avec Annuler uniquement.';

  @override
  String get drawerDebugResetEntitlementTitle =>
      'Réinitialiser la version complète (Debug)';

  @override
  String get drawerDebugResetEntitlementSubtitle =>
      'Remet l’accès local en version gratuite pour retester les achats.';

  @override
  String get contentModeAnimals => 'Animaux (facile)';

  @override
  String get contentModeInstruments => 'Instruments (corsé)';

  @override
  String get contentModeButterflies => 'Papillons (joli)';

  @override
  String get contentModeShells => 'Coquillages (nouveau)';

  @override
  String get contentModeOpera => 'Opéra (surprenant)';

  @override
  String get contentModeNumbers => 'Nombres (classique)';

  @override
  String get appBarMenuTooltip =>
      'Appuyez ici pour ouvrir le tiroir. Utilisez le menu pour changer les animaux et le style.';

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
  String get statusDifficultyChangeBlocked =>
      'Terminez ou démarrez une nouvelle partie avant de changer la difficulté';

  @override
  String get statusDifficultyPremiumOnly =>
      'Cette difficulté est disponible dans la version complète.';

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
  String get statusContradictionUseUndo =>
      'Contradiction détectée. Utilisez Annuler pour récupérer.';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'Nouvelle partie ($difficulty) : $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count case(s) corrigée(s).';
  }
}
