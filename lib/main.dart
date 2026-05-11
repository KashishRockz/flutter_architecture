// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/auth_event.dart';
import 'features/auth/viewmodel/auth_viewmodel.dart';
import 'router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {

  @override
  void initState() {
    super.initState();
    // Listen for session expired event fired by AuthInterceptor
    // When refresh token fails → interceptor fires this → we show dialog
    AuthEventBus.stream.listen((event) {
      print('AuthEvent received: $event');
      if (event == AuthEvent.sessionExpired && mounted) {
        _showSessionExpiredDialog();
      }
    });
  }

  void _showSessionExpiredDialog() {
    final router = ref.read(routerProvider);
    final context = navigatorKey.currentContext;
    // final context = router.routerDelegate.navigatorKey.currentContext;
    if (context == null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text(
          'Your session has expired. Please login again.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authViewModelProvider.notifier).forceLogout();
              // forceLogout sets isAuthenticated = false
              // GoRouter redirect automatically goes to /login
            },
            child: const Text('Login Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Flutter Not AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}