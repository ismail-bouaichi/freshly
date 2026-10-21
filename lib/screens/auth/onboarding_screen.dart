import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/produce.dart';
import '../../core/svg_path.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

/// 01 · Onboarding — produce cluster springs in and floats, copy cascades up.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // (produce, size, x, y, rotation°) in the 390×380 design space.
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

  static const _sparkles = [(64.0, 20.0, 8.0), (340.0, 140.0, 10.0), (30.0, 170.0, 6.0), (330.0, 330.0, 8.0), (190.0, 4.0, 6.0)];

  @override
  Widget build(BuildContext context) {
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
                        Pressable(
                          onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.shell, (_) => false),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Skip',
                              style: ts(15, w: W.semi, c: AppColors.white.withValues(alpha: 0.7)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FittedBox(child: SizedBox(width: 390, height: 380, child: _cluster())),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: staggered(startMs: 950, stepMs: 90, offset: const Offset(0, 26), [
                      Pill(
                        '100% organic · Farm fresh',
                        bg: AppColors.lime.withValues(alpha: 0.12),
                        fg: AppColors.lime,
                        border: AppColors.lime.withValues(alpha: 0.4),
                        icon: AppIcon.leaf,
                        ph: 12,
                        pv: 7,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text.rich(
                          TextSpan(
                            text: 'Fresh groceries,\ndelivered in ',
                            children: [
                              TextSpan(
                                text: '30 min',
                                style: ts(35, w: W.black, c: AppColors.lime),
                              ),
                            ],
                          ),
                          style: ts(35, w: W.black, c: AppColors.white, lh: 42, ls: -1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          'Fruits, vegetables & herbs picked this morning by local farmers — at your door before lunch.',
                          style: ts(15, c: AppColors.white.withValues(alpha: 0.72), lh: 23),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 18, bottom: 18),
                        child: PageDots(count: 3, index: 0, active: AppColors.lime, inactive: AppColors.white.withValues(alpha: 0.3)),
                      ),
                      PrimaryButton(
                        label: 'Start shopping',
                        kind: ButtonStyleKind.lime,
                        onTap: () => Navigator.of(context).pushNamed(Routes.signUp),
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
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cluster() {
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
          child: Entrance(
            delay: const Duration(milliseconds: 200),
            offset: Offset.zero,
            child: Spin(
              period: const Duration(seconds: 40),
              child: DashedCircle(size: 370, color: AppColors.lime.withValues(alpha: 0.3)),
            ),
          ),
        ),
        for (var i = 0; i < _fruits.length; i++)
          Positioned(
            left: _fruits[i].$3,
            top: _fruits[i].$4,
            child: Entrance(
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
                  angle: figmaRot(_fruits[i].$5),
                  child: ProduceArt(_fruits[i].$1, size: _fruits[i].$2),
                ),
              ),
            ),
          ),
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
