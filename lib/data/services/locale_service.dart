import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/app_locales.dart';

class LocaleService {
  LocaleService(this._prefs);

  static const _key = 'locale';
  static const _defaultLocale = Locale('en');

  final SharedPreferences _prefs;

  Locale load() {
    try {
      final saved = _prefs.getString(_key);
      return saved != null ? localeFromCode(saved) : _defaultLocale;
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'LocaleService',
        context: ErrorDescription('ao carregar o locale do SharedPreferences'),
      ));
      return _defaultLocale;
    }
  }

  Future<void> save(Locale locale) async {
    try {
      await _prefs.setString(_key, localeToCode(locale));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'LocaleService',
        context: ErrorDescription('ao salvar o locale no SharedPreferences'),
      ));
    }
  }
}
