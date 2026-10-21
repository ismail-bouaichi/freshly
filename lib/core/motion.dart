import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/app_state.dart';

/// Spring-like overshoot used for "pop" entrances (Figma: GENTLE spring).
const Curve kGentle = Cubic(0.34, 1.45, 0.64, 1);
const Curve kEaseOut = Curves.easeOutCubic;

bool motionReduced(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) == true || (AppScope.maybeRead(context)?.reduceMotion ?? false);

/// One-shot entrance: fade + slide (+ optional scale/rotate pop) after [delay].
/// Mirrors the keyframed entrances designed in Figma.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 550),
    this.offset = const Offset(0, 22),
    this.scale = 1,
    this.rotate = 0,
    this.fade = true,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Starting translation in logical pixels.
  final Offset offset;

  /// Starting scale (1 = none). Uses a spring-like overshoot.
  final double scale;

  /// Starting rotation in degrees (clockwise positive).
  final double rotate;
  final bool fade;

  /// Convenience for staggered lists.
  static Duration step(int i, {int startMs = 0, int stepMs = 60}) => Duration(milliseconds: startMs + i * stepMs);

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration);
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (motionReduced(context)) {
      _c.value = 1;
    } else if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = kEaseOut.transform(_c.value);
        final s = kGentle.transform(_c.value);
        Widget w = child!;
        if (widget.rotate != 0) w = Transform.rotate(angle: (1 - s) * widget.rotate * math.pi / 180, child: w);
        if (widget.scale != 1) w = Transform.scale(scale: widget.scale + (1 - widget.scale) * s, child: w);
        if (widget.offset != Offset.zero) w = Transform.translate(offset: widget.offset * (1 - t), child: w);
        if (widget.fade) w = Opacity(opacity: (_c.value * 1.6).clamp(0.0, 1.0), child: w);
        return w;
      },
    );
  }
}

/// Wraps each child in a staggered [Entrance].
List<Widget> staggered(List<Widget> children, {int startMs = 0, int stepMs = 60, Offset offset = const Offset(0, 22)}) => [
  for (var i = 0; i < children.length; i++)
    Entrance(
      delay: Entrance.step(i, startMs: startMs, stepMs: stepMs),
      offset: offset,
      child: children[i],
    ),
];

/// Endless looping animation helper.
abstract class _Loop extends StatefulWidget {
  const _Loop({super.key, required this.period});
  final Duration period;
}

abstract class _LoopState<T extends _Loop> extends State<T> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: widget.period);
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    if (!motionReduced(context)) c.repeat();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }
}

/// Gentle up/down float (produce bobbing in the Figma motion).
class Bob extends _Loop {
  const Bob({super.key, required this.child, this.amplitude = 6, super.period = const Duration(milliseconds: 2600), this.phase = 0});
  final Widget child;
  final double amplitude;
  final double phase;
  @override
  State<Bob> createState() => _BobState();
}

class _BobState extends _LoopState<Bob> {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    child: widget.child,
    builder: (_, child) =>
        Transform.translate(offset: Offset(0, math.sin((c.value + widget.phase) * 2 * math.pi) * widget.amplitude), child: child),
  );
}

/// Continuous rotation (orbit rings).
class Spin extends _Loop {
  const Spin({super.key, required this.child, super.period = const Duration(seconds: 24), this.reverse = false});
  final Widget child;
  final bool reverse;
  @override
  State<Spin> createState() => _SpinState();
}

class _SpinState extends _LoopState<Spin> {
  @override
  Widget build(BuildContext context) => RotationTransition(turns: widget.reverse ? ReverseAnimation(c) : c, child: widget.child);
}

/// Expanding, fading ring (location pins).
class Pulse extends _Loop {
  const Pulse({super.key, required this.size, required this.color, super.period = const Duration(milliseconds: 1600)});
  final double size;
  final Color color;
  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends _LoopState<Pulse> {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (_, _) {
      final t = Curves.easeOut.transform(c.value);
      return Transform.scale(
        scale: 0.5 + t,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: widget.color.a * (1 - t)),
          ),
        ),
      );
    },
  );
}

/// Opacity twinkle (sparkles).
class Twinkle extends _Loop {
  const Twinkle({super.key, required this.child, super.period = const Duration(milliseconds: 1800), this.phase = 0});
  final Widget child;
  final double phase;
  @override
  State<Twinkle> createState() => _TwinkleState();
}

class _TwinkleState extends _LoopState<Twinkle> {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    child: widget.child,
    builder: (_, child) => Opacity(opacity: 0.35 + 0.65 * (0.5 + 0.5 * math.sin((c.value + widget.phase) * 2 * math.pi)), child: child),
  );
}

/// Breathing scale (halo behind hero produce).
class Breathe extends _Loop {
  const Breathe({super.key, required this.child, this.amount = 0.04, super.period = const Duration(milliseconds: 3200)});
  final Widget child;
  final double amount;
  @override
  State<Breathe> createState() => _BreatheState();
}

class _BreatheState extends _LoopState<Breathe> {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    child: widget.child,
    builder: (_, child) => Transform.scale(scale: 1 + widget.amount * (0.5 - 0.5 * math.cos(c.value * 2 * math.pi)), child: child),
  );
}

/// Shrinks slightly while pressed — tactile feedback for every tappable card.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.96, this.haptic = true});
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapCancel: () => _set(false),
        onTapUp: (_) => _set(false),
        onTap: enabled
            ? () {
                if (widget.haptic) AppScope.maybeRead(context)?.tick();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Animates a money amount between values (totals in cart/checkout).
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney(this.value, {super.key, required this.style});
  final double value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: value),
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeOutCubic,
    builder: (_, v, _) => Text('\$${v.toStringAsFixed(2)}', style: style),
  );
}

/// Bounces its child every time [trigger] changes (cart badge).
class BumpOnChange extends StatefulWidget {
  const BumpOnChange({super.key, required this.trigger, required this.child});
  final Object trigger;
  final Widget child;
  @override
  State<BumpOnChange> createState() => _BumpOnChangeState();
}

class _BumpOnChangeState extends State<BumpOnChange> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));

  @override
  void didUpdateWidget(BumpOnChange old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && !motionReduced(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (_, child) => Transform.scale(scale: 1 + 0.35 * math.sin(_c.value * math.pi), child: child),
  );
}
