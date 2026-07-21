import 'package:flutter/material.dart';
import 'package:flutter_app/ui/ui_strings.dart';

class SudokuDrawerLanguageSection extends StatelessWidget {
  final EdgeInsets sectionPadding;
  final VisualDensity compactDensity;
  final String? selectedLanguageCode;
  final ValueChanged<String>? onLanguageChanged;
  final bool showExpandedMenuForScreenshot;

  const SudokuDrawerLanguageSection({
    super.key,
    required this.sectionPadding,
    required this.compactDensity,
    required this.selectedLanguageCode,
    this.onLanguageChanged,
    this.showExpandedMenuForScreenshot = false,
  });

  static const _languageOptions = <_LanguageOption>[
    _LanguageOption('en', 'English'),
    _LanguageOption('ja', '日本語'),
    _LanguageOption('de', 'Deutsch'),
    _LanguageOption('fr', 'Français'),
    _LanguageOption('es', 'Español'),
    _LanguageOption('pt', 'Português'),
    _LanguageOption('it', 'Italiano'),
    _LanguageOption('hi', 'हिन्दी'),
  ];

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
            items: _languageOptions
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option.code,
                    child: Text(option.nativeName),
                  ),
                )
                .toList(),
          ),
        ),
        if (showExpandedMenuForScreenshot)
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _languageOptions
                        .map(
                          (option) => _languageMenuEntry(
                            context,
                            option.code,
                            option.nativeName,
                            resolvedLanguageCode,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        const Divider(height: 8),
      ],
    );
  }

  Widget _languageMenuEntry(
    BuildContext context,
    String code,
    String label,
    String resolvedLanguageCode,
  ) {
    final selected = code == resolvedLanguageCode;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textStyle)),
          if (selected) const Icon(Icons.check, size: 18),
        ],
      ),
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

class _LanguageOption {
  final String code;
  final String nativeName;

  const _LanguageOption(this.code, this.nativeName);
}
