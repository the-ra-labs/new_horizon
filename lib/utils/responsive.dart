import 'package:flutter/widgets.dart';

enum ScreenType { mobile, tablet, desktop }

class Responsive {
  static const double tabletBreak = 700;
  static const double desktopBreak = 1050;

  static ScreenType of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktopBreak) return ScreenType.desktop;
    if (w >= tabletBreak) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  static bool isMobile(BuildContext c) => of(c) == ScreenType.mobile;
  static bool isDesktop(BuildContext c) => of(c) == ScreenType.desktop;

  /// Content ki max width screen type ke hisab se
  static double maxContentWidth(BuildContext c) => switch (of(c)) {
    ScreenType.mobile => 560.0,
    ScreenType.tablet => 760.0,
    ScreenType.desktop => 1180.0,
  };
}