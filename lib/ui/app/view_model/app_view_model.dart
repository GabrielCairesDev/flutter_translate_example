import 'package:flutter/widgets.dart';

import '../../../data/repositories/locale_repository.dart';

class AppViewModel extends ChangeNotifier {
  AppViewModel({required LocaleRepository localeRepository})
    : _localeRepository = localeRepository {
    _localeRepository.localeListenable.addListener(notifyListeners);
  }

  final LocaleRepository _localeRepository;

  Locale get locale => _localeRepository.localeListenable.value;

  @override
  void dispose() {
    _localeRepository.localeListenable.removeListener(notifyListeners);
    super.dispose();
  }
}
