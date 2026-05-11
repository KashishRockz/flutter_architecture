// lib/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_not_ai/features/auth/screen/ProfileScreen.dart';
import 'package:flutter_not_ai/features/posts/screen/home_screen.dart';
import 'package:flutter_not_ai/features/auth/screen/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'features/auth/enum/auth_enum.dart';
import 'main.dart';


class AppRoutes {
  static const login   = '/login';
  static const home    = '/home';
  static const profile = '/home/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    navigatorKey: navigatorKey,
    redirect: (context, routerState) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading       = authState.isApiLoading(AuthEnum.login);
      final onLogin         = routerState.uri.path == AppRoutes.login;

      if (isLoading)                     return null; // still logging in, wait
      if (!isAuthenticated && !onLogin)  return AppRoutes.login;
      if (isAuthenticated  &&  onLogin)  return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeView(),
        routes: [
          GoRoute(
            path: 'profile',               // full path becomes /home/profile
            builder: (_, __) => const ProfileView(),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});