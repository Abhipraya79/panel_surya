import 'package:flutter/material.dart';

/// Reusable BorderRadius constants for the Panel Care design system.
class AppRadius {
  AppRadius._();

  static const double _xs = 4.0;
  static const double _sm = 8.0;
  static const double _md = 12.0;
  static const double _lg = 16.0;
  static const double _xl = 20.0;
  static const double _xxl = 28.0;
  static const double _pill = 100.0;

  static BorderRadius get xs => BorderRadius.circular(_xs);
  static BorderRadius get sm => BorderRadius.circular(_sm);
  static BorderRadius get md => BorderRadius.circular(_md);
  static BorderRadius get lg => BorderRadius.circular(_lg);
  static BorderRadius get xl => BorderRadius.circular(_xl);
  static BorderRadius get xxl => BorderRadius.circular(_xxl);
  static BorderRadius get pill => BorderRadius.circular(_pill);

  // Directional helpers
  static BorderRadius topOnly(double radius) => BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      );
  static BorderRadius bottomOnly(double radius) => BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
}
