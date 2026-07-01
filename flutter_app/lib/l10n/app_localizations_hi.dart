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
  String get actionNewShort => 'नया';

  @override
  String get actionNewGame => 'नया\nखेल';

  @override
  String get actionPlay => 'खेलें';

  @override
  String get actionResume => 'जारी रखें';

  @override
  String get actionStartNewGame => 'नया खेल';

  @override
  String get actionPleaseWait => 'कृपया प्रतीक्षा करें...';

  @override
  String get tooltipNewGame => 'नया खेल शुरू करने के लिए यहाँ दबाएँ।';

  @override
  String get tooltipUndo =>
      'पूर्ववत से अपनी पिछली चालें वापस लें। सुधार खत्म हो जाएँ तो भी यह काम आएगा।';

  @override
  String get tooltipClear =>
      'अभी चुनी गई टाइल साफ़ करें। आप केवल वही टाइल साफ़ कर सकते हैं जो आपने भरी हैं।';

  @override
  String get tooltipNotes =>
      'पक्का न हो तो नोट्स से संभावित विकल्प चिन्हित करें। वे हरे रंग में दिखेंगे। बंद करने के लिए नोट्स फिर दबाएँ।';

  @override
  String get tooltipDifficulty => 'वही कठिनाई चुनें जो आपको सही लगे।';

  @override
  String candidateLongPressToast(int digit) {
    return 'उम्मीदवार $digit';
  }

  @override
  String labelCorrections(int count) {
    return 'सुधार: $count';
  }

  @override
  String labelElapsedTime(String time) {
    return 'समय: $time';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'इस पहेली में आपके पास $limit अपने-आप होने वाले सुधार हैं। पहले की कोई चाल आपको रोक दे तो सुधार इस्तेमाल करें। सुधार खत्म हों तो पूर्ववत करें।';
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
  String get helpBody =>
      'गेम स्क्रीन पर ***कुछ चीज़ें*** पहली नज़र में साफ़ नहीं लगेंगी।\n\nउन पर **कुछ सेकंड उंगली दबाकर रखें**, तब उनका छोटा सा विवरण दिखेगा।\n\nउदाहरण के लिए, **सुधार** बताता है कि कितने अपने-आप होने वाले सुधार बचे हैं। अगर पहले की किसी चाल से आप फँस जाएँ, तो सुधार आपको आगे बढ़ने में मदद करेगा।\n\n**पूर्ववत** से आप अपनी पिछली चालें एक-एक करके वापस ले सकते हैं। सुधार खत्म होने पर भी यह काम आता है।';

  @override
  String get startInstruction =>
      'शुरू करने के लिए वह वर्ग चुनें जिसमें आप आइकन जोड़ना चाहते हैं।\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies प्रस्तुत करते हैं';

  @override
  String get launchTitle => 'SuDoKu Fresh';

  @override
  String get appBrandIos => 'SuDoKu Playtime';

  @override
  String get appBrandAndroid => 'SuDoKu Fresh';

  @override
  String get launchSubtitle => 'चित्रों वाला आरामदायक सुडोकू';

  @override
  String get launchErrorOpenGame =>
      'गेम नहीं खुल सका। कृपया फिर से प्रयास करें।';

  @override
  String get launchHintsTitle => 'संकेत';

  @override
  String get tooltipPrevHint => 'पिछला संकेत';

  @override
  String get tooltipNextHint => 'अगला संकेत';

  @override
  String get launchHint1 =>
      'नोट्स से आप संभावित विकल्प याद रख सकते हैं। बंद करने के लिए नोट्स फिर दबाएँ।';

  @override
  String get launchHint2 =>
      'लगभग दो सेकंड दबाकर रखें, तब पता चलेगा कि कुछ चीज़ें क्या करती हैं। इसे किसी टाइल पर आज़माएँ।';

  @override
  String get launchHint3 =>
      'अगर आपके चयन से दो या ज़्यादा टाइलें गुलाबी हो जाएँ, तो पहले कहीं गलती हुई है। आप ऑटो-करेक्ट कर सकते हैं।';

  @override
  String get launchHint4 => 'गेम के दौरान कठिनाई बदलने पर नया खेल शुरू होगा।';

  @override
  String get launchHint5 => 'गेम कैसे खेलना है, यह देखने के लिए मदद दबाएँ।';

  @override
  String get launchHint6 => 'ऊपर दाएँ ☰ दबाने से मेन्यू खुलता है।';

  @override
  String get launchHint7 =>
      'यदि ध्वनियाँ परेशान करें या आप शांत वातावरण में खेलना चाहें, तो ड्रॉअर (☰) में ऑडियो बंद करें।';

  @override
  String get launchHint8 =>
      'बैकग्राउंड म्यूज़िक बंद करने के लिए संगीत आइकन एक बार दबाएँ, फिर चालू करने के लिए जल्दी से दो बार दबाएँ।';

  @override
  String get launchHint9 => 'पासा नया खेल शुरू करता है।';

  @override
  String get launchHint10 =>
      'अगर आपने फुल वर्ज़न खरीदा है और वह नहीं दिख रहा, तो मेन्यू में \'खरीद पुनर्स्थापित करें\' दबाएँ।';

  @override
  String get victoryMessage1 => 'बहुत बढ़िया! फिर से खेलें!';

  @override
  String get victoryMessage2 => 'शानदार काम! फिर से खेलें!';

  @override
  String get victoryMessage3 => 'आपने कर दिखाया! फिर से खेलें!';

  @override
  String get victoryMessage4 => 'कमाल की समाप्ति! फिर से खेलें!';

  @override
  String get victoryMessage5 => 'उत्कृष्ट काम! फिर से खेलें!';

  @override
  String get victoryMessage6 => 'वाह! फिर से खेलें!';

  @override
  String get victoryMessage7 => 'आप सफल हुए! फिर से खेलें!';

  @override
  String get victoryMessage8 => 'बेहतरीन प्रयास! फिर से खेलें!';

  @override
  String get victoryMessage9 => 'आप पर गर्व है! फिर से खेलें!';

  @override
  String get victoryMessage10 => 'ऐसे ही आगे बढ़ें! फिर से खेलें!';

  @override
  String get victoryMessage11 => 'कमाल का काम! फिर से खेलें!';

  @override
  String get victoryMessage12 => 'लाजवाब! फिर से खेलें!';

  @override
  String get victoryMessage13 => 'एकदम सही हल! फिर से खेलें!';

  @override
  String get victoryMessage14 => 'मज़बूत समाप्ति! फिर से खेलें!';

  @override
  String get victoryMessage15 => 'बहुत समझदारी! फिर से खेलें!';

  @override
  String get victoryMessage16 => 'मीठी जीत! फिर से खेलें!';

  @override
  String get victoryMessage17 => 'उत्तम प्रयास! फिर से खेलें!';

  @override
  String get victoryMessage18 => 'माहिराना खेल! फिर से खेलें!';

  @override
  String get victoryMessage19 => 'विजेता जैसी सोच! फिर से खेलें!';

  @override
  String get victoryMessage20 => 'शानदार परिणाम! फिर से खेलें!';

  @override
  String get dialogActionCancel => 'रद्द करें';

  @override
  String get dialogActionStartNewGame => 'नया खेल शुरू करें';

  @override
  String get dialogActionUseCorrection => 'सुधार उपयोग करें';

  @override
  String get dialogUnlockSettingsTitle => 'सेटिंग्स अनलॉक करें?';

  @override
  String get dialogUnlockSettingsMessage =>
      'कठिनाई अनलॉक करते ही नया खेल शुरू होगा और यह बोर्ड रीसेट हो जाएगा। जारी रखें?';

  @override
  String get dialogStartNewGameTitle => 'नया खेल शुरू करें?';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return 'कठिनाई $difficultyLabel करें और नया खेल शुरू करें?';
  }

  @override
  String get dialogStartNewGameResetBoard =>
      'नया खेल शुरू करके मौजूदा बोर्ड रीसेट करें?';

  @override
  String get labelLockedSettingsTitle => 'बोर्ड सेटिंग्स लॉक हैं';

  @override
  String get labelLockedSettingsMessage =>
      'खेल के दौरान कठिनाई लॉक रहती है। इसे खोलने के लिए लॉक आइकन पर दो बार टैप करें या नया खेल शुरू करें।';

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
  String get progressResetDialogMessage =>
      'आपकी अब तक की पूरी प्रगति मिट जाएगी।';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile => 'इस टाइल के लिए ऑडियो अभी उपलब्ध नहीं है।';

  @override
  String get correctionPromptMessage =>
      'पहले की चाल के कारण यह बोर्ड अब हल नहीं हो सकता। 1 सुधार उपयोग करें?';

  @override
  String get premiumFeatureIntroGeneric =>
      'पूर्ण संस्करण के साथ आपको पूरा SuDoKu अनुभव एक ही खरीद में मिलता है।';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel पूर्ण संस्करण में मिलता है।';
  }

  @override
  String get premiumSheetTitle => 'पूर्ण संस्करण अनलॉक करें';

  @override
  String get premiumIncludesTitle => 'पूर्ण संस्करण में शामिल है:';

  @override
  String get premiumIncludesHardDifficulties =>
      '• कठिन और लगभग असंभव कठिनाई स्तर';

  @override
  String get premiumIncludesProgress =>
      '• प्रगति ट्रैकिंग और व्यक्तिगत सर्वश्रेष्ठ';

  @override
  String get premiumIncludesThemesSounds =>
      '• अतिरिक्त थीम, ध्वनियाँ और सेलिब्रेशन';

  @override
  String get premiumOneTimePurchase => 'एक बार की खरीद। कोई सब्सक्रिप्शन नहीं।';

  @override
  String get premiumActionNotNow => 'अभी नहीं';

  @override
  String get premiumActionUnlock => 'पूर्ण संस्करण अनलॉक करें';

  @override
  String get purchaseStartedMessage =>
      'पूर्ण संस्करण अनलॉक करने के लिए App Store डायलॉग में खरीद की पुष्टि करें।';

  @override
  String get restoreStartedMessage =>
      'रीस्टोर शुरू हो गया है। आपकी खरीदी गई चीज़ें अभी थोड़ी देर में फिर दिखेंगी।';

  @override
  String get billingUnavailable => 'अभी इस डिवाइस पर खरीदारी उपलब्ध नहीं है।';

  @override
  String get billingProductNotConfigured =>
      'पूर्ण संस्करण अभी उपलब्ध नहीं है। कृपया बाद में फिर कोशिश करें।';

  @override
  String get billingProductUnavailable =>
      'पूर्ण संस्करण की जानकारी लोड नहीं हो सकी। कृपया फिर कोशिश करें।';

  @override
  String get billingFailed => 'यह काम नहीं किया। कृपया फिर प्रयास करें।';

  @override
  String get drawerTitle => 'SuDoKu Fresh';

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
  String get drawerBackgroundMusicSubtitle => 'आराम से खेलने के लिए संगीत';

  @override
  String get musicControlsTooltip =>
      'यहाँ से बैकग्राउंड म्यूज़िक चलाएँ या बंद करें। एक बार दबाने से यह बंद होगा, और जल्दी से दो बार दबाने पर फिर चालू होगा। पिछला और अगला ट्रैक चुनने के लिए < और > दबाएँ।';

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
  String get drawerPremiumProgressSubtitle =>
      'पूर्ण पहेलियाँ और माइलस्टोन ट्रैक करें।';

  @override
  String get drawerPremiumThemesTitle => 'अतिरिक्त थीम 🔒';

  @override
  String get drawerPremiumThemesSubtitle =>
      'अतिरिक्त दृश्य शैलियाँ अनलॉक करें।';

  @override
  String get drawerPremiumSoundsTitle => 'ध्वनियाँ और सेलिब्रेशन 🔒';

  @override
  String get drawerPremiumSoundsSubtitle =>
      'अतिरिक्त ध्वनियाँ और सेलिब्रेशन अनलॉक करें।';

  @override
  String get drawerUnlockFullVersion => 'पूर्ण संस्करण अनलॉक करें';

  @override
  String get drawerRestorePurchases => 'खरीद पुनर्स्थापित करें';

  @override
  String get drawerAboutChip => 'जानकारी';

  @override
  String get drawerAboutTitle => 'जानकारी';

  @override
  String drawerAboutMessage(String versionLabel) {
    return 'संस्करण: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy\n\nडेव टीम में कोई भी कलाकार या संगीतकार नहीं है। हम खुलकर मानते हैं कि इस सामग्री को बनाने के लिए हमने एआई का उपयोग किया है। हम सब बहुत पुराने हैं; अपनी रचनात्मकता को जितना भी व्यक्त कर सकते हैं, उस अवसर को हम बहुत महत्व देते हैं!';
  }

  @override
  String get drawerDebugTitle => 'डिबग';

  @override
  String get drawerDebugLoadCorrectionTitle => 'सुधार परिदृश्य लोड करें';

  @override
  String get drawerDebugLoadCorrectionSubtitle =>
      'सहायता-आधारित रिकवरी परीक्षण के लिए अस्थायी नियंत्रण।';

  @override
  String get drawerDebugLoadExhaustedTitle => 'सुधार-समाप्त परिदृश्य लोड करें';

  @override
  String get drawerDebugLoadExhaustedSubtitle =>
      'केवल Undo रिकवरी परीक्षण के लिए अस्थायी नियंत्रण।';

  @override
  String get drawerDebugResetEntitlementTitle =>
      'पूर्ण संस्करण रीसेट करें (डिबग)';

  @override
  String get drawerDebugResetEntitlementSubtitle =>
      'खरीद पुनः परीक्षण हेतु स्थानीय अधिकार को मुफ़्त पर सेट करता है।';

  @override
  String get contentModeAnimals => 'जानवर (आसान)';

  @override
  String get contentModeInstruments => 'वाद्ययंत्र (कठिन)';

  @override
  String get contentModeButterflies => 'तितलियाँ (सुंदर)';

  @override
  String get contentModeShells => 'शंख (नया)';

  @override
  String get contentModeOpera => 'ओपेरा (अद्भुत)';

  @override
  String get contentModeNumbers => 'संख्याएँ (पुराना अंदाज़)';

  @override
  String get appBarMenuTooltip =>
      'ड्रॉअर खोलने के लिए यहाँ दबाएँ। जानवर और शैली बदलने के लिए ड्रॉअर मेन्यू का उपयोग करें।';

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
  String get statusDifficultyChangeBlocked =>
      'कठिनाई बदलने से पहले खेल पूरा करें या नया खेल शुरू करें';

  @override
  String get statusDifficultyPremiumOnly =>
      'यह कठिनाई पूर्ण संस्करण में उपलब्ध है।';

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
  String get statusContradictionUseUndo =>
      'विरोधाभास मिला। ठीक करने के लिए पूर्ववत उपयोग करें।';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return 'नया खेल ($difficulty): $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count टाइल(ें) ठीक की गईं।';
  }
}
