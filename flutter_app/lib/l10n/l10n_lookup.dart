import 'package:flutter/widgets.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

AppLocalizations appL10nCurrent() {
  final currentLocale = Intl.getCurrentLocale();
  final locale = Locale(
    currentLocale.split(RegExp('[-_]')).firstWhere(
      (part) => part.isNotEmpty,
      orElse: () => 'en',
    ),
  );
  try {
    return lookupAppLocalizations(locale);
  } catch (_) {
    return lookupAppLocalizations(const Locale('en'));
  }
}
