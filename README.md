# Flutter Translate Example

Projeto de referência que demonstra como implementar **internacionalização (l10n)** com a solução oficial do Flutter (`flutter_localizations` + `gen-l10n`) combinada com **persistência de idioma** via `shared_preferences`, seguindo a arquitetura **MVVM** recomendada pela equipe do Flutter.

---

## Sumário

1. [Estrutura do projeto](#1-estrutura-do-projeto)
2. [Dependências](#2-dependências)
3. [Como a internacionalização foi configurada](#3-como-a-internacionalização-foi-configurada)
4. [Estrutura e uso dos arquivos de tradução (ARB)](#4-estrutura-e-uso-dos-arquivos-de-tradução-arb)
5. [Como o idioma padrão é definido](#5-como-o-idioma-padrão-é-definido)
6. [Persistência com SharedPreferences](#6-persistência-com-sharedpreferences)
7. [Fluxo completo: do início do app à troca de idioma](#7-fluxo-completo-do-início-do-app-à-troca-de-idioma)
8. [Como adicionar um novo idioma](#8-como-adicionar-um-novo-idioma)
9. [Referências](#9-referências)
10. [Screenshots](#10-screenshots)

---

## 1. Estrutura do projeto

```
lib/
├── main.dart                          # Ponto de entrada; composição das dependências
├── app.dart                           # Widget raiz (MaterialApp)
│
├── data/
│   ├── repositories/
│   │   └── locale_repository.dart    # Repositório de idioma (stateless)
│   └── services/
│       └── locale_service.dart       # Acesso ao SharedPreferences (stateless)
│
├── domain/
│   └── app_locales.dart              # Mapa de idiomas e funções utilitárias de conversão de Locale
│
├── routing/
│   └── app_routes.dart               # Rotas nomeadas do app
│
├── ui/
│   ├── app/
│   │   └── view_model/
│   │       └── app_view_model.dart   # ViewModel do widget raiz
│   ├── core/
│   │   └── widgets/
│   │       └── app_dropdown_menu.dart # Widget de seleção reutilizável
│   └── home/
│       ├── view_model/
│       │   └── home_view_model.dart  # Lógica de apresentação da tela inicial
│       └── widgets/
│           └── home_screen.dart      # Tela inicial
│
└── l10n/
    ├── context_l10n.dart             # Extensão de atalho para BuildContext
    ├── app_en.arb                    # Traduções em inglês (template)
    ├── app_es.arb                    # Traduções em espanhol
    ├── app_pt.arb                    # Traduções em português
    ├── app_zh.arb                    # Traduções em chinês
    └── app_localizations*.dart       # Arquivos gerados automaticamente pelo Flutter
```

---

## 2. Dependências

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter      # Pacote oficial de localização do Flutter
  intl: any           # Formatação de datas, números e plurais por locale
  shared_preferences: ^2.5.5  # Persistência de chave-valor no dispositivo

flutter:
  generate: true      # Habilita a geração automática de código l10n
```

> **Por que `intl: any`?** O SDK do Flutter já fixa a versão do `intl` internamente via `flutter_localizations`. Usar `any` evita conflitos de versão.

---

## 3. Como a internacionalização foi configurada

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

> **Nunca edite os arquivos gerados se você usar o `gen-l10n` automático.** Eles são sobrescritos a cada build. Neste projeto, os arquivos `app_localizations*.dart` são mantidos manualmente — edite apenas os `.arb` para adicionar ou alterar traduções.

### 3.4 Registrando os delegates no `MaterialApp`

```dart
// lib/app.dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: _viewModel.locale,
  initialRoute: AppRoutes.home,
  routes: AppRoutes.routes(_viewModel),
)
```

| Propriedade | O que faz |
|---|---|
| `localizationsDelegates` | Registra os provedores de strings traduzidas (inclui Material, Cupertino e Widgets) |
| `supportedLocales` | Lista os idiomas que o app suporta |
| `locale` | Define o idioma ativo. Quando muda, o `MaterialApp` reconstrói a árvore |
| `initialRoute` | Rota exibida na inicialização do app |
| `routes` | Mapa de rotas nomeadas definido em `AppRoutes` |

O `AppViewModel` é a **fonte da verdade** do estado do idioma em memória. O `ListenableBuilder` envolve o `MaterialApp` para que qualquer mudança de idioma reconstrua o widget e aplique o novo `locale`:

```dart
// lib/app.dart
ListenableBuilder(
  listenable: _viewModel,
  builder: (context, _) {
    return MaterialApp(
      locale: _viewModel.locale,
      // ...
    );
  },
)
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
// lib/ui/home/widgets/home_screen.dart
Text(context.l10n.helloWorld)
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
  }
}
```

| Campo | Significado |
|---|---|
| `@@locale` | Declara o idioma do arquivo |
| `"helloWorld"` | Chave da string (usada no código como `context.l10n.helloWorld`) |
| `"@helloWorld"` | Metadados da string (descrição, parâmetros, exemplos) |

O arquivo `app_en.arb` é o **template**: todas as chaves que você quiser usar no app devem estar nele. Os outros `.arb` traduzem essas mesmas chaves.

### 4.2 Arquivos dos demais idiomas

Os arquivos secundários só precisam conter a chave `@@locale` e as traduções, sem metadados:

```json
// app_pt.arb
{
  "@@locale": "pt",
  "helloWorld": "Olá, mundo"
}
```

```json
// app_es.arb
{
  "@@locale": "es",
  "helloWorld": "Hola, mundo"
}
```

```json
// app_zh.arb
{
  "@@locale": "zh",
  "helloWorld": "你好，世界"
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

**Passo 2:** Adicione a tradução nos demais `.arb`:

```json
// app_pt.arb
{
  "@@locale": "pt",
  "helloWorld": "Olá, mundo",
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
  return saved != null ? localeFromCode(saved) : _defaultLocale; // <-- retorna inglês se nada foi salvo
}
```

**Regra:** na primeira execução do app, nenhuma preferência foi salva ainda, então `_prefs.getString('locale')` retorna `null` e o método devolve `Locale('en')` como padrão.

Para alterar o idioma padrão, basta mudar o valor da constante:

```dart
static const _defaultLocale = Locale('pt'); // Agora o padrão é português
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

### 6.2 `LocaleService`: salvar e carregar (stateless)

O serviço delega a serialização para as funções de `app_locales.dart`. Como operações de I/O podem falhar (por exemplo, falta de espaço em disco), ambos os métodos envolvem a chamada em `try-catch`. Os erros são reportados via `FlutterError.reportError`, que em produção pode ser interceptado por ferramentas como Crashlytics através do `FlutterError.onError`:

```dart
// lib/data/services/locale_service.dart
class LocaleService {
  LocaleService(this._prefs);

  static const _key = 'locale';
  static const _defaultLocale = Locale('en');

  final SharedPreferences _prefs;

  Locale load() {
    try {
      final saved = _prefs.getString(_key);
      return saved != null ? localeFromCode(saved) : _defaultLocale;
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'LocaleService',
        context: ErrorDescription('ao carregar o locale do SharedPreferences'),
      ));
      return _defaultLocale;
    }
  }

  Future<void> save(Locale locale) async {
    try {
      await _prefs.setString(_key, localeToCode(locale));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'LocaleService',
        context: ErrorDescription('ao salvar o locale do SharedPreferences'),
      ));
    }
  }
}
```

**Por que `FlutterError.reportError` e não apenas `print`?** O `FlutterError.reportError` é o canal oficial do Flutter para reportar erros não fatais. Em modo debug ele imprime no console com formatação detalhada; em produção, qualquer handler registrado em `FlutterError.onError` (como o `FirebaseCrashlytics.instance.recordFlutterFatalError`) recebe o erro automaticamente. Usar `print` ou `debugPrint` descartaria essas integrações.

**Comportamento em caso de falha:**
- `load()` — retorna `_defaultLocale` (inglês), garantindo que o app sempre inicializa em um estado válido.
- `save()` — a UI já foi atualizada antes dessa chamada (via `notifyListeners()` no `AppViewModel`), então o app continua funcionando normalmente; apenas a preferência não será persistida para a próxima sessão.

### 6.3 Por que o `SharedPreferences` é inicializado no `main`

O método `SharedPreferences.getInstance()` é assíncrono. Para que o idioma já esteja disponível **antes** de o app renderizar qualquer widget, ele é inicializado no `main` com `await`:

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // necessário antes de qualquer await
  final prefs = await SharedPreferences.getInstance();
  final service = LocaleService(prefs);
  final repository = LocaleRepository(service);
  runApp(App(localeRepository: repository));
}
```

Esse padrão garante que o idioma correto é aplicado já no primeiro frame, sem exibir brevemente o idioma padrão antes de aplicar o idioma salvo pelo usuário.

### 6.4 `LocaleRepository`: acesso stateless aos dados

O `LocaleRepository` pertence à camada de Dados e é completamente stateless — ele apenas delega operações de leitura e escrita ao `LocaleService`, sem guardar estado em memória:

```dart
// lib/data/repositories/locale_repository.dart
class LocaleRepository {
  LocaleRepository(this._service);

  final LocaleService _service;

  Locale load() => _service.load();

  Future<void> save(Locale locale) => _service.save(locale);
}
```

### 6.5 `AppViewModel`: fonte da verdade do estado do idioma

O estado do idioma em memória vive na camada de Apresentação, dentro do `AppViewModel`. Ele carrega o valor inicial do repositório e notifica a UI sempre que o idioma muda:

```dart
// lib/ui/app/view_model/app_view_model.dart
class AppViewModel extends ChangeNotifier {
  AppViewModel(this._localeRepository)
      : _locale = _localeRepository.load();

  final LocaleRepository _localeRepository;
  Locale _locale;

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return; // evita notificações desnecessárias
    _locale = locale;
    notifyListeners(); // atualiza a UI imediatamente
    await _localeRepository.save(locale); // persiste em background
  }
}
```

**Detalhe importante:** `notifyListeners()` é chamado **antes** de `_localeRepository.save()`. Isso faz a UI responder de forma instantânea, enquanto a escrita no disco acontece de forma assíncrona em seguida.

Essa separação respeita a **Clean Architecture**: a camada de Dados apenas lê e grava dados; quem mantém o estado reativo e notifica a UI é a camada de Apresentação.

---

## 7. Fluxo completo: do início do app à troca de idioma

### 7.1 Inicialização

```
main()
  │
  ├─ await SharedPreferences.getInstance()
  │     └─ acessa o armazenamento local do dispositivo
  │
  ├─ LocaleService(prefs)
  │     └─ encapsula o acesso ao SharedPreferences (stateless)
  │
  ├─ LocaleRepository(service)
  │     └─ apenas delega load/save ao LocaleService (stateless)
  │
  └─ runApp(App(localeRepository: repository))
        │
        └─ App cria AppViewModel(localeRepository)
              └─ AppViewModel chama localeRepository.load() no construtor
                    └─ lê a chave "locale" do SharedPreferences
                          ├─ se existir → guarda o Locale salvo em _locale
                          └─ se não existir → guarda Locale('en')
              └─ MaterialApp já renderiza com o locale correto
```

### 7.2 Troca de idioma pelo usuário

```
Usuário seleciona "Português" no dropdown
  │
  ├─ HomeScreen.onSelected("Português")
  │
  ├─ HomeViewModel.setLocale("Português")
  │     ├─ converte o label para o código: "Português" → "pt"
  │     └─ chama appViewModel.setLocale(Locale('pt'))
  │
  ├─ AppViewModel.setLocale(Locale('pt'))
  │     ├─ atualiza _locale em memória
  │     ├─ notifyListeners() → notifica todos os ouvintes
  │     └─ localeRepository.save(Locale('pt')) → grava "pt" no SharedPreferences
  │
  ├─ App (ListenableBuilder) recebe a notificação do AppViewModel
  │     └─ reconstrói o MaterialApp com locale: Locale('pt')
  │
  ├─ HomeScreen (ListenableBuilder) recebe a notificação via HomeViewModel
  │     └─ atualiza o dropdown para refletir o idioma selecionado
  │
  └─ Flutter reconstrói toda a árvore de widgets com as strings em português
```

### 7.3 Diagrama de camadas

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│  App  ──►  AppViewModel (ChangeNotifier)            │
│               ↑ fonte da verdade do estado           │
│  HomeScreen  ──►  HomeViewModel (ChangeNotifier)    │
│                       │ ouve e delega a              │
│                       └──► AppViewModel              │
└────────────────────────┬────────────────────────────┘
                         │ usa
┌────────────────────────▼────────────────────────────┐
│                    Data Layer                        │
│  LocaleRepository (stateless)                       │
│       │                                              │
│       └──► LocaleService (stateless)                │
│                  │                                   │
│                  └──► SharedPreferences              │
└─────────────────────────────────────────────────────┘
```

---

## 8. Como adicionar um novo idioma

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

Esse mapa alimenta o dropdown da tela e a lógica de conversão entre label e código.

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
dart run intl_utils:generate
```

O Flutter detectará o novo `app_fr.arb` e criará `lib/l10n/app_localizations_fr.dart` automaticamente. O novo idioma já aparecerá no dropdown e será persistido corretamente.

### Resumo das alterações para adicionar um idioma

| Arquivo | O que fazer |
|---|---|
| `lib/l10n/app_fr.arb` | **Criar** com as traduções |
| `lib/domain/app_locales.dart` | **Adicionar** código e label ao mapa `appLocaleLabels` |
| `lib/data/services/locale_service.dart` | **Nada** — delega a serialização para `app_locales.dart` |
| `lib/domain/app_locales.dart` (`localeFromCode`/`localeToCode`) | **Nada** — funções genéricas para qualquer locale |
| `lib/app.dart` | **Nada** — usa `AppLocalizations.supportedLocales` (gerado) |

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
const Map<String, String> appLocaleLabels = <String, String>{
  // ...
  'pt_BR': 'Português (Brasil)',
};
```

O `AppViewModel` passará o `Locale('pt', 'BR')` para o `LocaleRepository`, que o serializará como `"pt_BR"` via `LocaleService` e o desserializará corretamente na próxima inicialização.

---

## 9. Referências

| Recurso | Link |
|---|---|
| Internacionalização Flutter (l10n) — guia oficial | [flutter.dev/to/internationalization](https://flutter.dev/to/internationalization) |
| `flutter_localizations` — documentação da API | [api.flutter.dev/flutter/flutter_localizations](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html) |
| `intl` — pub.dev | [pub.dev/packages/intl](https://pub.dev/packages/intl) |
| `shared_preferences` — pub.dev | [pub.dev/packages/shared_preferences](https://pub.dev/packages/shared_preferences) |
| Arquitetura MVVM recomendada pelo Flutter | [docs.flutter.dev/app-architecture/guide](https://docs.flutter.dev/app-architecture/guide) |
| Formato ARB (Application Resource Bundle) | [github.com/google/app-resource-bundle](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification) |
| `gen-l10n` — referência da ferramenta de geração | [docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#configuring-the-l10n-yaml-file](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#configuring-the-l10n-yaml-file) |

---

## 10. Screenshots

<p>
  <img width="243" height="517" alt="image" src="https://github.com/user-attachments/assets/e860cc19-a882-499f-a74c-afa01da22e2a" />
  <img width="248" height="514" alt="image" src="https://github.com/user-attachments/assets/3ceb35a7-f20e-47ea-832d-7daeb67c1212" />
</p>
