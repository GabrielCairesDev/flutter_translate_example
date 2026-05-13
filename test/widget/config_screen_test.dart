import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_translate_example/data/repositories/locale_repository.dart';
import 'package:flutter_translate_example/data/services/locale_service.dart';
import 'package:flutter_translate_example/l10n/app_localizations.dart';
import 'package:flutter_translate_example/ui/config/view_model/config_view_model.dart';
import 'package:flutter_translate_example/ui/config/widgets/config_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('exibe título localizado e DropdownMenu', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = LocaleRepository(LocaleService(prefs));
    final viewModel = ConfigViewModel(repo);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ConfigScreen(viewModel: viewModel),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(DropdownMenu<String>), findsOneWidget);
  });

  testWidgets('ao escolher outro idioma chama setLocale no repositório',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = LocaleRepository(LocaleService(prefs));
    final viewModel = ConfigViewModel(repo);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ConfigScreen(viewModel: viewModel),
      ),
    );

    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Português').last);
    await tester.pumpAndSettle();

    expect(repo.locale, const Locale('pt'));
  });
}
