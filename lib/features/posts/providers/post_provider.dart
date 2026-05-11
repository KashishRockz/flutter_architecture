// lib/features/posts/providers/post_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repository/app_repository.dart';
import '../models/post.dart';

final postsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final result = await ref.read(appRepositoryProvider).getPosts();
  return result.fold(
        (error) => throw error,   // home_view.dart when(error:) catches this
        (posts)  => posts,
  );
});