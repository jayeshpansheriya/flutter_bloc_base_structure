/// Example: How to use Secure Token Storage with DioClient
///
/// This file demonstrates how to use the secure storage-based
/// authentication system in your app.
library;

/*
import 'package:contribution/core/network/dio_client.dart';
import 'package:contribution/core/storage/secure_storage_service.dart';
import 'package:contribution/di/service_locator.dart';

// ============================================================================
// Example 1: Login and Save Tokens
// ============================================================================

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
      
      // Extract tokens from response
      final accessToken = response['access_token'] as String;
      final refreshToken = response['refresh_token'] as String;
      
      // Save tokens securely
      await _dioClient.setTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      
      print('Login successful! Tokens saved securely.');
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}

// ============================================================================
// Example 2: Logout and Clear Tokens
// ============================================================================

class AuthRepository {
  final DioClient _dioClient;
  
  AuthRepository(this._dioClient);
  
  Future<void> logout() async {
    // Clear tokens from secure storage
    await _dioClient.clearTokens();
    print('Logged out! Tokens cleared.');
  }
}

// ============================================================================
// Example 3: Check Authentication Status
// ============================================================================

class AuthRepository {
  final DioClient _dioClient;
  
  AuthRepository(this._dioClient);
  
  Future<bool> isUserLoggedIn() async {
    return await _dioClient.isAuthenticated();
  }
}

// ============================================================================
// Example 4: Automatic Token Refresh (Configured in service_locator.dart)
// ============================================================================

// In lib/di/service_locator.dart:

Future<void> initServiceLocator() async {
  // ... other registrations
  
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      secureStorage: sl<SecureStorageService>(),
      
      // Option 1: Use endpoint-based refresh
      refreshTokenEndpoint: '/auth/refresh',
      
      // Option 2: Use custom refresh logic
      onRefreshToken: (refreshToken) async {
        final dio = Dio(BaseOptions(
          baseUrl: 'https://your-api.com/v1',
        ));
        
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
}

// ============================================================================
// Example 5: Using Tokens in API Calls (Automatic)
// ============================================================================

class UserRepository {
  final UserApiService _apiService;
  
  UserRepository(this._apiService);
  
  Future<Map<String, dynamic>> getProfile() async {
    try {
      // Token is automatically added by AuthInterceptor
      // No need to manually add Authorization header
      final profile = await _apiService.getProfile();
      return profile;
    } on DioException catch (e) {
      // If token is expired (401), AuthInterceptor will:
      // 1. Automatically refresh the token
      // 2. Retry the request with new token
      // 3. If refresh fails, throw error
      throw ApiError.fromDioException(e);
    }
  }
}

// ============================================================================
// Example 6: Manual Token Management (Advanced)
// ============================================================================

class TokenManager {
  final SecureStorageService _storage;
  
  TokenManager(this._storage);
  
  // Get current access token
  Future<String?> getCurrentAccessToken() async {
    return await _storage.getAccessToken();
  }
  
  // Get current refresh token
  Future<String?> getCurrentRefreshToken() async {
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

// ============================================================================
// Example 7: BLoC Integration
// ============================================================================

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

// ============================================================================
// Example 8: App Initialization
// ============================================================================

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

// ============================================================================
// Key Benefits
// ============================================================================

// ✅ Tokens are stored securely in device keychain/keystore
// ✅ Automatic token refresh on 401 errors
// ✅ Automatic retry of failed requests after token refresh
// ✅ No need to manually add Authorization headers
// ✅ Tokens persist across app restarts
// ✅ Easy logout with clearTokens()
// ✅ Check authentication status with isAuthenticated()

*/
