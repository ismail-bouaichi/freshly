import 'dart:async';

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
import '../../widgets/shop.dart';
import '../shell.dart';

/// 02 · Home
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final shell = ShellScope.of(context);
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...staggered(stepMs: 70, [
              _Header(app: app),
              Text.rich(
                TextSpan(
                  text: 'Hello ${app.firstName},\nwhat\'s ',
                  children: [
                    TextSpan(
                      text: 'fresh',
                      style: ts(30, w: W.black, c: AppColors.leaf, ls: -0.8),
                    ),
                    const TextSpan(text: ' today?'),
                  ],
                ),
                style: ts(30, w: W.black, ls: -0.8, lh: 36),
              ),
              const SearchLauncher(heroTag: 'search-home'),
              const PromoCarousel(),
              SectionHeader('Categories', action: 'See all', onAction: () => shell.goTab(1)),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: Category.values.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final c = Category.values[i];
                    return Entrance(
                      delay: Entrance.step(i, startMs: 450, stepMs: 70),
                      offset: const Offset(50, 0),
                      child: CategoryChip(
                        label: c.label,
                        produce: c.art,
                        active: i == 0,
                        onTap: () => shell.goTab(1, category: c),
                      ),
                    );
                  },
                ),
              ),
              SectionHeader('Fresh picks', action: 'See all', onAction: () => shell.goTab(1)),
            ]).expand((w) => [w, const SizedBox(height: 22)]),
            const ProductGrid(products: Catalog.freshPicks, heroScope: 'home', startMs: 600),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final addr = app.currentAddress;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle),
          child: Text(
            app.initials,
            style: ts(16, w: W.black, c: AppColors.forest),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Pressable(
            scale: 0.98,
            onTap: () => Navigator.of(context).pushNamed(Routes.addresses),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deliver to',
                  style: ts(12, w: W.medium, c: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Ic(AppIcon.pin, size: 16, color: AppColors.leaf),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${addr.label} · ${addr.lines.split('\n').first.split(',').first}',
                        style: ts(15, w: W.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Ic(AppIcon.chevronDown, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
        RoundButton(
          icon: AppIcon.bell,
          shadow: true,
          dot: true,
          tooltip: 'Notifications',
          onTap: () => Navigator.of(context).pushNamed(Routes.notifications),
        ),
      ],
    );
  }
}

class _Banner {
  const _Banner({
    required this.tag,
    required this.title,
    required this.bg,
    required this.tagBg,
    required this.tagFg,
    required this.titleColor,
    required this.ctaBg,
    required this.ctaFg,
    required this.glow,
    required this.art,
    required this.category,
  });
  final String tag;
  final String title;
  final Color bg, tagBg, tagFg, titleColor, ctaBg, ctaFg, glow;
  final List<(Produce, double, double, double, double)> art;
  final Category category;
}

const _banners = [
  _Banner(
    tag: 'FARM DEAL',
    title: 'Up to 30% off\nsummer fruits',
    bg: AppColors.forest,
    tagBg: AppColors.lime,
    tagFg: AppColors.forest,
    titleColor: AppColors.white,
    ctaBg: AppColors.white,
    ctaFg: AppColors.forest,
    glow: AppColors.lime,
    art: [(Produce.orange, 100, 196, 50, 0), (Produce.strawberry, 86, 262, 6, -14), (Produce.lemon, 72, 280, 94, 18)],
    category: Category.fruits,
  ),
  _Banner(
    tag: 'HERB GARDEN',
    title: 'Fresh herbs,\ncut this morning',
    bg: AppColors.tintMint,
    tagBg: AppColors.leaf,
    tagFg: AppColors.white,
    titleColor: AppColors.ink,
    ctaBg: AppColors.forest,
    ctaFg: AppColors.white,
    glow: AppColors.white,
    art: [(Produce.basil, 112, 212, 24, -6), (Produce.basil, 72, 284, 74, 22), (Produce.lemon, 54, 196, 100, -12)],
    category: Category.herbs,
  ),
  _Banner(
    tag: 'FREE DELIVERY',
    title: 'Free delivery\non orders \$15+',
    bg: AppColors.tintOrange,
    tagBg: AppColors.tangerine,
    tagFg: AppColors.white,
    titleColor: AppColors.ink,
    ctaBg: AppColors.forest,
    ctaFg: AppColors.white,
    glow: AppColors.white,
    art: [(Produce.carrot, 104, 214, 24, 26), (Produce.tomato, 74, 278, 78, 0), (Produce.broccoli, 60, 200, 96, 0)],
    category: Category.veggies,
  ),
];

/// Auto-advancing promo banners (the "Farm Deal" banner + two more).
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});
  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final _pc = PageController();
  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pc.hasClients) return;
      final next = (_page + 1) % _banners.length;
      _pc.animateToPage(next, duration: const Duration(milliseconds: 650), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shell = ShellScope.of(context);
    return Column(
      children: [
        SizedBox(
          height: 156,
          child: PageView.builder(
            controller: _pc,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _BannerCard(
                b: _banners[i],
                active: i == _page,
                onTap: () => shell.goTab(1, category: _banners[i].category),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        PageDots(count: _banners.length, index: _page),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.b, required this.active, required this.onTap});
  final _Banner b;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.98,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          color: b.bg,
          child: LayoutBuilder(
            builder: (context, c) {
              final k = c.maxWidth / 342;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 190 * k,
                    top: -40,
                    child: Dot(size: 220, color: b.glow.withValues(alpha: b.glow == AppColors.white ? 0.5 : 0.12)),
                  ),
                  Positioned(
                    left: 270 * k,
                    top: 90,
                    child: Dot(size: 130, color: b.glow.withValues(alpha: b.glow == AppColors.white ? 0.35 : 0.10)),
                  ),
                  for (final (i, a) in b.art.indexed)
                    Positioned(
                      left: a.$3 * k,
                      top: a.$4,
                      child: AnimatedScale(
                        scale: active ? 1 : 0.6,
                        duration: Duration(milliseconds: 500 + i * 120),
                        curve: kGentle,
                        child: Bob(
                          amplitude: 4,
                          phase: i * 0.3,
                          child: Transform.rotate(
                            angle: figmaRot(a.$5),
                            child: ProduceArt(a.$1, size: a.$2),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 22,
                    top: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Pill(b.tag, bg: b.tagBg, fg: b.tagFg, size: 10, weight: W.black, ph: 10, pv: 5, ls: 1.2),
                        const SizedBox(height: 8),
                        Text(
                          b.title,
                          style: ts(21, w: W.black, c: b.titleColor, lh: 26, ls: -0.4),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
                          decoration: BoxDecoration(color: b.ctaBg, borderRadius: BorderRadius.circular(999)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Shop now',
                                style: ts(12, w: W.bold, c: b.ctaFg),
                              ),
                              const SizedBox(width: 6),
                              Ic(AppIcon.arrowRight, size: 14, color: b.ctaFg),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
