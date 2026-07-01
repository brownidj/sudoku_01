caption_for() {
  local language="$1"
  local filename="$2"
  case "$language:$filename" in
    en:02_drawer_open.png) printf '%s\n' 'Language support' ;;
    en:03_new_game_numbers.png) printf '%s\n' 'Yes, you can play with boring old numbers...' ;;
    en:04_new_game_animals.png) printf '%s\n' 'but time for something different!' ;;
    en:05_new_game_butterflies.png) printf '%s\n' 'Pretty butterflies!' ;;
    en:06_shells_after_16_moves.png) printf '%s\n' 'Just two more!' ;;
    en:07_celebration.png) printf '%s\n' "Let's celebrate" ;;
    ja:02_drawer_open.png) printf '%s\n' '言語サポート' ;;
    ja:03_new_game_numbers.png) printf '%s\n' '普通の数字でも楽しめます…' ;;
    ja:04_new_game_animals.png) printf '%s\n' 'でも、ときには違う楽しさも！' ;;
    ja:05_new_game_butterflies.png) printf '%s\n' 'きれいな蝶々！' ;;
    ja:06_shells_after_16_moves.png) printf '%s\n' 'あと2つ！' ;;
    ja:07_celebration.png) printf '%s\n' 'お祝いしましょう' ;;
    de:02_drawer_open.png) printf '%s\n' 'Sprachunterstützung' ;;
    de:03_new_game_numbers.png) printf '%s\n' 'Ja, du kannst auch mit langweiligen alten Zahlen spielen…' ;;
    de:04_new_game_animals.png) printf '%s\n' 'aber jetzt ist Zeit für etwas anderes!' ;;
    de:05_new_game_butterflies.png) printf '%s\n' 'Schöne Schmetterlinge!' ;;
    de:06_shells_after_16_moves.png) printf '%s\n' 'Nur noch zwei!' ;;
    de:07_celebration.png) printf '%s\n' 'Lasst uns feiern' ;;
    *)
      return 1
      ;;
  esac
}

font_for_language() {
  local language="$1"
  case "$language" in
    ja)
      printf '%s\n' 'Hiragino-Sans-W6'
      ;;
    *)
      printf '%s\n' 'Verdana-Bold'
      ;;
  esac
}

caption_position_for() {
  local filename="$1"
  case "$filename" in
    06_shells_after_16_moves.png|07_celebration.png)
      printf '%s\n' 'top'
      ;;
    *)
      printf '%s\n' 'bottom'
      ;;
  esac
}
