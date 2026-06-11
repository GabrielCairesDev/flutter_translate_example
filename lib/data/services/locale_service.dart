import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/app_locales.dart';

class LocaleService {
  LocaleService(this._prefs);

  static const _key = 'locale';
  static const _defaultLocale = Locale('en');

  final SharedPreferences _prefs;

  Locale load() {
    final saved = _prefs.getString(_key);
    return saved != null ? localeFromCode(saved) : _defaultLocale;
  }

  Future<void> save(Locale locale) async {
    await _prefs.setString(_key, localeToCode(locale));
  }
}
