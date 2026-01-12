import 'package:get_it/get_it.dart';
import 'package:contribution/core/network/dio_client.dart';
import 'package:contribution/core/storage/secure_storage_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // External

  // Core - Storage
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  // Core - Network
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      secureStorage: sl<SecureStorageService>(),
      // Optional: Configure token refresh endpoint
      // refreshTokenEndpoint: '/auth/refresh',
      // Optional: Custom token refresh logic
      // onRefreshToken: (refreshToken) async {
      //   final response = await dio.post('/auth/refresh', data: {
      //     'refresh_token': refreshToken,
      //   });
      //   return {
      //     'access_token': response.data['access_token'],
      //     'refresh_token': response.data['refresh_token'],
      //   };
      // },
    ),
  );

  // Features - Auth

  // Features - Home
}
