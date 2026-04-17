import 'package:flutter/material.dart';

import '../data/repositories/locale_repository.dart';
import '../ui/home/widgets/home_screen.dart';

abstract class AppRoutes {
  static const home = '/';

  static Map<String, WidgetBuilder> routes(LocaleRepository localeRepository) {
    return {home: (_) => HomeScreen(localeRepository: localeRepository)};
  }
}
