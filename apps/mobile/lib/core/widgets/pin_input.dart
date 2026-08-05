import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../haptics.dart';
import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Saisie de code en style minimaliste « souligné » : chaque chiffre est posé
/// sur un trait discret (pas de cadre ni d'ombre). Le trait devient navy et
/// s'épaissit sur la position active, rouge en cas d'erreur (avec shake +
/// haptique). Un TextField invisible par-dessus capte le clavier et le collage
/// (paste) — l'API (controller, length, onCompleted…) reste inchangée.
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
    this.focusNode,
  });

  final TextEditingController controller;
  final int length;
  final bool autofocus;
  final bool hasError;
  final ValueChanged<String>? onCompleted;

  /// FocusNode externe (ex. pour enchaîner le focus entre plusieurs champs).
  /// Si `null`, le widget gère son propre FocusNode interne.
  final FocusNode? focusNode;

  /// `false` pour les codes non secrets (ex. code SMS) : chiffres visibles.
  final bool obscure;

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
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
    if (widget.focusNode == null) _focusNode.dispose();
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Emplacements de largeur raisonnable, plafonnés, rangée centrée.
          const gap = AppSpacing.lg;
          final raw =
              (constraints.maxWidth - (widget.length - 1) * gap) /
              widget.length;
          final slotSize = raw.clamp(0.0, 52.0).toDouble();
          return SizedBox(
            height: 56,
            child: Stack(
              children: [
                // Chiffres + traits visibles — l'état vient du controller.
                Positioned.fill(
                  child: IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < widget.length; i++) ...[
                          if (i > 0) const SizedBox(width: gap),
                          SizedBox(
                            width: slotSize,
                            height: 56,
                            child: _PinSlot(
                              filled: i < text.length,
                              active:
                                  _focusNode.hasFocus &&
                                  i ==
                                      text.length.clamp(0, widget.length - 1) &&
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
                // Champ réel invisible : capte le clavier, les taps et le paste.
                Positioned.fill(
                  child: Semantics(
                    label: text.isEmpty
                        ? 'Code à ${widget.length} chiffres'
                        : 'Code à ${widget.length} chiffres — '
                              '${text.length} saisis',
                    liveRegion: true,
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
          );
        },
      ),
    );
  }
}

/// Un emplacement : chiffre (ou pastille) posé sur un trait souligné discret.
class _PinSlot extends StatelessWidget {
  const _PinSlot({
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
    final underlineColor = hasError
        ? AppColors.errorText
        : active
        ? AppColors.navy
        : filled
        ? AppColors.neutral500
        : AppColors.neutral200;

    final contentColor = hasError ? AppColors.errorText : AppColors.navy;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 42,
          child: Center(
            child: filled
                ? (obscure
                      ? Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: contentColor,
                            shape: BoxShape.circle,
                          ),
                        )
                      : Text(
                          char!,
                          style: AppTypography.title2.copyWith(
                            color: hasError
                                ? AppColors.errorText
                                : AppColors.neutral900,
                            fontFeatures: const [AppTypography.tabular],
                          ),
                        ))
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.emphasized,
          height: active ? 4 : 2.5,
          decoration: BoxDecoration(
            color: underlineColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
