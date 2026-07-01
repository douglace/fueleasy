import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendant/screens/attendant_shell_screen.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/screens/activation_screen.dart';
import '../../features/auth/screens/device_change_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/unsupported_role_screen.dart';
import '../../features/driver/screens/driver_shell_screen.dart';

const splashPath = '/splash';
const loginPath = '/login';
const activatePath = '/activate';
const deviceChangePath = '/device-change';
const driverHomePath = '/driver';
const attendantHomePath = '/attendant';
const unsupportedRolePath = '/unsupported-role';

/// Notifie go_router à chaque changement d'état d'authentification, pour que
/// `redirect` soit ré-évalué automatiquement (connexion, déconnexion, etc.).
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: splashPath,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isAuthRoute =
          location == loginPath ||
          location == activatePath ||
          location == deviceChangePath;

      return auth.when(
        loading: () => location == splashPath ? null : splashPath,
        error: (_, _) => location == splashPath ? null : splashPath,
        data: (profile) {
          if (profile == null) {
            return isAuthRoute ? null : loginPath;
          }
          if (profile.role.isDriver) {
            return location == driverHomePath ? null : driverHomePath;
          }
          if (profile.role.isPompiste) {
            return location == attendantHomePath ? null : attendantHomePath;
          }
          return location == unsupportedRolePath ? null : unsupportedRolePath;
        },
      );
    },
    routes: [
      GoRoute(
        path: splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: activatePath,
        builder: (context, state) => const ActivationScreen(),
      ),
      GoRoute(
        path: deviceChangePath,
        builder: (context, state) => const DeviceChangeScreen(),
      ),
      GoRoute(
        path: driverHomePath,
        builder: (context, state) => const DriverShellScreen(),
      ),
      GoRoute(
        path: attendantHomePath,
        builder: (context, state) => const AttendantShellScreen(),
      ),
      GoRoute(
        path: unsupportedRolePath,
        builder: (context, state) => const UnsupportedRoleScreen(),
      ),
    ],
  );
});
