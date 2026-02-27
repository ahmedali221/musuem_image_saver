import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../../features/auth/viewmodel/auth_repository.dart';
import '../../features/auth/viewmodel/auth_cubit/auth_cubit.dart';
import '../../features/project/viewmodel/project_repository.dart';
import '../../features/project/viewmodel/project_cubit/project_cubit.dart';
import '../../features/landmark/viewmodel/landmark_repository.dart';
import '../../features/landmark/viewmodel/landmark_cubit/landmark_cubit.dart';
import '../../features/landmark/viewmodel/landmark_detail_cubit/landmark_detail_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ── Secure Storage ────────────────────────────────────────────────────────
  sl.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  // ── Dio ───────────────────────────────────────────────────────────────────
  sl.registerSingleton<Dio>(DioClient.create(sl<FlutterSecureStorage>()));

  // ── Repositories ─────────────────────────────────────────────────────────
  sl.registerSingleton<AuthRepository>(
    AuthRepository(dio: sl<Dio>(), storage: sl<FlutterSecureStorage>()),
  );

  sl.registerSingleton<ProjectRepository>(ProjectRepository(sl<Dio>()));
  sl.registerSingleton<LandmarkRepository>(LandmarkRepository(sl<Dio>()));

  // ── Cubits ────────────────────────────────────────────────────────────────
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl<AuthRepository>()));

  sl.registerFactory<ProjectCubit>(() => ProjectCubit(sl<ProjectRepository>()));

  // LandmarkCubit: fresh per project detail screen
  sl.registerFactory<LandmarkCubit>(
    () => LandmarkCubit(sl<LandmarkRepository>()),
  );

  // LandmarkDetailCubit: always fresh so each detail screen starts clean
  sl.registerFactory<LandmarkDetailCubit>(
    () => LandmarkDetailCubit(sl<LandmarkRepository>()),
  );
}
