import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../storage/token_store.dart';

/// Ajoute le jeton Bearer à chaque requête si présent.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStore);

  final TokenStore _tokenStore;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStore.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Construit le client Dio pour l'API mobile Fusy.
Dio buildDio(TokenStore tokenStore) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.mobileApiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
      contentType: Headers.jsonContentType,
    ),
  );

  dio.interceptors.add(AuthInterceptor(tokenStore));

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  return dio;
}
