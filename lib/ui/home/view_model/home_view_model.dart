import 'package:flutter/material.dart';
import 'package:flutter_translate_example/domain/app_locales.dart';

import '../../app/view_model/app_view_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._appViewModel) {
    _appViewModel.addListener(notifyListeners);
  }

  final AppViewModel _appViewModel;

  List<String> get availableLocales => appLocaleLabels.values.toList();

  String get currentLocale {
    final code = localeToCode(_appViewModel.locale);
    return appLocaleLabels[code] ?? appLocaleLabels.values.first;
  }

  Future<void> setLocale(String label) async {
    final code = appLocaleLabels.entries
        .firstWhere(
          (e) => e.value == label,
          orElse: () => appLocaleLabels.entries.first,
        )
        .key;
    await _appViewModel.setLocale(localeFromCode(code));
  }

  @override
  void dispose() {
    _appViewModel.removeListener(notifyListeners);
    super.dispose();
  }
}
