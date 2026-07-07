import 'package:dio/dio.dart';

import '../core/network/api_executor.dart';
import '../domain/entities.dart';

/// Session de travail et consultation des paiements côté pompiste.
class WorkSessionRepository {
  WorkSessionRepository(this._dio);

  final Dio _dio;

  /// Pompes actives de la station du pompiste (pour choisir où ouvrir une session).
  Future<List<PumpRef>> pumps() => runApi(
    () => _dio.get('station/pumps'),
    (data) => ((data as Map<String, dynamic>)['data'] as List)
        .map((e) => PumpRef.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Future<WorkSessionQr> open(int pumpId) => runApi(
    () => _dio.post('work-sessions', data: {'pump_id': pumpId}),
    (data) => WorkSessionQr.fromJson(data as Map<String, dynamic>),
  );

  Future<void> close(int workSessionId) =>
      runApi(() => _dio.post('work-sessions/$workSessionId/close'), (_) {});

  /// QR de la session ouverte courante (rafraîchi à chaque appel, TTL 60 s).
  Future<WorkSessionQr> currentQr() => runApi(
    () => _dio.get('work-sessions/current/qr'),
    (data) => WorkSessionQr.fromJson(data as Map<String, dynamic>),
  );

  /// Paiements du jour. `scope=pump` (défaut) filtre sur la pompe de la
  /// session ouverte ; le serveur bascule en vue station si aucune session
  /// n'est ouverte et renvoie le périmètre effectivement appliqué.
  Future<TodayPayments> todaysPayments({String scope = 'pump'}) => runApi(
    () => _dio.get('station/payments/today', queryParameters: {'scope': scope}),
    (data) {
      final map = data as Map<String, dynamic>;
      return TodayPayments(
        payments: (map['data'] as List)
            .map((e) => Payment.fromJson(e as Map<String, dynamic>))
            .toList(),
        appliedScope: (map['scope'] as String?) ?? scope,
        pumpId: map['pump_id'] as int?,
      );
    },
  );

  Future<Payment?> searchByCode(String code) => runApi(
    () => _dio.get('station/payments/search', queryParameters: {'code': code}),
    (data) {
      final map = data as Map<String, dynamic>;
      if (map['found'] != true) return null;
      return Payment.fromJson(map['payment'] as Map<String, dynamic>);
    },
  );

  /// Accuse réception d'un paiement (idempotent).
  Future<bool> acknowledge(int paymentId) => runApi(
    () => _dio.post('station/payments/$paymentId/ack'),
    (data) => (data as Map<String, dynamic>)['acknowledged'] == true,
  );
}
