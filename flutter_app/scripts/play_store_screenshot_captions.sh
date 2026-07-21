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
    fr:02_drawer_open.png) printf '%s\n' 'Prise en charge des langues' ;;
    fr:03_new_game_numbers.png) printf '%s\n' 'Oui, vous pouvez jouer avec de bons vieux chiffres...' ;;
    fr:04_new_game_animals.png) printf '%s\n' 'mais il est temps de changer !' ;;
    fr:05_new_game_butterflies.png) printf '%s\n' 'De jolis papillons !' ;;
    fr:06_shells_after_16_moves.png) printf '%s\n' 'Plus que deux !' ;;
    fr:07_celebration.png) printf '%s\n' 'Place à la fête' ;;
    es:02_drawer_open.png) printf '%s\n' 'Compatibilidad con idiomas' ;;
    es:03_new_game_numbers.png) printf '%s\n' 'Sí, puedes jugar con los números de siempre...' ;;
    es:04_new_game_animals.png) printf '%s\n' '¡pero es hora de algo diferente!' ;;
    es:05_new_game_butterflies.png) printf '%s\n' '¡Bonitas mariposas!' ;;
    es:06_shells_after_16_moves.png) printf '%s\n' '¡Solo faltan dos!' ;;
    es:07_celebration.png) printf '%s\n' 'Vamos a celebrar' ;;
    pt:02_drawer_open.png) printf '%s\n' 'Suporte de idiomas' ;;
    pt:03_new_game_numbers.png) printf '%s\n' 'Sim, podes jogar com os velhos números...' ;;
    pt:04_new_game_animals.png) printf '%s\n' 'mas está na hora de algo diferente!' ;;
    pt:05_new_game_butterflies.png) printf '%s\n' 'Borboletas bonitas!' ;;
    pt:06_shells_after_16_moves.png) printf '%s\n' 'Só faltam duas!' ;;
    pt:07_celebration.png) printf '%s\n' 'Vamos celebrar' ;;
    it:02_drawer_open.png) printf '%s\n' 'Supporto lingue' ;;
    it:03_new_game_numbers.png) printf '%s\n' 'Sì, puoi giocare con i soliti numeri...' ;;
    it:04_new_game_animals.png) printf '%s\n' 'ma è il momento di qualcosa di diverso!' ;;
    it:05_new_game_butterflies.png) printf '%s\n' 'Belle farfalle!' ;;
    it:06_shells_after_16_moves.png) printf '%s\n' 'Ne mancano solo due!' ;;
    it:07_celebration.png) printf '%s\n' 'Festeggiamo' ;;
    hi:02_drawer_open.png) printf '%s\n' 'भाषा समर्थन' ;;
    hi:03_new_game_numbers.png) printf '%s\n' 'हाँ, आप पुराने अच्छे नंबरों से खेल सकते हैं...' ;;
    hi:04_new_game_animals.png) printf '%s\n' 'लेकिन अब कुछ अलग करने का समय है!' ;;
    hi:05_new_game_butterflies.png) printf '%s\n' 'सुंदर तितलियाँ!' ;;
    hi:06_shells_after_16_moves.png) printf '%s\n' 'बस दो और!' ;;
    hi:07_celebration.png) printf '%s\n' 'आइए जश्न मनाएँ' ;;
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
    hi)
      printf '%s\n' 'Devanagari-Sangam-MN-Bold'
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
