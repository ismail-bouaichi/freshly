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

/// 03 · Product Detail — the card's produce flies in as a shared-element hero.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.args});
  final ProductArgs args;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int? _qtyState;
  bool _expanded = false;
  bool _added = false;

  Product get p => widget.args.product;

  /// Starts at the quantity already in the cart (or 1).
  int get _qty => _qtyState ??= () {
    final inCart = AppScope.read(context).qty(p);
    return inCart > 0 ? inCart : 1;
  }();
  set _qty(int v) => _qtyState = v;

  Future<void> _addToCart() async {
    final app = AppScope.read(context);
    app.setQty(p, _qty);
    setState(() => _added = true);
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    await Navigator.of(context).pushNamed(Routes.cart);
    if (mounted) setState(() => _added = false);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final inCart = app.qty(p);
    final fav = app.isFav(p);
    final top = MediaQuery.paddingOf(context).top;
    final related = Catalog.all.where((o) => o.id != p.id && o.categories.intersection(p.categories).isNotEmpty).take(4).toList();

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 392 + top * 0.5,
            child: LayoutBuilder(
              builder: (context, c) {
                final k = c.maxWidth / 390;
                final h = c.maxHeight;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: p.tint,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 45 * k,
                      top: h - 312,
                      child: Entrance(
                        scale: 0.7,
                        offset: Offset.zero,
                        child: Breathe(
                          child: Dot(size: 300 * k, color: AppColors.white.withValues(alpha: 0.55)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 19 * k,
                      top: h - 338,
                      child: Spin(
                        period: const Duration(seconds: 30),
                        child: DashedCircle(size: 352 * k, color: AppColors.forest.withValues(alpha: 0.18), dash: 3, gap: 9),
                      ),
                    ),
                    for (final (i, m) in [(26.0, h - 102, 56.0, 22.0), (316.0, h - 264, 44.0, -26.0), (300.0, h - 92, 50.0, -30.0)].indexed)
                      Positioned(
                        left: m.$1 * k,
                        top: m.$2,
                        child: Entrance(
                          delay: Duration(milliseconds: 400 + i * 120),
                          offset: Offset(0, i.isOdd ? 20 : -20),
                          child: Bob(
                            amplitude: 8,
                            phase: i * 0.33,
                            child: Transform.rotate(
                              angle: figmaRot(m.$4),
                              child: ProduceArt(i == 2 && p.art != Produce.basil ? Produce.basil : p.art, size: m.$3),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: h - 290,
                      child: Center(
                        child: Bob(
                          amplitude: 6,
                          period: const Duration(milliseconds: 3400),
                          child: Hero(tag: widget.args.heroTag, child: ProduceArt(p.art, size: 240)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      top: top + 8,
                      child: Entrance(
                        offset: const Offset(0, -12),
                        child: Row(
                          children: [
                            RoundButton(icon: AppIcon.chevronLeft, onTap: () => Navigator.of(context).maybePop(), tooltip: 'Back'),
                            Expanded(
                              child: Text(
                                'Details',
                                textAlign: TextAlign.center,
                                style: ts(17, w: W.bold),
                              ),
                            ),
                            Pressable(
                              onTap: () => app.toggleFav(p),
                              child: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 320),
                                  transitionBuilder: (c, a) => ScaleTransition(
                                    scale: CurvedAnimation(parent: a, curve: kGentle),
                                    child: c,
                                  ),
                                  child: Ic(fav ? AppIcon.heartFill : AppIcon.heart, key: ValueKey(fav), size: 20, color: AppColors.berry),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: staggered(startMs: 300, stepMs: 70, offset: const Offset(0, 26), [
                  Row(
                    children: [
                      Pill(p.tags.isNotEmpty ? p.tags.first.label : 'Fresh', icon: AppIcon.leaf),
                      const Spacer(),
                      const Ic(AppIcon.star, size: 16),
                      const SizedBox(width: 6),
                      Text(p.rating.toStringAsFixed(1), style: ts(14, w: W.black)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '(${p.reviews} reviews)',
                          style: ts(13, w: W.medium, c: AppColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: ts(27, w: W.black, ls: -0.7)),
                      const SizedBox(height: 4),
                      Text(
                        '${p.unit} · Picked ${p.picked.toLowerCase()}',
                        style: ts(14, w: W.medium, c: AppColors.muted),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        money(p.price),
                        style: ts(30, w: W.black, c: AppColors.forest, ls: -0.6),
                      ),
                      if (p.oldPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          money(p.oldPrice!),
                          style: ts(15, w: W.semi, c: AppColors.muted, deco: TextDecoration.lineThrough),
                        ),
                      ],
                      const Spacer(),
                      QtyStepper(value: _qty, bg: AppColors.white, shadow: true, onChanged: (v) => setState(() => _qty = v)),
                    ],
                  ),
                  Row(
                    children: [
                      for (final (i, f) in [
                        (AppIcon.flame, '${p.kcal}', 'kcal', AppColors.tintOrange, AppColors.tangerine),
                        (AppIcon.drop, p.water, 'water', AppColors.tintMint, AppColors.leaf),
                        (AppIcon.leaf, p.vitamin, 'rich', AppColors.tintLeaf, AppColors.leafDark),
                        (AppIcon.clock, p.picked, 'picked', AppColors.tintLemon, AppColors.gold),
                      ].indexed) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              children: [
                                IconBox(f.$1, bg: f.$4, fg: f.$5, size: 32, iconSize: 17, radius: 11),
                                const SizedBox(height: 6),
                                FittedBox(
                                  child: Text(f.$2, style: ts(14, w: W.black)),
                                ),
                                Text(
                                  f.$3,
                                  style: ts(11, w: W.medium, c: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: Pressable(
                      scale: 0.99,
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Text.rich(
                        TextSpan(
                          text: '${p.description} ',
                          children: [
                            TextSpan(
                              text: _expanded ? 'Show less' : 'Read more',
                              style: ts(14, w: W.bold, c: AppColors.leaf),
                            ),
                          ],
                        ),
                        style: ts(14, c: AppColors.muted, lh: 22),
                        maxLines: _expanded ? null : 2,
                        overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (related.isNotEmpty) ...[SectionHeader('Goes well with')],
                  if (related.isNotEmpty)
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: related.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final r = related[i];
                          final tag = 'art-related-${p.id}-${r.id}';
                          return Pressable(
                            onTap: () => Navigator.of(context).pushReplacementNamed(Routes.product, arguments: ProductArgs(r, tag)),
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(22)),
                              child: Row(
                                children: [
                                  ProduceTile(produce: r.art, tint: r.tint, size: 64, artSize: 48, heroTag: tag),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.name,
                                          style: ts(14, w: W.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          money(r.price),
                                          style: ts(14, w: W.black, c: AppColors.forest),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ]).expand((w) => [w, const SizedBox(height: 14)]).toList(),
              ),
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Entrance(
                delay: const Duration(milliseconds: 600),
                offset: const Offset(0, 30),
                child: PrimaryButton(
                  label: _added ? 'Added to cart' : '${inCart > 0 ? 'Update cart' : 'Add to cart'}  ·  ${money(p.price * _qty)}',
                  done: _added,
                  onTap: _addToCart,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
