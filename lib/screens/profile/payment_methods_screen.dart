import 'package:flutter/material.dart';

import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../widgets/common.dart';

/// 20 · Payment Methods
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});
  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _pc = PageController(viewportFraction: 0.92);
  int _page = 0;

  static const _cards = [
    ('DEBIT', '4242', 'Sara Amrani', '08/28', AppColors.forest, AppColors.lime),
    ('CREDIT', '8810', 'Sara Amrani', '02/27', AppColors.leafDark, AppColors.lemon),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Future<void> _topUp(AppState app) async {
    final amount = await showModalBottomSheet<double>(
      context: context,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.paddingOf(c).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 16),
            Text('Top up wallet', style: ts(22, w: W.black)),
            const SizedBox(height: 6),
            Text('Funds are charged to your default card.', style: ts(13, c: AppColors.muted)),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final (i, v) in const [10.0, 25.0, 50.0].indexed) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: Pressable(
                      onTap: () => Navigator.pop(c, v),
                      child: Container(
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i == 1 ? AppColors.forest : AppColors.cream,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\$${v.toStringAsFixed(0)}',
                          style: ts(20, w: W.black, c: i == 1 ? AppColors.lime : AppColors.ink),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
    if (amount != null) {
      app.topUp(amount);
      if (mounted) showToast(context, '\$${amount.toStringAsFixed(0)} added to your wallet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TopBar(
                title: 'Payment methods',
                trailing: RoundButton(
                  icon: AppIcon.plus,
                  bg: AppColors.forest,
                  fg: AppColors.lime,
                  tooltip: 'Add card',
                  onTap: () => showToast(context, 'Card scanner opens here'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 204,
              child: PageView.builder(
                controller: _pc,
                itemCount: _cards.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final card = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _PayCard(data: _cards[i]),
                  );
                  return i == 0
                      ? Entrance(rotate: -8, scale: 0.85, offset: Offset.zero, duration: const Duration(milliseconds: 750), child: card)
                      : card;
                },
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: PageDots(count: _cards.length, index: _page),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: staggered(startMs: 150, stepMs: 70, [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.tintLime, borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        const IconBox(AppIcon.wallet, bg: AppColors.lime, fg: AppColors.forest, size: 46, iconSize: 22, radius: 16),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Freshly Wallet', style: ts(15, w: W.bold)),
                              Row(
                                children: [
                                  AnimatedMoney(
                                    app.wallet,
                                    style: ts(13, w: W.bold, c: AppColors.leafDark),
                                  ),
                                  Text(
                                    ' available',
                                    style: ts(13, w: W.medium, c: AppColors.muted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Pressable(
                          onTap: () => _topUp(app),
                          child: const Pill(
                            'Top up',
                            bg: AppColors.forest,
                            fg: AppColors.white,
                            icon: AppIcon.plus,
                            iconColor: AppColors.lime,
                            ph: 12,
                            pv: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SectionLabel('OTHER METHODS'),
                  GroupCard(
                    children: [
                      ListRow(
                        icon: AppIcon.card,
                        tint: AppColors.tintOrange,
                        iconColor: AppColors.tangerine,
                        title: 'Credit card •••• 8810',
                        description: 'Expires 02/27',
                        trailing: const Chevron(),
                        onTap: () => _pc.animateToPage(1, duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic),
                      ),
                      ListRow(
                        icon: AppIcon.cash,
                        tint: AppColors.tintLemon,
                        iconColor: AppColors.gold,
                        title: 'Cash on delivery',
                        description: 'Pay the courier at the door',
                        trailing: AppToggle(value: app.cashOnDelivery, onChanged: app.setCash),
                      ),
                      ListRow(
                        icon: AppIcon.plus,
                        tint: AppColors.tintLeaf,
                        iconColor: AppColors.leafDark,
                        title: 'Add new card',
                        trailing: const Chevron(),
                        onTap: () => showToast(context, 'Card scanner opens here'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Ic(AppIcon.shield, size: 14, color: AppColors.leaf),
                      const SizedBox(width: 6),
                      Text(
                        'Payments are encrypted & secured',
                        style: ts(12, w: W.medium, c: AppColors.muted),
                      ),
                    ],
                  ),
                ]).expand((w) => [w, const SizedBox(height: 16)]).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayCard extends StatelessWidget {
  const _PayCard({required this.data});
  final (String, String, String, String, Color, Color) data;

  @override
  Widget build(BuildContext context) {
    final (kind, last4, holder, exp, bg, accent) = data;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        color: bg,
        padding: const EdgeInsets.all(22),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(right: -100, top: -100, child: Dot(size: 240, color: accent.withValues(alpha: 0.14))),
            Positioned(left: -72, bottom: -110, child: Dot(size: 170, color: AppColors.leaf.withValues(alpha: 0.25))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const FreshlyLogo(size: 26, text: 'freshly pay'),
                    const Spacer(),
                    Text(
                      kind,
                      style: ts(12, w: W.black, c: accent, ls: 2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 42,
                  height: 32,
                  decoration: BoxDecoration(color: AppColors.lemon.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(8)),
                ),
                const Spacer(),
                FittedBox(
                  child: Text(
                    '••••   ••••   ••••   $last4',
                    style: ts(20, w: W.bold, c: AppColors.white, ls: 1.5),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [_kv('CARD HOLDER', holder), const Spacer(), _kv('EXPIRES', exp)]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        k,
        style: ts(10, w: W.bold, c: AppColors.white.withValues(alpha: 0.55), ls: 1),
      ),
      Text(
        v,
        style: ts(14, w: W.bold, c: AppColors.white),
      ),
    ],
  );
}
