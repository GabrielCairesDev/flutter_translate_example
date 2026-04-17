import 'package:flutter/material.dart';

import '../data/services/locale_service.dart';
import '../ui/home/widgets/home_screen.dart';

abstract class AppRoutes {
  static const home = '/';

  static Map<String, WidgetBuilder> routes(LocaleService localeService) => {
    home: (_) => HomeScreen(localeService: localeService),
  };
}
