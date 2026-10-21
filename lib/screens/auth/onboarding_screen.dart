import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/produce.dart';
import '../../core/svg_path.dart';
import '../../core/theme.dart';
import '../../core/vector_art.dart';
import '../../widgets/common.dart';

/// 01 · Onboarding — three swipeable pages (Fresh groceries · Local farms ·
/// Live tracking). Next → Next → Get started, Skip goes to Sign up.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  static const _pages = [
    _PageData(
      badge: '100% organic · Farm fresh',
      badgeIcon: AppIcon.leaf,
      headline: 'Fresh groceries,\ndelivered in ',
      highlight: '30 min',
      sub: 'Fruits, vegetables & herbs picked this morning by local farmers — at your door before lunch.',
    ),
    _PageData(
      badge: 'Local farms · 80 km radius',
      badgeIcon: AppIcon.leaf,
      headline: 'Straight from\n',
      highlight: 'local farms',
      sub: 'Our 120+ partner farms are close by — your basket was growing yesterday.',
    ),
    _PageData(
      badge: 'Live tracking · 30 min delivery',
      badgeIcon: AppIcon.truck,
      headline: 'Track every\nbasket ',
      highlight: 'live',
      sub: 'Watch your courier on the map and get a ping the moment your fresh basket is at the door.',
    ),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _pc.nextPage(duration: const Duration(milliseconds: 520), curve: Curves.easeInOutCubic);
    } else {
      Navigator.of(context).pushNamed(Routes.signUp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.forest,
      body: Stack(
        children: [
          Positioned(right: -110, top: -150, child: Dot(size: 460, color: AppColors.lime.withValues(alpha: 0.07))),
          Positioned(left: -120, bottom: 160, child: Dot(size: 260, color: AppColors.leaf.withValues(alpha: 0.14))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Entrance(
                    offset: const Offset(0, -14),
                    child: Row(
                      children: [
                        const FreshlyLogo(),
                        const Spacer(),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: last ? 0 : 1,
                          child: Pressable(
                            onTap: last ? null : () => Navigator.of(context).pushNamed(Routes.signUp),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                'Skip',
                                style: ts(15, w: W.semi, c: AppColors.white.withValues(alpha: 0.7)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => _Page(index: i, data: _pages[i]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageDots(
                        count: _pages.length,
                        index: _page,
                        active: AppColors.lime,
                        inactive: AppColors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 18),
                      Entrance(
                        delay: const Duration(milliseconds: 1200),
                        offset: const Offset(0, 26),
                        child: PrimaryButton(label: last ? 'Get started' : 'Next', kind: ButtonStyleKind.lime, onTap: _next),
                      ),
                      Pressable(
                        onTap: () => Navigator.of(context).pushNamed(Routes.signIn),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                children: [
                                  TextSpan(
                                    text: 'Sign in',
                                    style: ts(14, w: W.bold, c: AppColors.lime),
                                  ),
                                ],
                              ),
                              style: ts(14, w: W.medium, c: AppColors.white.withValues(alpha: 0.7)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  const _PageData({required this.badge, required this.badgeIcon, required this.headline, required this.highlight, required this.sub});
  final String badge;
  final AppIcon badgeIcon;
  final String headline;
  final String highlight;
  final String sub;
}

class _Page extends StatelessWidget {
  const _Page({required this.index, required this.data});
  final int index;
  final _PageData data;

  @override
  Widget build(BuildContext context) {
    final art = switch (index) {
      0 => const _GroceriesArt(),
      1 => const _FarmsArt(),
      _ => const _TrackingArt(),
    };
    return Column(
      children: [
        Expanded(
          child: FittedBox(
            child: SizedBox(width: 390, height: 380, child: _ClusterFrame(child: art)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: staggered(startMs: index == 0 ? 950 : 150, stepMs: 90, offset: const Offset(0, 26), [
              Pill(
                data.badge,
                bg: AppColors.lime.withValues(alpha: 0.12),
                fg: AppColors.lime,
                border: AppColors.lime.withValues(alpha: 0.4),
                icon: data.badgeIcon,
                ph: 12,
                pv: 7,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      text: data.headline,
                      children: [
                        TextSpan(
                          text: data.highlight,
                          style: ts(35, w: W.black, c: AppColors.lime),
                        ),
                      ],
                    ),
                    style: ts(35, w: W.black, c: AppColors.white, lh: 42, ls: -1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    data.sub,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: ts(15, c: AppColors.white.withValues(alpha: 0.72), lh: 23),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Shared backdrop: forest disc, lime glow, spinning dashed orbit, sparkles.
class _ClusterFrame extends StatelessWidget {
  const _ClusterFrame({required this.child});
  final Widget child;

  static const _sparkles = [(64.0, 20.0, 8.0), (340.0, 140.0, 10.0), (30.0, 170.0, 6.0), (330.0, 330.0, 8.0), (190.0, 4.0, 6.0)];

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 40,
          top: 28,
          child: Entrance(
            scale: 0.55,
            offset: Offset.zero,
            duration: const Duration(milliseconds: 700),
            child: const Dot(size: 310, color: AppColors.forest2),
          ),
        ),
        Positioned(
          left: 85,
          top: 73,
          child: Entrance(
            delay: const Duration(milliseconds: 100),
            scale: 0.4,
            offset: Offset.zero,
            duration: const Duration(milliseconds: 700),
            child: Breathe(child: Dot(size: 220, color: AppColors.lime.withValues(alpha: 0.09))),
          ),
        ),
        Positioned(
          left: 10,
          top: -2,
          child: Spin(
            period: const Duration(seconds: 40),
            child: DashedCircle(size: 370, color: AppColors.lime.withValues(alpha: 0.3)),
          ),
        ),
        Positioned.fill(child: child),
        for (var i = 0; i < _sparkles.length; i++)
          Positioned(
            left: _sparkles[i].$1,
            top: _sparkles[i].$2,
            child: Entrance(
              delay: Duration(milliseconds: 900 + i * 150),
              scale: 0,
              offset: Offset.zero,
              child: Twinkle(
                phase: i * 0.21,
                child: Dot(size: _sparkles[i].$3, color: AppColors.lime.withValues(alpha: 0.9)),
              ),
            ),
          ),
      ],
    );
  }
}

/// A produce item that springs in, then floats.
class _Fruit extends StatelessWidget {
  const _Fruit(this.i, this.produce, this.size, this.rot);
  final int i;
  final Produce produce;
  final double size;
  final double rot;

  @override
  Widget build(BuildContext context) => Entrance(
    delay: Duration(milliseconds: 250 + i * 80),
    duration: const Duration(milliseconds: 750),
    scale: 0.3,
    rotate: i.isOdd ? 18 : -18,
    offset: const Offset(0, 36),
    child: Bob(
      amplitude: 6,
      phase: i * 0.17,
      period: Duration(milliseconds: 2600 + i * 120),
      child: Transform.rotate(
        angle: figmaRot(rot),
        child: ProduceArt(produce, size: size),
      ),
    ),
  );
}

Widget _place(double x, double y, Widget child) => Positioned(left: x, top: y, child: child);

/// Page 1 — the produce cluster around an avocado.
class _GroceriesArt extends StatelessWidget {
  const _GroceriesArt();

  static const _fruits = [
    (Produce.apple, 74.0, 196.0, 8.0, 8.0),
    (Produce.orange, 118.0, 250.0, 34.0, 0.0),
    (Produce.strawberry, 108.0, 26.0, 30.0, 14.0),
    (Produce.lemon, 98.0, 262.0, 164.0, -16.0),
    (Produce.carrot, 118.0, 6.0, 200.0, 28.0),
    (Produce.tomato, 80.0, 268.0, 270.0, 0.0),
    (Produce.basil, 84.0, 78.0, 262.0, 12.0),
    (Produce.broccoli, 96.0, 160.0, 252.0, 0.0),
    (Produce.avocado, 160.0, 115.0, 86.0, -8.0),
  ];

  @override
  Widget build(BuildContext context) =>
      Stack(clipBehavior: Clip.none, children: [for (final (i, f) in _fruits.indexed) _place(f.$3, f.$4, _Fruit(i, f.$1, f.$2, f.$5))]);
}

/// Page 2 — farmer card with harvest and rating chips.
class _FarmsArt extends StatelessWidget {
  const _FarmsArt();

  static const _fruits = [
    (Produce.basil, 80.0, 296.0, 14.0, -14.0),
    (Produce.carrot, 92.0, 14.0, 176.0, 28.0),
    (Produce.tomato, 74.0, 300.0, 214.0, 0.0),
    (Produce.broccoli, 80.0, 206.0, 292.0, 0.0),
    (Produce.apple, 64.0, 40.0, 40.0, 10.0),
  ];

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      for (final (i, f) in _fruits.indexed) _place(f.$3, f.$4, _Fruit(i, f.$1, f.$2, f.$5)),
      _place(
        62,
        112,
        Entrance(
          delay: const Duration(milliseconds: 150),
          duration: const Duration(milliseconds: 750),
          offset: const Offset(0, 60),
          rotate: -10,
          child: Transform.rotate(angle: figmaRot(5), child: const _FarmCard()),
        ),
      ),
      _place(
        178,
        62,
        Entrance(
          delay: const Duration(milliseconds: 600),
          scale: 0.4,
          offset: Offset.zero,
          child: Transform.rotate(angle: figmaRot(-6), child: const _Chip('Harvested 6:00 AM', AppIcon.clock, lime: true)),
        ),
      ),
      _place(
        40,
        296,
        Entrance(
          delay: const Duration(milliseconds: 750),
          scale: 0.4,
          offset: Offset.zero,
          child: Transform.rotate(angle: figmaRot(4), child: const _Chip('4.9 farm rating', AppIcon.star)),
        ),
      ),
    ],
  );
}

class _FarmCard extends StatelessWidget {
  const _FarmCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(28), boxShadow: AppShadows.float),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle),
              child: Text(
                'FY',
                style: ts(15, w: W.black, c: AppColors.forest),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farmer Youssef',
                  style: ts(15, w: W.bold),
                  textScaler: TextScaler.noScaling,
                ),
                Text(
                  '12 km away · Organic',
                  style: ts(12, w: W.medium, c: AppColors.muted),
                  textScaler: TextScaler.noScaling,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (p, tint) in const [
              (Produce.carrot, AppColors.tintOrange),
              (Produce.tomato, AppColors.tintBerry),
              (Produce.broccoli, AppColors.tintLeaf),
            ]) ...[
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: ProduceArt(p, size: 36),
              ),
              const SizedBox(width: 8),
            ],
            const Pill('Picked today', icon: AppIcon.leaf),
          ],
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip(this.text, this.icon, {this.lime = false});
  final String text;
  final AppIcon icon;
  final bool lime;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
    decoration: BoxDecoration(
      color: lime ? AppColors.lime : AppColors.white,
      borderRadius: BorderRadius.circular(999),
      boxShadow: AppShadows.soft,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Ic(icon, size: 14, color: lime ? AppColors.forest : AppColors.ink),
        const SizedBox(width: 6),
        Text(
          text,
          style: ts(12, w: W.black, c: lime ? AppColors.forest : AppColors.ink),
          textScaler: TextScaler.noScaling,
        ),
      ],
    ),
  );
}

/// Page 3 — mini live map with a driving courier, plus a notification.
class _TrackingArt extends StatelessWidget {
  const _TrackingArt();

  static const _fruits = [
    (Produce.orange, 84.0, 8.0, 34.0, 0.0),
    (Produce.strawberry, 70.0, 312.0, 46.0, -12.0),
    (Produce.lemon, 70.0, 12.0, 250.0, 16.0),
    (Produce.avocado, 92.0, 296.0, 232.0, -8.0),
  ];

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      for (final (i, f) in _fruits.indexed) _place(f.$3, f.$4, _Fruit(i, f.$1, f.$2, f.$5)),
      _place(
        60,
        72,
        Entrance(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 750),
          scale: 0.8,
          rotate: 8,
          offset: Offset.zero,
          child: Transform.rotate(angle: figmaRot(-4), child: const _MiniMap()),
        ),
      ),
      _place(
        92,
        292,
        Entrance(
          delay: const Duration(milliseconds: 900),
          offset: const Offset(0, 50),
          child: Transform.rotate(angle: figmaRot(3), child: const _Notification()),
        ),
      ),
    ],
  );
}

class _MiniMap extends StatefulWidget {
  const _MiniMap();
  @override
  State<_MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends State<_MiniMap> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 5200));
  bool _init = false;

  static final _route = parseSvgPath('M50 150V140H140V72H230V44');
  static final ui.PathMetric _metric = _route.computeMetrics().first;

  static final List<VShape> _map = [
    vr(0, 0, 270, 200, fill: const Color(0xFFE9EEE3)),
    vp('M-10 175C50 150 90 190 150 168C200 150 240 140 280 158', stroke: const Color(0xFFBEE3F2), sw: 18),
    vr(150, 84, 64, 52, rx: 12, fill: const Color(0xFFCDE7C5)),
    vc(168, 102, 7, fill: const Color(0xFFA8D69A)),
    vc(194, 118, 8, fill: const Color(0xFFA8D69A)),
    vr(30, 30, 34, 30, rx: 7, fill: const Color(0xFFDCE3D4)),
    vr(200, 20, 44, 34, rx: 7, fill: const Color(0xFFDCE3D4)),
    vr(30, 96, 34, 34, rx: 7, fill: const Color(0xFFDCE3D4)),
    vp('M0 72H270M0 140H270M80 0V200M140 0V200M230 0V200', stroke: const Color(0xFFFFFFFF), sw: 11),
    VShape(_route, stroke: const Color(0x400F3D2E), strokeWidth: 5),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    if (motionReduced(context)) {
      _c.value = 0.45;
    } else {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 270,
        height: 200,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            // Drive for 75% of the loop, then wait at the door.
            final t = Curves.easeInOutCubic.transform((_c.value / 0.75).clamp(0.0, 1.0));
            final pos = _metric.getTangentForOffset(_metric.length * t)!.position;
            final arrived = t >= 0.999;
            final mins = math.max(1, ((1 - t) * 12).ceil());
            return Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(size: const Size(270, 200), painter: VectorPainter(_map, const Size(270, 200)), foregroundPainter: _Done(t)),
                const Positioned(
                  left: 200,
                  top: 14,
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Center(child: Pulse(size: 60, color: Color(0x88C8F169))),
                  ),
                ),
                Positioned(
                  left: 211,
                  top: 25,
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    child: const Ic(AppIcon.home, size: 18, color: AppColors.lime),
                  ),
                ),
                Positioned(
                  left: pos.dx - 22,
                  top: pos.dy - 22,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 4),
                      boxShadow: AppShadows.float,
                    ),
                    child: const Ic(AppIcon.truck, size: 20, color: AppColors.forest),
                  ),
                ),
                Positioned(
                  left: 96,
                  top: 150,
                  child: _Chip(arrived ? 'At your door' : '$mins min away', arrived ? AppIcon.check : AppIcon.clock),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Done extends CustomPainter {
  _Done(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final m = _MiniMapState._metric;
    canvas.drawPath(
      m.extractPath(0, m.length * t),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.forest,
    );
  }

  @override
  bool shouldRepaint(_Done old) => old.t != t;
}

class _Notification extends StatelessWidget {
  const _Notification();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.float),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const IconBox(AppIcon.bell, bg: AppColors.lime, fg: AppColors.forest, size: 38, iconSize: 18, radius: 12),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Courier nearby',
              style: ts(13, w: W.bold),
              textScaler: TextScaler.noScaling,
            ),
            Text(
              'Your basket arrives in 5 min',
              style: ts(11, w: W.medium, c: AppColors.muted),
              textScaler: TextScaler.noScaling,
            ),
          ],
        ),
      ],
    ),
  );
}
