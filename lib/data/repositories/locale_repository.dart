import 'package:flutter/widgets.dart';

import '../services/locale_service.dart';

class LocaleRepository extends ChangeNotifier {
  LocaleRepository(this._service) : _locale = _service.load();

  final LocaleService _service;
  Locale _locale;

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _service.save(locale);
  }
}
