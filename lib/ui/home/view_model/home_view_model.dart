import 'package:flutter/material.dart';
import 'package:flutter_translate_example/data/repositories/locale_repository.dart';
import 'package:flutter_translate_example/domain/app_locales.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._localeRepository) {
    _localeRepository.addListener(notifyListeners);
  }

  final LocaleRepository _localeRepository;

  List<String> get availableLocales => appLocaleLabels.values.toList();

  String get currentLocale {
    final code = localeToCode(_localeRepository.locale);
    return appLocaleLabels[code] ?? appLocaleLabels.values.first;
  }

  Future<void> setLocale(String label) async {
    final code = appLocaleLabels.entries
        .firstWhere(
          (e) => e.value == label,
          orElse: () => appLocaleLabels.entries.first,
        )
        .key;
    await _localeRepository.setLocale(localeFromCode(code));
  }

  @override
  void dispose() {
    _localeRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
