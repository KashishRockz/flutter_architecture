import 'package:dio/dio.dart';
import 'package:flutter_not_ai/core/token_storage.dart';

class AuthInterceptor extends Interceptor {

  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthInterceptor(this._dio, this._tokenStorage);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // super.onRequest(options, handler);

    final token = await _tokenStorage.getToken();
    if(token != null){
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
    }
  //   navy: add token refresh logic here
  }
