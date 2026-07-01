import 'package:dio/dio.dart';

import '../error/failure.dart';

/// Exécute un appel Dio et convertit toute [DioException] en [Failure] typé.
/// [parse] transforme le corps de réponse en entité.
Future<T> runApi<T>(
  Future<Response<dynamic>> Function() request,
  T Function(dynamic data) parse,
) async {
  try {
    final response = await request();
    return parse(response.data);
  } on DioException catch (e) {
    throw mapDioError(e);
  }
}
