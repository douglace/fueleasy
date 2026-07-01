import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/error/failure.dart';
import 'package:fusy_mobile/domain/enums.dart';

DioException _http(int status, Object? data) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  response: Response(
    requestOptions: RequestOptions(path: '/x'),
    statusCode: status,
    data: data,
  ),
  type: DioExceptionType.badResponse,
);

void main() {
  test('422 with reason maps to DomainFailure with typed payment reason', () {
    final f = mapDioError(
      _http(422, {
        'message': 'Budget insuffisant.',
        'reason': 'budget_insufficient',
      }),
    );
    expect(f, isA<DomainFailure>());
    final d = f as DomainFailure;
    expect(d.message, 'Budget insuffisant.');
    expect(d.paymentReason, PaymentFailureReason.budgetInsufficient);
  });

  test('401 maps to UnauthenticatedFailure', () {
    expect(
      mapDioError(_http(401, {'message': 'Session invalide.'})),
      isA<UnauthenticatedFailure>(),
    );
  });

  test('403/404/409 map to their failures', () {
    expect(mapDioError(_http(403, null)), isA<ForbiddenFailure>());
    expect(mapDioError(_http(404, null)), isA<NotFoundFailure>());
    expect(mapDioError(_http(409, null)), isA<ConflictFailure>());
  });

  test('timeouts and connection errors map to NetworkFailure', () {
    final e = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionError,
    );
    expect(mapDioError(e), isA<NetworkFailure>());
  });
}
