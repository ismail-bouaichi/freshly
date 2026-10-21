import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/produce.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../../widgets/shop.dart';

/// 04 · Cart — swipe to remove, live totals, free-delivery progress.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = app.cartItems;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: TopBar(
                title: 'My Cart',
                subtitle: items.isEmpty ? null : '${app.cartUnits} item${app.cartUnits == 1 ? '' : 's'}',
                trailing: items.isEmpty
                    ? null
                    : RoundButton(
                        icon: AppIcon.trash,
                        iconSize: 20,
                        tooltip: 'Clear cart',
                        onTap: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Empty your cart?'),
                              content: const Text('This removes every item from your basket.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: Text(
                                    'Keep',
                                    style: ts(14, w: W.bold, c: AppColors.muted),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: Text(
                                    'Empty cart',
                                    style: ts(14, w: W.bold, c: AppColors.berry),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) app.clearCart();
                        },
                      ),
              ),
            ),
            // No AnimatedSwitcher here: it would keep a just-dismissed row alive.
            Expanded(
              child: items.isEmpty ? const Entrance(child: _EmptyCart()) : _CartBody(app: app, items: items),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({required this.app, required this.items});
  final AppState app;
  final List<MapEntry<Product, int>> items;

  @override
  Widget build(BuildContext context) {
    final free = app.subtotal >= AppState.freeDeliveryAt;
    final missing = AppState.freeDeliveryAt - app.subtotal;
    return Column(
      key: const ValueKey('body'),
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            children: [
              Entrance(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    children: [
                      const IconBox(AppIcon.truck, bg: AppColors.lime, fg: AppColors.forest, size: 48, iconSize: 24, radius: 16),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: Text(
                                      free ? 'Free delivery unlocked' : 'Add ${money(missing)} for free delivery',
                                      key: ValueKey(free),
                                      style: ts(15, w: W.bold, c: AppColors.white),
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$15+',
                                  style: ts(12, w: W.black, c: AppColors.lime),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(end: app.freeDeliveryProgress),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, _) => LinearProgressIndicator(
                                  value: v,
                                  minHeight: 8,
                                  backgroundColor: AppColors.white.withValues(alpha: 0.15),
                                  valueColor: const AlwaysStoppedAnimation(AppColors.lime),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Arriving today · 4:00 – 4:30 PM',
                              style: ts(12, w: W.medium, c: AppColors.white.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              for (final (i, e) in items.indexed)
                Padding(
                  key: ValueKey(e.key.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Entrance(
                    delay: Entrance.step(i, startMs: 150, stepMs: 90),
                    offset: const Offset(70, 0),
                    child: Dismissible(
                      key: ValueKey('cart-${e.key.id}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        final q = e.value;
                        app.remove(e.key);
                        showToast(context, '${e.key.name} removed', action: 'Undo', onAction: () => app.setQty(e.key, q));
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 26),
                        decoration: BoxDecoration(color: AppColors.tintBerry, borderRadius: BorderRadius.circular(24)),
                        child: const Ic(AppIcon.trash, color: AppColors.berry),
                      ),
                      child: _CartRow(product: e.key, qty: e.value),
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              Entrance(
                delay: const Duration(milliseconds: 450),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: [
                      _line('Subtotal', AnimatedMoney(app.subtotal, style: ts(14, w: W.bold))),
                      const SizedBox(height: 10),
                      _line(
                        'Delivery',
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            app.delivery == 0 ? 'Free' : money(app.delivery),
                            key: ValueKey(app.delivery),
                            style: ts(14, w: W.bold, c: app.delivery == 0 ? AppColors.leaf : AppColors.ink),
                          ),
                        ),
                      ),
                      if (app.promoCode != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Promo · ',
                              style: ts(14, w: W.medium, c: AppColors.muted),
                            ),
                            Pill(app.promoCode!, ph: 8, pv: 3, size: 11),
                            Pressable(
                              onTap: app.removePromo,
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Ic(AppIcon.x, size: 14, color: AppColors.muted),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '−${money(app.discount)}',
                              style: ts(14, w: W.bold, c: AppColors.leaf),
                            ),
                          ],
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: AppColors.line),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Total', style: ts(16, w: W.bold)),
                          ),
                          AnimatedMoney(
                            app.total,
                            style: ts(22, w: W.black, c: AppColors.forest, ls: -0.4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Entrance(
            delay: const Duration(milliseconds: 550),
            offset: const Offset(0, 30),
            scale: 0.94,
            child: PrimaryButton(label: 'Checkout  ·  ${money(app.total)}', onTap: () => Navigator.of(context).pushNamed(Routes.checkout)),
          ),
        ),
      ],
    );
  }

  Widget _line(String label, Widget value) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: ts(14, w: W.medium, c: AppColors.muted),
        ),
      ),
      value,
    ],
  );
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.product, required this.qty});
  final Product product;
  final int qty;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.read(context);
    final tag = 'art-cart-${product.id}';
    return Pressable(
      scale: 0.98,
      onTap: () => Navigator.of(context).pushNamed(Routes.product, arguments: ProductArgs(product, tag)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppShadows.soft),
        child: Row(
          children: [
            ProduceTile(produce: product.art, tint: product.tint, size: 76, artSize: 58, heroTag: tag),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: ts(16, w: W.bold)),
                  const SizedBox(height: 3),
                  Text(
                    product.unit,
                    style: ts(13, w: W.medium, c: AppColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedMoney(
                          product.price * qty,
                          style: ts(17, w: W.black, c: AppColors.forest),
                        ),
                      ),
                      QtyStepper(value: qty, min: 0, onChanged: (v) => app.setQty(product, v)),
                    ],
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

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();
  @override
  Widget build(BuildContext context) => Center(
    key: const ValueKey('empty'),
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 200,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Dot(size: 160, color: AppColors.tintLime),
                Entrance(
                  scale: 0.4,
                  offset: Offset.zero,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle, boxShadow: AppShadows.soft),
                    alignment: Alignment.center,
                    child: const Ic(AppIcon.bag, size: 40, color: AppColors.forest),
                  ),
                ),
                const Positioned(left: 10, bottom: 18, child: Bob(child: ProduceArt(Produce.carrot, size: 56))),
                const Positioned(right: 12, top: 8, child: Bob(phase: 0.4, child: ProduceArt(Produce.apple, size: 50))),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Your basket is empty', style: ts(22, w: W.black, ls: -0.5)),
          const SizedBox(height: 6),
          Text(
            'Fill it with something fresh — fruit, veg and herbs picked today.',
            textAlign: TextAlign.center,
            style: ts(14, c: AppColors.muted, lh: 21),
          ),
          const SizedBox(height: 22),
          PrimaryButton(label: 'Start shopping', kind: ButtonStyleKind.lime, onTap: () => Navigator.of(context).maybePop()),
        ],
      ),
    ),
  );
}
