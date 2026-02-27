import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/viewmodel/auth_cubit/auth_cubit.dart';
import 'features/auth/viewmodel/auth_form_cubit/auth_form_cubit.dart';
import 'features/project/viewmodel/project_cubit/project_cubit.dart';
import 'features/landmark/viewmodel/landmark_cubit/landmark_cubit.dart';

class MuseumApp extends StatefulWidget {
  const MuseumApp({super.key});

  @override
  State<MuseumApp> createState() => _MuseumAppState();
}

class _MuseumAppState extends State<MuseumApp> {
  // Keep a single AuthCubit instance so the router can listen to its stream
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>()..checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider(create: (_) => AuthFormCubit()),
        // Shared cubits — data loads only when the screen first calls load()
        BlocProvider(create: (_) => sl<ProjectCubit>()),
        BlocProvider(create: (_) => sl<LandmarkCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Museum Image Saver',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.createRouter(_authCubit),
      ),
    );
  }
}
