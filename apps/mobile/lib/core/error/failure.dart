import 'package:dio/dio.dart';

import '../../domain/enums.dart';

/// Échecs typés exposés par la couche data. Les écrans n'exposent jamais un
/// code technique brut : ils lisent [message] et, pour les paiements, [reason].
sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// Reason code renvoyé au login quand le compte n'a jamais été activé
/// (PIN temporaire correct fourni). L'écran de connexion oriente alors
/// vers le flux « Activer mon compte ».
const accountNotActivatedReason = 'account_not_activated';

/// Erreur métier 422 renvoyée par le backend (`{message, reason?}`).
class DomainFailure extends Failure {
  const DomainFailure(super.message, {this.reasonCode});
  final String? reasonCode;

  /// Raison typée quand elle correspond à un échec de paiement connu.
  PaymentFailureReason get paymentReason =>
      PaymentFailureReason.fromValue(reasonCode);
}

/// 401 — jeton absent, invalide ou révoqué : déclenche la déconnexion.
class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([super.message = 'Session expirée.']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Action non autorisée.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Ressource introuvable.']);
}

class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Conflit avec l\'état actuel.']);
}

/// Problème réseau (timeout, pas de connexion).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Connexion instable. Réessayez.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur est survenue.']);
}

/// Traduit une exception Dio en [Failure] typé.
Failure mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.cancel:
      return const NetworkFailure('Requête annulée.');
    default:
      break;
  }

  final response = e.response;
  final status = response?.statusCode;
  final data = response?.data;
  final message = data is Map && data['message'] is String
      ? data['message'] as String
      : null;
  final reason = data is Map && data['reason'] is String
      ? data['reason'] as String
      : null;

  return switch (status) {
    401 => UnauthenticatedFailure(message ?? 'Session expirée.'),
    403 => ForbiddenFailure(message ?? 'Action non autorisée.'),
    404 => NotFoundFailure(message ?? 'Ressource introuvable.'),
    409 => ConflictFailure(message ?? 'Conflit avec l\'état actuel.'),
    422 => DomainFailure(message ?? 'Requête invalide.', reasonCode: reason),
    _ => UnknownFailure(message ?? 'Une erreur est survenue.'),
  };
}
