import 'package:flutter/material.dart';

/// Breakpoint constants for responsive design
/// - Mobile: < 600dp
/// - Tablet: 600-840dp
/// - Desktop: > 840dp
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 840;

  /// Returns true if the current screen width is in mobile range (< 600dp)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// Returns true if the current screen width is in tablet range (600-840dp)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  /// Returns true if the current screen width is in desktop range (> 840dp)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }

  /// Returns the appropriate number of grid columns based on screen width
  /// - Mobile: 2 columns
  /// - Tablet: 3 columns
  /// - Desktop: 4 columns
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }
}
