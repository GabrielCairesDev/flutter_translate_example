import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_translate_example/data/repositories/locale_repository.dart';
import 'package:flutter_translate_example/data/services/locale_service.dart';

void main() {
  group('LocaleRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('usa Locale en quando não há valor salvo', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = LocaleRepository(LocaleService(prefs));

      expect(repo.locale, const Locale('en'));
    });

    test('carrega locale persistido', () async {
      SharedPreferences.setMockInitialValues({'locale': 'pt'});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocaleRepository(LocaleService(prefs));

      expect(repo.locale, const Locale('pt'));
    });

    test('setLocale atualiza estado e persiste', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = LocaleRepository(LocaleService(prefs));

      var notifies = 0;
      repo.localeListenable.addListener(() => notifies++);

      await repo.setLocale(const Locale('es'));

      expect(repo.locale, const Locale('es'));
      expect(prefs.getString('locale'), 'es');
      expect(notifies, 1);
    });

    test('setLocale não notifica quando locale igual', () async {
      SharedPreferences.setMockInitialValues({'locale': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocaleRepository(LocaleService(prefs));

      var notifies = 0;
      repo.localeListenable.addListener(() => notifies++);

      await repo.setLocale(const Locale('en'));

      expect(notifies, 0);
    });
  });
}
