import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shimmer maison — un seul AnimationController partagé par sous-arbre via
/// [SkeletonTheme]. Respecte TickerMode (les onglets inactifs de
/// l'IndexedStack des shells ne consomment rien) ; pas de package externe.
class SkeletonTheme extends StatefulWidget {
  const SkeletonTheme({super.key, required this.child});

  final Widget child;

  static Animation<double>? maybeAnimationOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_SkeletonAnimation>()
        ?.animation;
  }

  @override
  State<SkeletonTheme> createState() => _SkeletonThemeState();
}

class _SkeletonThemeState extends State<SkeletonTheme>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SkeletonAnimation(animation: _controller, child: widget.child);
  }
}

class _SkeletonAnimation extends InheritedWidget {
  const _SkeletonAnimation({required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_SkeletonAnimation oldWidget) =>
      animation != oldWidget.animation;
}

/// Bloc scintillant de base. À composer dans des placeholders d'écran.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = AppRadii.field,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final animation = SkeletonTheme.maybeAnimationOf(context);
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    if (animation == null) return box;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        // Pulse triangulaire entre 0.5 et 1.0 d'opacité.
        builder: (context, child) => Opacity(
          opacity: 1 - 0.5 * (animation.value - 0.5).abs() * 2,
          child: child,
        ),
        child: box,
      ),
    );
  }
}

/// Ligne de texte factice.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.width = double.infinity});

  final double width;

  @override
  Widget build(BuildContext context) =>
      SkeletonBox(width: width, height: 14, radius: 7);
}

/// Carte placeholder standard (tuile de liste).
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 72});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(height: height, radius: AppRadii.card);
  }
}

/// Liste de placeholders pour les écrans d'historique/paiements.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 6, this.itemHeight = 72});

  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return SkeletonTheme(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, _) => SkeletonCard(height: itemHeight),
      ),
    );
  }
}
