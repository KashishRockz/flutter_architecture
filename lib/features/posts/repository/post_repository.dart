import 'package:dio/dio.dart';
import 'package:flutter_not_ai/features/posts/models/post.dart';

class PostRepository {
  final Dio dio;

  PostRepository(this.dio);


  Future<List<Post>> fetchPosts() async {
    try {
      final response = await dio.get('/posts');
      // navy: why are we doing this, feeding data to List<dynamic>?
      // and why do we need to map before returning?
      final List<dynamic> data = response.data;
      return data.map((json) => Post.fromJson(json)).toList();
    }catch(e){
      rethrow;
    }
  }

}