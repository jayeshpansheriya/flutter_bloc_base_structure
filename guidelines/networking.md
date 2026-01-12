# Networking Rules

## 1. Technology Stack

- **HTTP Client**: `dio` (v5.9.0+)
- **API Client**: `retrofit` (v4.9.2+)
- **Secure Storage**: `flutter_secure_storage` (v9.2.2+)

## 2. DioClient Configuration

### Location

`lib/core/network/dio_client.dart`

### Features

- ✅ Configured with base URL and timeouts from `ApiConstants`
- ✅ `AuthInterceptor` with token caching for performance
- ✅ `LoggingInterceptor` (only in debug mode via `kDebugMode`)
- ✅ Separate Dio instance for token refresh (prevents interceptor loops)

### Usage

```dart
// Inject via GetIt
final dioClient = sl<DioClient>();

// Pass to Retrofit services
final userService = UserApiService(dioClient.dio);
```

## 3. Creating Retrofit Services

### Step 1: Create Service Interface

Location: `lib/features/[feature_name]/data/api/` or `lib/core/network/api/`

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

### Step 2: Run Code Generation

**ALWAYS** run this after creating or modifying Retrofit services:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 3: Register in Service Locator

```dart
// lib/di/service_locator.dart
sl.registerLazySingleton<UserApiService>(
  () => UserApiService(sl<DioClient>().dio),
);
```

## 4. Error Handling

### ApiError Class

Location: `lib/core/network/api_error.dart`

```dart
try {
  final user = await _apiService.getUser(1);
} on DioException catch (e) {
  throw ApiError.fromDioException(e);
}
```

### ApiError Properties

- `message`: User-friendly error message
- `statusCode`: HTTP status code (if available)
- `type`: `ApiErrorType` enum (network, timeout, response, cancel, unknown)
- `data`: Raw error response data

### Error Handling in Repository

```dart
class UserRepository {
  final UserApiService _apiService;

  Future<User> getUser(int id) async {
    try {
      final response = await _apiService.getUser(id);
      return User.fromJson(response);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
```

### Error Handling in BLoC/Cubit

```dart
class UserCubit extends Cubit<UserState> {
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

## 5. Authentication & Token Management

### Secure Storage with Caching

Location: `lib/core/storage/secure_storage_service.dart`

**Performance Optimization:**

- Tokens cached in memory (no storage read on every request)
- First request loads from storage, subsequent requests use cache
- 99% reduction in storage I/O operations

### Token Management

```dart
// After login
await dioClient.setTokens(
  accessToken: response['access_token'],
  refreshToken: response['refresh_token'],
);

// On logout
await dioClient.clearTokens();

// Check authentication
final isAuth = await dioClient.isAuthenticated();

// Get tokens (from cache, instant!)
final accessToken = dioClient.getAccessToken();
final refreshToken = dioClient.getRefreshToken();
```

### Automatic Token Refresh

Configure in `lib/di/service_locator.dart`:

```dart
sl.registerLazySingleton<DioClient>(
  () => DioClient(
    secureStorage: sl<SecureStorageService>(),
    refreshTokenEndpoint: '/auth/refresh',
    // OR custom refresh logic:
    // onRefreshToken: (refreshToken) async { ... },
  ),
);
```

**How it works:**

1. API request returns 401
2. `AuthInterceptor` catches 401
3. Refreshes token using refresh endpoint
4. Retries original request with new token
5. If refresh fails, clears tokens and propagates error

## 6. API Constants

Location: `lib/core/constants/api_constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/v1';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String contentType = 'application/json';
  static const String accept = 'application/json';

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
}
```

## 7. Retrofit Annotations Reference

### HTTP Methods

```dart
@GET('/path')           // GET request
@POST('/path')          // POST request
@PUT('/path')           // PUT request
@PATCH('/path')         // PATCH request
@DELETE('/path')        // DELETE request
@HEAD('/path')          // HEAD request
@OPTIONS('/path')       // OPTIONS request
```

### Parameters

```dart
@Path('id')             // Path parameter: /users/{id}
@Query('page')          // Query parameter: /users?page=1
@Queries()              // Multiple query parameters
@Body()                 // Request body
@Header('key')          // Single header
@Headers()              // Multiple headers
@Part()                 // Multipart form data
@Field()                // Form field
```

### Special Annotations

```dart
@MultiPart()            // For file uploads
@FormUrlEncoded()       // For form data
@CacheControl()         // Cache control
```

## 8. Best Practices

### DO:

- ✅ Use Retrofit for ALL API calls (not direct Dio methods)
- ✅ Run code generation after creating/modifying services
- ✅ Handle errors in repositories using `ApiError`
- ✅ Use `DioClient.setTokens()` after login
- ✅ Use `DioClient.clearTokens()` on logout
- ✅ Let `AuthInterceptor` handle token injection automatically
- ✅ Configure token refresh endpoint in service locator
- ✅ Use meaningful endpoint constants in `ApiConstants`

### DON'T:

- ❌ Use direct Dio methods (get, post, etc.) in repositories
- ❌ Manually add Authorization headers (handled by interceptor)
- ❌ Read tokens from storage on every request (use cache)
- ❌ Store tokens in SharedPreferences or plain storage
- ❌ Forget to run code generation after creating services
- ❌ Catch generic `Exception` (use `DioException` and `ApiError`)
- ❌ Log tokens in production

## 9. Common Patterns

### File Upload

```dart
@POST('/upload')
@MultiPart()
Future<UploadResponse> uploadFile(
  @Part(name: 'file') File file,
  @Part(name: 'description') String description,
);
```

### Query Parameters

```dart
@GET('/users')
Future<List<User>> getUsers(
  @Query('page') int page,
  @Query('limit') int limit,
  @Query('sort') String? sort,
);
```

### Custom Headers

```dart
@GET('/profile')
@Headers(<String, dynamic>{
  'Custom-Header': 'value',
})
Future<Profile> getProfile();
```

### Response Types

```dart
@GET('/users/{id}')
Future<HttpResponse<User>> getUser(@Path('id') int id);
// Returns both response data and HTTP metadata
```

## 10. Troubleshooting

### Code Generation Fails

- Ensure `part` directive is correct
- Check for syntax errors in annotations
- Run `flutter pub get` first
- Use `--delete-conflicting-outputs` flag

### 401 Errors Not Refreshing

- Verify `refreshTokenEndpoint` is configured
- Check refresh endpoint doesn't require authentication
- Ensure refresh token is valid

### Tokens Not Persisting

- Verify `setTokens()` is called after login
- Check `SecureStorageService` is registered in DI
- Ensure `initServiceLocator()` is called before use
