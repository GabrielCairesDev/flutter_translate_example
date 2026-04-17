import 'package:flutter/widgets.dart';

import '../../../data/repositories/locale_repository.dart';

class AppViewModel extends ChangeNotifier {
  AppViewModel(this._localeRepository) {
    _localeRepository.addListener(notifyListeners);
  }

  final LocaleRepository _localeRepository;

  Locale get locale => _localeRepository.locale;

  @override
  void dispose() {
    _localeRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
