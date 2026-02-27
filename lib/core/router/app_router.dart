import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/viewmodel/auth_cubit/auth_cubit.dart';
import '../../features/auth/viewmodel/auth_cubit/auth_state.dart';
import '../../features/auth/view/screens/login_screen.dart';
import '../../features/auth/view/screens/register_screen.dart';
import '../../features/project/model/project_model.dart';
import '../../features/project/view/screens/projects_screen.dart';
import '../../features/project/view/screens/project_detail_screen.dart';
import '../../features/landmark/view/screens/landmark_detail_screen.dart';
import '../../features/signature/view/screens/signature_screen.dart';
import '../../features/local_gallery/view/screens/local_gallery_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/projects',
      // Rebuild router whenever auth state changes
      refreshListenable: _GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final authState = authCubit.state;

        // While loading let the current page stay
        if (authState is AuthLoading || authState is AuthInitial) return null;

        final isLoggedIn = authState is Authenticated;
        final loc = state.matchedLocation;
        final isAuthPage = loc == '/login' || loc == '/register';

        if (!isLoggedIn && !isAuthPage) return '/login';
        if (isLoggedIn && isAuthPage) return '/projects';
        return null;
      },
      routes: [
        // ── Auth ───────────────────────────────────────────────────────────
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(
          path: '/local-gallery',
          builder: (_, __) => const LocalGalleryScreen(),
        ),

        // ── Projects ────────────────────────────────────────────────────────
        GoRoute(
          path: '/projects',
          builder: (_, __) => const ProjectsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                // Full project object passed via extra to avoid a second API call
                final project = state.extra as ProjectModel;
                return ProjectDetailScreen(project: project);
              },
              routes: [
                GoRoute(
                  path: 'landmarks/:landmarkId',
                  builder: (context, state) {
                    final projectId = int.parse(state.pathParameters['id']!);
                    final landmarkId = int.parse(
                      state.pathParameters['landmarkId']!,
                    );
                    return LandmarkDetailScreen(
                      projectId: projectId,
                      landmarkId: landmarkId,
                    );
                  },
                ),
                GoRoute(
                  path: 'signature',
                  builder: (context, state) {
                    final projectId = int.parse(state.pathParameters['id']!);
                    // Optional landmarkId passed via extra (int?)
                    final landmarkId = state.extra as int?;
                    return SignatureScreen(
                      projectId: projectId,
                      landmarkId: landmarkId,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// Standard helper that converts a Stream into a ChangeNotifier for GoRouter.
class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
