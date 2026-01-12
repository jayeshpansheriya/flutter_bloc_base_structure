# Project Architecture Rules

## 1. Feature-First Structure

This project follows a **STRICT Feature-First architecture** where each feature is self-contained.

### Directory Layout

```
lib/
├── core/                       # Shared core functionality
│   ├── constants/              # App-wide constants
│   │   └── api_constants.dart
│   ├── network/                # Networking layer
│   │   ├── dio_client.dart
│   │   ├── api_error.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       └── logging_interceptor.dart
│   ├── storage/                # Secure storage
│   │   └── secure_storage_service.dart
│   ├── theme/                  # App theming
│   │   └── app_theme.dart
│   └── utils/                  # Utility functions
│       └── validators.dart
│
├── features/                   # Feature modules
│   ├── auth/                   # Authentication feature
│   │   ├── auth_login_page.dart        # Login page
│   │   ├── auth_register_page.dart     # Register page (optional)
│   │   │
│   │   ├── bloc/               # State management
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   │
│   │   ├── models/             # Data models
│   │   │   └── user_model.dart
│   │   │
│   │   └── repository/         # Business logic & data
│   │       └── auth_repository.dart
│   │
│   └── home/                   # Home feature
│       ├── home_page.dart      # Home page
│       │
│       ├── bloc/               # State management
│       ├── models/             # Data models
│       └── repository/         # Business logic & data
│
├── routes/                     # App routing
│   └── app_router.dart
│
├── di/                         # Dependency injection
│   └── service_locator.dart
│
├── app.dart                    # Root MaterialApp widget
└── main.dart                   # App entry point
```

## 2. Flat Feature Structure

This project uses a **flat, pragmatic structure** for maximum simplicity:

### Feature Organization

Each feature contains:

- **Pages** (at feature root): `[feature]_[page_name]_page.dart`
- **bloc/**: State management (BLoC/Cubit, Events, States)
- **models/**: Data models (JSON serializable)
- **repository/**: Business logic and data operations

### Why This Structure?

- ✅ **Simple**: No deep nesting, easy to navigate
- ✅ **Fast**: Quick to create new features
- ✅ **Practical**: Perfect for most apps
- ✅ **Scalable**: Can add subfolders (widgets/, api/) when needed

### File Naming Convention

- **Pages**: `[feature]_[page_name]_page.dart`
  - Example: `auth_login_page.dart`, `home_page.dart`, `profile_settings_page.dart`
- **BLoC/Cubit**: `[feature]_bloc.dart` or `[feature]_cubit.dart`
- **Models**: `[model_name]_model.dart`
- **Repository**: `[feature]_repository.dart`

### When to Add Subfolders

As features grow, you can add:

- **widgets/**: Feature-specific reusable widgets
- **api/**: Retrofit API services (if not in core)
- **utils/**: Feature-specific utilities

## 3. File Organization Rules

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE` or `camelCase` for const

### Import Organization

```dart
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports (alphabetically)
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 4. Project imports (alphabetically)
import 'package:contribution/core/network/dio_client.dart';
import 'package:contribution/features/auth/domain/entities/user.dart';

// 5. Relative imports (within same feature)
import '../bloc/auth_bloc.dart';
import 'widgets/login_form.dart';
```

## 4. Feature Module Structure

### Example: Auth Feature (Current Structure)

```
features/auth/
├── auth_login_page.dart            # Login page (at feature root)
├── auth_register_page.dart         # Register page (optional)
│
├── bloc/                           # State management
│   ├── auth_bloc.dart              # Or auth_cubit.dart
│   ├── auth_event.dart             # If using Bloc
│   └── auth_state.dart
│
├── models/                         # Data models
│   ├── user_model.dart
│   ├── login_request_model.dart
│   └── login_response_model.dart
│
└── repository/                     # Business logic & data
    └── auth_repository.dart
```

### Example: Home Feature

```
features/home/
├── home_page.dart                  # Home page (at feature root)
│
├── bloc/                           # State management
│   ├── home_cubit.dart
│   └── home_state.dart
│
├── models/                         # Data models
│   └── dashboard_model.dart
│
└── repository/                     # Business logic & data
    └── home_repository.dart
```

### With Additional Subfolders (As Needed)

As features grow, you can add more organization:

```
features/auth/
├── auth_login_page.dart
├── auth_register_page.dart
├── auth_forgot_password_page.dart
│
├── bloc/
│   ├── auth_bloc.dart
│   ├── auth_event.dart
│   └── auth_state.dart
│
├── widgets/                        # Feature-specific widgets
│   ├── login_form.dart
│   ├── password_field.dart
│   └── social_login_buttons.dart
│
├── models/
│   ├── user_model.dart
│   ├── login_request_model.dart
│   └── login_response_model.dart
│
├── api/                            # Feature-specific API (if not in core)
│   ├── auth_api_service.dart
│   └── auth_api_service.g.dart
│
└── repository/
    └── auth_repository.dart
```

## 5. Core Module Guidelines

### When to Add to Core

- ✅ Used by multiple features
- ✅ Provides infrastructure (network, storage, etc.)
- ✅ App-wide constants or utilities
- ✅ Shared theme/styling

### When NOT to Add to Core

- ❌ Feature-specific logic
- ❌ Feature-specific widgets
- ❌ Feature-specific models

## 6. Barrel Files (Optional)

If using barrel files for exports:

```dart
// features/auth/auth.dart
export 'data/repositories/auth_repository_impl.dart';
export 'domain/entities/user.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/usecases/login_usecase.dart';
export 'presentation/bloc/auth_bloc.dart';
export 'presentation/pages/login_page.dart';
```

## 7. Dependency Rules

### Flat Structure (Current)

```
Pages → BLoC/Cubit → Repository → Models
  ↓         ↓           ↓          ↓
Core ← Core ← Core ← Core
```

**Rules:**

- ✅ Pages can use BLoC/Cubit for state management
- ✅ BLoC/Cubit calls Repository for business logic
- ✅ Repository uses Models for data
- ✅ Everything can use Core (network, storage, constants, utils)
- ❌ Repository cannot depend on BLoC/Cubit
- ❌ Models cannot depend on BLoC/Cubit or Repository
- ❌ Core cannot depend on features
- ❌ Features cannot depend on other features directly

### Example Dependency Flow

```dart
// Page uses BLoC
class AuthLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: // UI
    );
  }
}

// BLoC calls Repository
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  Future<void> _onLoginRequested(event, emit) async {
    final user = await _repository.login(event.email, event.password);
  }
}

// Repository uses Models and Core
class AuthRepository {
  final DioClient _dioClient;

  Future<UserModel> login(String email, String password) async {
    final response = await _dioClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(response.data);
  }
}
```

## 8. Best Practices

### DO:

- ✅ Keep features independent and self-contained
- ✅ Use dependency injection for all dependencies
- ✅ Follow the single responsibility principle
- ✅ Create small, focused files
- ✅ Use meaningful names for files and classes

### DON'T:

- ❌ Create circular dependencies between features
- ❌ Put feature-specific code in `core`
- ❌ Mix presentation logic with business logic
- ❌ Create god classes or god files
- ❌ Use global state or singletons (except via DI)
