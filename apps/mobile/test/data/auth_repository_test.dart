import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/error/failure.dart';
import 'package:fusy_mobile/core/storage/token_store.dart';
import 'package:fusy_mobile/data/auth_repository.dart';
import 'package:fusy_mobile/domain/enums.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  late DioAdapter adapter;
  late TokenStore tokenStore;
  late AuthRepository repo;

  const base = 'http://test.local/api/v1/mobile/';

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    dio = Dio(BaseOptions(baseUrl: base));
    adapter = DioAdapter(dio: dio);
    tokenStore = TokenStore(const FlutterSecureStorage());
    repo = AuthRepository(dio, tokenStore);
  });

  test('login returns a session and persists the token', () async {
    adapter.onPost(
      'auth/login',
      (server) => server.reply(200, {
        'token': 'tok_123',
        'user': {
          'id': 1,
          'name': 'Boris Mballa',
          'role': 'driver',
          'organization_id': 9,
        },
      }),
      data: Matchers.any,
    );

    final session = await repo.login(
      organizationCode: 'SCEFEA',
      identifier: 'boris',
      pin: '1234',
    );

    expect(session.token, 'tok_123');
    expect(session.user.role, Role.driver);
    expect(await tokenStore.readToken(), 'tok_123');
  });

  test(
    'login maps a 422 to DomainFailure and does not store a token',
    () async {
      adapter.onPost(
        'auth/login',
        (server) => server.reply(422, {'message': 'Identifiants invalides.'}),
        data: Matchers.any,
      );

      await expectLater(
        repo.login(organizationCode: 'X', identifier: 'y', pin: '0000'),
        throwsA(isA<DomainFailure>()),
      );
      expect(await tokenStore.readToken(), isNull);
    },
  );
}
