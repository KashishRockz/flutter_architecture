// lib/core/repository/app_repository.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/model/user_model.dart';
import '../dio_provider.dart';
import '../../features/posts/models/post.dart';

final appRepositoryProvider = Provider<AppRepository>((ref) {
  return AppRepository(ref.watch(dioProvider));
});

class AppRepository {
  final Dio _dio;
  AppRepository(this._dio);

  // ── AUTH ───────────────────────────────────────────────────────────────────

  Future<Either<String, Map<String, dynamic>>> login(
      String username,
      String password,
      ) =>
      _safeCall(() async {
        final res = await _dio.post(
          '/auth/login',                           // ← change to your endpoint
          data: {
            'username': username,
            'password': password,
            'expiresInMins': 30,                   // ← remove if your API doesn't need it
          },
        );
        return res.data as Map<String, dynamic>;
      });

  Future<Either<String, void>> logout() =>
      _safeCall(() async {
        await _dio.post('/auth/logout');           // ← change to your endpoint
      });

  Future<Either<String, UserModel>> getUserDetails() =>
      _safeCall(() async {
        final res = await _dio.get('/auth/me');    // ← change to your endpoint
        return UserModel.fromJson(res.data as Map<String, dynamic>);
      });

  // ── POSTS ──────────────────────────────────────────────────────────────────

  Future<Either<String, List<Post>>> getPosts() =>
      _safeCall(() async {
        final res = await _dio.get('/posts');
        return (res.data['posts'] as List)
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<Either<String, Post>> createPost(String title, String body) =>
      _safeCall(() async {
        final res = await _dio.post(
          '/posts/add',
          data: {'title': title, 'body': body},
        );
        return Post.fromJson(res.data as Map<String, dynamic>);
      });

  Future<Either<String, Post>> updatePost(int id, String title) =>
      _safeCall(() async {
        final res = await _dio.put(
          '/posts/$id',
          data: {'title': title},
        );
        return Post.fromJson(res.data as Map<String, dynamic>);
      });

  Future<Either<String, void>> deletePost(int id) =>
      _safeCall(() async {
        await _dio.delete('/posts/$id');
      });

  // ── single try/catch for the entire app ────────────────────────────────────

  Future<Either<String, T>> _safeCall<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on DioException catch (e) {
      return Left(_parseDioError(e));
    } catch (e) {
      return Left(e.toString());
    }
  }

  String _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return e.message ?? 'Something went wrong';
  }
}