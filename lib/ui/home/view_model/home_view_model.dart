import 'package:flutter/material.dart';
import 'package:flutter_translate_example/data/services/locale_service.dart';
import 'package:flutter_translate_example/domain/app_locales.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._localeService) {
    _localeService.addListener(notifyListeners);
  }

  final LocaleService _localeService;

  List<String> get availableLocales => appLocaleLabels.values.toList();

  String get currentLocale {
    final code = localeToCode(_localeService.locale);
    return appLocaleLabels[code] ?? appLocaleLabels.values.first;
  }

  Future<void> setLocale(String label) async {
    final code = appLocaleLabels.entries
        .firstWhere(
          (e) => e.value == label,
          orElse: () => appLocaleLabels.entries.first,
        )
        .key;
    await _localeService.setLocale(localeFromCode(code));
  }

  @override
  void dispose() {
    _localeService.removeListener(notifyListeners);
    super.dispose();
  }
}
