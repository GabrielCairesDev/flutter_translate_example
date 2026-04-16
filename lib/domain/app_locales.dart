import 'package:flutter/widgets.dart';

const Map<String, String> appLocaleLabels = <String, String>{
  'en': 'English',
  'es': 'Español',
  'pt': 'Português',
  'zh': '中文',
};

Locale localeFromCode(String code) {
  final parts = code.split('_');
  return parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
}

String localeToCode(Locale locale) {
  return locale.countryCode != null
      ? '${locale.languageCode}_${locale.countryCode}'
      : locale.languageCode;
}
