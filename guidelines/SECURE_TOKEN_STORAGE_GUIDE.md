# 🔐 Secure Token Storage & Auto-Refresh Guide

## Overview

Your Flutter app now has a complete secure token storage system with automatic token refresh capabilities. Tokens are stored in the device's secure keychain (iOS) or keystore (Android).

## 🎯 Key Features

✅ **Secure Storage**: Tokens stored in device keychain/keystore  
✅ **Automatic Token Refresh**: Handles 401 errors and refreshes tokens automatically  
✅ **Request Retry**: Automatically retries failed requests after token refresh  
✅ **Persistent Authentication**: Tokens persist across app restarts  
✅ **Easy Token Management**: Simple API for login/logout  
✅ **No Manual Headers**: Authorization headers added automatically

## 📦 What Was Added

### 1. **SecureStorageService** (`lib/core/network/secure_storage_service.dart`)

Manages secure storage of access and refresh tokens.

**Methods:**

```dart
// Save tokens
await secureStorage.saveTokens(
  accessToken: 'access_token',
  refreshToken: 'refresh_token',
);

// Get tokens
final accessToken = await secureStorage.getAccessToken();
final refreshToken = await secureStorage.getRefreshToken();

// Check if tokens exist
final hasToken = await secureStorage.hasAccessToken();

// Delete tokens
await secureStorage.deleteAllTokens();
```

### 2. **Updated AuthInterceptor** (`lib/core/network/interceptors/auth_interceptor.dart`)

Now includes:

- Automatic token retrieval from secure storage
- 401 error handling with token refresh
- Request retry after successful refresh
- Configurable refresh endpoint or custom refresh logic

### 3. **Updated DioClient** (`lib/core/network/dio_client.dart`)

Enhanced with:

- Secure storage integration
- Token management methods
- Authentication status checking
- Separate Dio instance for token refresh (prevents interceptor loops)

## 🚀 Usage Guide

### Step 1: Configure Token Refresh (Optional)

In `lib/di/service_locator.dart`, you can configure how tokens are refreshed:

#### Option A: Using Endpoint-Based Refresh

```dart
sl.registerLazySingleton<DioClient>(
  () => DioClient(
    secureStorage: sl<SecureStorageService>(),
    refreshTokenEndpoint: '/auth/refresh', // Your refresh endpoint
  ),
);
```

#### Option B: Using Custom Refresh Logic

```dart
sl.registerLazySingleton<DioClient>(
  () => DioClient(
    secureStorage: sl<SecureStorageService>(),
    onRefreshToken: (refreshToken) async {
      // Custom refresh logic
      final dio = Dio(BaseOptions(baseUrl: 'https://your-api.com/v1'));
      final response = await dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      return {
        'access_token': response.data['access_token'],
        'refresh_token': response.data['refresh_token'],
      };
    },
  ),
);
```

### Step 2: Login Flow

```dart
class AuthRepository {
  final AuthApiService _apiService;
  final DioClient _dioClient;

  AuthRepository(this._apiService, this._dioClient);

  Future<void> login(String email, String password) async {
    try {
      // Call login API
      final response = await _apiService.login({
        'email': email,
        'password': password,
      });

      // Save tokens securely
      await _dioClient.setTokens(
        accessToken: response['access_token'],
        refreshToken: response['refresh_token'],
      );

      print('✅ Login successful! Tokens saved securely.');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
```

### Step 3: Logout Flow

```dart
class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  Future<void> logout() async {
    // Clear tokens from secure storage
    await _dioClient.clearTokens();
    print('✅ Logged out! Tokens cleared.');
  }
}
```

### Step 4: Check Authentication Status

```dart
class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  Future<bool> isUserLoggedIn() async {
    return await _dioClient.isAuthenticated();
  }
}
```

### Step 5: Making API Calls (Automatic Token Injection)

```dart
class UserRepository {
  final UserApiService _apiService;

  UserRepository(this._apiService);

  Future<Map<String, dynamic>> getProfile() async {
    try {
      // ✅ Token is automatically added by AuthInterceptor
      // ✅ If token expires (401), it will automatically refresh
      // ✅ Request will be retried with new token
      final profile = await _apiService.getProfile();
      return profile;
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
```

## 🔄 How Automatic Token Refresh Works

```
1. API Request → 401 Unauthorized
2. AuthInterceptor catches 401
3. Retrieves refresh token from secure storage
4. Calls refresh endpoint with refresh token
5. Saves new access & refresh tokens
6. Retries original request with new access token
7. Returns successful response
```

If token refresh fails:

- Tokens are cleared from storage
- 401 error is propagated to the app
- User should be redirected to login

## 🎨 BLoC Integration Example

```dart
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final DioClient _dioClient;

  AuthCubit(this._repository, this._dioClient) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      await _repository.login(email, password);
      emit(AuthAuthenticated());
    } on ApiError catch (e) {
      emit(AuthError(e.message));
    }
  }

  Future<void> logout() async {
    await _dioClient.clearTokens();
    emit(AuthUnauthenticated());
  }

  Future<void> checkAuthStatus() async {
    final isAuthenticated = await _dioClient.isAuthenticated();
    if (isAuthenticated) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
```

## 🏁 App Initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator
  await initServiceLocator();

  // Check if user is already logged in
  final dioClient = sl<DioClient>();
  final isAuthenticated = await dioClient.isAuthenticated();

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isAuthenticated ? HomePage() : LoginPage(),
    );
  }
}
```

## 🔧 Advanced: Manual Token Management

If you need direct access to the storage service:

```dart
class TokenManager {
  final SecureStorageService _storage;

  TokenManager(this._storage);

  // Get current tokens
  Future<String?> getAccessToken() async {
    return await _storage.getAccessToken();
  }

  Future<String?> getRefreshToken() async {
    return await _storage.getRefreshToken();
  }

  // Check if tokens exist
  Future<bool> hasTokens() async {
    final hasAccess = await _storage.hasAccessToken();
    final hasRefresh = await _storage.hasRefreshToken();
    return hasAccess && hasRefresh;
  }

  // Manually save tokens
  Future<void> saveTokens(String access, String refresh) async {
    await _storage.saveTokens(
      accessToken: access,
      refreshToken: refresh,
    );
  }

  // Delete all tokens
  Future<void> clearAllTokens() async {
    await _storage.deleteAllTokens();
  }
}
```

## 📱 Platform-Specific Notes

### iOS

- Tokens stored in iOS Keychain
- Accessible after first unlock
- Survives app uninstall if device backup is restored

### Android

- Tokens stored in Android Keystore
- Encrypted automatically
- Cleared on app uninstall

## 🔒 Security Best Practices

✅ **DO:**

- Use HTTPS for all API calls
- Implement proper token expiration
- Use short-lived access tokens (15-30 minutes)
- Use long-lived refresh tokens (7-30 days)
- Implement token rotation on refresh
- Clear tokens on logout

❌ **DON'T:**

- Store tokens in SharedPreferences
- Log tokens in production
- Share tokens between apps
- Use tokens without expiration

## 🐛 Troubleshooting

### Tokens not persisting

- Ensure `initServiceLocator()` is called before using DioClient
- Check that tokens are being saved after login

### 401 errors not refreshing

- Verify `refreshTokenEndpoint` or `onRefreshToken` is configured
- Check that refresh endpoint returns correct token format
- Ensure refresh token is valid and not expired

### Infinite refresh loop

- Check that refresh endpoint doesn't require authentication
- Verify that the separate `_dioForRefresh` Dio instance is being used

## 📚 API Reference

### DioClient Methods

```dart
// Set both tokens
await dioClient.setTokens(
  accessToken: 'access_token',
  refreshToken: 'refresh_token',
);

// Set individual tokens
await dioClient.setAccessToken('access_token');
await dioClient.setRefreshToken('refresh_token');

// Get tokens
final accessToken = await dioClient.getAccessToken();
final refreshToken = await dioClient.getRefreshToken();

// Clear tokens
await dioClient.clearTokens();

// Check authentication
final isAuth = await dioClient.isAuthenticated();
```

### SecureStorageService Methods

```dart
// Save
await storage.saveAccessToken('token');
await storage.saveRefreshToken('token');
await storage.saveTokens(accessToken: 'a', refreshToken: 'r');

// Get
final access = await storage.getAccessToken();
final refresh = await storage.getRefreshToken();

// Check
final hasAccess = await storage.hasAccessToken();
final hasRefresh = await storage.hasRefreshToken();

// Delete
await storage.deleteAccessToken();
await storage.deleteRefreshToken();
await storage.deleteAllTokens();
await storage.clearAll();
```

## 📦 Dependencies Added

```yaml
dependencies:
  flutter_secure_storage: ^9.2.2
```

## ✅ Benefits Summary

1. **Security**: Tokens stored in device keychain/keystore
2. **Convenience**: Automatic token refresh and retry
3. **Persistence**: Tokens survive app restarts
4. **Simplicity**: Easy-to-use API
5. **Reliability**: Handles edge cases and errors
6. **Performance**: Minimal overhead
7. **Best Practices**: Follows industry standards

---

For more examples, see `lib/core/network/secure_storage_usage_example.dart`
