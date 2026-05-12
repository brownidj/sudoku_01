import 'package:flutter/material.dart';
import 'package:flutter_app/ui/ui_strings.dart';

class SudokuDrawerLanguageSection extends StatelessWidget {
  final EdgeInsets sectionPadding;
  final VisualDensity compactDensity;
  final String? selectedLanguageCode;
  final ValueChanged<String>? onLanguageChanged;
  final VoidCallback? onResetToSystemLanguage;

  const SudokuDrawerLanguageSection({
    super.key,
    required this.sectionPadding,
    required this.compactDensity,
    required this.selectedLanguageCode,
    this.onLanguageChanged,
    this.onResetToSystemLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedLanguageCode = _resolveLanguageCode(
      context,
      selectedLanguageCode,
    );
    return Column(
      children: [
        ListTile(
          contentPadding: sectionPadding,
          minVerticalPadding: 0,
          visualDensity: compactDensity,
          dense: true,
          title: Text(
            UiStrings.drawerLanguageTitle(context),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: DropdownButton<String>(
            key: const ValueKey<String>('drawer-language-dropdown'),
            itemHeight: kMinInteractiveDimension,
            value: resolvedLanguageCode,
            onChanged: onLanguageChanged == null
                ? null
                : (value) {
                    if (value != null) {
                      onLanguageChanged!(value);
                    }
                  },
            items: [
              DropdownMenuItem<String>(
                value: 'en',
                child: Text(UiStrings.languageEnglish(context)),
              ),
              DropdownMenuItem<String>(
                value: 'ja',
                child: Text(UiStrings.languageJapanese(context)),
              ),
              DropdownMenuItem<String>(
                value: 'de',
                child: Text(UiStrings.languageGerman(context)),
              ),
              DropdownMenuItem<String>(
                value: 'fr',
                child: Text(UiStrings.languageFrench(context)),
              ),
              DropdownMenuItem<String>(
                value: 'es',
                child: Text(UiStrings.languageSpanish(context)),
              ),
              DropdownMenuItem<String>(
                value: 'pt',
                child: Text(UiStrings.languagePortuguese(context)),
              ),
              DropdownMenuItem<String>(
                value: 'it',
                child: Text(UiStrings.languageItalian(context)),
              ),
              DropdownMenuItem<String>(
                value: 'hi',
                child: Text(UiStrings.languageHindi(context)),
              ),
            ],
          ),
        ),
        Padding(
          padding: sectionPadding,
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const ValueKey<String>('drawer-language-reset-button'),
              onPressed: onResetToSystemLanguage,
              child: Text(UiStrings.drawerLanguageReset(context)),
            ),
          ),
        ),
        const Divider(height: 8),
      ],
    );
  }

  String _resolveLanguageCode(BuildContext context, String? selected) {
    const supported = <String>{'en', 'ja', 'de', 'fr', 'it', 'pt', 'hi', 'es'};
    if (selected != null && supported.contains(selected)) {
      return selected;
    }
    final device = Localizations.localeOf(context).languageCode;
    if (supported.contains(device)) {
      return device;
    }
    return 'en';
  }
}
