
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/post.dart';

class PostService {
  static const String baseUrl =
      'https://jsonplaceholder.typicode.com';

  // Guarda o último statusCode recebido
  static int lastStatusCode = 0;

  // =========================================================
  // GET - BUSCAR POSTS
  // =========================================================

  static Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
    );

    lastStatusCode = response.statusCode;

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final List<dynamic> data =
          jsonDecode(response.body);

      return data
          .map((json) => Post.fromJson(json))
          .toList();
    }

    throw Exception(
      'Erro ao buscar posts. '
      'StatusCode: ${response.statusCode}',
    );
  }

  // =========================================================
  // POST - CRIAR POST
  // =========================================================

  static Future<Post> createPost(Post post) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(post.toJson()),
    );

    lastStatusCode = response.statusCode;

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = jsonDecode(response.body);

      return Post.fromJson(data);
    }

    throw Exception(
      'Erro ao criar post. '
      'StatusCode: ${response.statusCode}',
    );
  }

  // =========================================================
  // PUT - ATUALIZAR POST
  // =========================================================

  static Future<Post> updatePost(
    int id,
    Post post,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(post.toJson()),
    );

    lastStatusCode = response.statusCode;

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = jsonDecode(response.body);

      return Post.fromJson(data);
    }

    throw Exception(
      'Erro ao atualizar post. '
      'StatusCode: ${response.statusCode}',
    );
  }

  // =========================================================
  // DELETE - EXCLUIR POST
  // =========================================================

  static Future<int> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$id'),
    );

    lastStatusCode = response.statusCode;

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return response.statusCode;
    }

    throw Exception(
      'Erro ao excluir post. '
      'StatusCode: ${response.statusCode}',
    );
  }
}

