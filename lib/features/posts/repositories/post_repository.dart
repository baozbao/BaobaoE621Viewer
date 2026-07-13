import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/e621_post.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(ref.watch(dioProvider));
});

class PostRepository {
  final Dio _dio;

  PostRepository(this._dio);

  Future<List<E621Post>> getPosts({
    required String tags,
    int page = 1,
    int limit = 75,
  }) async {
    try {
      final response = await _dio.get(
        '/posts.json',
        queryParameters: {
          'tags': tags,
          'page': page,
          'limit': limit,
        },
      );

      final postResponse = E621PostResponse.fromJson(response.data);
      return postResponse.posts;
    } catch (e) {
      log('Error fetching posts: $e');
      rethrow;
    }
  }

  /// Fetches the total post count by scraping HTML pagination metadata.
  /// e621's JSON API does not expose total counts.
  ///
  /// Strategy:
  /// 1. Request `/posts?tags=xxx` WITHOUT a limit param, so e621 uses its
  ///    server-side default per-page (found in `data-user-per-page` on <body>).
  /// 2. Extract `data-total` (total pages at that per-page) from the <nav>.
  /// 3. Extract `data-user-per-page` from the <body>.
  /// 4. Return totalPages * perPage = approximate total post count.
  Future<int> fetchTotalPostCount({required String tags}) async {
    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: {'tags': tags},
        options: Options(responseType: ResponseType.plain),
      );

      final html = response.data.toString();

      // Extract data-total="X" from the pagination nav
      final totalMatch = RegExp(r'data-total="(\d+)"').firstMatch(html);
      // Extract data-user-per-page="X" from the <body> tag
      final perPageMatch = RegExp(r'data-user-per-page="(\d+)"').firstMatch(html);

      if (totalMatch != null && perPageMatch != null) {
        final totalPages = int.parse(totalMatch.group(1)!);
        final perPage = int.parse(perPageMatch.group(1)!);
        return totalPages * perPage;
      }
      return 0;
    } catch (e) {
      log('Error fetching total post count from HTML: $e');
      return 0;
    }
  }
}
