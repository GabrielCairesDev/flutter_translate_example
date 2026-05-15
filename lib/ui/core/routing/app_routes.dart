import 'package:flutter/material.dart';

import '../../../data/repositories/locale_repository.dart';
import '../../features/config/view_models/config_view_model.dart';
import '../../features/config/views/config_screen.dart';
import '../../features/home/views/home_screen.dart';

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
