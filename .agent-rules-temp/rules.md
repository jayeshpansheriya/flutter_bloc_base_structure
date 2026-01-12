---
trigger: always_on
---

# Flutter BLoC Project Rules

**IMPORTANT**: This project has comprehensive guidelines in the `guidelines/` directory. Always refer to these documents when working on this project.

## 📚 Required Reading

Before making any changes, consult these guidelines:

### Core Guidelines (MUST READ)

1. **[guidelines/architecture.md](../guidelines/architecture.md)** - Project structure, feature-first architecture, clean architecture layers
2. **[guidelines/networking.md](../guidelines/networking.md)** - DioClient, Retrofit services, token management, error handling
3. **[guidelines/coding_standards.md](../guidelines/coding_standards.md)** - Naming conventions, imports, formatting, BLoC/Cubit usage
4. **[guidelines/antigravity_behavior.md](../guidelines/antigravity_behavior.md)** - How you should behave, what to check, what to remind

### Developer Guides (Reference)

5. **[guidelines/DIO_RETROFIT_SETUP.md](../guidelines/DIO_RETROFIT_SETUP.md)** - Complete Retrofit setup guide with examples
6. **[guidelines/SECURE_TOKEN_STORAGE_GUIDE.md](../guidelines/SECURE_TOKEN_STORAGE_GUIDE.md)** - Token management and authentication flows
7. **[guidelines/PERFORMANCE_OPTIMIZATION.md](../guidelines/PERFORMANCE_OPTIMIZATION.md)** - Token caching and performance tips

## 🎯 Quick Rules Summary

### Project Structure

```
lib/
├── core/           # Shared: network, storage, constants, theme, utils
├── features/       # Feature modules (auth, home, etc.)
│   └── [feature]/
│       ├── data/       # API, models, repositories
│       ├── domain/     # Entities, use cases
│       └── presentation/ # BLoC/Cubit, pages, widgets
├── routes/         # GoRouter configuration
├── di/             # GetIt service locator
├── app.dart        # Root MaterialApp
└── main.dart       # Entry point
```

### Technology Stack

- **State Management**: `flutter_bloc` (Cubit for simple, Bloc for complex)
- **DI**: `get_it` (Service Locator)
- **Routing**: `go_router`
- **Networking**: `dio` + `retrofit` (ALWAYS use Retrofit, not direct Dio)
- **Storage**: `flutter_secure_storage` (with in-memory caching)

### Critical Rules

#### 1. Networking

- ✅ **ALWAYS** use Retrofit for API calls (never direct Dio methods)
- ✅ **ALWAYS** run `flutter pub run build_runner build --delete-conflicting-outputs` after creating/modifying Retrofit services
- ✅ **ALWAYS** catch `DioException` in repositories and convert to `ApiError`
- ✅ **ALWAYS** register API services in `lib/di/service_locator.dart`

#### 2. Token Management

- ✅ Tokens are cached in memory (no storage read on every request)
- ✅ Use `dioClient.setTokens()` after login
- ✅ Use `dioClient.clearTokens()` on logout
- ✅ Token refresh is automatic (configured in service locator)

#### 3. File Organization

- ✅ Feature-specific code → `lib/features/[feature_name]/`
- ✅ Shared code → `lib/core/`
- ✅ Retrofit services → `lib/features/[feature]/data/api/` or `lib/core/network/api/`
- ✅ Storage service → `lib/core/storage/`

#### 4. Naming Conventions

- ✅ Files: `snake_case.dart`
- ✅ Classes: `PascalCase`
- ✅ Variables/Functions: `camelCase`

#### 5. Error Handling

```dart
// In Repository
try {
  final response = await _apiService.getUser(id);
  return User.fromJson(response);
} on DioException catch (e) {
  throw ApiError.fromDioException(e);
}

// In BLoC/Cubit
try {
  final user = await _repository.getUser(id);
  emit(UserLoaded(user));
} on ApiError catch (e) {
  emit(UserError(e.message));
}
```

#### 6. Service Registration

```dart
// lib/di/service_locator.dart

// Storage
sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

// Network
sl.registerLazySingleton<DioClient>(() => DioClient(secureStorage: sl()));

// API Services
sl.registerLazySingleton<UserApiService>(() => UserApiService(sl<DioClient>().dio));

// Repositories
sl.registerLazySingleton<UserRepository>(() => UserRepository(sl()));

// BLoCs/Cubits (Factory)
sl.registerFactory<UserCubit>(() => UserCubit(sl()));
```

## 🔍 Before You Code

### Checklist

- [ ] Read relevant guideline document
- [ ] Check if file/class already exists
- [ ] Verify dependencies in `pubspec.yaml`
- [ ] Understand the feature-first structure
- [ ] Know where to place the file

### After You Code

- [ ] Run code generation if needed
- [ ] Register in service locator if needed
- [ ] Run `flutter analyze`
- [ ] Verify imports are organized
- [ ] Check error handling is in place

## 🚀 Common Commands

```bash
# Install dependencies
flutter pub get

# Code generation (after Retrofit changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test
```

## 📖 Documentation Hierarchy

```
Project Root
│
├── guidelines/                 ← ALL documentation here
│   ├── architecture.md         (How to structure code)
│   ├── networking.md           (How to make API calls)
│   ├── coding_standards.md     (How to write code)
│   ├── antigravity_behavior.md (How Antigravity works)
│   ├── DIO_RETROFIT_SETUP.md   (Retrofit setup guide)
│   ├── SECURE_TOKEN_STORAGE_GUIDE.md (Token management)
│   └── PERFORMANCE_OPTIMIZATION.md (Performance tips)
│
├── .agent/rules/
│   └── rules.md                ← YOU ARE HERE (references guidelines/)
│
└── README.md                   (Project overview)
```

## ⚠️ IMPORTANT REMINDERS

### When Creating Retrofit Services:

1. Create service interface with `@RestApi()` annotation
2. Add `part '[filename].g.dart';` directive
3. **RUN CODE GENERATION** ← Don't forget!
4. Register in `service_locator.dart`

### When Handling Errors:

1. Catch `DioException` in repositories
2. Convert to `ApiError` using `ApiError.fromDioException(e)`
3. Catch `ApiError` in BLoC/Cubit
4. Emit user-friendly error messages

### When Managing Tokens:

1. After login: `await dioClient.setTokens(accessToken, refreshToken)`
2. On logout: `await dioClient.clearTokens()`
3. Don't read from storage on every request (use cache!)
4. Token refresh is automatic (no manual handling needed)

---

**Remember**: When in doubt, check the relevant guideline document in `guidelines/` directory!
