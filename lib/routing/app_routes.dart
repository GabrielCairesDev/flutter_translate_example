import 'package:flutter/material.dart';

import '../ui/home/widgets/home_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';

  static final Map<String, WidgetBuilder> routes = {
    home: (_) => const HomeScreen(),
  };
}
