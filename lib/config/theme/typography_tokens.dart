import 'package:flutter/material.dart';

class TypographyTokens {
  static const String fontFamily = 'Inter';

  static const double sizeXs = 12.0;
  static const double sizeSm = 14.0;
  static const double sizeMd = 16.0;
  static const double sizeLg = 18.0;
  static const double sizeXl = 20.0;
  static const double size2xl = 24.0;
  static const double size3xl = 32.0;
  static const double size4xl = 40.0;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.7;

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: size3xl,
    fontWeight: bold,
    height: lineHeightTight,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: size2xl,
    fontWeight: semiBold,
    height: lineHeightTight,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeXl,
    fontWeight: semiBold,
    height: lineHeightNormal,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeLg,
    fontWeight: semiBold,
    height: lineHeightNormal,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeMd,
    fontWeight: regular,
    height: lineHeightRelaxed,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeSm,
    fontWeight: regular,
    height: lineHeightNormal,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeMd,
    fontWeight: semiBold,
    height: lineHeightNormal,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: sizeXs,
    fontWeight: medium,
    height: lineHeightNormal,
  );
}
