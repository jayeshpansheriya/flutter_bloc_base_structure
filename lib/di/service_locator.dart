import 'package:get_it/get_it.dart';
import 'package:contribution/core/network/dio_client.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // External

  // Core - Network
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Features - Auth

  // Features - Home
}
