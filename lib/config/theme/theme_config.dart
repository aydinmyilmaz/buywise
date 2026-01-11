import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'spacing_tokens.dart';
import 'typography_tokens.dart';

class ThemeConfig {
  static ThemeData build({required bool feminine}) {
    final primary = feminine ? ColorTokens.femininePrimary : ColorTokens.masculinePrimary;
    final secondary = feminine ? ColorTokens.feminineSecondary : ColorTokens.masculineSecondary;
    final background = feminine ? ColorTokens.feminineBackground : ColorTokens.masculineBackground;
    final surface = feminine ? ColorTokens.feminineSurface : ColorTokens.masculineSurface;
    final border = feminine ? ColorTokens.feminineBorder : ColorTokens.masculineBorder;

    final baseTextTheme = ThemeData.light().textTheme.apply(
          bodyColor: ColorTokens.textPrimary,
          displayColor: ColorTokens.textPrimary,
          fontFamily: TypographyTokens.fontFamily,
        );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
        outline: border,
        error: ColorTokens.error,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: TypographyTokens.displayLarge,
        headlineMedium: TypographyTokens.headlineMedium,
        titleLarge: TypographyTokens.titleLarge,
        titleMedium: TypographyTokens.titleMedium,
        bodyLarge: TypographyTokens.bodyLarge,
        bodyMedium: TypographyTokens.bodyMedium,
        labelLarge: TypographyTokens.labelLarge,
        labelSmall: TypographyTokens.labelSmall,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ColorTokens.textPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: RadiusTokens.inputRadius,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.inputRadius,
          borderSide: BorderSide(color: primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: ColorTokens.textInverse,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: RadiusTokens.buttonRadius),
          textStyle: TypographyTokens.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.cardRadius,
          side: BorderSide(color: border),
        ),
      ),
    );
  }
}
