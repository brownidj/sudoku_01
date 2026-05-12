// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'सुडोकू';

  @override
  String get actionUndo => 'पूर्ववत';

  @override
  String get actionClear => 'साफ़ करें';

  @override
  String get actionNotes => 'नोट्स';

  @override
  String get actionNewGame => 'नया खेल';

  @override
  String get actionPlay => 'खेलें';

  @override
  String get actionResume => 'जारी रखें';

  @override
  String get actionStartNewGame => 'नया खेल';

  @override
  String get actionPleaseWait => 'कृपया प्रतीक्षा करें...';

  @override
  String get tooltipNewGame => 'नया खेल शुरू करने के लिए इसे दबाएँ।';

  @override
  String get tooltipUndo => 'पहले किए गए चयन हटाने के लिए पूर्ववत का उपयोग करें। यदि सुधार खत्म हो जाएँ तो भी इसका उपयोग कर सकते हैं।';

  @override
  String get tooltipClear => 'अभी चुनी गई टाइल साफ़ करें। आप केवल वही टाइल साफ़ कर सकते हैं जो आपने भरी हैं।';

  @override
  String get tooltipNotes => 'यदि आप निश्चित नहीं हैं, तो नोट्स संभावित विकल्प याद रखने में मदद करता है। विकल्प हरे रंग में दिखेंगे। बंद करने के लिए नोट्स फिर दबाएँ।';

  @override
  String get tooltipDifficulty => 'ऐसा कठिनाई स्तर चुनें जिससे आप रोज़ नियमित प्रगति कर सकें।';

  @override
  String labelCorrections(int count) {
    return 'सुधार: $count';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'इस पहेली के लिए आपके पास $limit स्वचालित सुधार उपलब्ध हैं। पहले की कोई चाल प्रगति रोके तो सुधार उपयोग करें। सुधार खत्म हों तो पूर्ववत करें।';
  }

  @override
  String get difficultyEasy => 'आसान';

  @override
  String get difficultyMedium => 'थोड़ा कठिन';

  @override
  String get difficultyHard => 'बहुत कठिन';

  @override
  String get difficultyVeryHard => 'लगभग असंभव';

  @override
  String get helpTitle => 'मदद';

  @override
  String get helpDismiss => 'ठीक है';

  @override
  String get helpBody => 'गेम स्क्रीन पर ***कुछ चीज़ें*** थोड़ी रहस्यमय लग सकती हैं।\n\nउन पर **कुछ सेकंड उंगली दबाकर रखें** ताकि उनका विवरण दिखे।\n\nउदाहरण के लिए, **सुधार** बताता है कि आपके पास कितने स्वचालित सुधार बचे हैं। अगर पहले की चाल के कारण कोई वैध विकल्प न बचे, तो सुधार उस स्थिति को ठीक करके आपको खेल जारी रखने देता है।\n\n**पूर्ववत** से आप अपने पिछले चयन एक-एक करके वापस ले सकते हैं। सुधार खत्म होने पर भी यह काम आता है।';

  @override
  String get startInstruction => 'शुरू करने के लिए वह वर्ग चुनें जिसमें आप आइकन जोड़ना चाहते हैं।\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies प्रस्तुत करते हैं';

  @override
  String get launchTitle => 'SuDoKu Playtime';

  @override
  String get launchSubtitle => 'समय लें, हर पहेली का आनंद लें और दिमाग सक्रिय रखें।';

  @override
  String get launchErrorOpenGame => 'गेम नहीं खुल सका। कृपया फिर से प्रयास करें।';

  @override
  String get launchHintsTitle => 'संकेत';

  @override
  String get tooltipPrevHint => 'पिछला संकेत';

  @override
  String get tooltipNextHint => 'अगला संकेत';

  @override
  String get launchHint1 => 'नोट्स, निश्चित न होने पर संभावित विकल्प याद रखने में मदद करते हैं। विकल्प हरे रंग में दिखते हैं। बंद करने के लिए नोट्स फिर दबाएँ।';

  @override
  String get launchHint2 => 'लॉन्ग-प्रेस (कुछ सेकंड दबाकर रखें) से समझें कि चीज़ें क्या करती हैं। भरी हुई टाइल पर भी आज़माएँ।';

  @override
  String get launchHint3 => 'अगर आपके चयन से दो या अधिक टाइलें गुलाबी हो जाएँ, तो कहीं गलती हुई है। आपके पास सीमित स्वचालित सुधार हैं।';

  @override
  String get launchHint4 => 'गेम के दौरान कठिनाई बदलने पर नया खेल शुरू होगा।';

  @override
  String get launchHint5 => 'गेम खेलने की जानकारी के लिए Help दबाएँ।';

  @override
  String get launchHint6 => '☰ (ऊपर दाएँ) दबाने से ड्रॉअर खुलता है जहाँ आप विकल्प चुन सकते हैं।';

  @override
  String get launchHint7 => 'यदि ध्वनियाँ परेशान करें या आप शांत वातावरण में खेलना चाहें, तो ड्रॉअर (☰) में Audio बंद करें।';

  @override
  String get launchHint8 => 'बैकग्राउंड म्यूज़िक बंद करने के लिए संगीत आइकन एक बार दबाएँ, चालू करने के लिए जल्दी से दो बार दबाएँ।';

  @override
  String get launchHint9 => 'पासा नया खेल शुरू करता है।';

  @override
  String get launchHint10 => 'अगर आपने फुल वर्ज़न खरीदा है और अपडेट के बाद वह दिखाई नहीं देता, तो ड्रॉअर में \'खरीद पुनर्स्थापित करें\' का उपयोग करें।';

  @override
  String get dialogActionCancel => 'रद्द करें';

  @override
  String get dialogActionStartNewGame => 'नया खेल शुरू करें';

  @override
  String get dialogActionUseCorrection => 'correction उपयोग करें';

  @override
  String get dialogUnlockSettingsTitle => 'सेटिंग्स अनलॉक करें?';

  @override
  String get dialogUnlockSettingsMessage => 'कठिनाई अनलॉक करने पर नया खेल शुरू होगा और यह बोर्ड रीसेट होगा। जारी रखें?';

  @override
  String get dialogStartNewGameTitle => 'नया खेल शुरू करें?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return 'कठिनाई $difficultyLabel करें और नया खेल शुरू करें?';
  }

  @override
  String get dialogStartNewGameResetBoard => 'नया खेल शुरू कर यह बोर्ड रीसेट करें?';

  @override
  String get labelLockedSettingsTitle => 'बोर्ड सेटिंग्स लॉक हैं';

  @override
  String get labelLockedSettingsMessage => 'गेम के दौरान कठिनाई लॉक रहती है। अनलॉक करने के लिए लॉक आइकन पर डबल-टैप करें या \'नया खेल\' शुरू करें।';

  @override
  String get progressSheetTitle => 'आपकी प्रगति';

  @override
  String progressSheetBody(int completedPuzzles) {
    return 'पूर्ण पहेलियाँ: $completedPuzzles\nखेले गए दिन: जल्द आ रहा है\nस्ट्रीक: जल्द आ रहा है';
  }

  @override
  String progressCompletedPuzzles(int count) {
    return 'पूर्ण पहेलियाँ: $count';
  }

  @override
  String progressDaysPlayed(int count) {
    return 'खेले गए दिन: $count';
  }

  @override
  String progressStreak(int count) {
    return 'स्ट्रीक: $count';
  }

  @override
  String get progressBestSolveTimesTitle => 'सर्वश्रेष्ठ समय:';

  @override
  String progressBestSolveTimeRow(String difficulty, String time) {
    return '• $difficulty: $time';
  }

  @override
  String get progressBestSolveTimeMissing => '--';

  @override
  String get progressResetAction => 'रीसेट';

  @override
  String get progressResetDialogTitle => 'प्रगति रीसेट करें?';

  @override
  String get progressResetDialogMessage => 'आपका \'मैं कैसा कर रहा/रही हूँ?\' डेटा खो जाएगा।';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile => 'इस टाइल के लिए ऑडियो अभी उपलब्ध नहीं है।';

  @override
  String get correctionPromptMessage => 'पहले की चाल के कारण यह बोर्ड अब हल नहीं हो सकता। 1 correction उपयोग करें?';

  @override
  String get premiumFeatureIntroGeneric => 'Full Version आपको एक खरीद में पूरा Sudoku अनुभव देता है।';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel Full Version में उपलब्ध है।';
  }

  @override
  String get premiumSheetTitle => 'Full Version अनलॉक करें';

  @override
  String get premiumIncludesTitle => 'Full Version में शामिल है:';

  @override
  String get premiumIncludesHardDifficulties => '• Hard और Nigh Impossible कठिनाई स्तर';

  @override
  String get premiumIncludesProgress => '• प्रगति ट्रैकिंग और व्यक्तिगत सर्वश्रेष्ठ';

  @override
  String get premiumIncludesThemesSounds => '• अतिरिक्त थीम, ध्वनियाँ और सेलिब्रेशन';

  @override
  String get premiumOneTimePurchase => 'एक बार की खरीद। कोई सब्सक्रिप्शन नहीं।';

  @override
  String get premiumActionNotNow => 'अभी नहीं';

  @override
  String get premiumActionUnlock => 'Full Version अनलॉक करें';

  @override
  String get purchaseStartedMessage => 'Full Version अनलॉक करने के लिए App Store डायलॉग में खरीद की पुष्टि करें।';

  @override
  String get restoreStartedMessage => 'रीस्टोर शुरू हो गया है। खरीदी गई चीज़ें जल्द फिर दिखेंगी।';

  @override
  String get billingUnavailable => 'अभी इस डिवाइस पर खरीद उपलब्ध नहीं है।';

  @override
  String get billingProductNotConfigured => 'Full Version अभी कॉन्फ़िगर नहीं है। कृपया बाद में प्रयास करें।';

  @override
  String get billingProductUnavailable => 'Full Version उत्पाद विवरण लोड नहीं हो सके। कृपया फिर प्रयास करें।';

  @override
  String get billingFailed => 'यह काम नहीं किया। कृपया फिर प्रयास करें।';

  @override
  String get drawerTitle => 'SuDoKu Playtime';

  @override
  String get drawerPuzzleStyleTitle => 'पहेली शैली';

  @override
  String get styleModern => 'आधुनिक';

  @override
  String get styleClassic => 'क्लासिक';

  @override
  String get styleHighContrast => 'उच्च कॉन्ट्रास्ट';

  @override
  String get drawerAudioTitle => 'ऑडियो';

  @override
  String get labelOn => 'चालू';

  @override
  String get labelOff => 'बंद';

  @override
  String get drawerBackgroundMusicTitle => 'बैकग्राउंड संगीत';

  @override
  String get drawerBackgroundMusicSubtitle => 'SuDoKu प्रेमियों के लिए ध्वनियाँ';

  @override
  String get drawerVolumeTitle => 'आवाज़';

  @override
  String get drawerVersionTitle => 'संस्करण';

  @override
  String get drawerVersionFull => 'पूर्ण';

  @override
  String get drawerVersionFree => 'मुफ़्त';

  @override
  String get drawerPremiumProgressTitle => 'प्रगति ट्रैकर 🔒';

  @override
  String get drawerPremiumProgressSubtitle => 'पूर्ण पहेलियाँ और माइलस्टोन ट्रैक करें।';

  @override
  String get drawerPremiumThemesTitle => 'अतिरिक्त थीम 🔒';

  @override
  String get drawerPremiumThemesSubtitle => 'अतिरिक्त दृश्य शैलियाँ अनलॉक करें।';

  @override
  String get drawerPremiumSoundsTitle => 'ध्वनियाँ और सेलिब्रेशन 🔒';

  @override
  String get drawerPremiumSoundsSubtitle => 'अतिरिक्त ध्वनियाँ और सेलिब्रेशन अनलॉक करें।';

  @override
  String get drawerUnlockFullVersion => 'Full Version अनलॉक करें';

  @override
  String get drawerRestorePurchases => 'खरीद पुनर्स्थापित करें';

  @override
  String get drawerAboutChip => 'जानकारी';

  @override
  String get drawerAboutTitle => 'जानकारी';

  @override
  String drawerAboutMessage(String versionLabel) {
    return 'संस्करण: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy';
  }

  @override
  String get drawerDebugTitle => 'डिबग';

  @override
  String get drawerDebugLoadCorrectionTitle => 'Correction परिदृश्य लोड करें';

  @override
  String get drawerDebugLoadCorrectionSubtitle => 'सहायता-आधारित रिकवरी परीक्षण के लिए अस्थायी नियंत्रण।';

  @override
  String get drawerDebugLoadExhaustedTitle => 'Exhausted Correction परिदृश्य लोड करें';

  @override
  String get drawerDebugLoadExhaustedSubtitle => 'केवल Undo रिकवरी परीक्षण के लिए अस्थायी नियंत्रण।';

  @override
  String get drawerDebugResetEntitlementTitle => 'Full Version रीसेट करें (Debug)';

  @override
  String get drawerDebugResetEntitlementSubtitle => 'खरीद पुनः परीक्षण हेतु स्थानीय entitlement को Free पर सेट करता है।';

  @override
  String get contentModeAnimals => 'जानवर (आसान)';

  @override
  String get contentModeInstruments => 'वाद्ययंत्र (कठिन)';

  @override
  String get contentModeButterflies => 'तितलियाँ (सुंदर)';

  @override
  String get contentModeOpera => 'ओपेरा (अद्भुत)';

  @override
  String get contentModeNumbers => 'संख्याएँ (पुराना अंदाज़)';

  @override
  String get topControlsProgress => 'मैं कैसा कर रहा/रही हूँ?';

  @override
  String get topControlsHelp => 'मदद';

  @override
  String get infoSheetDismiss => 'समझ गया/गई';

  @override
  String get drawerLanguageTitle => 'भाषा';

  @override
  String get drawerLanguageReset => 'सिस्टम भाषा पर रीसेट करें';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageJapanese => 'जापानी';

  @override
  String get languageGerman => 'जर्मन';

  @override
  String get languageFrench => 'फ़्रेंच';

  @override
  String get languageItalian => 'इतालवी';

  @override
  String get languagePortuguese => 'पुर्तगाली';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get languageSpanish => 'स्पेनिश';

  @override
  String statusUnknownDifficulty(String difficulty) {
    return 'अज्ञात कठिनाई: $difficulty';
  }

  @override
  String get statusDifficultyChangeBlocked => 'कठिनाई बदलने से पहले खेल पूरा करें या नया खेल शुरू करें';

  @override
  String get statusDifficultyPremiumOnly => 'यह कठिनाई Full Version में उपलब्ध है।';

  @override
  String get statusPuzzleModeUnique => 'पहेली मोड: unique';

  @override
  String get statusSessionRestored => 'सत्र पुनर्स्थापित';

  @override
  String get statusCellSelected => 'सेल चयनित';

  @override
  String get statusEntitlementRefreshed => 'Entitlement रिफ्रेश हुआ';

  @override
  String get statusEntitlementUpdated => 'Entitlement अपडेट हुआ';

  @override
  String get statusCheckComplete => 'जाँच पूरी';

  @override
  String get statusSolution => 'समाधान';

  @override
  String get statusSolved => 'हल हो गया।';

  @override
  String get statusContradictionUseUndo => 'विरोधाभास मिला। रिकवरी के लिए Undo उपयोग करें।';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'नया खेल ($difficulty): $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count टाइल(ें) ठीक की गईं।';
  }
}
