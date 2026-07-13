import 'package:dio/dio.dart';
import '../constants/strings.dart';

/// 把底层异常翻译成人话文案（A5）。
/// 放在 core/utils 而非 widgets 层，方便 provider 在 catch 时直接调用，
/// 避免 provider 依赖 UI 层。
String humanizeError(Object? error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Strings.errorTimeout;
      case DioExceptionType.connectionError:
        return Strings.errorNetwork;
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode ?? 0;
        if (code >= 500) return Strings.errorServer;
        if (code == 422) return '搜索条件无效或超出页数上限';
        if (code == 403) return '访问被拒绝（可能触发了频率限制）';
        return '请求失败（$code）';
      default:
        return Strings.errorUnknown;
    }
  }
  return Strings.errorUnknown;
}
