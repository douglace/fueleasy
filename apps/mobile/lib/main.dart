import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/error/failure.dart';
import 'core/providers.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/widgets/app_buttons.dart';
import 'core/widgets/app_card.dart';
import 'core/widgets/status_badge.dart';

void main() {
  runApp(const ProviderScope(child: FusyApp()));
}

class FusyApp extends StatelessWidget {
  const FusyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fusy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _FoundationsDemoScreen(),
    );
  }
}

/// Écran de démonstration/diagnostic (Phases 0 & 1). Sera remplacé par le
/// routage réel en Phase 2.
class _FoundationsDemoScreen extends ConsumerStatefulWidget {
  const _FoundationsDemoScreen();

  @override
  ConsumerState<_FoundationsDemoScreen> createState() => _DemoState();
}

class _DemoState extends ConsumerState<_FoundationsDemoScreen> {
  String? _deviceId;
  String? _healthResult;
  bool _healthOk = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final id = await ref.read(tokenStoreProvider).getOrCreateDeviceId();
    if (mounted) setState(() => _deviceId = id);
  }

  /// Exerce la couche réseau + le mapping d'erreurs contre le backend réel.
  Future<void> _checkBackend() async {
    setState(() {
      _checking = true;
      _healthResult = null;
    });
    final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
    try {
      final res = await dio.get<Map<String, dynamic>>('/api/health');
      final data = res.data ?? const {};
      setState(() {
        _healthOk = true;
        _healthResult =
            'Backend joignable — ${data['app']} (${data['status']})';
      });
    } on DioException catch (e) {
      final failure = mapDioError(e);
      setState(() {
        _healthOk = false;
        _healthResult = failure.message;
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fusy — Fondations')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          children: [
            Image.asset('assets/images/primary-logo.png', height: 56),
            const SizedBox(height: AppSpacing.xl),

            // --- Vitrine design (Phase 0) ---
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Budget disponible', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.xs),
                  Text('50 000 FCFA', style: AppTypography.amount),
                  const SizedBox(height: AppSpacing.md),
                  const Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      StatusBadge(label: 'Payée', tone: StatusTone.success),
                      StatusBadge(label: 'À accuser', tone: StatusTone.warning),
                      StatusBadge(label: 'Expirée', tone: StatusTone.neutral),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- Diagnostic Phase 1 (couche données) ---
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnostic — couche données (Phase 1)',
                    style: AppTypography.title3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Backend : ${AppConfig.apiBaseUrl}',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Device ID : ${_deviceId ?? '…'}',
                    style: AppTypography.caption,
                  ),
                  if (_healthResult != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    StatusBadge(
                      label: _healthResult!,
                      tone: _healthOk ? StatusTone.success : StatusTone.error,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Tester la connexion au backend',
                    loading: _checking,
                    onPressed: _checkBackend,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(label: 'Voir le reçu', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
