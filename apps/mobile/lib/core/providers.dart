import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/auth_repository.dart';
import '../data/me_repository.dart';
import '../data/payment_repository.dart';
import '../data/work_session_repository.dart';
import 'network/dio_client.dart';
import 'storage/token_store.dart';

/// Providers d'infrastructure et repositories, partagés par toute l'app.

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final tokenStoreProvider = Provider<TokenStore>(
  (ref) => TokenStore(ref.watch(secureStorageProvider)),
);

final dioProvider = Provider<Dio>(
  (ref) => buildDio(ref.watch(tokenStoreProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) =>
      AuthRepository(ref.watch(dioProvider), ref.watch(tokenStoreProvider)),
);

final meRepositoryProvider = Provider<MeRepository>(
  (ref) => MeRepository(ref.watch(dioProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepository(ref.watch(dioProvider)),
);

final workSessionRepositoryProvider = Provider<WorkSessionRepository>(
  (ref) => WorkSessionRepository(ref.watch(dioProvider)),
);
