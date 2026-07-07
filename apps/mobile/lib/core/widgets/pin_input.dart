import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../haptics.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Saisie PIN en cases individuelles (style OTP) : chaque chiffre remplit sa
/// case, la case active est surlignée, erreur = bordures rouges + shake +
/// haptique. Un TextField invisible par-dessus capte le clavier — l'API
/// (controller, length, onCompleted…) reste inchangée.
/// Ne jamais stocker ni afficher le PIN en clair ailleurs.
class PinInput extends StatefulWidget {
  const PinInput({
    super.key,
    required this.controller,
    this.length = 4,
    this.autofocus = false,
    this.hasError = false,
    this.onCompleted,
    this.obscure = true,
  });

  final TextEditingController controller;
  final int length;
  final bool autofocus;
  final bool hasError;
  final ValueChanged<String>? onCompleted;

  /// `false` pour les codes non secrets (ex. code SMS) : chiffres visibles.
  final bool obscure;

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput>
    with SingleTickerProviderStateMixin {
  final _focusNode = FocusNode();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
  );

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(PinInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
    if (widget.hasError && !oldWidget.hasError) {
      AppHaptics.error();
      _shake.forward(from: 0);
    }
  }

  void _onChanged() {
    setState(() {});
    if (widget.controller.text.length == widget.length) {
      widget.onCompleted?.call(widget.controller.text);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focusNode.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        // Trois oscillations amorties.
        final t = _shake.value;
        final dx = t == 0 || t == 1
            ? 0.0
            : 8 * (1 - t) * (t * 30).remainder(2.0) - 8 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: SizedBox(
        height: 56,
        child: Stack(
          children: [
            // Cases visibles — l'état vient du controller.
            Positioned.fill(
              child: IgnorePointer(
                child: Row(
                  children: [
                    for (var i = 0; i < widget.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _PinBox(
                          filled: i < text.length,
                          active:
                              _focusNode.hasFocus &&
                              i == text.length.clamp(0, widget.length - 1) &&
                              text.length < widget.length,
                          hasError: widget.hasError,
                          char: i < text.length ? text[i] : null,
                          obscure: widget.obscure,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Champ réel invisible : capte le clavier et les taps.
            Positioned.fill(
              child: Semantics(
                label: 'Code à ${widget.length} chiffres',
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  maxLength: widget.length,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 1,
                  ),
                  cursorColor: Colors.transparent,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinBox extends StatelessWidget {
  const _PinBox({
    required this.filled,
    required this.active,
    required this.hasError,
    required this.char,
    required this.obscure,
  });

  final bool filled;
  final bool active;
  final bool hasError;
  final String? char;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError
        ? AppColors.errorText
        : active
        ? AppColors.navy
        : filled
        ? AppColors.neutral300
        : AppColors.neutral200;

    return AnimatedContainer(
      duration: AppDurations.fast,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.field),
        border: Border.all(color: borderColor, width: active ? 1.5 : 1),
        boxShadow: active ? AppShadows.card : null,
      ),
      child: filled
          ? AnimatedScale(
              scale: 1,
              duration: AppDurations.fast,
              child: obscure
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.neutral900,
                        shape: BoxShape.circle,
                      ),
                    )
                  : Text(
                      char!,
                      style: AppTypography.title2.copyWith(
                        fontFeatures: const [AppTypography.tabular],
                      ),
                    ),
            )
          : active
          ? Container(width: 2, height: 24, color: AppColors.navy)
          : const SizedBox.shrink(),
    );
  }
}
