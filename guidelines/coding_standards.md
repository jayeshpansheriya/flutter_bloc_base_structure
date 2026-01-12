# Coding Standards

## 1. Naming Conventions

### Files

- **Format**: `snake_case.dart`
- **Examples**:
  - ✅ `user_repository.dart`
  - ✅ `auth_api_service.dart`
  - ✅ `login_page.dart`
  - ❌ `UserRepository.dart`
  - ❌ `authApiService.dart`

### Classes

- **Format**: `PascalCase`
- **Examples**:
  - ✅ `UserRepository`
  - ✅ `AuthApiService`
  - ✅ `LoginPage`
  - ❌ `userRepository`
  - ❌ `auth_api_service`

### Variables & Functions

- **Format**: `camelCase`
- **Examples**:
  - ✅ `userName`
  - ✅ `getUserById()`
  - ✅ `isAuthenticated`
  - ❌ `UserName`
  - ❌ `get_user_by_id()`

### Constants

- **Format**: `camelCase` for const, `SCREAMING_SNAKE_CASE` for static const
- **Examples**:
  - ✅ `const apiTimeout = Duration(seconds: 30);`
  - ✅ `static const String API_BASE_URL = '...';`
  - ❌ `const API_TIMEOUT = Duration(seconds: 30);`

## 2. Import Organization

Organize imports in this order:

```dart
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Package imports (alphabetically)
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// 4. Project imports (alphabetically)
import 'package:contribution/core/network/dio_client.dart';
import 'package:contribution/features/auth/domain/entities/user.dart';

// 5. Relative imports (within same feature/module)
import '../bloc/auth_bloc.dart';
import 'widgets/login_form.dart';
```

### Import Rules

- ✅ Use **package imports** for `core` or cross-feature imports
- ✅ Use **relative imports** for files within the same feature/module
- ❌ Don't mix package and relative imports for the same module

## 3. Code Formatting

### Use `const` Constructors

```dart
// ✅ Good
const SizedBox(height: 16);
const Text('Hello');
const EdgeInsets.all(8);

// ❌ Bad
SizedBox(height: 16);
Text('Hello');
EdgeInsets.all(8);
```

### Trailing Commas

Always use trailing commas for better formatting:

```dart
// ✅ Good
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Hello'),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {},
        child: Text('Click'),
      ),
    ],
  );
}

// ❌ Bad (no trailing commas)
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Hello'),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {},
        child: Text('Click')
      )
    ]
  );
}
```

## 4. Error Handling

### In Repositories (Data Layer)

```dart
class UserRepository {
  final UserApiService _apiService;

  Future<User> getUser(int id) async {
    try {
      final response = await _apiService.getUser(id);
      return User.fromJson(response);
    } on DioException catch (e) {
      // Convert to ApiError for consistent error handling
      throw ApiError.fromDioException(e);
    }
  }
}
```

### In BLoC/Cubit (Presentation Layer)

```dart
class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  Future<void> loadUser(int id) async {
    emit(UserLoading());
    try {
      final user = await _repository.getUser(id);
      emit(UserLoaded(user));
    } on ApiError catch (e) {
      // Handle specific error types
      switch (e.type) {
        case ApiErrorType.network:
          emit(UserError('No internet connection'));
          break;
        case ApiErrorType.timeout:
          emit(UserError('Request timeout'));
          break;
        default:
          emit(UserError(e.message));
      }
    }
  }
}
```

### Error Handling Rules

- ✅ Catch `DioException` in repositories
- ✅ Convert to `ApiError` using `ApiError.fromDioException(e)`
- ✅ Handle `ApiError` in BLoC/Cubit
- ✅ Provide user-friendly error messages
- ❌ Don't catch generic `Exception` unless necessary
- ❌ Don't expose raw error messages to users

## 5. Code Generation Workflow

### When to Run Code Generation

Run this command **AFTER**:

- Creating a new Retrofit service
- Modifying an existing Retrofit service
- Adding/changing JSON serialization annotations

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Generated Files

- Retrofit: `*_api_service.g.dart`
- JSON Serialization: `*.g.dart`

### Rules

- ✅ Always commit generated files to version control
- ✅ Run code generation before committing
- ✅ Use `--delete-conflicting-outputs` to avoid conflicts
- ❌ Don't manually edit generated files

## 6. Documentation

### Class Documentation

```dart
/// Repository for managing user data.
///
/// Provides methods to fetch, create, update, and delete users.
/// All methods throw [ApiError] on failure.
class UserRepository {
  // ...
}
```

### Method Documentation

````dart
/// Fetches a user by their ID.
///
/// Throws [ApiError] if the request fails or user is not found.
///
/// Example:
/// ```dart
/// final user = await repository.getUser(123);
/// ```
Future<User> getUser(int id) async {
  // ...
}
````

### Documentation Rules

- ✅ Document public classes and methods
- ✅ Explain what exceptions can be thrown
- ✅ Provide usage examples for complex APIs
- ❌ Don't over-document obvious code
- ❌ Don't duplicate information already in code

## 7. State Management (BLoC/Cubit)

### Use Cubit for Simple State

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

### Use Bloc for Event-Driven Logic

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _repository.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } on ApiError catch (e) {
      emit(AuthError(e.message));
    }
  }
}
```

## 8. Dependency Injection

### Register Dependencies in Service Locator

```dart
// lib/di/service_locator.dart
Future<void> initServiceLocator() async {
  // Core - Storage
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // Core - Network
  sl.registerLazySingleton<DioClient>(
    () => DioClient(secureStorage: sl()),
  );

  // API Services
  sl.registerLazySingleton<UserApiService>(
    () => UserApiService(sl<DioClient>().dio),
  );

  // Repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(sl()),
  );

  // BLoCs/Cubits (Factory - new instance each time)
  sl.registerFactory<UserCubit>(
    () => UserCubit(sl()),
  );
}
```

### DI Rules

- ✅ Use `registerLazySingleton` for services, repositories, clients
- ✅ Use `registerFactory` for BLoCs/Cubits
- ✅ Register dependencies in logical order (dependencies first)
- ❌ Don't use `registerSingleton` unless necessary
- ❌ Don't create circular dependencies

## 9. Widget Best Practices

### Extract Widgets

```dart
// ✅ Good - Extracted widget
class UserCard extends StatelessWidget {
  final User user;

  const UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
      ),
    );
  }
}

// ❌ Bad - Inline widget
Widget build(BuildContext context) {
  return ListView.builder(
    itemBuilder: (context, index) {
      return Card(
        child: ListTile(
          title: Text(users[index].name),
          subtitle: Text(users[index].email),
        ),
      );
    },
  );
}
```

### Use Keys for Lists

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(
      key: ValueKey(items[index].id), // ✅ Good
      item: items[index],
    );
  },
);
```

## 10. Code Quality Checklist

Before committing code, ensure:

- [ ] All imports are organized correctly
- [ ] No unused imports
- [ ] Trailing commas added
- [ ] `const` used where possible
- [ ] Error handling implemented
- [ ] Code generation run (if needed)
- [ ] `flutter analyze` passes with no errors
- [ ] Meaningful variable/function names
- [ ] Public APIs documented
- [ ] No hardcoded values (use constants)
