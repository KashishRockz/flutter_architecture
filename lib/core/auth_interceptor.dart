import 'package:dio/dio.dart';
import 'package:flutter_not_ai/core/token_storage.dart';
import 'auth_event.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._tokenStorage, this._dio);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    final isRefreshEndpoint = err.requestOptions.path.contains('/auth/refresh');

    if (err.response?.statusCode == 401 && !isRefreshEndpoint && !_isRefreshing) {
      final newToken = await _refreshToken();

      if (newToken != null) {
        try {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {}
      }
    }

    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    if (_isRefreshing) return null;
    _isRefreshing = true;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null) {              // ← null = no token = force logout
        await _tokenStorage.clearTokens();
        AuthEventBus.emit(AuthEvent.sessionExpired);
        return null;
      }

      final response = await _dio.post(
        '/auth/refresh',                       // ← change to your endpoint
        data: {'refreshToken': refreshToken},
      );

      final newToken = response.data['accessToken'] as String;
      await _tokenStorage.saveTokens(accessToken: newToken);
      return newToken;
    } catch (e) {
      await _tokenStorage.clearTokens();
      AuthEventBus.emit(AuthEvent.sessionExpired);
      return null;
    } finally {
      _isRefreshing = false;
    }
  }
}