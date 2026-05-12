import 'dart:developer';
import 'package:dio/dio.dart';

class ApiClient {

  final Dio _dio;
  String? _token;
  static const coinGecko="CG-STpUPhRiZgxoyPFkerdkScpM";
  static const ethScanKey="N8N1CQHKPX5YY1Q219XNX2EJRWDRUIGY2W";
  static const cmcKey="4f24b8e5372747a59d47f996e05d196b"; // TODO: Replace with your actual CMC API key
  static const moralisKey="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJub25jZSI6IjJjZDlkYTRlLWVkZmUtNDJmNC1iOGRmLTIwMTk4OTE2YmJlNiIsIm9yZ0lkIjoiNDk4OTgzIiwidXNlcklkIjoiNTEzNDY1IiwidHlwZUlkIjoiYjdkNmZkNjUtODk2OC00NjI0LTk2YmItMTkwMDEwZmIxNjFhIiwidHlwZSI6IlBST0pFQ1QiLCJpYXQiOjE3NzA0MjY4NDcsImV4cCI6NDkyNjE4Njg0N30.h46nVUkFn9XpCi0FpRWHLsTlaC-_xSd5Ie3BizSaBCo";

  ApiClient() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.responseType = ResponseType.json;
    _dio.options.validateStatus = (status) => status != null && status <= 500;
  }

  void setToken(String token) {
    _token = token;
  }

  Map<String, dynamic> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Response?> get(String url, {Map<String, dynamic>? queryParams,Map<String, dynamic>? headers,}) async {
    try {
      log('GET Request to $url');
      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(headers: headers??_headers),
      );
      return response;
    } catch (e) {
      log('GET Error: $e');
      rethrow;
    }
  }

  Future<Response?> post(String url, {dynamic data, Map<String, dynamic>? headers}) async {
    try {
      log('POST Request to $url');
      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: headers ?? _headers),
      );
      return response;
    } catch (e) {
      log('POST Error: $e');
      rethrow;
    }
  }

  Future<Response?> put(String url, {dynamic data, Map<String, dynamic>? headers}) async {
    try {
      log('PUT Request to $url');
      final response = await _dio.put(
        url,
        data: data,
        options: Options(headers: headers ?? _headers),
      );
      return response;
    } catch (e) {
      log('PUT Error: $e');
      rethrow;
    }
  }
}
