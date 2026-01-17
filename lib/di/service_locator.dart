import 'package:get_it/get_it.dart';
import 'package:contribution/core/network/dio_client.dart';
import 'package:contribution/core/network/connectivity_service.dart';
import 'package:contribution/core/network/cubit/connectivity_cubit.dart';
import 'package:contribution/core/storage/secure_storage_service.dart';
import 'package:contribution/core/storage/shared_preferences_service.dart';
import 'package:contribution/core/localization/locale_cubit.dart';

final GetIt sl = GetIt.instance;

void initServiceLocator() {
  // External

  // Core - Storage
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  // Register SharedPreferencesService with async initialization
  sl.registerSingletonAsync<SharedPreferencesService>(() async {
    final service = SharedPreferencesService();
    await service.init();
    return service;
  });

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

  // Core - Connectivity
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  sl.registerLazySingleton<ConnectivityCubit>(
    () => ConnectivityCubit(sl<ConnectivityService>()),
  );

  // Core - Localization
  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(sl<SharedPreferencesService>()),
  );

  // Features - Auth

  // Features - Home
}
