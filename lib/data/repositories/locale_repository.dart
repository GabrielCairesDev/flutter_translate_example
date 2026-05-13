import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../services/locale_service.dart';

class LocaleRepository {
  LocaleRepository(this._service) {
    _locale = ValueNotifier(_service.load());
  }

  final LocaleService _service;
  late final ValueNotifier<Locale> _locale;

  Locale get locale => _locale.value;

  ValueListenable<Locale> get localeListenable => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale.value == locale) return;
    await _service.save(locale);
    _locale.value = locale;
  }
}
