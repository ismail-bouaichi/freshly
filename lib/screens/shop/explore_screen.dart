import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/produce.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../../widgets/shop.dart';
import '../shell.dart';

/// 06 · Explore — category browsing with tag filters, sort and an in-season feature.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  Tag? _tag;
  SortBy _sort = SortBy.popular;

  static const _featured = {
    Category.fruits: (Catalog.oranges, 'IN SEASON', 'Juicy oranges\nfrom local groves', 'From \$1.99 / kg · 20% off', AppColors.tintLemon),
    Category.veggies: (
      Catalog.carrots,
      'JUST PULLED',
      'Crunchy carrots\nfrom the valley',
      'Organic · \$1.89 / 500 g',
      AppColors.tintOrange,
    ),
    Category.herbs: (Catalog.basil, 'PESTO SEASON', 'Genovese basil,\ncut at sunrise', 'Local · \$1.29 / bunch', AppColors.tintMint),
    Category.exotic: (Catalog.avocado, 'READY TO EAT', 'Creamy Hass\navocados', 'Perfectly ripe · \$2.99', AppColors.tintLime),
  };

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final shell = ShellScope.of(context);
    return ValueListenableBuilder<Category>(
      valueListenable: shell.exploreCategory,
      builder: (context, cat, _) {
        var items = Catalog.inCategory(cat);
        if (_tag != null) items = items.where((p) => p.tags.contains(_tag)).toList();
        sortList(items, _sort);
        final f = _featured[cat]!;
        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...staggered(stepMs: 70, [
                  Row(
                    children: [
                      RoundButton(icon: AppIcon.chevronLeft, onTap: () => shell.goTab(0), tooltip: 'Back to home'),
                      Expanded(
                        child: Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                cat.label,
                                key: ValueKey(cat),
                                style: ts(18, w: W.black),
                              ),
                            ),
                            Text(
                              '${Catalog.inCategory(cat).length} items near you',
                              style: ts(12, w: W.medium, c: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      RoundButton(
                        icon: AppIcon.bag,
                        badge: app.cartLines,
                        tooltip: 'Cart',
                        onTap: () => Navigator.of(context).pushNamed(Routes.cart),
                      ),
                    ],
                  ),
                  const SearchLauncher(heroTag: 'search-explore', hint: 'Search in the market…'),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: Category.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final c = Category.values[i];
                        return CategoryChip(label: c.label, produce: c.art, active: c == cat, onTap: () => shell.exploreCategory.value = c);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        FilterPill(label: 'All', active: _tag == null, onTap: () => setState(() => _tag = null)),
                        for (final t in [Tag.seasonal, Tag.organic, Tag.sale, Tag.local])
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterPill(label: t.label, active: _tag == t, onTap: () => setState(() => _tag = _tag == t ? null : t)),
                          ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    layoutBuilder: heroSafeSwitcherLayout,
                    child: _Feature(key: ValueKey(cat), product: f.$1, tag: f.$2, title: f.$3, sub: f.$4, bg: f.$5),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Popular picks', style: ts(16, w: W.black)),
                      ),
                      PopupMenuButton<SortBy>(
                        initialValue: _sort,
                        onSelected: (s) => setState(() => _sort = s),
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        itemBuilder: (_) => [
                          for (final s in SortBy.values)
                            PopupMenuItem(
                              value: s,
                              child: Text(s.label, style: ts(14, w: s == _sort ? W.bold : W.medium)),
                            ),
                        ],
                        child: Row(
                          children: [
                            Text(
                              'Sort: ${_sort == SortBy.popular
                                  ? 'Popular'
                                  : _sort == SortBy.priceLow
                                  ? 'Price ↑'
                                  : 'Price ↓'}',
                              style: ts(13, w: W.bold, c: AppColors.leafDark),
                            ),
                            const SizedBox(width: 4),
                            const Ic(AppIcon.chevronDown, size: 16, color: AppColors.leafDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]).expand((w) => [w, const SizedBox(height: 18)]),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  layoutBuilder: heroSafeSwitcherLayout,
                  child: items.isEmpty
                      ? Padding(
                          key: const ValueKey('empty'),
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              const ProduceArt(Produce.basil, size: 72),
                              const SizedBox(height: 12),
                              Text('Nothing here yet', style: ts(16, w: W.black)),
                              Text('Try another filter', style: ts(13, c: AppColors.muted)),
                            ],
                          ),
                        )
                      : ProductGrid(key: ValueKey('$cat-$_tag-$_sort'), products: items, heroScope: 'explore'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({super.key, required this.product, required this.tag, required this.title, required this.sub, required this.bg});
  final Product product;
  final String tag, title, sub;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final heroTag = 'art-feature-${product.id}';
    return Pressable(
      scale: 0.98,
      onTap: () => Navigator.of(context).pushNamed(Routes.product, arguments: ProductArgs(product, heroTag)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 10, 16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(26)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Pill(tag, bg: AppColors.gold, fg: AppColors.white, size: 10, weight: W.black, ph: 9, pv: 4, ls: 1),
                  const SizedBox(height: 6),
                  Text(title, style: ts(18, w: W.black, lh: 23, ls: -0.4)),
                  const SizedBox(height: 6),
                  Text(
                    sub,
                    style: ts(13, w: W.bold, c: AppColors.leafDark),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              height: 100,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 6,
                    top: 0,
                    child: Entrance(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 700),
                      offset: const Offset(140, 0),
                      rotate: 120,
                      child: Hero(tag: heroTag, child: ProduceArt(product.art, size: 96)),
                    ),
                  ),
                  Positioned(
                    left: 66,
                    top: 54,
                    child: Entrance(
                      delay: const Duration(milliseconds: 420),
                      duration: const Duration(milliseconds: 700),
                      offset: const Offset(120, 0),
                      rotate: 140,
                      child: ProduceArt(product.art, size: 52),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
