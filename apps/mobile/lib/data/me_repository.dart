import 'package:dio/dio.dart';

import '../core/network/api_executor.dart';
import '../domain/entities.dart';

/// Profil courant et révélation du budget.
class MeRepository {
  MeRepository(this._dio);

  final Dio _dio;

  Future<MeProfile> me() => runApi(
    () => _dio.get('me'),
    (data) => MeProfile.fromJson(data as Map<String, dynamic>),
  );

  /// Révèle le solde du budget après vérification du PIN (chauffeur).
  Future<BudgetReveal> revealBudget(String pin) => runApi(
    () => _dio.post('budget/reveal', data: {'pin': pin}),
    (data) => BudgetReveal.fromJson(data as Map<String, dynamic>),
  );
}
