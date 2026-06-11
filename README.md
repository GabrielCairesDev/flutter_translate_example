# Flutter Translate Example

Projeto de referência que demonstra como implementar **internacionalização (l10n)** com a solução oficial do Flutter (`flutter_localizations` + `gen-l10n`) combinada com **persistência de idioma** via `shared_preferences`, seguindo a arquitetura **MVVM** e as diretrizes de **Layered Architecture** recomendadas pela equipe do Flutter.

---

## Sumário

1. [Estrutura do projeto](#1-estrutura-do-projeto)
2. [Dependências](#2-dependências)
3. [Como a internacionalização é configurada](#3-como-a-internacionalização-é-configurada)
4. [Estrutura e uso dos arquivos de tradução (ARB)](#4-estrutura-e-uso-dos-arquivos-de-tradução-arb)
5. [Como o idioma padrão é definido](#5-como-o-idioma-padrão-é-definido)
6. [Persistência com SharedPreferences](#6-persistência-com-sharedpreferences)
7. [Injeção de dependências por construtor](#7-injeção-de-dependências-por-construtor)
8. [Fluxo completo: do início do app à troca de idioma](#8-fluxo-completo-do-início-do-app-à-troca-de-idioma)
9. [Como adicionar um novo idioma](#9-como-adicionar-um-novo-idioma)
10. [Referências](#10-referências)
11. [Screenshots](#11-screenshots)

---

## 1. Estrutura do projeto

```
lib/
├── main.dart                                    # Ponto de entrada; constrói e injeta as dependências
│
├── data/
│   ├── repositories/
│   │   └── locale_repository.dart              # Fonte da verdade do locale; expõe ValueListenable<Locale>
│   └── services/
│       └── locale_service.dart                 # Lê e grava o locale no SharedPreferences
│
├── domain/
│   └── app_locales.dart                        # localeFromCode, localeToCode e appLocaleLabels
│
└── ui/
    ├── core/
    │   └── routing/
    │       └── app_routes.dart                 # onGenerateRoute; instancia ConfigViewModel por rota
    │
    ├── features/
    │   ├── app/
    │   │   └── views/
    │   │       └── app.dart                    # Widget raiz — ouve LocaleRepository e configura MaterialApp
    │   ├── config/
    │   │   ├── view_models/
    │   │   │   └── config_view_model.dart      # currentLocaleCode, setLocale(Locale)
    │   │   └── views/
    │   │       └── config_screen.dart          # Tela de configuração; _LocaleDropdown + appLocaleLabels
    │   └── home/
    │       └── views/
    │           └── home_screen.dart            # Tela inicial (navega para ConfigScreen via FAB)
    │
    └── l10n/  *(gerado — não editar manualmente)*
        ├── context_l10n.dart                   # Extensão de atalho para BuildContext
        ├── app_en.arb                          # Traduções em inglês (template)
        ├── app_es.arb                          # Traduções em espanhol
        ├── app_pt.arb                          # Traduções em português
        ├── app_zh.arb                          # Traduções em chinês
        ├── app_localizations.dart              # Classe abstrata base (gerado)
        ├── app_localizations_en.dart           # Implementação para inglês (gerado)
        ├── app_localizations_es.dart           # Implementação para espanhol (gerado)
        ├── app_localizations_pt.dart           # Implementação para português (gerado)
        └── app_localizations_zh.dart           # Implementação para chinês (gerado)

test/
├── unit/
│   └── locale_repository_test.dart             # Testes do repositório (setLocale, ValueNotifier)
└── widget/
    └── config_screen_test.dart                 # Testes de widget da ConfigScreen
```

---

## 2. Dependências

O `pubspec.yaml` fixa `environment.sdk: ^3.11.0` (Dart 3.11+). As dependências centrais para l10n e persistência são:

```yaml
# pubspec.yaml (trecho — dependências de i18n e armazenamento)
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter      # Pacote oficial de localização do Flutter
  intl: any           # Formatação de datas, números e plurais por locale
  shared_preferences: ^2.5.5  # Persistência de chave-valor no dispositivo
  # Também presente no template do projeto (ícones estilo iOS):
  cupertino_icons: ^1.0.8

flutter:
  generate: true      # Habilita a geração automática de código l10n
```

> **Por que `intl: any`?** O SDK do Flutter já fixa a versão do `intl` internamente via `flutter_localizations`. Usar `any` evita conflitos de versão.

---

## 3. Como a internacionalização é configurada

A configuração usa a solução **oficial** do Flutter: o comando `flutter gen-l10n`, que lê arquivos `.arb` e gera classes Dart automaticamente.

### 3.1 Arquivo `l10n.yaml`

Na raiz do projeto existe o arquivo `l10n.yaml`, que instrui o gerador:

```yaml
# l10n.yaml
arb-dir: lib/l10n                        # Pasta onde ficam os arquivos .arb
template-arb-file: app_en.arb            # Arquivo-template (define as chaves)
output-localization-file: app_localizations.dart  # Nome do arquivo gerado
```

| Campo | Significado |
|---|---|
| `arb-dir` | Onde o gerador procura os arquivos de tradução |
| `template-arb-file` | Define quais chaves existem e serve de referência para os demais idiomas |
| `output-localization-file` | Nome da classe base gerada |

### 3.2 Habilitando a geração no `pubspec.yaml`

```yaml
flutter:
  generate: true   # <-- essencial para o gen-l10n funcionar
```

Sem essa linha, o Flutter não executa o gerador durante o build.

### 3.3 O que é gerado

Após rodar `flutter pub get` (ou `flutter run`), o Flutter gera automaticamente em `lib/l10n/`:

- `app_localizations.dart` — classe abstrata base `AppLocalizations`
- `app_localizations_en.dart` — implementação para inglês
- `app_localizations_es.dart` — implementação para espanhol
- `app_localizations_pt.dart` — implementação para português
- `app_localizations_zh.dart` — implementação para chinês

> **Não edite `app_localizations*.dart` na mão.** Com `flutter gen-l10n` e `l10n.yaml` apontando para `lib/l10n/`, o gerador **reescreve** esses arquivos quando você roda `flutter pub get`, `flutter run` ou `flutter gen-l10n`. Eles podem estar versionados no repositório só para conveniência/diff; a fonte de verdade das strings são sempre os `.arb`.

### 3.4 Registrando os delegates no `MaterialApp`

```dart
// lib/ui/features/app/views/app.dart (dentro do ListenableBuilder)
MaterialApp(
  title: 'Flutter Translate Example',
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: viewModel.locale,
  onGenerateRoute: routes.onGenerateRoute,
)
```

| Propriedade | O que faz |
|---|---|
| `localizationsDelegates` | Registra os provedores de strings traduzidas (inclui Material, Cupertino e Widgets) |
| `supportedLocales` | Lista os idiomas que o app suporta |
| `locale` | Define o idioma ativo. Quando muda, o `MaterialApp` reconstrói a árvore |
| `onGenerateRoute` | Função de roteamento dinâmico definida em `AppRoutes` |

O `LocaleRepository` é a **fonte da verdade** do locale. O widget `App` escuta `localeListenable` diretamente com `ValueListenableBuilder` — sem ViewModel intermediário, porque não há lógica de apresentação além de repassar o locale ao `MaterialApp`:

```dart
// lib/ui/features/app/views/app.dart
class App extends StatelessWidget {
  const App({super.key, required this.localeRepository, required this.routes});

  final LocaleRepository localeRepository;
  final AppRoutes routes;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeRepository.localeListenable,
      builder: (context, locale, _) {
        return MaterialApp(
          locale: locale,
          onGenerateRoute: routes.onGenerateRoute,
          // ...
        );
      },
    );
  }
}
```

### 3.5 Acessando as strings traduzidas na UI

Uma extensão sobre `BuildContext` elimina o boilerplate de `AppLocalizations.of(context)!`:

```dart
// lib/l10n/context_l10n.dart
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
```

Uso na tela:

```dart
// lib/ui/features/home/views/home_screen.dart
Text(context.l10n.helloWorld)

// lib/ui/features/config/views/config_screen.dart
AppBar(title: Text(context.l10n.config))
```

---

## 4. Estrutura e uso dos arquivos de tradução (ARB)

Os arquivos `.arb` (Application Resource Bundle) são JSONs que contêm as strings traduzidas.

### 4.1 O arquivo-template: `app_en.arb`

```json
{
  "@@locale": "en",
  "helloWorld": "Hello World",
  "@helloWorld": {
    "description": "The conventional newborn programmer greeting"
  },
  "config": "Settings",
  "@config": {
    "description": "Label for the configuration screen"
  }
}
```

| Campo | Significado |
|---|---|
| `@@locale` | Declara o idioma do arquivo |
| `"helloWorld"` | Chave da string (usada no código como `context.l10n.helloWorld`) |
| `"@helloWorld"` | Metadados da string (descrição, parâmetros, exemplos) |
| `"config"` | Chave da string (ex.: `context.l10n.config` no `AppBar` da `ConfigScreen`) |
| `"@config"` | Metadados da string `config` |

O arquivo `app_en.arb` é o **template**: todas as chaves que você quiser usar no app devem estar nele. Os outros `.arb` traduzem essas mesmas chaves.

### 4.2 Arquivos dos demais idiomas

Os arquivos secundários só precisam conter a chave `@@locale` e as traduções; metadados `@…` são opcionais (no repositório, `app_zh.arb` repete `@helloWorld`).

`app_pt.arb`:

```json
{
  "@@locale": "pt",
  "helloWorld": "Olá, mundo",
  "config": "Configurações"
}
```

`app_es.arb`:

```json
{
  "@@locale": "es",
  "helloWorld": "Hola, mundo",
  "config": "Configuración"
}
```

`app_zh.arb`:

```json
{
  "@@locale": "zh",
  "helloWorld": "你好，世界",
  "config": "设置"
}
```

### 4.3 Adicionando uma nova string traduzível

**Passo 1:** Adicione a chave no template `app_en.arb`:

```json
{
  "@@locale": "en",
  "helloWorld": "Hello World",
  "@helloWorld": {
    "description": "The conventional newborn programmer greeting"
  },
  "welcomeMessage": "Welcome, {name}!",
  "@welcomeMessage": {
    "description": "Greeting with the user's name",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**Passo 2:** Adicione a tradução nos demais `.arb` (exemplo `app_pt.arb`):

```json
{
  "@@locale": "pt",
  "helloWorld": "Olá, mundo",
  "config": "Configurações",
  "welcomeMessage": "Bem-vindo, {name}!"
}
```

**Passo 3:** Use no código:

```dart
Text(context.l10n.welcomeMessage('João'))
```

---

## 5. Como o idioma padrão é definido

O idioma padrão é definido em `LocaleService`, na camada de serviços:

```dart
// lib/data/services/locale_service.dart
static const _defaultLocale = Locale('en');

Locale load() {
  final saved = _prefs.getString(_key);
  return saved != null ? localeFromCode(saved) : _defaultLocale; // <-- retorna inglês se nada estiver salvo
}
```

**Regra:** na primeira execução do app, nenhuma preferência está salva ainda, então `_prefs.getString('locale')` retorna `null` e o método devolve `Locale('en')` como padrão.

Para alterar o idioma padrão, basta mudar o valor da constante:

```dart
static const _defaultLocale = Locale('pt'); // padrão: português
```

---

## 6. Persistência com SharedPreferences

### 6.1 Como o idioma é serializado

O `Locale` do Flutter tem dois componentes: `languageCode` e `countryCode` (opcional). A serialização e desserialização são feitas pelas funções utilitárias definidas em `lib/domain/app_locales.dart`:

```dart
// lib/domain/app_locales.dart

// Converte código string → Locale
Locale localeFromCode(String code) {
  final parts = code.split('_');
  return parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
}

// Converte Locale → código string
String localeToCode(Locale locale) {
  return locale.countryCode != null
      ? '${locale.languageCode}_${locale.countryCode}'
      : locale.languageCode;
}
```

```
Locale('en')       → "en"
Locale('pt', 'BR') → "pt_BR"
Locale('zh')       → "zh"
```

### 6.2 `LocaleService`: salvar e carregar

O serviço encapsula o `SharedPreferences` e delega a serialização para `app_locales.dart`:

```dart
// lib/data/services/locale_service.dart
class LocaleService {
  LocaleService(this._prefs);

  static const _key = 'locale';
  static const _defaultLocale = Locale('en');

  final SharedPreferences _prefs;

  Locale load() {
    final saved = _prefs.getString(_key);
    return saved != null ? localeFromCode(saved) : _defaultLocale;
  }

  Future<void> save(Locale locale) async {
    await _prefs.setString(_key, localeToCode(locale));
  }
}
```

Se nada estiver salvo, `load()` retorna inglês (`_defaultLocale`).

### 6.3 Por que o `SharedPreferences` é inicializado no `main`

O método `SharedPreferences.getInstance()` é assíncrono. Para que o idioma já esteja disponível **antes** de o app renderizar qualquer widget, ele é inicializado no `main` com `await`:

```dart
// lib/main.dart
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
```

Esse padrão garante que o idioma correto é aplicado já no primeiro frame, sem exibir brevemente o idioma padrão antes de aplicar o idioma salvo pelo usuário. As dependências são compostas e injetadas diretamente no `main`, sem uso de Service Locator global.

### 6.4 `LocaleRepository`: fonte da verdade do locale

O `LocaleRepository` mantém um `ValueNotifier<Locale>` interno. Ele carrega o valor inicial do `LocaleService` no construtor e o atualiza a cada `setLocale`. É a **única fonte da verdade** do locale em todo o app:

```dart
// lib/data/repositories/locale_repository.dart
class LocaleRepository {
  LocaleRepository(this._service) {
    _locale = ValueNotifier(_service.load());
  }

  final LocaleService _service;
  late final ValueNotifier<Locale> _locale;

  Locale get locale => _locale.value;

  ValueListenable<Locale> get localeListenable => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale.value == locale) return;
    await _service.save(locale);
    _locale.value = locale; // notifica todos os ouvintes automaticamente
  }
}
```

Expor `ValueListenable<Locale>` (em vez de `Listenable` opaco) permite que a camada de apresentação leia o valor atual e se inscreva para mudanças de forma direta.

### 6.5 Por que o `App` não usa ViewModel

Neste projeto pequeno, o widget raiz só precisa reagir a mudanças de locale. Criar um `AppViewModel` que apenas repassa `localeListenable` adicionaria uma camada sem lógica própria.

O `ValueListenableBuilder` já resolve isso: o repositório permanece a única fonte da verdade e o `MaterialApp` reconstrói quando o locale muda.

**ViewModel fica na `ConfigScreen`**, onde há interação do usuário (dropdown) e lógica de apresentação (`currentLocaleCode`).

---

## 7. Injeção de dependências por construtor

### 7.1 A estratégia: composição no `main`

O projeto usa **injeção por construtor** como mecanismo de DI. Todas as dependências são instanciadas e compostas no `main`, antes de `runApp()`. Cada objeto recebe explicitamente o que precisa — sem Singleton global, sem Service Locator:

```dart
// lib/main.dart
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
```

| Vantagem | Explicação |
|---|---|
| Testabilidade | Cada classe pode receber mocks no construtor sem configuração extra |
| Rastreabilidade | O grafo de dependências é visível inteiramente no `main` |
| Sem estado global | Não há Singleton acessível de qualquer lugar; dependências fluem explicitamente |
| Single Responsibility | Cada classe declara exatamente o que precisa, sem consultar um locator |

### 7.2 Fluxo de dependências

```
main()
  ├─ LocaleService(prefs)
  ├─ LocaleRepository(service)
  │
  ├─ App(localeRepository)              ← ValueListenableBuilder ouve localeListenable
  │
  └─ AppRoutes(localeRepository)        ← recebe LocaleRepository
          └─ por rota: ConfigViewModel(localeRepository)
                  └─ ouve localeListenable
```

### 7.3 `AppRoutes`: criação do ViewModel por rota

`AppRoutes` recebe `LocaleRepository` e instancia um novo `ConfigViewModel` a cada navegação para `/config`. O `ConfigScreen` é um `StatefulWidget` que chama `viewModel.dispose()` no seu próprio `dispose`, encerrando o listener:

```dart
// lib/ui/core/routing/app_routes.dart
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
```

### 7.4 `ConfigViewModel`: lógica de apresentação da tela de configuração

O `ConfigViewModel` depende de `LocaleRepository`. Expõe `currentLocaleCode` e `setLocale` — o mapa `appLocaleLabels` em `app_locales.dart` é usado diretamente na View para montar o dropdown.

```dart
// lib/ui/features/config/view_models/config_view_model.dart
class ConfigViewModel extends ChangeNotifier {
  ConfigViewModel(this._localeRepository) {
    _localeRepository.localeListenable.addListener(notifyListeners);
  }

  final LocaleRepository _localeRepository;

  String get currentLocaleCode =>
      localeToCode(_localeRepository.localeListenable.value);

  Future<void> setLocale(Locale locale) async {
    await _localeRepository.setLocale(locale);
  }
}
```

**Por que `setLocale(Locale)` e não `setLocale(String label)`?** O mapeamento de label de exibição para `Locale` é uma responsabilidade da View. O ViewModel opera com tipos de domínio (`Locale`), não com strings de apresentação.

### 7.5 `ConfigScreen`: ListenableBuilder cirúrgico

O `Scaffold` e o `AppBar` são estáticos — só o dropdown precisa reconstruir. O `ListenableBuilder` envolve apenas o widget `_LocaleDropdown`, evitando reconstruções desnecessárias da tela inteira:

```dart
// lib/ui/features/config/views/config_screen.dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text(context.l10n.config)), // estático
    body: Center(
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => _LocaleDropdown(viewModel: widget.viewModel),
      ),
    ),
  );
}
```

O `_LocaleDropdown` mapeia `appLocaleLabels` para `DropdownMenuEntry` e converte o código selecionado de volta para `Locale` via `localeFromCode` antes de chamar `viewModel.setLocale`:

```dart
onSelected: (String? code) {
  if (code == null || code == currentCode) return;
  viewModel.setLocale(localeFromCode(code)); // lógica de apresentação na View
},
```

### 7.6 Caminho para o `get_it`

Se o projeto crescer e a composição manual no `main` se tornar verbosa, a migração para o `get_it` é direta: cada `repository` e `viewModel` passa a ser registrado com `GetIt.I.registerSingleton` ou `registerFactory`. A lógica interna das classes não precisa mudar, pois nenhuma delas consulta um locator — elas só recebem dependências pelo construtor.

---

## 8. Fluxo completo: do início do app à troca de idioma

### 8.1 Inicialização

```
main()
  │
  ├─ await SharedPreferences.getInstance()
  │     └─ acessa o armazenamento local do dispositivo
  │
  ├─ LocaleService(prefs)
  │     └─ encapsula o acesso ao SharedPreferences
  │
  ├─ LocaleRepository(service)
  │     └─ ValueNotifier(_service.load())
  │           └─ lê a chave "locale" do SharedPreferences
  │                 ├─ se existir → ValueNotifier(Locale salvo)
  │                 └─ se não existir → ValueNotifier(Locale('en'))
  │
  ├─ AppRoutes(localeRepository: repository)
  │
  └─ runApp(App(localeRepository: ..., routes: ...))
        └─ ValueListenableBuilder ouve localeListenable
              └─ MaterialApp renderiza com locale correto no primeiro frame
```

### 8.2 Troca de idioma pelo usuário

```
Usuário pressiona o FAB na HomeScreen
  │
  └─ Navigator.pushNamed(context, AppRoutes.config)
        └─ AppRoutes.onGenerateRoute cria ConfigViewModel(localeRepository)
              └─ ConfigScreen(viewModel: configViewModel) é exibida

Usuário seleciona "Português" no dropdown
  │
  ├─ _LocaleDropdown.onSelected(code: "pt")
  │     └─ viewModel.setLocale(localeFromCode("pt"))  ← lógica de apresentação na View
  │
  ├─ ConfigViewModel.setLocale(Locale('pt'))
  │     └─ localeRepository.setLocale(Locale('pt'))
  │           ├─ service.save(Locale('pt')) → grava "pt" no SharedPreferences
  │           └─ _locale.value = Locale('pt')  ← ValueNotifier notifica ouvintes
  │
  ├─ App (ValueListenableBuilder) recebe notificação via localeListenable
  │     └─ MaterialApp reconstrói com locale: Locale('pt')
  │
  ├─ ConfigViewModel recebe notificação via localeListenable
  │     └─ notifyListeners() → _LocaleDropdown reconstrói com currentLocaleCode: "pt"
  │
  └─ Flutter reconstrói toda a árvore de widgets com as strings em português
```

### 8.3 Diagrama de camadas

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│                                                      │
│  App ──► ValueListenableBuilder (localeListenable)  │
│  HomeScreen ──► navega ──► ConfigScreen             │
│  ConfigScreen ──► ConfigViewModel (observer fino)   │
│                    │ ouve localeListenable         │
└────────────────────┼────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│                    Data Layer                        │
│  LocaleRepository  (ValueNotifier<Locale>)         │
│       │                                             │
│       └──► LocaleService                           │
│                  │                                  │
│                  └──► SharedPreferences             │
└─────────────────────────────────────────────────────┘

  Utilitários em domain/: app_locales (serialização + labels do dropdown)

  Composição das dependências: main() → runApp()
  (sem Service Locator global)
```

---

## 9. Como adicionar um novo idioma

Este é um processo de **4 etapas**. Vamos usar o **francês** (`fr`) como exemplo.

### Etapa 1 — Criar o arquivo ARB

Crie o arquivo `lib/l10n/app_fr.arb` com as traduções:

```json
{
  "@@locale": "fr",
  "helloWorld": "Bonjour le monde"
}
```

> Todas as chaves que existem no `app_en.arb` (template) devem ser traduzidas aqui.

### Etapa 2 — Registrar o idioma nos metadados do app

Abra `lib/domain/app_locales.dart` e adicione o francês:

```dart
// lib/domain/app_locales.dart
const Map<String, String> appLocaleLabels = <String, String>{
  'en': 'English',
  'es': 'Español',
  'pt': 'Português',
  'zh': '中文',
  'fr': 'Français', // +fr
};
```

Esse mapa alimenta o dropdown da `ConfigScreen` (via `appLocaleLabels`) e deve permanecer alinhado aos locales suportados pelo app.

### Etapa 3 — Verificar o `LocaleService` e `app_locales.dart`

O `LocaleService` **não precisa de alteração**. Ele delega toda a lógica de serialização para as funções `localeToCode` e `localeFromCode` de `app_locales.dart`, que já tratam qualquer `Locale` de forma genérica:

```dart
// Salva qualquer Locale como string ("fr" neste exemplo)
Future<void> save(Locale locale) async {
  await _prefs.setString(_key, localeToCode(locale)); // Locale('fr') → "fr"
}

// Carrega a string e converte de volta para Locale
Locale load() {
  final saved = _prefs.getString(_key); // lê "fr"
  return saved != null ? localeFromCode(saved) : _defaultLocale; // → Locale('fr')
}
```

Da mesma forma, as funções `localeFromCode` e `localeToCode` em `app_locales.dart` **não precisam de alteração** — elas já funcionam para qualquer código de idioma.

### Etapa 4 — Executar o gerador

Execute qualquer um dos comandos abaixo para gerar o arquivo `app_localizations_fr.dart`:

```bash
flutter pub get
# ou
flutter run
# ou, explicitamente:
flutter gen-l10n
```

O Flutter detectará o novo `app_fr.arb` e criará `lib/l10n/app_localizations_fr.dart` automaticamente. O novo idioma já aparecerá no dropdown e será persistido corretamente.

### Resumo dos arquivos ao adicionar um idioma

| Arquivo | O que fazer |
|---|---|
| `lib/l10n/app_fr.arb` | **Criar** com as traduções |
| `lib/domain/app_locales.dart` | **Adicionar** código e label ao mapa `appLocaleLabels` |
| `lib/data/services/locale_service.dart` | **Nada** — delega a serialização para `app_locales.dart` |
| `lib/domain/app_locales.dart` (`localeFromCode`/`localeToCode`) | **Nada** — funções genéricas para qualquer locale |
| `lib/ui/features/app/views/app.dart` | **Nada** — usa `AppLocalizations.supportedLocales` (gerado) |

### Exemplo com código de país: Português do Brasil (`pt_BR`)

Para idiomas que usam código de país, o processo é idêntico. Crie `app_pt_BR.arb`:

```json
{
  "@@locale": "pt_BR",
  "helloWorld": "Olá, Mundo!"
}
```

Registre em `app_locales.dart`:

```dart
// lib/domain/app_locales.dart
const Map<String, String> appLocaleLabels = <String, String>{
  // ...
  'pt_BR': 'Português (Brasil)',
};
```

O `ConfigViewModel` passará `localeFromCode('pt_BR')` → `Locale('pt', 'BR')` para o `LocaleRepository`, que o serializará como `"pt_BR"` via `LocaleService` e o desserializará corretamente na próxima inicialização.

---

## 10. Referências

| Recurso | Link |
|---|---|
| Internacionalização Flutter (l10n) — guia oficial | [flutter.dev/to/internationalization](https://flutter.dev/to/internationalization) |
| `flutter_localizations` — documentação da API | [api.flutter.dev/flutter/flutter_localizations](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html) |
| `intl` — pub.dev | [pub.dev/packages/intl](https://pub.dev/packages/intl) |
| `shared_preferences` — pub.dev | [pub.dev/packages/shared_preferences](https://pub.dev/packages/shared_preferences) |
| Arquitetura MVVM recomendada pelo Flutter | [docs.flutter.dev/app-architecture/guide](https://docs.flutter.dev/app-architecture/guide) |
| Layered Architecture — Flutter docs | [docs.flutter.dev/app-architecture/concepts](https://docs.flutter.dev/app-architecture/concepts) |
| Formato ARB (Application Resource Bundle) | [github.com/google/app-resource-bundle](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification) |
| `gen-l10n` — referência da ferramenta de geração | [docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#configuring-the-l10n-yaml-file](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#configuring-the-l10n-yaml-file) |
| `get_it` — Service Locator pub.dev (caminho para escalar o DI) | [pub.dev/packages/get_it](https://pub.dev/packages/get_it) |

---

## 11. Screenshots

<p>
  <img width="243" height="517" alt="image" src="https://github.com/user-attachments/assets/e860cc19-a882-499f-a74c-afa01da22e2a" />
  <img width="248" height="514" alt="image" src="https://github.com/user-attachments/assets/3ceb35a7-f20e-47ea-832d-7daeb67c1212" />
</p>
