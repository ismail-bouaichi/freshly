import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';

/// 18 · My Orders
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final active = [if (app.lastOrder != null) app.lastOrder!, ...Catalog.activeOrders];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const TopBar(title: 'My orders'),
            const SizedBox(height: 16),
            Segmented(
              labels: ['Active · ${active.length}', 'Past · ${Catalog.pastOrders.length}'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _tab == 0
                  ? Column(
                      key: const ValueKey('active'),
                      children: [
                        for (final (i, o) in active.indexed) ...[
                          Entrance(
                            delay: Entrance.step(i, stepMs: 90),
                            child: _ActiveOrderCard(order: o, dark: i == 0),
                          ),
                          const SizedBox(height: 14),
                        ],
                        Entrance(
                          delay: const Duration(milliseconds: 250),
                          child: SectionHeader('Past orders', action: 'See all', onAction: () => setState(() => _tab = 1)),
                        ),
                        const SizedBox(height: 12),
                        for (final (i, o) in Catalog.pastOrders.take(2).indexed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Entrance(
                              delay: Entrance.step(i, startMs: 300, stepMs: 80),
                              child: _PastRow(order: o),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('past'),
                      children: [
                        for (final (i, o) in Catalog.pastOrders.indexed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Entrance(
                              delay: Entrance.step(i, stepMs: 70),
                              offset: const Offset(50, 0),
                              child: _PastRow(order: o),
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

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order, required this.dark});
  final Order order;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final onWay = order.status == OrderStatus.onTheWay;
    final fg = dark ? AppColors.white : AppColors.ink;
    final stages = onWay ? 3 : 1;
    return Pressable(
      scale: 0.98,
      onTap: () => Navigator.of(context).pushNamed(Routes.tracking),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: dark ? AppColors.forest : AppColors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: dark ? null : AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: ts(12, w: W.black, c: dark ? AppColors.lime : AppColors.muted, ls: 0.6),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${order.items.length} items · ${money(order.total)}',
                        style: ts(16, w: W.bold, c: fg),
                      ),
                    ],
                  ),
                ),
                onWay
                    ? const Pill('On the way', bg: AppColors.lime, fg: AppColors.forest, icon: AppIcon.truck, ph: 10)
                    : const Pill('Packing', bg: AppColors.tintLemon, fg: AppColors.ink, icon: AppIcon.package, ph: 10),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Thumbs(items: order.items, ring: dark ? AppColors.forest : AppColors.white, size: dark ? 44 : 40, max: dark ? 3 : 4),
                const Spacer(),
                if (!dark)
                  Text(
                    order.when.replaceAll(' · ', '\n'),
                    textAlign: TextAlign.right,
                    style: ts(12, w: W.bold, c: AppColors.muted, lh: 17),
                  ),
              ],
            ),
            if (dark) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: i < stages ? 1 : 0),
                        duration: Duration(milliseconds: 500 + i * 150),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: v,
                            minHeight: 6,
                            backgroundColor: AppColors.white.withValues(alpha: 0.18),
                            valueColor: AlwaysStoppedAnimation(i == stages - 1 ? AppColors.lime : AppColors.leaf),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.when,
                      style: ts(13, w: W.medium, c: AppColors.white.withValues(alpha: 0.75)),
                    ),
                  ),
                  const Pill('Track order', bg: AppColors.white, fg: AppColors.forest, icon: AppIcon.navArrow, ph: 12, pv: 8),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PastRow extends StatelessWidget {
  const _PastRow({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.read(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(22)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Thumbs(items: order.items, ring: AppColors.white, size: 38, max: 2),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.when} · ${order.items.length} items',
                  style: ts(14, w: W.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Ic(AppIcon.check, size: 13, color: AppColors.leaf),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Delivered · ${money(order.total)}',
                        style: ts(12, w: W.medium, c: AppColors.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Pressable(
                  onTap: () {
                    app.addAll({for (final p in order.items) p.id: 1});
                    showToast(
                      context,
                      '${order.items.length} items added to cart',
                      action: 'View',
                      onAction: () => Navigator.of(context).pushNamed(Routes.cart),
                    );
                  },
                  child: const Pill('Reorder', icon: AppIcon.repeat, ph: 10, pv: 7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
