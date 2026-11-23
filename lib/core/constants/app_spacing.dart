import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Insets
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets card = EdgeInsets.all(12.0);
  static const EdgeInsets post = EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0);
  static const EdgeInsets dialog = EdgeInsets.all(20.0);
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 12.0,
  );
  static const EdgeInsets buttonCompact = EdgeInsets.symmetric(
    horizontal: 14.0,
    vertical: 8.0,
  );
  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 6.0,
  );
}
