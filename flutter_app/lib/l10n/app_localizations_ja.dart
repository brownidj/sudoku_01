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
  String get actionNewShort => '新規';

  @override
  String get actionNewGame => '新しい\nゲーム';

  @override
  String get actionPlay => 'プレイ';

  @override
  String get actionResume => '再開';

  @override
  String get actionStartNewGame => '新しいゲーム';

  @override
  String get actionPleaseWait => 'しばらくお待ちください...';

  @override
  String get tooltipNewGame => 'ここを押すと新しいゲームが始まります。';

  @override
  String get tooltipUndo => '「戻す」で直前の手を取り消せます。修正がなくなったときにも使えます。';

  @override
  String get tooltipClear => '現在選択中のタイルをクリアします。自分で入力したタイルのみクリアできます。';

  @override
  String get tooltipNotes => '迷ったときは「メモ」で候補を残せます。候補は緑で表示されます。もう一度押すとオフになります。';

  @override
  String get tooltipDifficulty => '自分に合った難易度を選んでください。';

  @override
  String candidateLongPressToast(int digit) {
    return '候補 $digit';
  }

  @override
  String labelCorrections(int count) {
    return '修正: $count';
  }

  @override
  String labelElapsedTime(String time) {
    return '時間: $time';
  }

  @override
  String tooltipCorrections(int limit) {
    return 'このパズルでは自動修正を $limit 回使えます。前の手で行き詰まったら、修正で先に進めます。なくなったら「戻す」を使ってください。';
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
  String get helpBody =>
      'ゲーム画面には、最初は少し分かりにくいところがあります。\n\n気になるところを**長押し**すると説明が出ます。\n\nたとえば **修正** では、自動修正の残り回数が分かります。前の手で行き詰まってしまったときは、修正でその場を直して先に進めます。\n\n**戻す** を使うと、直前の手を1つずつ取り消せます。修正がなくなったときにも便利です。';

  @override
  String get startInstruction => '開始するには、アイコンを入れたいマスを選んでください。\n';

  @override
  String get launchTitlePrefix => 'The Angry Grannies がお届け';

  @override
  String get launchTitle => 'SuDoKu Fresh';

  @override
  String get appBrandIos => 'SuDoKu Playtime';

  @override
  String get appBrandAndroid => 'SuDoKu Fresh';

  @override
  String get launchSubtitle => 'リラックスできる絵柄の数独';

  @override
  String get launchErrorOpenGame => 'ゲームを開けませんでした。もう一度お試しください。';

  @override
  String get launchHintsTitle => 'ヒント';

  @override
  String get tooltipPrevHint => '前のヒント';

  @override
  String get tooltipNextHint => '次のヒント';

  @override
  String get launchHint1 => '「メモ」を押すと候補を書き残せます。もう一度押すとオフになります。';

  @override
  String get launchHint2 => '長押しすると、何ができるか説明が出ます。まずはタイルでも試してみてください。';

  @override
  String get launchHint3 => '選んだあとにピンクのタイルが2つ以上出たら、前にミスがあります。自動修正できます。';

  @override
  String get launchHint4 => 'ゲーム中に難易度を変更すると、新しいゲームが始まります。';

  @override
  String get launchHint5 => '遊び方を知りたいときは「ヘルプ」を押してください。';

  @override
  String get launchHint6 => '右上の ☰ を押すとメニューが開きます。';

  @override
  String get launchHint7 => '音が気になる場合は、ドロワー（☰）で Audio をオフにできます。';

  @override
  String get launchHint8 => '音楽アイコンを1回押すとBGMがオフ、すばやく2回押すとまたオンになります。';

  @override
  String get launchHint9 => 'サイコロで新しいゲームを開始します。';

  @override
  String get launchHint10 => 'フルバージョンを買ったのに反映されないときは、メニューの「購入を復元」を使ってください。';

  @override
  String get victoryMessage1 => 'よくできました！ もう一度あそぼう！';

  @override
  String get victoryMessage2 => 'すばらしい！ もう一度あそぼう！';

  @override
  String get victoryMessage3 => 'やったね！ もう一度あそぼう！';

  @override
  String get victoryMessage4 => '見事なフィニッシュ！ もう一度あそぼう！';

  @override
  String get victoryMessage5 => '最高の出来です！ もう一度あそぼう！';

  @override
  String get victoryMessage6 => 'いいね！ もう一度あそぼう！';

  @override
  String get victoryMessage7 => 'できました！ もう一度あそぼう！';

  @override
  String get victoryMessage8 => 'がんばったね！ もう一度あそぼう！';

  @override
  String get victoryMessage9 => '誇らしいね！ もう一度あそぼう！';

  @override
  String get victoryMessage10 => 'その調子！ もう一度あそぼう！';

  @override
  String get victoryMessage11 => 'すごい出来！ もう一度あそぼう！';

  @override
  String get victoryMessage12 => 'ファンタスティック！ もう一度あそぼう！';

  @override
  String get victoryMessage13 => '完ぺきなクリア！ もう一度あそぼう！';

  @override
  String get victoryMessage14 => '力強い締めくくり！ もう一度あそぼう！';

  @override
  String get victoryMessage15 => 'さえていたね！ もう一度あそぼう！';

  @override
  String get victoryMessage16 => '気持ちいい成功！ もう一度あそぼう！';

  @override
  String get victoryMessage17 => '最高のがんばり！ もう一度あそぼう！';

  @override
  String get victoryMessage18 => '見事なプレイ！ もう一度あそぼう！';

  @override
  String get victoryMessage19 => '勝者の気持ちだね！ もう一度あそぼう！';

  @override
  String get victoryMessage20 => 'すばらしい結果！ もう一度あそぼう！';

  @override
  String get dialogActionCancel => 'キャンセル';

  @override
  String get dialogActionStartNewGame => '新しいゲームを開始';

  @override
  String get dialogActionUseCorrection => '修正を使う';

  @override
  String get dialogUnlockSettingsTitle => '設定を解除しますか？';

  @override
  String get dialogUnlockSettingsMessage =>
      '難易度を解除すると新しいゲームが始まり、この盤面はリセットされます。続けますか？';

  @override
  String get dialogStartNewGameTitle => '新しいゲームを開始しますか？';

  @override
  String dialogStartNewGameForDifficulty(String difficultyLabel) {
    return '難易度を $difficultyLabel に変更して新しいゲームを開始しますか？';
  }

  @override
  String get dialogStartNewGameResetBoard => '新しいゲームを始めて、今の盤面をリセットしますか？';

  @override
  String get labelLockedSettingsTitle => '盤面設定はロック中です';

  @override
  String get labelLockedSettingsMessage =>
      'ゲーム中は難易度がロックされます。解除するにはロックをダブルタップするか、新しいゲームを始めてください。';

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
  String get progressResetDialogMessage => 'これまでの進行状況はすべて消えます。';

  @override
  String get dialogActionOk => 'OK';

  @override
  String get audioUnavailableTile => 'このタイルの音声はまだ利用できません。';

  @override
  String get correctionPromptMessage => '以前の手によりこの盤面は解けません。修正を1回使いますか？';

  @override
  String get premiumFeatureIntroGeneric => 'フルバージョンなら、SuDoKuを一度の購入でたっぷり楽しめます。';

  @override
  String premiumFeatureIntroNamed(String featureLabel) {
    return '$featureLabel はフルバージョンで使えます。';
  }

  @override
  String get premiumSheetTitle => 'フルバージョンを解除';

  @override
  String get premiumIncludesTitle => 'フルバージョンに含まれる内容:';

  @override
  String get premiumIncludesHardDifficulties => '• 高難度・超難問レベル';

  @override
  String get premiumIncludesProgress => '• 進捗トラッキングと自己ベスト';

  @override
  String get premiumIncludesThemesSounds => '• 追加テーマ・サウンド・演出';

  @override
  String get premiumOneTimePurchase => '買い切りです。サブスクリプションはありません。';

  @override
  String get premiumActionNotNow => '今はしない';

  @override
  String get premiumActionUnlock => 'フルバージョンを解除';

  @override
  String get purchaseStartedMessage =>
      'App Store の購入ダイアログで確認するとフルバージョンが解除されます。';

  @override
  String get restoreStartedMessage => '復元を開始しました。購入した内容はまもなく戻ります。';

  @override
  String get billingUnavailable => 'この端末では今は購入できません。';

  @override
  String get billingProductNotConfigured => 'フルバージョンはまだ使えません。あとでもう一度試してください。';

  @override
  String get billingProductUnavailable => 'フルバージョンの情報を読み込めませんでした。もう一度試してください。';

  @override
  String get billingFailed => '処理に失敗しました。もう一度お試しください。';

  @override
  String get drawerTitle => 'SuDoKu Fresh';

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
  String get drawerBackgroundMusicSubtitle => 'ゆったり遊べるBGM';

  @override
  String get musicControlsTooltip =>
      'ここでBGMを切り替えられます。1回押すとオフ、すばやく2回押すとまたオンになります。< と > で前の曲と次の曲に切り替えられます。';

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
  String get drawerUnlockFullVersion => 'フルバージョンを解除';

  @override
  String get drawerRestorePurchases => '購入を復元';

  @override
  String get drawerAboutChip => 'このアプリについて';

  @override
  String get drawerAboutTitle => 'このアプリについて';

  @override
  String drawerAboutMessage(String versionLabel) {
    return 'バージョン: $versionLabel\n\nThe Angry Grannies Dev Team\ndev - DayDay\ndev - SudokuQueen\ntech advisor - Icy\n\n開発チームには芸術家も音楽家もいません。このコンテンツの制作にAIを使ったことは、私たちも率直に認めます。私たちはみなかなり年配ですが、届くところまで自分たちの創造性を表現できる機会を大切にしています！';
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
  String get drawerDebugResetEntitlementTitle => 'フルバージョンをリセット（デバッグ）';

  @override
  String get drawerDebugResetEntitlementSubtitle =>
      '購入再テスト用にローカル権限を Free に戻します。';

  @override
  String get contentModeAnimals => '動物（やさしい）';

  @override
  String get contentModeInstruments => '楽器（やや難しい）';

  @override
  String get contentModeButterflies => '蝶（きれい）';

  @override
  String get contentModeShells => '貝殻（新）';

  @override
  String get contentModeOpera => 'オペラ（独特）';

  @override
  String get contentModeNumbers => '数字（クラシック）';

  @override
  String get appBarMenuTooltip => 'ここを押すとドロワーが開きます。ドロワーメニューで動物やスタイルを変更できます。';

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
  String get statusDifficultyChangeBlocked =>
      '難易度を変更するには、現在のゲームを終了するか新しいゲームを開始してください';

  @override
  String get statusDifficultyPremiumOnly => 'この難易度はフルバージョンで利用できます。';

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
