import 'package:flutter/widgets.dart';

import '../repositories/locale_repository.dart';

class LocaleService extends ChangeNotifier {
  LocaleService(this._repository) : _locale = _repository.load();

  final LocaleRepository _repository;
  Locale _locale;

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _repository.save(locale);
  }
}
