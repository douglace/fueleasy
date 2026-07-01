import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fusy_mobile/core/error/failure.dart';
import 'package:fusy_mobile/core/providers.dart';
import 'package:fusy_mobile/domain/enums.dart';
import 'package:fusy_mobile/features/auth/auth_controller.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Dio dio;
  late DioAdapter adapter;
  late ProviderContainer container;

  const base = 'http://test.local/api/v1/mobile/';

  Map<String, dynamic> userJson({String role = 'driver'}) => {
    'id': 1,
    'name': 'Boris Mballa',
    'role': role,
    'organization_id': 9,
  };

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    dio = Dio(BaseOptions(baseUrl: base));
    adapter = DioAdapter(dio: dio);
    container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );
    addTearDown(container.dispose);
  });

  test('starts unauthenticated when no token is stored', () async {
    final profile = await container.read(authControllerProvider.future);
    expect(profile, isNull);
  });

  test(
    'login succeeds, persists token and exposes the driver profile',
    () async {
      adapter.onPost(
        'auth/login',
        (server) => server.reply(200, {'token': 'tok_1', 'user': userJson()}),
        data: Matchers.any,
      );
      adapter.onGet(
        'me',
        (server) => server.reply(200, {
          ...userJson(),
          'budget': {'mode': 'weekly', 'masked': true},
          'enterprise_status': 'operational',
        }),
      );

      await container
          .read(authControllerProvider.notifier)
          .login(
            organizationCode: 'SCEFEA',
            identifier: '+237600000000',
            pin: '1234',
          );

      final state = container.read(authControllerProvider);
      expect(state.value, isNotNull);
      expect(state.value!.role, Role.driver);
      expect(await container.read(tokenStoreProvider).readToken(), 'tok_1');
    },
  );

  test(
    'login failure surfaces the Failure and keeps state unauthenticated',
    () async {
      adapter.onPost(
        'auth/login',
        (server) => server.reply(422, {'message': 'Identifiants invalides.'}),
        data: Matchers.any,
      );

      await expectLater(
        container
            .read(authControllerProvider.notifier)
            .login(organizationCode: 'X', identifier: 'y', pin: '0000'),
        throwsA(isA<DomainFailure>()),
      );

      final profile = await container.read(authControllerProvider.future);
      expect(profile, isNull);
    },
  );

  test('logout clears the token and resets state to unauthenticated', () async {
    adapter.onPost(
      'auth/login',
      (server) => server.reply(200, {'token': 'tok_2', 'user': userJson()}),
      data: Matchers.any,
    );
    adapter.onGet('me', (server) => server.reply(200, userJson()));

    await container
        .read(authControllerProvider.notifier)
        .login(organizationCode: 'SCEFEA', identifier: 'x', pin: '1234');
    expect(container.read(authControllerProvider).value, isNotNull);

    await container.read(authControllerProvider.notifier).logout();

    expect(container.read(authControllerProvider).value, isNull);
    expect(await container.read(tokenStoreProvider).readToken(), isNull);
  });
}
