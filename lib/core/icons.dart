import 'package:flutter/widgets.dart';

import 'svg_path.dart';
import 'theme.dart';
import 'vector_art.dart';

/// The Freshly icon set (24×24, 2px round strokes) — same paths as the
/// `Icon/*` components in the Figma file.
enum AppIcon {
  search,
  bell,
  pin,
  heart,
  heartFill,
  plus,
  minus,
  home,
  grid,
  bag,
  user,
  star,
  chevronLeft,
  chevronRight,
  chevronDown,
  arrowRight,
  clock,
  leaf,
  truck,
  sliders,
  trash,
  check,
  flame,
  drop,
  ticket,
  mail,
  lock,
  eye,
  eyeOff,
  card,
  phone,
  chat,
  settings,
  gift,
  logout,
  wallet,
  cash,
  repeat,
  receipt,
  help,
  navArrow,
  package,
  x,
  sparkle,
  camera,
  calendar,
  briefcase,
  pencil,
  moon,
  link,
  dots,
  globe,
  shield,
  sun,
  copy,
}

VShape _s(String d) => VShape(parseSvgPath(d), tintStroke: true, strokeWidth: 2);
VShape _f(String d) => VShape(parseSvgPath(d), tintFill: true);
VShape _sc(double cx, double cy, double r) =>
    VShape(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)), tintStroke: true, strokeWidth: 2);
VShape _fc(double cx, double cy, double r) => VShape(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)), tintFill: true);
VShape _sr(double x, double y, double w, double h, double rx) =>
    VShape(Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(rx))), tintStroke: true, strokeWidth: 2);

const _heart =
    'M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z';

List<VShape> _build(AppIcon i) => switch (i) {
  AppIcon.search => [_sc(11, 11, 7), _s('M20 20l-3.5-3.5')],
  AppIcon.bell => [_s('M6 8a6 6 0 1 1 12 0c0 7 3 9 3 9H3s3-2 3-9'), _s('M10.3 21a1.94 1.94 0 0 0 3.4 0')],
  AppIcon.pin => [_s('M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z'), _sc(12, 10, 3)],
  AppIcon.heart => [_s(_heart)],
  AppIcon.heartFill => [_f(_heart)],
  AppIcon.plus => [_s('M12 5v14M5 12h14')],
  AppIcon.minus => [_s('M5 12h14')],
  AppIcon.home => [_s('M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1Z')],
  AppIcon.grid => [_sr(3, 3, 7, 7, 2), _sr(14, 3, 7, 7, 2), _sr(3, 14, 7, 7, 2), _sr(14, 14, 7, 7, 2)],
  AppIcon.bag => [_s('M6 7h12l1.2 12.1A2 2 0 0 1 17.2 21H6.8a2 2 0 0 1-2-1.9Z'), _s('M9 10V6a3 3 0 0 1 6 0v4')],
  AppIcon.user => [_sc(12, 8, 4), _s('M4 21a8 8 0 0 1 16 0')],
  AppIcon.star => [
    VShape(parseSvgPath('M12 2.5l2.9 6.1 6.6.8-4.9 4.6 1.3 6.6L12 17.3l-5.9 3.3 1.3-6.6L2.5 9.4l6.6-.8Z'), fill: AppColors.gold),
  ],
  AppIcon.chevronLeft => [_s('m15 18-6-6 6-6')],
  AppIcon.chevronRight => [_s('m9 18 6-6-6-6')],
  AppIcon.chevronDown => [_s('m6 9 6 6 6-6')],
  AppIcon.arrowRight => [_s('M5 12h14M13 6l6 6-6 6')],
  AppIcon.clock => [_sc(12, 12, 9), _s('M12 7v5l3 2')],
  AppIcon.leaf => [
    _s('M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z'),
    _s('M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12'),
  ],
  AppIcon.truck => [
    _s('M14 18V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v11a1 1 0 0 0 1 1h2'),
    _s('M15 18H9'),
    _s('M19 18h2a1 1 0 0 0 1-1v-3.65a1 1 0 0 0-.22-.62l-3.48-4.35A1 1 0 0 0 17.52 8H14'),
    _sc(17, 18, 2),
    _sc(7, 18, 2),
  ],
  AppIcon.sliders => [_s('M4 6h10M18 6h2M4 12h4M12 12h8M4 18h12'), _sc(16, 6, 2), _sc(10, 12, 2), _sc(18, 18, 2)],
  AppIcon.trash => [_s('M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6')],
  AppIcon.check => [_s('M20 6 9 17l-5-5')],
  AppIcon.flame => [
    _s(
      'M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.07-2.14-.22-4.05 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.15.43-2.29 1-3a2.5 2.5 0 0 0 2.5 2.5Z',
    ),
  ],
  AppIcon.drop => [_s('M12 22a7 7 0 0 0 7-7c0-2-1-3.9-3-5.5s-3.5-4-4-6.5c-.5 2.5-2 4.9-4 6.5C6 11.1 5 13 5 15a7 7 0 0 0 7 7Z')],
  AppIcon.ticket => [
    _s('M3 9a3 3 0 0 0 0 6v3a1 1 0 0 0 1 1h16a1 1 0 0 0 1-1v-3a3 3 0 0 1 0-6V6a1 1 0 0 0-1-1H4a1 1 0 0 0-1 1Z'),
    _s('M13 5v2M13 17v2M13 11v2'),
  ],
  AppIcon.mail => [_sr(3, 5, 18, 14, 3), _s('m3 7 9 6 9-6')],
  AppIcon.lock => [_sr(4, 11, 16, 10, 3), _s('M8 11V7a4 4 0 0 1 8 0v4')],
  AppIcon.eye => [_s('M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z'), _sc(12, 12, 3)],
  AppIcon.eyeOff => [
    _s(
      'M10.7 5.1A10.4 10.4 0 0 1 12 5c6.5 0 10 7 10 7a17.6 17.6 0 0 1-3.2 4.2M6.6 6.6A17.4 17.4 0 0 0 2 12s3.5 7 10 7a9.6 9.6 0 0 0 5.4-1.6M9.9 9.9a3 3 0 0 0 4.2 4.2M2 2l20 20',
    ),
  ],
  AppIcon.card => [_sr(2, 5, 20, 14, 3), _s('M2 10h20M6 15h4')],
  AppIcon.phone => [
    _s(
      'M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1 1 .4 1.9.7 2.8a2 2 0 0 1-.5 2.1L8 9.9a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.4c.9.3 1.8.6 2.8.7a2 2 0 0 1 1.7 2Z',
    ),
  ],
  AppIcon.chat => [_s('M21 12a8 8 0 0 1-11.6 7.1L3 21l1.9-6.4A8 8 0 1 1 21 12Z')],
  AppIcon.settings => [
    _sc(12, 12, 3),
    _s(
      'M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1Z',
    ),
  ],
  AppIcon.gift => [
    _sr(3, 8, 18, 4, 1),
    _s('M12 8v13M19 12v7a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-7M7.5 8a2.5 2.5 0 0 1 0-5C11 3 12 8 12 8s1-5 4.5-5a2.5 2.5 0 0 1 0 5'),
  ],
  AppIcon.logout => [_s('M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9')],
  AppIcon.wallet => [_s('M19 7V5a2 2 0 0 0-2-2H5a2 2 0 0 0 0 4h14a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5'), _s('M17 14h.01')],
  AppIcon.cash => [_sr(2, 6, 20, 12, 3), _sc(12, 12, 2.5), _s('M6 12h.01M18 12h.01')],
  AppIcon.repeat => [_s('m17 2 4 4-4 4'), _s('M3 11v-1a4 4 0 0 1 4-4h14M7 22l-4-4 4-4'), _s('M21 13v1a4 4 0 0 1-4 4H3')],
  AppIcon.receipt => [_s('M4 2v20l3-2 3 2 2-2 2 2 3-2 3 2V2l-3 2-3-2-2 2-2-2-3 2Z'), _s('M8 8h8M8 12h8M8 16h5')],
  AppIcon.help => [_sc(12, 12, 9), _s('M9.1 9a3 3 0 0 1 5.8 1c0 2-3 3-3 3M12 17h.01')],
  AppIcon.navArrow => [_s('m3 11 19-9-9 19-2-8Z')],
  AppIcon.package => [_s('M21 8 12 3 3 8v8l9 5 9-5Z'), _s('M3 8l9 5 9-5M12 13v8')],
  AppIcon.x => [_s('M18 6 6 18M6 6l12 12')],
  AppIcon.sparkle => [_s('M12 3v4M12 17v4M3 12h4M17 12h4M6 6l2.5 2.5M15.5 15.5 18 18M6 18l2.5-2.5M15.5 8.5 18 6')],
  AppIcon.camera => [_s('M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3Z'), _sc(12, 13, 3.5)],
  AppIcon.calendar => [_sr(3, 4, 18, 18, 3), _s('M16 2v4M8 2v4M3 10h18')],
  AppIcon.briefcase => [_sr(2, 7, 20, 14, 3), _s('M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16')],
  AppIcon.pencil => [_s('M17 3a2.8 2.8 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z')],
  AppIcon.moon => [_s('M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z')],
  AppIcon.link => [
    _s('M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71'),
    _s('M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71'),
  ],
  AppIcon.dots => [_fc(5, 12, 1.6), _fc(12, 12, 1.6), _fc(19, 12, 1.6)],
  AppIcon.globe => [_sc(12, 12, 9), _s('M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18')],
  AppIcon.shield => [_s('M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z')],
  AppIcon.sun => [_sc(12, 12, 4), _s('M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4')],
  AppIcon.copy => [_sr(9, 9, 12, 12, 3), _s('M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1')],
};

final Map<AppIcon, List<VShape>> _cache = {};
List<VShape> iconShapes(AppIcon i) => _cache.putIfAbsent(i, () => _build(i));

/// An icon from the Freshly set.
class Ic extends StatelessWidget {
  const Ic(this.icon, {super.key, this.size = 24, this.color = AppColors.ink});

  final AppIcon icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => VectorArt(iconShapes(icon), viewBox: const Size(24, 24), width: size, tint: color);
}
