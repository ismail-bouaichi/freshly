import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/produce.dart';
import '../../core/svg_path.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

/// 09 · Order Placed — check draws itself, produce bursts from the badge,
/// confetti tumbles down.
class OrderPlacedScreen extends StatelessWidget {
  const OrderPlacedScreen({super.key});

  // (produce, size, x, y, rotation°) in the 390-wide design.
  static const _burst = [
    (Produce.strawberry, 72.0, 26.0, 140.0, 20.0),
    (Produce.lemon, 66.0, 300.0, 150.0, -20.0),
    (Produce.basil, 64.0, 40.0, 340.0, -15.0),
    (Produce.orange, 66.0, 290.0, 330.0, 0.0),
    (Produce.apple, 52.0, 170.0, 84.0, 8.0),
    (Produce.carrot, 60.0, 186.0, 380.0, 35.0),
  ];

  static const _confetti = [
    (AppColors.berry, 110.0, 120.0, 10.0, 18.0, 25.0),
    (AppColors.lemon, 268.0, 110.0, 12.0, 12.0, 0.0),
    (AppColors.lime, 330.0, 270.0, 8.0, 16.0, -30.0),
    (AppColors.tangerine, 70.0, 270.0, 12.0, 8.0, 15.0),
    (AppColors.white, 240.0, 400.0, 8.0, 8.0, 0.0),
    (AppColors.berry, 330.0, 410.0, 9.0, 15.0, 40.0),
    (AppColors.lemon, 120.0, 420.0, 10.0, 18.0, -20.0),
    (AppColors.lime, 60.0, 210.0, 6.0, 6.0, 0.0),
  ];

  void _home(BuildContext context) => Navigator.of(context).popUntil(ModalRoute.withName(Routes.shell));

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final order = app.lastOrder ?? Catalog.activeOrders.first;
    return Scaffold(
      backgroundColor: AppColors.forest,
      body: Stack(
        children: [
          Positioned(left: -35, top: 40, child: Dot(size: 460, color: AppColors.lime.withValues(alpha: 0.06))),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: RoundButton(
                      icon: AppIcon.x,
                      bg: AppColors.white.withValues(alpha: 0.12),
                      fg: AppColors.white,
                      size: 44,
                      iconSize: 20,
                      tooltip: 'Close',
                      onTap: () => _home(context),
                    ),
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    child: SizedBox(
                      width: 390,
                      height: 400,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 40,
                            top: 50,
                            child: Entrance(
                              delay: const Duration(milliseconds: 250),
                              scale: 0.4,
                              offset: Offset.zero,
                              duration: const Duration(milliseconds: 800),
                              child: Breathe(amount: 0.06, child: Dot(size: 310, color: AppColors.lime.withValues(alpha: 0.06))),
                            ),
                          ),
                          Positioned(
                            left: 80,
                            top: 90,
                            child: Entrance(
                              delay: const Duration(milliseconds: 150),
                              scale: 0.4,
                              offset: Offset.zero,
                              duration: const Duration(milliseconds: 800),
                              child: Breathe(amount: 0.08, child: Dot(size: 230, color: AppColors.lime.withValues(alpha: 0.12))),
                            ),
                          ),
                          for (final (i, b) in _burst.indexed)
                            Positioned(
                              left: b.$3,
                              top: b.$4 - 56,
                              child: Entrance(
                                delay: Duration(milliseconds: 350 + i * 50),
                                duration: const Duration(milliseconds: 800),
                                offset: Offset(195 - (b.$3 + b.$2 / 2), 209 - (b.$4 - 56 + b.$2 / 2)),
                                scale: 0.2,
                                child: Bob(
                                  amplitude: 6,
                                  phase: i * 0.2,
                                  child: Transform.rotate(
                                    angle: figmaRot(b.$5),
                                    child: ProduceArt(b.$1, size: b.$2),
                                  ),
                                ),
                              ),
                            ),
                          for (final (i, c) in _confetti.indexed)
                            Positioned(
                              left: c.$2,
                              top: c.$3 - 56,
                              child: Entrance(
                                delay: Duration(milliseconds: 500 + i * 60),
                                duration: const Duration(milliseconds: 1400),
                                offset: const Offset(0, -60),
                                rotate: i.isOdd ? 180 : -180,
                                child: Transform.rotate(
                                  angle: figmaRot(c.$6),
                                  child: Container(
                                    width: c.$4,
                                    height: c.$5,
                                    decoration: BoxDecoration(color: c.$1, borderRadius: BorderRadius.circular(3)),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            left: 120,
                            top: 134,
                            child: Entrance(
                              scale: 0,
                              rotate: -30,
                              offset: Offset.zero,
                              duration: const Duration(milliseconds: 700),
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle, boxShadow: AppShadows.float),
                                alignment: Alignment.center,
                                child: const _DrawCheck(size: 72),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Column(
                    children: staggered(startMs: 800, stepMs: 80, offset: const Offset(0, 26), [
                      Text(
                        'Order placed!',
                        style: ts(32, w: W.black, c: AppColors.white, ls: -0.8),
                      ),
                      Text(
                        "Farmer Youssef is packing your basket.\nIt'll be at your door ${order.when.toLowerCase().startsWith('today') ? 'today' : 'soon'}.",
                        textAlign: TextAlign.center,
                        style: ts(15, c: AppColors.white.withValues(alpha: 0.72), lh: 23),
                      ),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: AppColors.forest2, borderRadius: BorderRadius.circular(24)),
                        child: Column(
                          children: [
                            _row('Order', order.id),
                            const SizedBox(height: 12),
                            _row('Arriving', order.when),
                            const SizedBox(height: 12),
                            _row('Paid', '${money(order.total)} · ${app.lastPayment}'),
                          ],
                        ),
                      ),
                      PrimaryButton(
                        label: 'Track my order',
                        kind: ButtonStyleKind.lime,
                        onTap: () => Navigator.of(context).pushReplacementNamed(Routes.tracking),
                      ),
                      Pressable(
                        onTap: () => _home(context),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            'Back to home',
                            style: ts(14, w: W.bold, c: AppColors.lime),
                          ),
                        ),
                      ),
                    ]).expand((w) => [w, const SizedBox(height: 12)]).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String l, String v) => Row(
    children: [
      Text(
        l,
        style: ts(14, w: W.medium, c: AppColors.white.withValues(alpha: 0.6)),
      ),
      const Spacer(),
      Flexible(
        child: Text(
          v,
          textAlign: TextAlign.right,
          style: ts(14, w: W.bold, c: AppColors.white),
        ),
      ),
    ],
  );
}

/// A check mark that draws itself.
class _DrawCheck extends StatefulWidget {
  const _DrawCheck({required this.size});
  final double size;
  @override
  State<_DrawCheck> createState() => _DrawCheckState();
}

class _DrawCheckState extends State<_DrawCheck> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    if (motionReduced(context)) {
      _c.value = 1;
    } else {
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => CustomPaint(size: Size.square(widget.size), painter: _CheckPainter(Curves.easeOutCubic.transform(_c.value))),
  );
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.t);
  final double t;
  // Drawn from the short stroke to the long one, like a hand-drawn tick.
  static final _metric = parseSvgPath('M4 12l5 5L20 6').computeMetrics().first;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    canvas.scale(size.width / 24);
    final m = _metric;
    canvas.drawPath(
      m.extractPath(0, m.length * t),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.forest,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.t != t;
}
