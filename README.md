# vascomm_test

A Flutter app built feature-first with Clean Architecture and Riverpod. It
covers login, register, a home screen, and an editable profile.

Riverpod providers here are written by hand. No `riverpod_generator`, no
`@riverpod` annotations, so there are no `part` files to keep in sync for
state management.

## Running it

```bash
cp env/.env.example env/.env   # fill in your API key
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The backend is [reqres.in](https://reqres.in), which hands out a free API
key. Put it in `env/.env`; that file is gitignored, and
`env/.env.example` is the committed template.

Config is read at startup by `core/config/env.dart` through
`flutter_dotenv`, and `env/.env` is declared as an asset in
`pubspec.yaml`. If you add a key, add it to the example file too and
expose it as a getter on `Env` instead of calling `dotenv` from random
places. That way a missing key blows up in one predictable spot.

`build_runner` is only for the `@freezed` entities and DTOs and their
JSON serialization. Re-run it after editing any of those classes, or
leave `dart run build_runner watch --delete-conflicting-outputs` going
while you work.

## Layout

```
env/
├── .env                # gitignored
└── .env.example        # committed template
lib/
├── core/
│   ├── config/env.dart              Typed getters over env/.env
│   ├── error/                       Failure types, mapError/guard, ErrorReporter
│   ├── network/dio_client.dart      Shared Dio instance + auth token interceptor
│   ├── storage/
│   │   ├── token_storage.dart       Access/refresh tokens in secure storage
│   │   └── user_cache_storage.dart  Cached profile (see note below)
│   ├── routing/app_router.dart      go_router config + auth redirect guard
│   ├── theme/                       Colors and ThemeData
│   └── presentation/widgets/        UI shared across features
├── features/
│   ├── auth/
│   │   ├── domain/      Pure Dart. No Flutter, no Riverpod, no Dio.
│   │   │   ├── entities/            User, LoginParams, RegisterParams, ...
│   │   │   ├── repositories/        AuthRepository (abstract)
│   │   │   └── usecases/            login, register, logout, get_current_user,
│   │   │                            update_profile
│   │   ├── data/        Models, remote data source, repository impl
│   │   └── presentation/            AuthController, login/register pages
│   ├── home/presentation/           Landing screen + its own widgets
│   └── profile/presentation/        "Profile Saya", edits the session user
└── main.dart
test/                                Unit + widget tests
```

Widgets that more than one feature renders live in
`core/presentation/widgets/`. Anything a single screen owns stays in that
feature's `presentation/widgets/` folder. `features/home/` is the example
to follow.

## Providers without codegen

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

Wiring happens by `ref.watch()`-ing the layer below.
`authRepositoryProvider` watches `authRemoteDataSourceProvider` and
`tokenStorageProvider`; `authRemoteDataSourceProvider` watches
`dioProvider`. To swap a layer in tests, override its provider in a
`ProviderScope`. Nothing gets threaded through constructors and nothing
needs regenerating.

## Auth notes

`authControllerProvider` is an `AsyncNotifier<User?>` and it's the only
source of truth for the session. `null` means logged out, a `User` means
logged in. Its `build()` runs `GetCurrentUser`, which looks for a token
in secure storage and validates it against `/auth/me` if it finds one.

`app_router.dart` listens to that provider through a small
`ChangeNotifier` bridge passed as `refreshListenable`. Unauthenticated
users get redirected to `/login`, and logged-in users can't get back to
`/login` or `/register`.

`TokenStorage` wraps `flutter_secure_storage`, and the Dio interceptor
reads the access token from it and attaches `Authorization: Bearer …` to
everything except the `/auth/*` endpoints themselves.

There's also a `UserCacheStorage`, which exists because of the backend.
reqres.in returns only a token from `/api/login` and `/api/register`, no
user object, so the profile fields the forms collect (name, phone, KTP)
have nowhere to live but on the device.

One thing that looks odd until you know why: `login()` and `register()`
deliberately don't flip the controller to `AsyncValue.loading()` while a
request is in flight. That same loading state drives the app-wide splash
in `main.dart`, so doing it would blank the form out mid-login. Each form
page keeps its own `_isSubmitting` flag for the button instead.

Input validation sits in the domain layer. `LoginUser`, `RegisterUser`
and `UpdateProfile` reject bad email formats, short passwords and empty
required fields before the repository is ever called, so the same rules
hold whether the call comes from a widget or a test.

`flutter_secure_storage` needs no extra setup on Android, iOS or macOS.
Check its docs if you're targeting web or Linux.

## Error handling

Errors travel one path, from the throw to the message on screen:

```
data source throws  →  guard()  →  Either<Failure, T>  →  AsyncValue
   (DioException,       maps via     (nothing throws       →  errorMessageFor()
    SocketException,     mapError()    above this line)        in the widget
    plugin errors)
```

`core/error/failure.dart` holds the sealed `Failure` hierarchy. Two rules
about it: `message` is always safe to put in front of a user, and `cause`
(the original exception) is for logs only. `isRetryable` lets the UI
offer a retry button without switching on concrete types.

`core/error/error_mapper.dart` has the one `mapError()` that turns a
thrown object into a `Failure`. New transport errors go here, not into a
repository. Widgets call `errorMessageFor(error)`. They should never call
`error.toString()`, which leaks type names and payloads into the UI.

`core/error/result_guard.dart` provides `guard()`, which wraps a
repository body so each method stays a single expression instead of a
stack of try/catch. It takes `unauthorizedMessage:` if a 401 needs
different wording in that context, or `onError:` for one-off mapping.

`core/error/error_reporter.dart` is where unexpected errors end up.
`ErrorReporter.installGlobalHandlers()` in `main()` picks up framework
and platform errors too. Wiring in Crashlytics or Sentry means assigning
`ErrorReporter.instance` once in `main()` and changing nothing else. Only
`UnknownFailure` gets reported, since a dropped connection or a wrong
password isn't a bug.

## Rules the code sticks to

The domain layer stays pure. Nothing under `domain/` imports
`flutter_riverpod`, `dio` or `json_annotation`. It knows about
`freezed_annotation` for immutability and `fpdart` for `Either`, and
that's it.

Above the data source, errors are values rather than exceptions.
`AuthRemoteDataSource` throws `DioException`, and the repository's
`guard()` is the single seam where that gets caught and turned into a
`Failure` inside an `Either`.

Controllers orchestrate and use cases decide. `AuthController` doesn't
validate anything itself, it calls the use case that owns the rule.

Async state goes through `AsyncValue` instead of ad-hoc `isLoading` /
`errorMessage` booleans, so a forgotten branch is a compile-time problem
rather than a blank screen.

## Adding to it

For a new feature, copy `features/auth/` and rename, then register its
routes in `core/routing/app_router.dart`.

For a new use case, add a class under the feature's `domain/usecases/`
that takes the repository interface in its constructor, and keep it to a
single public `call()`.

For a new error case, add a `Failure` subclass rather than a stringly
typed error code.

For tests, remember the domain layer only depends on the
`AuthRepository` interface, so use case and controller tests can hand it
a fake with no Dio and no platform channels involved. Override
`authRepositoryProvider` in the test's `ProviderScope`. Run them with:

```bash
flutter test
```
