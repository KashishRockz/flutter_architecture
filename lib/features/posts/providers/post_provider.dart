import 'package:dio/dio.dart';
import 'package:flutter_not_ai/core/dio_provider.dart';
import 'package:flutter_not_ai/features/posts/repository/post_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';

// navy: whats the usage of this file provider, if it is related to di
// then why dont we ues it for dio and tokenstorage?



final postRepositoryProvider = Provider<PostRepository>((ref){
  final dio = ref.watch(dioProvider);
  return PostRepository(dio);
});

final postsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.fetchPosts();
});





// navy - uncommented below code and added above code
// Provide the ApiService (singleton)
/*
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// FutureProvider that automatically fetches posts
final postsProvider = FutureProvider<List<Post>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.fetchPosts();
});*/
