import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories/locale_repository.dart';
import 'data/services/locale_service.dart';
import 'routing/app_routes.dart';
import 'ui/app/view_model/app_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repository = LocaleRepository(LocaleService(prefs));
  runApp(
    App(
      viewModel: AppViewModel(localeRepository: repository),
      routes: AppRoutes(localeRepository: repository),
    ),
  );
}
