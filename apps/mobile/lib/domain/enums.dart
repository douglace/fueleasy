// Enums du domaine Fusy, alignés sur le backend.
// Chaque enum parse une valeur serveur inconnue vers `unknown` (tolérance à
// l'évolution de l'API) plutôt que de lever une exception.

enum Role {
  driver('driver'),
  pompiste('pompiste'),
  fusyAdmin('fusy_admin'),
  enterpriseAdmin('enterprise_admin'),
  stationAdmin('station_admin'),
  unknown('unknown');

  const Role(this.value);
  final String value;

  static Role fromValue(String? v) =>
      Role.values.firstWhere((e) => e.value == v, orElse: () => Role.unknown);

  bool get isDriver => this == Role.driver;
  bool get isPompiste => this == Role.pompiste;
}

enum PaymentStatus {
  pending('pending'),
  paid('paid'),
  expired('expired'),
  failed('failed'),
  refunded('refunded'),
  unknown('unknown');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromValue(String? v) => PaymentStatus.values.firstWhere(
    (e) => e.value == v,
    orElse: () => PaymentStatus.unknown,
  );

  bool get isPaid => this == PaymentStatus.paid;
  bool get isPending => this == PaymentStatus.pending;
}

enum FuelType {
  gasoil('gasoil'),
  superFuel('super'),
  petrole('petrole'),
  unknown('unknown');

  const FuelType(this.value);
  final String value;

  static FuelType fromValue(String? v) => FuelType.values.firstWhere(
    (e) => e.value == v,
    orElse: () => FuelType.unknown,
  );

  String get label => switch (this) {
    FuelType.gasoil => 'Gasoil',
    FuelType.superFuel => 'Super',
    FuelType.petrole => 'Pétrole',
    FuelType.unknown => '—',
  };
}

enum BudgetMode {
  manual('manual'),
  weekly('weekly'),
  monthly('monthly'),
  unknown('unknown');

  const BudgetMode(this.value);
  final String value;

  static BudgetMode fromValue(String? v) => BudgetMode.values.firstWhere(
    (e) => e.value == v,
    orElse: () => BudgetMode.unknown,
  );
}

enum WorkSessionStatus {
  open('open'),
  closed('closed'),
  unknown('unknown');

  const WorkSessionStatus(this.value);
  final String value;

  static WorkSessionStatus fromValue(String? v) => WorkSessionStatus.values
      .firstWhere((e) => e.value == v, orElse: () => WorkSessionStatus.unknown);
}

enum QrType {
  dynamicQr('dynamic'),
  fixed('fixed'),
  unknown('unknown');

  const QrType(this.value);
  final String value;

  static QrType fromValue(String? v) => QrType.values.firstWhere(
    (e) => e.value == v,
    orElse: () => QrType.unknown,
  );
}

/// Raisons d'échec / blocage d'un paiement (source : PaymentFailureReason côté API).
enum PaymentFailureReason {
  qrInvalid('qr_invalid'),
  qrExpired('qr_expired'),
  qrRevoked('qr_revoked'),
  organizationInactive('organization_inactive'),
  driverInactive('driver_inactive'),
  stationInactive('station_inactive'),
  pumpInactive('pump_inactive'),
  fuelUnavailable('fuel_unavailable'),
  stationNotAuthorized('station_not_authorized'),
  budgetInsufficient('budget_insufficient'),
  balanceInsufficient('balance_insufficient'),
  sessionExpired('session_expired'),
  noBudget('no_budget'),
  noFuelAccount('no_fuel_account'),
  invalidPin('invalid_pin'),
  pinLocked('pin_locked'),
  unknown('unknown');

  const PaymentFailureReason(this.value);
  final String value;

  static PaymentFailureReason fromValue(String? v) {
    if (v == null) return PaymentFailureReason.unknown;
    return PaymentFailureReason.values.firstWhere(
      (e) => e.value == v,
      orElse: () => PaymentFailureReason.unknown,
    );
  }
}
