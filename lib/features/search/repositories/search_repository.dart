import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/log_service.dart';
import '../models/e621_tag.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ref.watch(dioProvider));
});

class SearchRepository {
  final Dio _dio;

  SearchRepository(this._dio);

  Future<List<E621Tag>> getTagAutocomplete(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final response = await _dio.get(
        '/tags/autocomplete.json',
        queryParameters: {
          'search[name_matches]': query,
          'expiry': 7,
        },
        // 补全随每次输入触发，量远大于其他请求。单独归类，
        // 否则它会把真正要排查的 posts 查询从日志里冲掉。
        options: Options(
          extra: {AppLogInterceptor.typeKey: LogType.autocomplete},
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => E621Tag.fromJson(json)).toList();
    } catch (e) {
      log('Error fetching tag autocomplete: $e');
      rethrow;
    }
  }
}
