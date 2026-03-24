import 'dart:async';
import 'package:dio/dio.dart';
import 'package:olam/core/navigation/app_navigation.dart';
import 'package:olam/core/networks/api_urls.dart';
import 'package:olam/core/route/route_names.dart';
import 'package:olam/features/auth/data/datasource/local/auth_local_data_source.dart';

class DioClient {
  final Dio _dio;
  final AuthLocalDataSource local;

  bool _isRefreshing = false;
  final List<void Function(String token)> _refreshQueue = [];

  DioClient({required this.local})
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiUrls.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  ) {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Refresh endpointga Authorization qo'shmaymiz
          final isRefreshCall = options.path.contains('yangilash');

          if (!isRefreshCall) {
            final access = local.getAccessToken();
            if (access != null && access.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $access';
            }
          } else {
            options.headers.remove('Authorization');
          }

          return handler.next(options);
        },
        onError: (e, handler) async {
          final isRefreshCall = e.requestOptions.path.contains('yangilash');

          // Refresh so'rovi o'zi yiqilsa, yana refreshga urunmaymiz
          if (isRefreshCall) {
            return handler.next(e);
          }

          if (_looksLikeTokenError(e)) {
            try {
              final newAccess = await _refreshTokenSafely();

              if (newAccess != null && newAccess.isNotEmpty) {
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccess';
                final cloned = await _dio.fetch(opts);
                return handler.resolve(cloned);
              } else {
                await _forceLogout();
                return handler.next(e);
              }
            } catch (_) {
              await _forceLogout();
              return handler.next(e);
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  bool _looksLikeTokenError(DioException e) {
    final code = e.response?.statusCode;

    if (code == 400 || code == 401 || code == 403) {
      final data = e.response?.data;
      final text = (data is String) ? data : data?.toString() ?? '';
      final lower = text.toLowerCase();

      return lower.contains('token') ||
          lower.contains('expired') ||
          lower.contains('not valid') ||
          lower.contains('invalid') ||
          lower.contains('unauthorized') ||
          lower.contains('token_not_valid');
    }

    return false;
  }

  Future<void> _forceLogout() async {
    await local.clearAll();

    appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      RouteNames.login,
          (route) => false,
    );
  }

  Future<String?> _refreshTokenSafely() async {
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add((token) => completer.complete(token));
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refresh = local.getRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        for (final cb in _refreshQueue) cb('');
        _refreshQueue.clear();
        return null;
      }

      //  TO'G'RI: refresh token Authorization headerida yuboriladi
      final resp = await _dio.post(
        ApiUrls.refreshToken, // '/api/auth/yangilash'
        options: Options(
          headers: {
            'Authorization': 'Bearer $refresh',
            'Content-Type': 'application/json',
          },
        ),
      );

      //  Server 'access_token' qaytaradi (sizning API ga mos)
      final data = resp.data['data'] as Map<String, dynamic>?;
      final newAccess = data?['access_token'] as String?;

      if (newAccess != null && newAccess.isNotEmpty) {
        await local.saveAccessToken(newAccess);

        for (final cb in _refreshQueue) {
          cb(newAccess);
        }
        _refreshQueue.clear();

        return newAccess;
      }

      for (final cb in _refreshQueue) cb('');
      _refreshQueue.clear();
      return null;
    } catch (e) {
      for (final cb in _refreshQueue) cb('');
      _refreshQueue.clear();
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParams,
        Options? options,
      }) =>
      _dio.get(path, queryParameters: queryParams, options: options);

  Future<Response> post(String path, {dynamic data, Options? options}) =>
      _dio.post(path, data: data, options: options);

  Future<Response> put(String path, {dynamic data, Options? options}) =>
      _dio.put(path, data: data, options: options);

  Future<Response> patch(String path, {dynamic data, Options? options}) =>
      _dio.patch(path, data: data, options: options);

  Future<Response> delete(
      String path, {
        Map<String, dynamic>? queryParams,
        Options? options,
      }) =>
      _dio.delete(path, queryParameters: queryParams, options: options);
}