import 'package:flutter/widgets.dart';

import '../services/locale_service.dart';

class LocaleRepository {
  LocaleRepository(this._service);

  final LocaleService _service;

  Locale load() => _service.load();

  Future<void> save(Locale locale) => _service.save(locale);
}
