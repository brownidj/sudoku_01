// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '数独';

  @override
  String get actionUndo => '戻す';

  @override
  String get actionClear => '消去';

  @override
  String get actionNotes => 'メモ';

  @override
  String get actionNewGame => '新しいゲーム';

  @override
  String get actionPlay => 'プレイ';

  @override
  String get actionResume => '再開';

  @override
  String get actionStartNewGame => '新しいゲーム';

  @override
  String get actionPleaseWait => 'しばらくお待ちください...';

  @override
  String get tooltipNewGame => '新しいゲームを開始します。';

  @override
  String get tooltipUndo => '以前の選択を取り消して戻ります。修正がなくなった場合にも使えます。';

  @override
  String get tooltipClear => '現在選択中のタイルをクリアします。自分で入力したタイルのみクリアできます。';

  @override
  String get tooltipNotes => 'メモは、確信がないときに候補を残すために使います。候補は緑で表示されます。もう一度メモを押すと解除されます。';

  @override
  String get tooltipDifficulty => '毎日のペースに合った難易度を選んでください。';

  @override
  String labelCorrections(int count) {
    return '修正: $count';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'このパズルでは自動修正を $limit 回使えます。以前の手で進行不能になった場合、修正で続行できます。修正がなくなったら Undo を使ってください。';
  }

  @override
  String get difficultyEasy => 'やさしい';

  @override
  String get difficultyMedium => '少し難しい';

  @override
  String get difficultyHard => 'かなり難しい';

  @override
  String get difficultyVeryHard => '超難問';

  @override
  String get helpTitle => 'ヘルプ';

  @override
  String get helpDismiss => 'OK';

  @override
  String get helpBody => 'ゲーム画面には、少し分かりにくい項目があります。\n\nそれらを**長押し**すると説明が表示されます。\n\n例えば **修正** は、自動修正の残り回数です。以前の手で有効な選択肢がなくなった場合、修正が行き詰まりを自動で修正して、続けて遊べます。\n\n**Undo** を使うと、以前の選択を1つずつ取り消せます。修正がなくなったときにも使えます。';

  @override
  String get startInstruction => '開始するには、アイコンを入れたいマスを選んでください。\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies がお届け';

  @override
  String get launchTitle => 'SuDoKu Playtime';

  @override
  String get launchSubtitle => 'あせらずに、パズルを楽しみながら頭を活性化しましょう。';

  @override
  String get launchErrorOpenGame => 'ゲームを開けませんでした。もう一度お試しください。';

  @override
  String get launchHintsTitle => 'ヒント';

  @override
  String get tooltipPrevHint => '前のヒント';

  @override
  String get tooltipNextHint => '次のヒント';

  @override
  String get launchHint1 => 'メモは、確信がないときに候補を残すために使います。候補は緑で表示されます。もう一度メモを押すと解除されます。';

  @override
  String get launchHint2 => '機能の説明を見るには、数秒間長押ししてください。値が入ったタイルでも試してみてください。';

  @override
  String get launchHint3 => '選択によってピンクのタイルが2つ以上出る場合、どこかでミスしています。自動修正の回数には制限があります。';

  @override
  String get launchHint4 => 'ゲーム中に難易度を変更すると、新しいゲームが始まります。';

  @override
  String get launchHint5 => '遊び方の情報は Help を押してください。';

  @override
  String get launchHint6 => '右上の ☰ を押すと、各種設定メニューを開けます。';

  @override
  String get launchHint7 => '音が気になる場合は、ドロワー（☰）で Audio をオフにできます。';

  @override
  String get launchHint8 => '音楽アイコンを1回押すとBGMオフ、すばやく2回押すとオンになります。';

  @override
  String get launchHint9 => 'サイコロで新しいゲームを開始します。';

  @override
  String get launchHint10 => 'フルバージョンを購入済みなのにアップデート後に反映されない場合は、メニューの「購入を復元」を使ってください。';

  @override
  String get dialogActionCancel => 'キャンセル';

  @override
  String get dialogActionStartNewGame => '新しいゲームを開始';

  @override
  String get dialogActionUseCorrection => '修正を使う';

  @override
  String get dialogUnlockSettingsTitle => '設定を解除しますか？';

  @override
  String get dialogUnlockSettingsMessage => '難易度のロック解除には新しいゲームの開始と盤面リセットが必要です。続行しますか？';

  @override
  String get dialogStartNewGameTitle => '新しいゲームを開始しますか？';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return '難易度を $difficultyLabel に変更して新しいゲームを開始しますか？';
  }

  @override
  String get dialogStartNewGameResetBoard => '新しいゲームを開始してこの盤面をリセットしますか？';

  @override
  String get labelLockedSettingsTitle => '盤面設定はロック中です';

  @override
  String get labelLockedSettingsMessage => 'ゲーム中は難易度がロックされます。解除するにはロックアイコンをダブルタップするか「New Game」を開始してください。';

  @override
  String get progressSheetTitle => '進行状況';

  @override
  String progressSheetBody(int completedPuzzles) {
    return '完了したパズル: $completedPuzzles\nプレイ日数: 近日対応\n連続日数: 近日対応';
  }

  @override
  String progressCompletedPuzzles(int count) {
    return '完了したパズル: $count';
  }

  @override
  String progressDaysPlayed(int count) {
    return 'プレイ日数: $count';
  }

  @override
  String progressStreak(int count) {
    return '連続日数: $count';
  }

  @override
  String get progressBestSolveTimesTitle => 'ベストタイム:';

  @override
  String progressBestSolveTimeRow(String difficulty, String time) {
    return '• $difficulty: $time';
  }

  @override
  String get progressBestSolveTimeMissing => '--';

  @override
  String get progressResetAction => 'リセット';

  @override
  String get progressResetDialogTitle => '進行状況をリセットしますか？';

  @override
  String get progressResetDialogMessage => '「進み具合は？」のデータは失われます。';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile => 'このタイルの音声はまだ利用できません。';

  @override
  String get correctionPromptMessage => '以前の手によりこの盤面は解けません。修正を1回使いますか？';

  @override
  String get premiumFeatureIntroGeneric => 'Full Version を購入すると、数独の全機能を一度の購入で利用できます。';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel は Full Version で利用できます。';
  }

  @override
  String get premiumSheetTitle => 'Full Version を解除';

  @override
  String get premiumIncludesTitle => 'Full Version に含まれる内容:';

  @override
  String get premiumIncludesHardDifficulties => '• Hard / Nigh Impossible の難易度';

  @override
  String get premiumIncludesProgress => '• 進捗トラッキングと自己ベスト';

  @override
  String get premiumIncludesThemesSounds => '• 追加テーマ・サウンド・演出';

  @override
  String get premiumOneTimePurchase => '買い切りです。サブスクリプションはありません。';

  @override
  String get premiumActionNotNow => '今はしない';

  @override
  String get premiumActionUnlock => 'Full Version を解除';

  @override
  String get purchaseStartedMessage => 'App Store の購入ダイアログで確認すると Full Version が解除されます。';

  @override
  String get restoreStartedMessage => '復元を開始しました。購入済み項目はまもなく再表示されます。';

  @override
  String get billingUnavailable => 'この端末では現在購入機能を利用できません。';

  @override
  String get billingProductNotConfigured => 'Full Version はまだ設定されていません。後でもう一度お試しください。';

  @override
  String get billingProductUnavailable => 'Full Version の商品情報を取得できませんでした。もう一度お試しください。';

  @override
  String get billingFailed => '処理に失敗しました。もう一度お試しください。';

  @override
  String get drawerTitle => 'SuDoKu Playtime';

  @override
  String get drawerPuzzleStyleTitle => 'パズルスタイル';

  @override
  String get styleModern => 'モダン';

  @override
  String get styleClassic => 'クラシック';

  @override
  String get styleHighContrast => 'ハイコントラスト';

  @override
  String get drawerAudioTitle => 'オーディオ';

  @override
  String get labelOn => 'オン';

  @override
  String get labelOff => 'オフ';

  @override
  String get drawerBackgroundMusicTitle => 'BGM';

  @override
  String get drawerBackgroundMusicSubtitle => 'SuDoKu が好きな人のためのサウンド';

  @override
  String get drawerVolumeTitle => '音量';

  @override
  String get drawerVersionTitle => 'バージョン';

  @override
  String get drawerVersionFull => 'フル';

  @override
  String get drawerVersionFree => '無料';

  @override
  String get drawerPremiumProgressTitle => '進捗トラッカー 🔒';

  @override
  String get drawerPremiumProgressSubtitle => '完了したパズルとマイルストーンを追跡します。';

  @override
  String get drawerPremiumThemesTitle => '追加テーマ 🔒';

  @override
  String get drawerPremiumThemesSubtitle => '追加の見た目スタイルを解除します。';

  @override
  String get drawerPremiumSoundsTitle => 'サウンドと演出 🔒';

  @override
  String get drawerPremiumSoundsSubtitle => '追加サウンドと演出を解除します。';

  @override
  String get drawerUnlockFullVersion => 'Full Version を解除';

  @override
  String get drawerRestorePurchases => '購入を復元';

  @override
  String get drawerAboutChip => 'このアプリについて';

  @override
  String get drawerAboutTitle => 'このアプリについて';

  @override
  String drawerAboutMessage(String versionLabel) {
    return 'バージョン: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy';
  }

  @override
  String get drawerDebugTitle => 'デバッグ';

  @override
  String get drawerDebugLoadCorrectionTitle => '修正シナリオを読み込む';

  @override
  String get drawerDebugLoadCorrectionSubtitle => '補助回復テスト用の一時コントロールです。';

  @override
  String get drawerDebugLoadExhaustedTitle => '修正枯渇シナリオを読み込む';

  @override
  String get drawerDebugLoadExhaustedSubtitle => 'Undo のみ回復テスト用の一時コントロールです。';

  @override
  String get drawerDebugResetEntitlementTitle => 'Full Version をリセット（デバッグ）';

  @override
  String get drawerDebugResetEntitlementSubtitle => '購入再テスト用にローカル権限を Free に戻します。';

  @override
  String get contentModeAnimals => '動物（やさしい）';

  @override
  String get contentModeInstruments => '楽器（やや難しい）';

  @override
  String get contentModeButterflies => '蝶（きれい）';

  @override
  String get contentModeOpera => 'オペラ（独特）';

  @override
  String get contentModeNumbers => '数字（クラシック）';

  @override
  String get topControlsProgress => '進み具合は？';

  @override
  String get topControlsHelp => 'ヘルプ';

  @override
  String get infoSheetDismiss => '閉じる';

  @override
  String get drawerLanguageTitle => '言語';

  @override
  String get drawerLanguageReset => 'システム言語にリセット';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageGerman => 'ドイツ語';

  @override
  String get languageFrench => 'フランス語';

  @override
  String get languageItalian => 'イタリア語';

  @override
  String get languagePortuguese => 'ポルトガル語';

  @override
  String get languageHindi => 'ヒンディー語';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String statusUnknownDifficulty(String difficulty) {
    return '不明な難易度です: $difficulty';
  }

  @override
  String get statusDifficultyChangeBlocked => '難易度を変更するには、現在のゲームを終了するか新しいゲームを開始してください';

  @override
  String get statusDifficultyPremiumOnly => 'この難易度は Full Version で利用できます。';

  @override
  String get statusPuzzleModeUnique => 'パズルモード: unique';

  @override
  String get statusSessionRestored => 'セッションを復元しました';

  @override
  String get statusCellSelected => 'マスを選択しました';

  @override
  String get statusEntitlementRefreshed => '利用権を更新しました';

  @override
  String get statusEntitlementUpdated => '利用権を更新しました';

  @override
  String get statusCheckComplete => 'チェック完了';

  @override
  String get statusSolution => '解答';

  @override
  String get statusSolved => '解けました。';

  @override
  String get statusContradictionUseUndo => '矛盾を検出しました。回復するには Undo を使ってください。';

  @override
  String statusNewGame(String difficulty, String puzzleId) {
    return '新しいゲーム（$difficulty）: $puzzleId';
  }

  @override
  String statusTilesCorrected(int count) {
    return '$count マスを修正しました。';
  }
}
