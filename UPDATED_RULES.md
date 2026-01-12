---
trigger: always_on
---

# Antigravity Project Rules & Guidelines

These rules must be followed for all code generation and modifications in this project.

## 1. Project Architecture (Feature-First)

This project adheres to a STRICT Feature-First architecture.
Code must be organized into the following directory structure:

### Directory Layout

- `lib/core/`
  - `network/`: Dio client, Retrofit services, API interceptors.
  - `constants/`: App-wide constants (colors, strings, API endpoints).
  - `utils/`: Shared utility functions, extensions, and validators.
  - `theme/`: Theme configuration (light/dark mode, text styles).
- `lib/features/`
  - Each feature must be self-contained in its own directory (e.g., `lib/features/auth/`, `lib/features/home/`).
  - Inside a feature, follow a standard layering (clean architecture preferred):
    - `data/`: Repositories, Data Sources, Models.
    - `domain/`: Entities, Use Cases, Repository Interfaces.
    - `presentation/`: BLoCs/Cubits, Pages, Widgets.
- `lib/routes/`: GoRouter configuration (`AppRouter`).
- `lib/di/`: Dependency injection setup (GetIt).
- `lib/app.dart`: Root `MaterialApp` widget.
- `lib/main.dart`: App entry point.

## 2. Technology Stack

- **State Management**: `flutter_bloc`
  - Use `Cubit` for simple state, `Bloc` for event-driven complex logic.
- **Dependency Injection**: `get_it` (Service Locator pattern).
- **Routing**: `go_router`
  - Use named routes.
  - Centralize route definitions in `lib/routes/`.
- **Networking**: `dio` + `retrofit`
  - **DioClient**: Provides configured Dio instance with interceptors (auth, logging).
  - **Retrofit Services**: Create API service interfaces using Retrofit annotations.
  - **Code Generation**: Run `flutter pub run build_runner build --delete-conflicting-outputs` after creating/modifying Retrofit services.
  - **Location**: Place Retrofit services in `lib/features/[feature_name]/data/api/` or `lib/core/network/api/` for shared services.

## 3. Networking Guidelines

### 3.1 DioClient Setup

- `DioClient` is a singleton that configures Dio with:
  - Base URL and timeouts from `ApiConstants`
  - `AuthInterceptor` for automatic token injection
  - `LoggingInterceptor` for debugging (should be disabled in production)
- Access via `sl<DioClient>().dio` when creating Retrofit services.

### 3.2 Creating Retrofit Services

1. Create an abstract class with `@RestApi()` annotation
2. Define methods with HTTP annotations (`@GET`, `@POST`, `@PUT`, `@DELETE`, etc.)
3. Use `@Path`, `@Query`, `@Body`, `@Header` for parameters
4. Add `part '[filename].g.dart';` directive
5. Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
6. Register service in `service_locator.dart`

Example:

```dart
@RestApi()
abstract class UserApiService {
  factory UserApiService(Dio dio) = _UserApiService;

  @GET('/users/{id}')
  Future<UserModel> getUser(@Path('id') int id);

  @POST('/users')
  Future<UserModel> createUser(@Body() Map<String, dynamic> data);
}
```

### 3.3 Error Handling

- Catch `DioException` in repositories
- Convert to `ApiError` using `ApiError.fromDioException(e)`
- `ApiError` provides:
  - `message`: User-friendly error message
  - `statusCode`: HTTP status code (if available)
  - `type`: `ApiErrorType` enum (network, timeout, response, cancel, unknown)
  - `data`: Raw error response data

### 3.4 Authentication

- Use `DioClient.setAuthToken(token)` after successful login
- Use `DioClient.clearAuthToken()` on logout
- `AuthInterceptor` automatically adds `Authorization: Bearer {token}` header
- Handles 401 responses (token expired/invalid)

## 4. Coding Standards

- **File Naming**: snake_case for files, PascalCase for classes.
- **Imports**: Use relative imports for files within the same feature/module. Use package imports for `core` or external packages.
- **Const**: Use `const` constructors for Widgets and immutable classes explicitly.
- **Error Handling**:
  - Catch `DioException` in the Data layer (repositories)
  - Convert to `ApiError` for consistent error handling
  - Return `Either<Failure, Type>` or similar wrapper if using functional error handling
  - Propagate errors to BLoC/Cubit for UI state management

## 5. Antigravity Behavior

- **Check Before Create**: Always check if a file or class exists before creating it.
- **Don't Assume**: If a dependency (like `build_runner`) seems missing for a code-gen task, explicitly check `pubspec.yaml` or ask the user.
- **Update Exports**: When adding new files to `core` or `features`, ensure they are exported via barrel files if that pattern is in use.
- **Code Generation**: After creating Retrofit services, always run `flutter pub run build_runner build --delete-conflicting-outputs` to generate the implementation files.
