import 'package:flutter/material.dart';

import '../ui/home/widgets/home_screen.dart';

abstract class AppRoutes {
  static const home = '/';

  static Map<String, WidgetBuilder> get routes {
    return {home: (_) => const HomeScreen()};
  }
}
