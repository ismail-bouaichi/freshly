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
import '../shell.dart';

/// 07 · Saved — favourite items and recurring baskets.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});
  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final favs = Catalog.all.where(app.isFav).toList();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 130),
        children: [
          ...staggered(stepMs: 70, [
            Row(
              children: [
                Expanded(
                  child: Text('Saved', style: ts(28, w: W.black, ls: -0.8)),
                ),
                RoundButton(icon: AppIcon.search, tooltip: 'Search', onTap: () => Navigator.of(context).pushNamed(Routes.search)),
              ],
            ),
            Segmented(
              labels: ['Items · ${favs.length}', 'Baskets · ${Catalog.baskets.length}'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ]).expand((w) => [w, const SizedBox(height: 18)]),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(a),
                child: c,
              ),
            ),
            child: _tab == 0 ? _items(context, app, favs) : _baskets(context, app),
          ),
        ],
      ),
    );
  }

  Widget _items(BuildContext context, AppState app, List<Product> favs) {
    return Column(
      key: const ValueKey('items'),
      children: [
        Entrance(
          delay: const Duration(milliseconds: 140),
          child: BasketCard(basket: Catalog.baskets[0]),
        ),
        const SizedBox(height: 16),
        if (favs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                const Ic(AppIcon.heart, size: 40, color: AppColors.berry),
                const SizedBox(height: 12),
                Text('Nothing saved yet', style: ts(16, w: W.black)),
                const SizedBox(height: 4),
                Text('Tap the heart on any product to keep it here.', style: ts(13, c: AppColors.muted)),
                const SizedBox(height: 16),
                OutlineButton(label: 'Browse the market', onTap: () => ShellScope.of(context).goTab(1)),
              ],
            ),
          ),
        for (final (i, p) in favs.indexed)
          Padding(
            key: ValueKey(p.id),
            padding: const EdgeInsets.only(bottom: 12),
            child: Entrance(
              delay: Entrance.step(i, startMs: 220, stepMs: 70),
              offset: const Offset(60, 0),
              child: Dismissible(
                key: ValueKey('fav-${p.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  app.toggleFav(p);
                  showToast(context, '${p.name} removed from saved', action: 'Undo', onAction: () => app.toggleFav(p));
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(color: AppColors.tintBerry, borderRadius: BorderRadius.circular(22)),
                  child: const Ic(AppIcon.trash, color: AppColors.berry),
                ),
                child: _SavedRow(product: p),
              ),
            ),
          ),
      ],
    );
  }

  Widget _baskets(BuildContext context, AppState app) => Column(
    key: const ValueKey('baskets'),
    children: [
      for (final (i, b) in Catalog.baskets.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Entrance(
            delay: Entrance.step(i, stepMs: 90),
            child: BasketCard(basket: b, dark: i == 0),
          ),
        ),
      OutlineButton(
        label: 'Create a new basket',
        icon: AppIcon.plus,
        onTap: () => showToast(context, 'Tip: save items, then group them into a basket'),
      ),
    ],
  );
}

class _SavedRow extends StatelessWidget {
  const _SavedRow({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final tag = 'art-saved-${product.id}';
    return Pressable(
      scale: 0.98,
      onTap: () => Navigator.of(context).pushNamed(Routes.product, arguments: ProductArgs(product, tag)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(22), boxShadow: AppShadows.soft),
        child: Row(
          children: [
            ProduceTile(produce: product.art, tint: product.tint, size: 68, artSize: 52, heroTag: tag),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: ts(15, w: W.bold)),
                  const SizedBox(height: 3),
                  Text(
                    product.unit,
                    style: ts(12, w: W.medium, c: AppColors.muted),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    money(product.price),
                    style: ts(16, w: W.black, c: AppColors.forest),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RoundButton(
                  icon: AppIcon.heartFill,
                  size: 32,
                  iconSize: 16,
                  bg: AppColors.tintBerry,
                  fg: AppColors.berry,
                  onTap: () => app.toggleFav(product),
                  tooltip: 'Unsave',
                ),
                const SizedBox(height: 10),
                Pressable(
                  onTap: () {
                    app.add(product);
                    showToast(
                      context,
                      '${product.name} added to cart',
                      action: 'View',
                      onAction: () => Navigator.of(context).pushNamed(Routes.cart),
                    );
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(12)),
                    child: const Ic(AppIcon.plus, size: 16, color: AppColors.lime),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Weekly basket" card with stacked produce and one-tap reorder.
class BasketCard extends StatelessWidget {
  const BasketCard({super.key, required this.basket, this.dark = true});
  final Basket basket;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = basket.items.keys.map(Catalog.byId).toList();
    final total = basket.items.entries.fold<double>(0, (s, e) => s + Catalog.byId(e.key).price * e.value);
    final fg = dark ? AppColors.white : AppColors.ink;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? AppColors.forest : AppColors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: dark ? null : AppShadows.soft,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Ic(AppIcon.repeat, size: 14, color: dark ? AppColors.lime : AppColors.leafDark),
                    const SizedBox(width: 6),
                    Text(
                      'WEEKLY BASKET',
                      style: ts(10, w: W.black, c: dark ? AppColors.lime : AppColors.leafDark, ls: 1.2),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  basket.name,
                  style: ts(18, w: W.black, c: fg, ls: -0.3),
                ),
                const SizedBox(height: 4),
                Text(
                  basket.note,
                  style: ts(12, w: W.medium, c: fg.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 10),
                Pressable(
                  onTap: () {
                    app.addAll(basket.items);
                    showToast(
                      context,
                      '${basket.name} added to cart',
                      action: 'View',
                      onAction: () => Navigator.of(context).pushNamed(Routes.cart),
                    );
                  },
                  child: Pill(
                    'Reorder · ${money(total)}',
                    bg: dark ? AppColors.lime : AppColors.forest,
                    fg: dark ? AppColors.forest : AppColors.white,
                    weight: W.black,
                    ph: 14,
                    pv: 8,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 108,
            height: 110,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final (i, p) in items.take(3).indexed)
                  Positioned(
                    left: [30.0, -4.0, 52.0][i],
                    top: [0.0, 34.0, 52.0][i],
                    child: Entrance(
                      delay: Duration(milliseconds: 300 + i * 100),
                      scale: 0.2,
                      rotate: i.isOdd ? 20 : -20,
                      offset: Offset.zero,
                      child: Transform.rotate(
                        angle: figmaRot([0.0, 24.0, -10.0][i]),
                        child: ProduceArt(p.art, size: [70.0, 70.0, 56.0][i]),
                      ),
                    ),
                  ),
                if (items.isEmpty) const ProduceArt(Produce.broccoli, size: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
