# Dio + Retrofit Setup Summary

## 📦 What We've Created

A complete, production-ready networking layer for your Flutter project using Dio + Retrofit with beautiful logging and error handling.

## 🗂️ File Structure

```
lib/core/
├── constants/
│   └── api_constants.dart          # API configuration (base URL, timeouts)
├── network/
│   ├── dio_client.dart             # Configured Dio instance provider
│   ├── api_error.dart              # Custom error handling class
│   └── interceptors/
│       ├── auth_interceptor.dart   # JWT token management
│       └── logging_interceptor.dart # Beautiful colorful logging (debug only)
```

## 🎯 Key Features

### 1. **DioClient** (`lib/core/network/dio_client.dart`)

- ✅ Singleton pattern via GetIt
- ✅ Pre-configured with base URL and timeouts
- ✅ Authentication interceptor for automatic token injection
- ✅ Beautiful logging (only in debug mode with `kDebugMode`)
- ✅ Provides Dio instance for Retrofit services

**Usage:**

```dart
final dioClient = sl<DioClient>();
dioClient.setAuthToken('your-jwt-token'); // After login
dioClient.clearAuthToken(); // On logout
```

### 2. **ApiError** (`lib/core/network/api_error.dart`)

- ✅ Converts DioException to user-friendly errors
- ✅ Provides error type categorization (network, timeout, response, etc.)
- ✅ Extracts status codes and error messages

**Usage:**

```dart
try {
  await apiService.getUser(1);
} on DioException catch (e) {
  throw ApiError.fromDioException(e);
}
```

### 3. **AuthInterceptor** (`lib/core/network/interceptors/auth_interceptor.dart`)

- ✅ Automatically adds `Authorization: Bearer {token}` header
- ✅ Handles 401 responses (token expired/invalid)
- ✅ Token management methods

### 4. **LoggingInterceptor** (`lib/core/network/interceptors/logging_interceptor.dart`)

- ✅ Beautiful colorful console output with ANSI colors
- ✅ Pretty-printed JSON formatting
- ✅ Request/Response/Error logging with emojis (🚀, ✅, ❌, 💥)
- ✅ Configurable logging options
- ✅ Support for FormData, Files, and JSON bodies
- ✅ **Only enabled in debug mode** (via `kDebugMode`)

**Features:**

- 🟡 Yellow for requests
- 🟢 Green for successful responses
- 🔴 Red for errors
- Formatted JSON with 2-space indentation
- Headers, timeouts, and body logging

### 5. **ApiConstants** (`lib/core/constants/api_constants.dart`)

- ✅ Centralized API configuration
- ✅ Base URL, API version, timeouts
- ✅ Default headers

## 📝 How to Use Retrofit

### Step 1: Create a Retrofit Service

Create a file in `lib/features/[feature_name]/data/api/` or `lib/core/network/api/`:

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'user_api_service.g.dart';

@RestApi()
abstract class UserApiService {
  factory UserApiService(Dio dio) = _UserApiService;

  @GET('/users/{id}')
  Future<Map<String, dynamic>> getUser(@Path('id') int id);

  @POST('/users')
  Future<Map<String, dynamic>> createUser(@Body() Map<String, dynamic> data);

  @PUT('/users/{id}')
  Future<Map<String, dynamic>> updateUser(
    @Path('id') int id,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/users/{id}')
  Future<void> deleteUser(@Path('id') int id);
}
```

### Step 2: Generate Code

Run the build_runner command:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate `user_api_service.g.dart`.

### Step 3: Register in Service Locator

In `lib/di/service_locator.dart`:

```dart
import 'package:contribution/features/user/data/api/user_api_service.dart';

Future<void> initServiceLocator() async {
  // Core - Network
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // API Services
  sl.registerLazySingleton<UserApiService>(
    () => UserApiService(sl<DioClient>().dio),
  );
}
```

### Step 4: Use in Repository

```dart
class UserRepository {
  final UserApiService _apiService;

  UserRepository(this._apiService);

  Future<Map<String, dynamic>> getUser(int id) async {
    try {
      return await _apiService.getUser(id);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    try {
      return await _apiService.createUser(data);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
```

### Step 5: Handle Errors in BLoC/Cubit

```dart
class UserCubit extends Cubit<UserState> {
  final UserRepository _repository;

  UserCubit(this._repository) : super(UserInitial());

  Future<void> loadUser(int id) async {
    emit(UserLoading());
    try {
      final user = await _repository.getUser(id);
      emit(UserLoaded(user));
    } on ApiError catch (e) {
      emit(UserError(e.message));
    }
  }
}
```

## 🔧 Configuration

### Update API Base URL

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://your-api.com'; // Update this
static const String apiVersion = '/v1';
```

### Customize Logging

In `lib/core/network/dio_client.dart`, you can customize logging options:

```dart
LoggingInterceptor(
  logRequestHeaders: true,   // Show request headers
  logResponseHeaders: true,  // Show response headers
  logRequestTimeout: false,  // Show timeout info
)
```

## 📦 Dependencies Added

```yaml
dependencies:
  dio: ^5.9.0
  retrofit: ^4.9.2

dev_dependencies:
  build_runner: ^2.4.14
  retrofit_generator: ^9.2.4
  json_serializable: ^6.9.3
```

## 🎨 Example Log Output

When you make an API call in debug mode, you'll see beautiful logs like:

```
────────────────────────────────────────────────────────────────────────────────
🚀 [REQUEST] -> GET https://api.example.com/v1/users/1
Uri: https://api.example.com/v1/users/1
Method: GET
Headers:
	Content-Type: application/json
	Authorization: Bearer eyJhbGc...
[Json] Request Body:
null
────────────────────────────────────────────────────────────────────────────────

════════════════════════════════════════════════════════════════════════════════
✅ [SUCCESS RESPONSE] -> GET https://api.example.com/v1/users/1 (200)
Uri: https://api.example.com/v1/users/1
Status Code: 200
Response Body:
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com"
}
════════════════════════════════════════════════════════════════════════════════
```

## ✅ Next Steps

1. ✅ Update `ApiConstants.baseUrl` with your actual API URL
2. ✅ Create your first Retrofit service
3. ✅ Run `flutter pub run build_runner build --delete-conflicting-outputs`
4. ✅ Register the service in `service_locator.dart`
5. ✅ Use it in your repositories

## 📚 Additional Resources

- [Retrofit Documentation](https://pub.dev/packages/retrofit)
- [Dio Documentation](https://pub.dev/packages/dio)
- See `UPDATED_RULES.md` for complete project guidelines

---

**Note:** The logging interceptor is automatically disabled in release builds thanks to `kDebugMode`, so your production app won't have any logging overhead.
