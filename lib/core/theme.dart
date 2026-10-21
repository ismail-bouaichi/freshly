import 'package:flutter/material.dart';

/// Design tokens mirrored from the "Freshly Colors" variables in Figma.
abstract final class AppColors {
  static const forest = Color(0xFF0F3D2E);
  static const forest2 = Color(0xFF185A43);
  static const leaf = Color(0xFF2BB673);
  static const leafDark = Color(0xFF1E8A4F);
  static const lime = Color(0xFFC8F169);
  static const cream = Color(0xFFF6F4EC);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF13231B);
  static const muted = Color(0xFF7C8B82);
  static const line = Color(0xFFE7E4D8);
  static const tangerine = Color(0xFFFF8A3D);
  static const berry = Color(0xFFE9445A);
  static const lemon = Color(0xFFFFD43B);
  static const gold = Color(0xFFFFB020);

  static const tintBerry = Color(0xFFFDE7EA);
  static const tintLeaf = Color(0xFFE3F6EA);
  static const tintOrange = Color(0xFFFFEDE0);
  static const tintLemon = Color(0xFFFFF6CF);
  static const tintLime = Color(0xFFEEF8D8);
  static const tintMint = Color(0xFFDDF3EC);
}

/// "Elevation/Soft" and "Elevation/Float" effect styles.
abstract final class AppShadows {
  static const soft = [BoxShadow(color: Color(0x140F3D2E), offset: Offset(0, 10), blurRadius: 24)];
  static const float = [BoxShadow(color: Color(0x470F3D2E), offset: Offset(0, 18), blurRadius: 36, spreadRadius: -6)];
}

const kFont = 'PlusJakartaSans';

/// Typography helper. [lh] is a line height in pixels, like in Figma.
TextStyle ts(double size, {FontWeight w = FontWeight.w400, Color c = AppColors.ink, double? ls, double? lh, TextDecoration? deco}) {
  return TextStyle(
    fontFamily: kFont,
    fontSize: size,
    fontWeight: w,
    color: c,
    letterSpacing: ls,
    height: lh == null ? null : lh / size,
    decoration: deco,
    decorationColor: c,
  );
}

abstract final class W {
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semi = FontWeight.w600;
  static const bold = FontWeight.w700;
  static const black = FontWeight.w800;
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.leaf,
    primary: AppColors.forest,
    onPrimary: AppColors.white,
    secondary: AppColors.lime,
    onSecondary: AppColors.forest,
    surface: AppColors.cream,
    onSurface: AppColors.ink,
    error: AppColors.berry,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: kFont,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.cream,
    splashFactory: InkRipple.splashFactory,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.leaf,
      selectionColor: Color(0x552BB673),
      selectionHandleColor: AppColors.leaf,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.forest,
      contentTextStyle: ts(14, w: W.semi, c: AppColors.white),
      actionTextColor: AppColors.lime,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: ts(20, w: W.black),
      contentTextStyle: ts(14, c: AppColors.muted, lh: 21),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.leaf,
      inactiveTrackColor: AppColors.line,
      thumbColor: AppColors.white,
      overlayColor: Color(0x222BB673),
      trackHeight: 4,
      rangeThumbShape: RoundRangeSliderThumbShape(enabledThumbRadius: 12, elevation: 3),
      showValueIndicator: ShowValueIndicator.never,
    ),
  );
}
