import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/produce.dart';
import '../../core/svg_path.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

/// 22 · Invite Friends
class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});
  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  static const _code = 'SARA-FRESH';
  static const _link = 'https://freshly.app/invite/SARA-FRESH';
  bool _copied = false;
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  Future<void> _copy(String text, String toast) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    setState(() => _copied = true);
    showToast(context, toast);
    _t?.cancel();
    _t = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: TopBar(title: 'Invite friends'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                children: staggered(stepMs: 70, [
                  const _Hero(),
                  DashedBorder(
                    color: AppColors.leaf,
                    radius: 22,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(22)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your invite code',
                                  style: ts(12, w: W.medium, c: AppColors.muted),
                                ),
                                Text(_code, style: ts(20, w: W.black, ls: 2)),
                              ],
                            ),
                          ),
                          Pressable(
                            onTap: () => _copy(_code, 'Code copied'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: _copied ? AppColors.leaf : AppColors.forest,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Ic(_copied ? AppIcon.check : AppIcon.copy, size: 14, color: AppColors.lime),
                                  const SizedBox(width: 6),
                                  Text(
                                    _copied ? 'Copied' : 'Copy',
                                    style: ts(12, w: W.bold, c: AppColors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final s in [
                        (AppIcon.chat, 'Messages', true),
                        (AppIcon.mail, 'Email', false),
                        (AppIcon.link, 'Copy link', false),
                        (AppIcon.dots, 'More', false),
                      ])
                        Column(
                          children: [
                            RoundButton(
                              icon: s.$1,
                              size: 56,
                              bg: s.$3 ? AppColors.leaf : AppColors.white,
                              fg: s.$3 ? AppColors.white : AppColors.ink,
                              shadow: !s.$3,
                              tooltip: s.$2,
                              onTap: () => _copy(
                                _link,
                                'Invite link copied — paste it in ${s.$2 == 'Copy link' || s.$2 == 'More' ? 'any app' : s.$2}',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(s.$2, style: ts(12, w: W.bold)),
                          ],
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How it works', style: ts(16, w: W.black, ls: -0.3)),
                      const SizedBox(height: 10),
                      for (final (i, t) in const [
                        'Share your code with friends',
                        'They order a basket of \$25+',
                        'You both get \$5 in your wallet',
                      ].indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle),
                                child: Text(
                                  '${i + 1}',
                                  style: ts(12, w: W.black, c: AppColors.forest),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(t, style: ts(14, w: W.medium)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Ic(AppIcon.check, size: 14, color: AppColors.leaf),
                      const SizedBox(width: 6),
                      Text(
                        '3 friends joined · \$15 earned so far',
                        style: ts(13, w: W.bold, c: AppColors.leafDark),
                      ),
                    ],
                  ),
                ]).expand((w) => [w, const SizedBox(height: 16)]).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: PrimaryButton(label: 'Share invite link', onTap: () => _copy(_link, 'Invite link copied')),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: Container(
      height: 212,
      color: AppColors.forest,
      child: LayoutBuilder(
        builder: (context, c) {
          final k = c.maxWidth / 342;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 41 * k,
                top: -110,
                child: Dot(size: 260, color: AppColors.lime.withValues(alpha: 0.08)),
              ),
              for (final (i, f) in const [
                (Produce.strawberry, 54.0, 30.0, 30.0, -14.0),
                (Produce.orange, 56.0, 258.0, 26.0, 10.0),
                (Produce.basil, 44.0, 286.0, 120.0, 18.0),
                (Produce.lemon, 46.0, 14.0, 128.0, -18.0),
              ].indexed)
                Positioned(
                  left: f.$3 * k,
                  top: f.$4,
                  child: Entrance(
                    delay: Duration(milliseconds: 300 + i * 80),
                    scale: 0.3,
                    offset: Offset.zero,
                    child: Bob(
                      phase: i * 0.27,
                      child: Transform.rotate(
                        angle: figmaRot(f.$5),
                        child: ProduceArt(f.$1, size: f.$2),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                top: 24,
                child: Center(
                  child: Entrance(
                    delay: const Duration(milliseconds: 200),
                    scale: 0.3,
                    offset: Offset.zero,
                    child: const _GiftWiggle(
                      child: IconBox(AppIcon.gift, bg: AppColors.lime, fg: AppColors.forest, size: 72, iconSize: 36, radius: 24),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 110,
                child: Column(
                  children: [
                    Text(
                      'Give \$5, get \$5',
                      style: ts(26, w: W.black, c: AppColors.white, ls: -0.6),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Friends save \$5 on their first basket.\nYou get \$5 when it arrives.',
                      textAlign: TextAlign.center,
                      style: ts(13, w: W.medium, c: AppColors.white.withValues(alpha: 0.72), lh: 19),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _GiftWiggle extends StatefulWidget {
  const _GiftWiggle({required this.child});
  final Widget child;
  @override
  State<_GiftWiggle> createState() => _GiftWiggleState();
}

class _GiftWiggleState extends State<_GiftWiggle> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!motionReduced(context) && !_c.isAnimating) _c.repeat();
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
    builder: (_, child) {
      final t = _c.value;
      final a = t < 0.35 ? math.sin(t / 0.35 * math.pi * 4) * 0.2 * (1 - t / 0.35) : 0.0;
      return Transform.rotate(angle: a, child: child);
    },
  );
}
