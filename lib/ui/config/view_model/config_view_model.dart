import 'package:flutter/widgets.dart';

import '../../../data/repositories/locale_repository.dart';
import '../../../domain/app_locales.dart';

class ConfigViewModel extends ChangeNotifier {
  ConfigViewModel(this._localeRepository) {
    _localeRepository.localeListenable.addListener(notifyListeners);
  }

  final LocaleRepository _localeRepository;

  String get currentLocaleCode =>
      localeToCode(_localeRepository.localeListenable.value);

  Future<void> setLocale(Locale locale) async {
    await _localeRepository.setLocale(locale);
  }

  @override
  void dispose() {
    _localeRepository.localeListenable.removeListener(notifyListeners);
    super.dispose();
  }
}
