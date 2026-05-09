import 'package:dio/dio.dart';
import 'package:flutter_not_ai/core/auth_interceptor.dart';
import 'package:flutter_not_ai/core/token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final dioProvider = Provider<Dio>((ref){
  final tokenStorage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),);

  dio.interceptors.add(AuthInterceptor(dio, tokenStorage));
  dio.interceptors.add(LogInterceptor(responseBody: true));

  ref.onDispose(() => dio.close());
  return dio;
});