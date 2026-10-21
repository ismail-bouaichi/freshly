import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/svg_path.dart';
import '../../core/theme.dart';
import '../../core/vector_art.dart';
import '../../data/app_state.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

/// 10 · Live Tracking — the courier drives the route, ETA counts down.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});
  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with TickerProviderStateMixin {
  static const _start = 0.42; // where the courier is when you open the screen
  static const _totalMinutes = 20.0;

  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  late final AnimationController _drive = AnimationController(vsync: this, duration: const Duration(seconds: 45));
  late final Animation<double> _introT = CurvedAnimation(parent: _intro, curve: Curves.easeInOutCubic);
  bool _init = false;

  double get progress => _intro.isCompleted ? _start + (1 - _start) * _drive.value : _start * _introT.value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    if (motionReduced(context)) {
      _intro.value = 1;
    } else {
      _intro.forward().whenComplete(() {
        if (mounted) _drive.forward();
      });
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _drive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final order = app.lastOrder ?? Catalog.activeOrders.first;
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          return AnimatedBuilder(
            animation: Listenable.merge([_intro, _drive]),
            builder: (context, _) {
              final p = progress;
              final arrived = p >= 0.999;
              final mins = arrived ? 0 : math.max(1, ((1 - p) / (1 - _start) * 12).ceil()).clamp(1, _totalMinutes.toInt());
              return Stack(
                children: [
                  Positioned.fill(bottom: 300, child: _MapView(progress: p)),
                  Positioned(
                    left: 24,
                    right: 24,
                    top: top + 8,
                    child: Entrance(
                      offset: const Offset(0, -14),
                      child: Row(
                        children: [
                          RoundButton(
                            icon: AppIcon.chevronLeft,
                            shadow: true,
                            tooltip: 'Back',
                            onTap: () {
                              final nav = Navigator.of(context);
                              if (nav.canPop()) {
                                nav.pop();
                              } else {
                                nav.pushReplacementNamed(Routes.shell);
                              }
                            },
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: AppShadows.soft,
                            ),
                            child: Row(
                              children: [
                                const Ic(AppIcon.navArrow, size: 16),
                                const SizedBox(width: 6),
                                Text('Live tracking', style: ts(14, w: W.black)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          RoundButton(
                            icon: AppIcon.help,
                            shadow: true,
                            tooltip: 'Help',
                            onTap: () => Navigator.of(context).pushNamed(Routes.help),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Entrance(
                      offset: const Offset(0, 360),
                      fade: false,
                      duration: const Duration(milliseconds: 700),
                      child: _Sheet(order: order, minutes: mins, arrived: arrived, progress: p),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// The illustrated map (same artwork as the Figma map), scaled to cover.
class _MapView extends StatelessWidget {
  const _MapView({required this.progress});
  final double progress;

  static const _vb = Size(390, 560);
  static final _route = parseSvgPath('M70 430V380H170V250H300V150');
  static final ui.PathMetric _metric = _route.computeMetrics().first;

  static final List<VShape> _map = [
    vr(0, 0, 390, 560, fill: const Color(0xFFE9EEE3)),
    vp('M-10 500C80 460 120 530 220 490C300 458 350 430 400 460', stroke: const Color(0xFFBEE3F2), sw: 28),
    vr(186, 266, 98, 98, rx: 18, fill: const Color(0xFFCDE7C5)),
    for (final t in const [
      [210, 292, 11],
      [240, 306, 9],
      [262, 284, 10],
      [220, 336, 10],
      [262, 340, 12],
    ])
      vc(t[0].toDouble(), t[1].toDouble(), t[2].toDouble(), fill: const Color(0xFFA8D69A)),
    for (final b in const [
      [54, 134, 38, 38],
      [118, 196, 40, 44],
      [250, 134, 40, 38],
      [316, 196, 60, 44],
      [54, 264, 40, 40],
      [316, 328, 56, 40],
      [118, 20, 40, 86],
      [250, 20, 40, 86],
    ])
      vr(b[0].toDouble(), b[1].toDouble(), b[2].toDouble(), b[3].toDouble(), rx: 8, fill: const Color(0xFFDCE3D4)),
    vp('M0 185H390M0 315H390M105 0V560M235 0V560', stroke: const Color(0xCCFFFFFF), sw: 7),
    vp('M0 120H390M0 250H390M0 380H390M40 0V560M170 0V560M300 0V560', stroke: const Color(0xFFFFFFFF), sw: 16),
    VShape(_route, stroke: const Color(0x400F3D2E), strokeWidth: 6),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final s = math.max(c.maxWidth / _vb.width, c.maxHeight / _vb.height);
        final dx = (c.maxWidth - _vb.width * s) / 2;
        final dy = (c.maxHeight - _vb.height * s) / 2;
        Offset map(Offset p) => Offset(dx + p.dx * s, dy + p.dy * s);
        final pos = _metric.getTangentForOffset(_metric.length * progress.clamp(0, 1))!.position;
        final courier = map(pos);
        final home = map(const Offset(300, 150));
        final store = map(const Offset(70, 430));
        return ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: dx,
                top: dy,
                child: CustomPaint(
                  size: Size(_vb.width * s, _vb.height * s),
                  painter: VectorPainter(_map, _vb),
                  foregroundPainter: _DonePainter(progress, s),
                ),
              ),
              Positioned(
                left: home.dx - 45,
                top: home.dy - 45,
                child: const SizedBox(
                  width: 90,
                  height: 90,
                  child: Center(child: Pulse(size: 90, color: Color(0x88C8F169))),
                ),
              ),
              Positioned(
                left: home.dx - 24,
                top: home.dy - 24,
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.forest,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lime.withValues(alpha: 0.7), width: 8, strokeAlign: BorderSide.strokeAlignOutside),
                  ),
                  child: const Ic(AppIcon.home, size: 22, color: AppColors.lime),
                ),
              ),
              Positioned(
                left: store.dx - 22,
                top: store.dy - 22,
                child: Entrance(
                  scale: 0.2,
                  offset: Offset.zero,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle, boxShadow: AppShadows.soft),
                    child: const Ic(AppIcon.leaf, size: 20, color: AppColors.leafDark),
                  ),
                ),
              ),
              Positioned(
                left: courier.dx - 26,
                top: courier.dy - 26,
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 4),
                    boxShadow: AppShadows.float,
                  ),
                  child: const Ic(AppIcon.truck, size: 24, color: AppColors.forest),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Solid route from the store to the courier's current position.
class _DonePainter extends CustomPainter {
  _DonePainter(this.progress, this.scale);
  final double progress;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);
    final m = _MapView._metric;
    canvas.drawPath(
      m.extractPath(0, m.length * progress.clamp(0, 1)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.forest,
    );
  }

  @override
  bool shouldRepaint(_DonePainter old) => old.progress != progress || old.scale != scale;
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.order, required this.minutes, required this.arrived, required this.progress});
  final Order order;
  final int minutes;
  final bool arrived;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final steps = [('Packed', 1.0), ('Picked up', 1.0), ('On the way', arrived ? 1.0 : 0.45), ('Delivered', arrived ? 1.0 : 0.0)];
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: AppShadows.float,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arrived ? 'Your courier is' : 'Arriving in',
                      style: ts(13, w: W.medium, c: AppColors.muted),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (c, a) => SlideTransition(
                        position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(a),
                        child: FadeTransition(opacity: a, child: c),
                      ),
                      child: Text(
                        arrived ? 'At your door' : '$minutes min',
                        key: ValueKey(minutes),
                        style: ts(34, w: W.black, ls: -1),
                      ),
                    ),
                  ],
                ),
              ),
              Pill(arrived ? 'Arrived' : 'On the way', icon: arrived ? AppIcon.check : AppIcon.truck, ph: 12, pv: 8),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: i == 2 && !arrived
                            ? const _ShimmerBar()
                            : LinearProgressIndicator(
                                value: steps[i].$2,
                                minHeight: 6,
                                backgroundColor: AppColors.line,
                                valueColor: const AlwaysStoppedAnimation(AppColors.leaf),
                              ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          steps[i].$1,
                          style: ts(11, w: W.bold, c: steps[i].$2 > 0 ? AppColors.ink : AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(22)),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle),
                  child: Text(
                    'YK',
                    style: ts(16, w: W.black, c: AppColors.forest),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Youssef K.', style: ts(15, w: W.bold)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Ic(AppIcon.star, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '4.9 · Your courier',
                            style: ts(12, w: W.medium, c: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                RoundButton(
                  icon: AppIcon.chat,
                  size: 44,
                  iconSize: 20,
                  tooltip: 'Message',
                  onTap: () => showToast(context, 'Opening chat with Youssef…'),
                ),
                const SizedBox(width: 8),
                RoundButton(
                  icon: AppIcon.phone,
                  size: 44,
                  iconSize: 20,
                  bg: AppColors.forest,
                  fg: AppColors.lime,
                  tooltip: 'Call',
                  onTap: () => showToast(context, 'Calling Youssef…'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Ic(AppIcon.package, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${order.items.length} items · ${money(order.total)}', style: ts(14, w: W.bold)),
              ),
              Pressable(
                onTap: () => _receipt(context),
                child: Text(
                  'View receipt',
                  style: ts(13, w: W.bold, c: AppColors.leafDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _receipt(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.paddingOf(c).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 16),
            Text('Receipt ${order.id}', style: ts(20, w: W.black)),
            const SizedBox(height: 12),
            for (final p in order.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ProduceTile(produce: p.art, tint: p.tint, size: 40, artSize: 30, radius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(p.name, style: ts(14, w: W.bold)),
                    ),
                    Text(
                      money(p.price),
                      style: ts(14, w: W.bold, c: AppColors.forest),
                    ),
                  ],
                ),
              ),
            const Divider(height: 24, color: AppColors.line),
            Row(
              children: [
                Expanded(
                  child: Text('Total paid', style: ts(15, w: W.bold)),
                ),
                Text(
                  money(order.total),
                  style: ts(18, w: W.black, c: AppColors.forest),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBar extends StatefulWidget {
  const _ShimmerBar();
  @override
  State<_ShimmerBar> createState() => _ShimmerBarState();
}

class _ShimmerBarState extends State<_ShimmerBar> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!motionReduced(context) && !_c.isAnimating) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => Container(height: 6, color: Color.lerp(AppColors.leaf.withValues(alpha: 0.3), AppColors.leaf, _c.value)),
  );
}
