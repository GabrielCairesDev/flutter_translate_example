import 'package:flutter/material.dart';
import '../../../domain/app_locales.dart';
import '../../app/view_model/app_view_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._appViewModel) {
    _appViewModel.addListener(notifyListeners);
  }

  final AppViewModel _appViewModel;

  List<String> get availableLocales => appLocaleLabels.values.toList();

  String get currentLocaleLabel {
    final code = localeToCode(_appViewModel.locale);
    return appLocaleLabels[code] ?? appLocaleLabels.values.first;
  }

  Future<void> setLocaleByLabel(String label) async {
    final entry = appLocaleLabels.entries.firstWhere(
      (e) => e.value == label,
      orElse: () => appLocaleLabels.entries.first,
    );
    await _appViewModel.setLocale(localeFromCode(entry.key));
  }

  @override
  void dispose() {
    _appViewModel.removeListener(notifyListeners);
    super.dispose();
  }
}
