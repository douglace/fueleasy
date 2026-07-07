import 'enums.dart';

/// Utilitaire de parsing de date ISO8601 tolérant.
DateTime? _parseDate(Object? v) =>
    v is String ? DateTime.tryParse(v)?.toLocal() : null;

/// Compte renvoyé par activate / login / device confirm.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.role,
    required this.organizationId,
  });

  final int id;
  final String name;
  final Role role;
  final int? organizationId;

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
    id: j['id'] as int,
    name: (j['name'] as String?) ?? '',
    role: Role.fromValue(j['role'] as String?),
    organizationId: j['organization_id'] as int?,
  );
}

/// Résultat d'une authentification : jeton Bearer + compte.
class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> j) => AuthSession(
    token: j['token'] as String,
    user: AuthUser.fromJson(j['user'] as Map<String, dynamic>),
  );
}

/// Info budget (chauffeur uniquement), solde masqué par défaut.
class BudgetInfo {
  const BudgetInfo({
    required this.mode,
    required this.masked,
    this.nextResetAt,
  });

  final BudgetMode mode;
  final bool masked;
  final DateTime? nextResetAt;

  factory BudgetInfo.fromJson(Map<String, dynamic> j) => BudgetInfo(
    mode: BudgetMode.fromValue(j['mode'] as String?),
    masked: (j['masked'] as bool?) ?? true,
    nextResetAt: _parseDate(j['next_reset_at']),
  );
}

/// Profil courant (GET /me). Budget + statut entreprise seulement pour le chauffeur.
class MeProfile {
  const MeProfile({
    required this.id,
    required this.name,
    required this.role,
    this.organizationId,
    this.budget,
    this.enterpriseStatus,
  });

  final int id;
  final String name;
  final Role role;
  final int? organizationId;
  final BudgetInfo? budget;
  final String? enterpriseStatus;

  factory MeProfile.fromJson(Map<String, dynamic> j) => MeProfile(
    id: j['id'] as int,
    name: (j['name'] as String?) ?? '',
    role: Role.fromValue(j['role'] as String?),
    organizationId: j['organization_id'] as int?,
    budget: j['budget'] is Map<String, dynamic>
        ? BudgetInfo.fromJson(j['budget'] as Map<String, dynamic>)
        : null,
    enterpriseStatus: j['enterprise_status'] as String?,
  );
}

/// Résultat de la révélation du budget (POST /budget/reveal).
class BudgetReveal {
  const BudgetReveal({required this.balance, required this.revealSeconds});

  final int? balance;
  final int revealSeconds;

  factory BudgetReveal.fromJson(Map<String, dynamic> j) => BudgetReveal(
    balance: j['balance'] as int?,
    revealSeconds: (j['reveal_seconds'] as int?) ?? 15,
  );
}

class StationRef {
  const StationRef({required this.id, required this.name});
  final int id;
  final String name;

  factory StationRef.fromJson(Map<String, dynamic> j) =>
      StationRef(id: j['id'] as int, name: (j['name'] as String?) ?? '');
}

class PumpRef {
  const PumpRef({
    required this.id,
    required this.label,
    required this.availableFuels,
  });

  final int id;
  final String label;
  final List<FuelType> availableFuels;

  factory PumpRef.fromJson(Map<String, dynamic> j) => PumpRef(
    id: j['id'] as int,
    label: (j['label'] as String?) ?? '',
    availableFuels: ((j['available_fuels'] as List?) ?? const [])
        .map((e) => FuelType.fromValue(e as String?))
        .toList(),
  );
}

/// Contexte résolu d'un scan QR (POST /scan).
class ScanContext {
  const ScanContext({
    required this.via,
    required this.station,
    required this.pump,
    this.pompisteId,
  });

  final QrType via;
  final StationRef station;
  final PumpRef pump;
  final int? pompisteId;

  factory ScanContext.fromJson(Map<String, dynamic> j) => ScanContext(
    via: QrType.fromValue(j['via'] as String?),
    station: StationRef.fromJson(j['station'] as Map<String, dynamic>),
    pump: PumpRef.fromJson(j['pump'] as Map<String, dynamic>),
    pompisteId: j['pompiste_id'] as int?,
  );
}

/// Paiement (création, détail, historique, station).
class Payment {
  const Payment({
    required this.id,
    required this.reference,
    required this.shortCode,
    required this.status,
    required this.via,
    required this.fuelType,
    required this.amount,
    required this.failureReason,
    required this.stationOrganizationId,
    required this.pumpId,
    required this.expiresAt,
    required this.confirmedAt,
    required this.createdAt,
    this.alertAcknowledgedAt,
  });

  final int id;
  final String reference;
  final String shortCode;
  final PaymentStatus status;
  final QrType via;
  final FuelType fuelType;
  final int amount;
  final PaymentFailureReason? failureReason;
  final int? stationOrganizationId;
  final int? pumpId;
  final DateTime? expiresAt;
  final DateTime? confirmedAt;
  final DateTime? createdAt;

  /// Accusé de réception pompiste (non nul une fois acquitté). `null` tant
  /// que le pompiste n'a pas confirmé avoir vu le paiement.
  final DateTime? alertAcknowledgedAt;

  bool get isAcknowledged => alertAcknowledgedAt != null;

  Payment copyWith({DateTime? alertAcknowledgedAt}) => Payment(
    id: id,
    reference: reference,
    shortCode: shortCode,
    status: status,
    via: via,
    fuelType: fuelType,
    amount: amount,
    failureReason: failureReason,
    stationOrganizationId: stationOrganizationId,
    pumpId: pumpId,
    expiresAt: expiresAt,
    confirmedAt: confirmedAt,
    createdAt: createdAt,
    alertAcknowledgedAt: alertAcknowledgedAt ?? this.alertAcknowledgedAt,
  );

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
    id: j['id'] as int,
    reference: (j['reference'] as String?) ?? '',
    shortCode: (j['short_code'] as String?) ?? '',
    status: PaymentStatus.fromValue(j['status'] as String?),
    via: QrType.fromValue(j['via'] as String?),
    fuelType: FuelType.fromValue(j['fuel_type'] as String?),
    amount: (j['amount'] as int?) ?? 0,
    failureReason: j['failure_reason'] == null
        ? null
        : PaymentFailureReason.fromValue(j['failure_reason'] as String?),
    stationOrganizationId: j['station_organization_id'] as int?,
    pumpId: j['pump_id'] as int?,
    expiresAt: _parseDate(j['expires_at']),
    confirmedAt: _parseDate(j['confirmed_at']),
    createdAt: _parseDate(j['created_at']),
    alertAcknowledgedAt: _parseDate(j['alert_acknowledged_at']),
  );
}

/// Session de travail ouverte (POST /work-sessions) ou QR courant.
/// Paiements du jour côté pompiste, avec le périmètre réellement appliqué
/// par le serveur : `pump` (pompe de la session ouverte) ou `station`
/// (bascule automatique quand aucune session n'est ouverte).
class TodayPayments {
  const TodayPayments({
    required this.payments,
    required this.appliedScope,
    this.pumpId,
  });

  final List<Payment> payments;
  final String appliedScope;
  final int? pumpId;

  bool get isStationScope => appliedScope == 'station';
}

class WorkSessionQr {
  const WorkSessionQr({
    required this.workSessionId,
    required this.pumpId,
    required this.qr,
    required this.expiresIn,
    this.status,
  });

  final int workSessionId;
  final int pumpId;
  final String qr;
  final int expiresIn;
  final WorkSessionStatus? status;

  factory WorkSessionQr.fromJson(Map<String, dynamic> j) => WorkSessionQr(
    workSessionId: j['work_session_id'] as int,
    pumpId: j['pump_id'] as int,
    qr: (j['qr'] as String?) ?? '',
    expiresIn: (j['expires_in'] as int?) ?? 60,
    status: j['status'] == null
        ? null
        : WorkSessionStatus.fromValue(j['status'] as String?),
  );
}
