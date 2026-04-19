import 'package:flutter/widgets.dart';

import '../../../data/repositories/locale_repository.dart';

class AppViewModel extends ChangeNotifier {
  AppViewModel(this._localeRepository)
      : _locale = _localeRepository.load();

  final LocaleRepository _localeRepository;
  Locale _locale;

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _localeRepository.save(locale);
  }
}
