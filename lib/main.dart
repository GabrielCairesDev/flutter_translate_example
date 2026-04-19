import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'data/repositories/locale_repository.dart';
import 'data/services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final service = LocaleService(prefs);
  final repository = LocaleRepository(service);
  ServiceLocator.instance.setup(repository: repository);
  runApp(const App());
}
