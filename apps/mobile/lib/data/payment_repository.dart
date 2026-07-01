import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/network/api_executor.dart';
import '../domain/entities.dart';
import '../domain/enums.dart';

/// Parcours paiement côté chauffeur.
class PaymentRepository {
  PaymentRepository(this._dio);

  final Dio _dio;

  Future<ScanContext> scan(String qr) => runApi(
    () => _dio.post('scan', data: {'qr': qr}),
    (data) => ScanContext.fromJson(data as Map<String, dynamic>),
  );

  Future<Payment> create({
    required String qr,
    required FuelType fuelType,
    required int amount,
  }) => runApi(
    () => _dio.post(
      'payments',
      data: {'qr': qr, 'fuel_type': fuelType.value, 'amount': amount},
    ),
    (data) => Payment.fromJson(data as Map<String, dynamic>),
  );

  Future<Payment> get(int paymentId) => runApi(
    () => _dio.get('payments/$paymentId'),
    (data) => Payment.fromJson(data as Map<String, dynamic>),
  );

  Future<Payment> confirm({
    required int paymentId,
    required String pin,
    required String idempotencyKey,
  }) => runApi(
    () => _dio.post(
      'payments/$paymentId/confirm',
      data: {'pin': pin, 'idempotency_key': idempotencyKey},
    ),
    (data) => Payment.fromJson(data as Map<String, dynamic>),
  );

  /// Récupération après perte réseau pendant la confirmation.
  Future<Payment?> findByIdempotencyKey(String key) => runApi(
    () =>
        _dio.get('payments/by-key', queryParameters: {'idempotency_key': key}),
    (data) {
      final map = data as Map<String, dynamic>;
      if (map['found'] != true) return null;
      return Payment.fromJson(map['payment'] as Map<String, dynamic>);
    },
  );

  Future<List<Payment>> history() => runApi(
    () => _dio.get('payments'),
    (data) => ((data as Map<String, dynamic>)['data'] as List)
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Reçu PDF (transaction payée uniquement — 409 sinon).
  Future<Uint8List> receiptPdf(int paymentId) => runApi(
    () => _dio.get(
      'payments/$paymentId/receipt',
      options: Options(responseType: ResponseType.bytes),
    ),
    (data) => data is List<int> ? Uint8List.fromList(data) : data as Uint8List,
  );
}
