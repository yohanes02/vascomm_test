# Flutter Clean Architecture Starter — Auth Feature

A Feature-First Clean Architecture scaffold with Riverpod state management
(plain, hand-written providers — no `riverpod_generator`/`@riverpod`
codegen) and a complete login/register auth feature.

## Getting started

```bash
cp env/.env.example env/.env   # then fill in your API key
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Runtime config lives in `env/.env` (gitignored) and is read at startup by
`core/config/env.dart` via `flutter_dotenv`. The file is declared as an
asset in `pubspec.yaml`, so **add new keys to `env/.env.example` too** and
expose them as getters on `Env` rather than reading `dotenv` directly —
that keeps the "missing key" error in one place. Get a free reqres.in key
at https://reqres.in.

`build_runner` is only needed for the `@freezed` classes (entities and
DTOs) and their `fromJson`/`toJson`. It generates `*.freezed.dart` and
`*.g.dart` files. Re-run it (or use `dart run build_runner watch
--delete-conflicting-outputs` while developing) after editing any
`@freezed` class.

Riverpod providers are **not** code-generated — they're plain
`Provider`/`AsyncNotifierProvider` declarations you can read and edit
directly with no `part` files and no separate build step.

## Folder structure

```
env/
├── .env                                # Runtime config — gitignored
└── .env.example                        # Committed template
lib/
├── core/
│   ├── config/env.dart                 # Env — typed getters over env/.env
│   ├── error/                          # Failure hierarchy, mapError/guard, ErrorReporter
│   ├── network/dio_client.dart         # dioProvider — shared Dio instance + auth token interceptor
│   ├── storage/token_storage.dart      # tokenStorageProvider — secure storage for access/refresh tokens
│   ├── routing/app_router.dart         # appRouterProvider — go_router config + auth redirect guard
│   ├── theme/app_theme.dart            # Light/dark ThemeData
│   └── presentation/
│       └── widgets/                    # Cross-feature UI only (AppDrawer, AppInputField,
│                                       # PrimaryButton, SegmentedToggle, AppIcon, ...)
├── features/
│   ├── home/
│   │   └── presentation/
│   │       ├── pages/home_page.dart    # Post-login landing screen
│   │       └── widgets/                # Home-only UI (PromoBannerCarousel, ServiceFeatureCard,
│   │                                   # SearchBarRow, CategoryChipBar)
│   ├── profile/
│   │   └── presentation/
│   │       └── pages/profile_page.dart # "Profile Saya" — edits the session user via auth's
│   │                                   # UpdateProfile use case
│   └── auth/
│       ├── domain/                     # Pure Dart. No Flutter, no Riverpod, no Dio.
│       │   ├── entities/user.dart
│       │   ├── entities/auth_params.dart          # LoginParams / RegisterParams value objects
│       │   ├── repositories/auth_repository.dart  # abstract interface
│       │   └── usecases/                          # login_user, register_user, logout_user, get_current_user
│       ├── data/
│       │   ├── models/user_model.dart
│       │   ├── models/auth_response_model.dart     # {accessToken, refreshToken, user} DTO
│       │   ├── datasources/auth_remote_data_source.dart   # authRemoteDataSourceProvider
│       │   └── repositories/auth_repository_impl.dart     # authRepositoryProvider
│       └── presentation/
│           ├── controllers/auth_controller.dart    # authControllerProvider — AsyncNotifierProvider<AuthController, User?>
│           ├── widgets/                            # AuthHeader, AuthFooter (shared by both auth pages)
│           └── pages/login_page.dart, register_page.dart
└── main.dart
```

## How Riverpod is wired here (no codegen)

Every provider is a plain top-level `final`:

```dart
// core/network/dio_client.dart
final dioProvider = Provider<Dio>((ref) { ... });

// features/auth/presentation/controllers/auth_controller.dart
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async { ... }
  Future<void> login({...}) async { ... }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);
```

Dependencies are injected by `ref.watch()`-ing the provider one layer
down: `authRepositoryProvider` watches `authRemoteDataSourceProvider` and
`tokenStorageProvider`; `authRemoteDataSourceProvider` watches
`dioProvider`. Swap any layer (e.g. for tests) by overriding its provider
in a `ProviderScope` — no constructor threading needed, and nothing to
regenerate.

## Auth feature notes

- **`authControllerProvider`** (`AsyncNotifier<User?>`) is the single
  source of truth for the session: `null` = logged out, a `User` =
  logged in. `build()` calls `GetCurrentUser`, which checks secure
  storage for a token and, if present, validates it against `/auth/me`.
- **Router guard.** `app_router.dart` listens to `authControllerProvider`
  via a small `ChangeNotifier` bridge (`refreshListenable`) and
  redirects: unauthenticated users are pushed to `/login`; authenticated
  users are kept out of `/login` and `/register`.
- **Token persistence & attachment.** `TokenStorage` wraps
  `flutter_secure_storage`. `dio_client.dart` adds an interceptor that
  reads the stored access token and attaches `Authorization: Bearer …` to
  every request except the `/auth/*` endpoints themselves.
- **Submitting vs. resolving.** `login()`/`register()` intentionally do
  *not* set the controller to `AsyncValue.loading()` mid-request — that
  loading state also drives the app-wide splash screen in `main.dart`.
  Each form page tracks its own `_isSubmitting` flag for the button
  instead, so a failed/slow login doesn't blank out the form.
- **Validation lives in the domain layer.** `LoginUser`/`RegisterUser`
  reject obviously-invalid input (bad email format, short password)
  before ever calling the repository — the same rule applies whether the
  call comes from a widget test or a future CLI tool.

Before running, note that `flutter_secure_storage` needs no extra setup
on Android/iOS/macOS by default; check the package's docs if you target
web or Linux.

## Error handling

One path, from the thing that broke to the sentence a user reads:

```
data source throws  →  guard()  →  Either<Failure, T>  →  AsyncValue
   (DioException,       maps via     (no exceptions        →  errorMessageFor()
    SocketException,     mapError()    above here)             in the widget
    plugin errors)
```

- **`core/error/failure.dart`** — the sealed `Failure` hierarchy. Two
  invariants: `message` is always safe to show a user, and `cause` (the
  raw exception) is for logs only. `isRetryable` lets UI offer "Try
  again" without switching on types.
- **`core/error/error_mapper.dart`** — the single `mapError()` that turns
  any thrown object into a `Failure`. Add a new transport error here, not
  in a repository. `errorMessageFor(error)` is what widgets call —
  **never `error.toString()`**, which leaks type names and payloads.
- **`core/error/result_guard.dart`** — `guard()` wraps a repository body,
  so methods are one expression each instead of a `try/catch` ladder.
  Pass `unauthorizedMessage:` to reword 401s per context, or `onError:`
  for bespoke mapping.
- **`core/error/error_reporter.dart`** — where unexpected errors go.
  `ErrorReporter.installGlobalHandlers()` in `main()` catches framework
  and platform errors too. To add Crashlytics/Sentry, assign
  `ErrorReporter.instance` once in `main()`; nothing else changes. Only
  `UnknownFailure`s are reported — an offline device or a wrong password
  is not a bug.

## Architectural rules this scaffold enforces

1. **Domain layer is pure.** `domain/` never imports `flutter_riverpod`,
   `dio`, or `json_annotation`. It only knows `freezed_annotation` (for
   immutability) and `fpdart` (for `Either`).
2. **Errors are values, not exceptions**, once you're above the data
   source. `AuthRemoteDataSource` throws `DioException`; the repository's
   `guard()` is the single seam that catches it and converts it into a
   `Failure`, returned as `Either<Failure, T>`. See "Error handling".
3. **Controllers orchestrate, use cases decide.** `AuthController` never
   validates input itself — it calls `LoginUser`/`RegisterUser`, which
   own the validation rules and are testable without Flutter or
   Riverpod.
4. **Dependency injection flows one direction**, via plain providers.
5. **UI never sees loading/error/data as ad-hoc booleans.** Async state
   goes through `AsyncValue`, so branches (loading/data/error) can't be
   silently forgotten.

## Extending this scaffold

- **New feature** → copy `features/auth/` as a template and rename;
  add its routes to `core/routing/app_router.dart`.
- **New use case** → add a class under a feature's `domain/usecases/`
  that takes the repository interface in its constructor; keep it to one
  public method (`call()`), one responsibility.
- **New Failure type** → add a subclass in `core/error/failure.dart`, not
  a stringly-typed error code.
- **Testing:** because the domain layer depends only on interfaces
  (`AuthRepository`), unit tests for use cases and the controller can
  supply a fake/mock repository with no Dio or platform channels
  involved. Override `authRepositoryProvider` in a test `ProviderScope`
  to inject the fake.
- **Where a widget lives** → `core/presentation/widgets/` is for UI used by
  more than one feature. Anything only one screen renders belongs in that
  feature's own `presentation/widgets/` (see `features/home/`).
