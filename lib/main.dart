import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories/locale_repository.dart';
import 'data/services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repository = LocaleRepository(prefs);
  final localeService = LocaleService(repository);
  runApp(App(localeService: localeService));
}
