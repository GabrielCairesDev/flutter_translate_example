import '../../data/repositories/locale_repository.dart';
import '../../ui/app/view_model/app_view_model.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  late final LocaleRepository localeRepository;
  late final AppViewModel appViewModel;

  void setup({required LocaleRepository repository}) {
    localeRepository = repository;
    appViewModel = AppViewModel(localeRepository);
  }
}
