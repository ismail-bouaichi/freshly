import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../../widgets/shop.dart';

/// 08 · Checkout
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _slot = 0;
  int _pay = 0;
  bool _placing = false;
  final _note = TextEditingController();

  static const _slots = [('Today', '4 – 5 PM'), ('Today', '6 – 7 PM'), ('Tomorrow', '9 – 10 AM')];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _place() async {
    final app = AppScope.read(context);
    setState(() => _placing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    final s = _slots[_slot];
    app.placeOrder(slot: '${s.$1}, ${s.$2}', payment: ['Card', 'Wallet', 'Cash'][_pay]);
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.placed, ModalRoute.withName(Routes.shell));
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final addr = app.currentAddress;
    final pays = [
      (AppIcon.card, AppColors.tintLime, AppColors.leafDark, 'Credit card', '•••• 4242 · Expires 08/28'),
      (AppIcon.wallet, AppColors.tintOrange, AppColors.tangerine, 'Freshly Wallet', 'Balance ${money(app.wallet)}'),
      if (app.cashOnDelivery) (AppIcon.cash, AppColors.tintLemon, AppColors.gold, 'Cash on delivery', 'Pay when it arrives'),
    ];
    if (_pay >= pays.length) _pay = 0;
    final walletShort = _pay == 1 && app.wallet < app.total;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: TopBar(title: 'Checkout'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                children: staggered(stepMs: 55, [
                  const _Steps(),
                  SectionHeader('Delivery address', action: 'Change', onAction: () => Navigator.of(context).pushNamed(Routes.addresses)),
                  SoftCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        IconBox(AppIcon.pin, bg: addr.tint, fg: addr.color, size: 46, iconSize: 22, radius: 16),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(addr.label, style: ts(15, w: W.bold)),
                              const SizedBox(height: 2),
                              Text(
                                addr.lines.replaceAll('\n', ' · '),
                                style: ts(13, w: W.medium, c: AppColors.muted),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(color: AppColors.leaf, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Ic(AppIcon.check, size: 14, color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                  const SectionHeader('Delivery slot'),
                  Row(
                    children: [
                      for (var i = 0; i < _slots.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: Pressable(
                            onTap: () => setState(() => _slot = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: i == _slot ? AppColors.forest : AppColors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: i == _slot ? AppColors.forest : AppColors.line),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _slots[i].$1,
                                    style: ts(12, w: W.medium, c: i == _slot ? AppColors.lime : AppColors.muted),
                                  ),
                                  const SizedBox(height: 3),
                                  FittedBox(
                                    child: Text(
                                      _slots[i].$2,
                                      style: ts(15, w: W.black, c: i == _slot ? AppColors.white : AppColors.ink),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SectionHeader('Payment method'),
                  Column(
                    children: [
                      for (var i = 0; i < pays.length; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: i == pays.length - 1 ? 0 : 10),
                          child: Pressable(
                            scale: 0.98,
                            onTap: () => setState(() => _pay = i),
                            child: SoftCard(
                              padding: const EdgeInsets.all(12),
                              radius: 20,
                              border: i == _pay ? AppColors.forest : null,
                              child: Row(
                                children: [
                                  IconBox(pays[i].$1, bg: pays[i].$2, fg: pays[i].$3, size: 44, iconSize: 22),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(pays[i].$4, style: ts(15, w: W.bold)),
                                        Text(
                                          pays[i].$5,
                                          style: ts(12, w: W.medium, c: AppColors.muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RadioDot(selected: i == _pay),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (walletShort)
                    Text(
                      'Wallet balance is lower than the total — top up in Payment methods.',
                      style: ts(12, w: W.semi, c: AppColors.berry),
                    ),
                  AppTextField(icon: AppIcon.chat, hint: 'Note for the courier (optional)', controller: _note),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total · ${app.cartUnits} items',
                          style: ts(14, w: W.medium, c: AppColors.muted),
                        ),
                      ),
                      AnimatedMoney(
                        app.total,
                        style: ts(24, w: W.black, c: AppColors.forest, ls: -0.5),
                      ),
                    ],
                  ),
                ]).expand((w) => [w, const SizedBox(height: 14)]).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: PrimaryButton(
                label: 'Place order  ·  ${money(app.total)}',
                loading: _placing,
                onTap: app.cartItems.isEmpty || walletShort ? null : _place,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    Widget step(int state, String n, String label) {
      final Widget circle = switch (state) {
        2 => Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.leaf, shape: BoxShape.circle),
          child: const Ic(AppIcon.check, size: 16, color: AppColors.white),
        ),
        1 => Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.forest, shape: BoxShape.circle),
          child: Text(
            n,
            style: ts(13, w: W.black, c: AppColors.lime),
          ),
        ),
        _ => Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: Text(
            n,
            style: ts(13, w: W.black, c: AppColors.muted),
          ),
        ),
      };
      return Column(
        children: [
          circle,
          const SizedBox(height: 6),
          Text(
            label,
            style: ts(12, w: W.bold, c: state == 0 ? AppColors.muted : AppColors.ink),
          ),
        ],
      );
    }

    Widget line(bool done) => Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 13, left: 6, right: 6),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: done ? 1 : 0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => ClipRRect(
            borderRadius: BorderRadius.circular(1),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 2,
              backgroundColor: AppColors.line,
              valueColor: const AlwaysStoppedAnimation(AppColors.leaf),
            ),
          ),
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [step(2, '1', 'Cart'), line(true), step(1, '2', 'Delivery'), line(false), step(0, '3', 'Done')],
    );
  }
}
