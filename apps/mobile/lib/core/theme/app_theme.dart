import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Thème clair Fusy. Thème clair uniquement (pas de dark mode au MVP).
abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.navy,
      onPrimary: AppColors.white,
      secondary: AppColors.green,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.neutral900,
      error: AppColors.errorText,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.neutral50,
      textTheme: AppTypography.textTheme,
      dividerColor: AppColors.neutral200,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.neutral50,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.title3,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.navy,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppTypography.label.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                )
              : AppTypography.label.copyWith(color: AppColors.neutral500),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.onNavy
                : AppColors.neutral500,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.neutral900,
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadowNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          borderSide: const BorderSide(color: AppColors.errorText),
        ),
      ),
    );
  }
}
