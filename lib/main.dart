import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/locale_repository.dart';
import 'data/services/locale_service.dart';
import 'ui/core/routing/app_routes.dart';
import 'ui/features/app/views/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repository = LocaleRepository(LocaleService(prefs));
  runApp(
    App(
      localeRepository: repository,
      routes: AppRoutes(localeRepository: repository),
    ),
  );
}
