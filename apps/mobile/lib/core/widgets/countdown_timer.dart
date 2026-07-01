import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Minuterie textuelle `Expire dans 04:32`.
/// Avertissement (couleur warning) sous une minute, sans clignotement agressif.
/// Appelle [onExpired] une fois quand le temps atteint zéro.
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.expiresAt,
    this.onExpired,
    this.prefix = 'Expire dans ',
  });

  final DateTime expiresAt;
  final VoidCallback? onExpired;
  final String prefix;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  late Duration _remaining;
  bool _firedExpired = false;

  @override
  void initState() {
    super.initState();
    _remaining = _computeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Duration _computeRemaining() {
    final diff = widget.expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  void _tick() {
    if (!mounted) return;
    setState(() => _remaining = _computeRemaining());
    if (_remaining == Duration.zero && !_firedExpired) {
      _firedExpired = true;
      _timer?.cancel();
      widget.onExpired?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final isUrgent = _remaining.inSeconds <= 60 && _remaining > Duration.zero;
    final color = isUrgent ? AppColors.warningText : AppColors.neutral600;
    return Text(
      '${widget.prefix}$minutes:$seconds',
      style: AppTypography.label.copyWith(
        color: color,
        fontFeatures: const [AppTypography.tabular],
      ),
    );
  }
}
