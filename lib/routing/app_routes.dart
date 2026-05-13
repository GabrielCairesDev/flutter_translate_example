import 'package:flutter/material.dart';

import '../data/repositories/locale_repository.dart';
import '../ui/config/view_model/config_view_model.dart';
import '../ui/config/widgets/config_screen.dart';
import '../ui/home/widgets/home_screen.dart';

class AppRoutes {
  const AppRoutes({required this.localeRepository});

  final LocaleRepository localeRepository;

  static const String config = '/config';

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      '/' => MaterialPageRoute(builder: (_) => const HomeScreen()),
      config => MaterialPageRoute(
          builder: (_) => ConfigScreen(
            viewModel: ConfigViewModel(localeRepository),
          ),
        ),
      _ => null,
    };
  }
}
