import 'package:flutter/material.dart';

import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/shop.dart';

/// 23 · Help Center — searchable FAQ with an accordion.
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});
  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _q = TextEditingController();
  int _open = 0;

  static const _faq = [
    (
      'What if an item arrives damaged?',
      "Snap a photo in My orders and we'll refund or replace it right away — no need to send anything back.",
    ),
    (
      'Can I change my delivery slot?',
      'Yes. Until your basket is packed you can pick any open slot from the order page. After packing, message your courier.',
    ),
    ('How fresh is the produce?', 'Everything is harvested within 24 hours of delivery by partner farms within 80 km of you.'),
    (
      'How do I cancel Freshly Plus?',
      'Go to Profile → Payment methods → Freshly Plus and tap Cancel. You keep the benefits until the end of the period.',
    ),
    (
      'Do you use plastic packaging?',
      'We pack in compostable paper and reusable crates. Hand crates back to your courier on your next delivery.',
    ),
  ];

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final q = _q.text.trim().toLowerCase();
    final faq = [
      for (final (i, f) in _faq.indexed)
        if (q.isEmpty || f.$1.toLowerCase().contains(q) || f.$2.toLowerCase().contains(q)) (i, f),
    ];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const TopBar(title: 'Help center'),
            const SizedBox(height: 14),
            ...staggered(stepMs: 60, [
              Text('Hi ${app.firstName}, how can\nwe help today?', style: ts(26, w: W.black, lh: 32, ls: -0.7)),
              AppTextField(icon: AppIcon.search, hint: 'Search help articles…', controller: _q, onChanged: (_) => setState(() {})),
              if (q.isEmpty)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    for (final t in const [
                      (AppIcon.package, AppColors.tintLeaf, AppColors.leafDark, 'Order issues', 'Missing or damaged items'),
                      (AppIcon.card, AppColors.tintOrange, AppColors.tangerine, 'Payments', 'Refunds & charges'),
                      (AppIcon.truck, AppColors.tintMint, AppColors.leaf, 'Delivery', 'Slots, tracking & fees'),
                      (AppIcon.user, AppColors.tintLemon, AppColors.gold, 'Account', 'Profile & security'),
                    ])
                      Pressable(
                        onTap: () => setState(() {
                          _q.text = t.$4.split(' ').first.toLowerCase();
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(22)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconBox(t.$1, bg: t.$2, fg: t.$3, size: 42, iconSize: 21),
                              const Spacer(),
                              Text(t.$4, style: ts(15, w: W.bold)),
                              Text(
                                t.$5,
                                style: ts(12, w: W.medium, c: AppColors.muted),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              Text(
                q.isEmpty ? 'Popular questions' : '${faq.length} result${faq.length == 1 ? '' : 's'}',
                style: ts(16, w: W.black, ls: -0.3),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24)),
                child: faq.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text('No articles match — try chatting with us below.', style: ts(14, c: AppColors.muted)),
                      )
                    : Column(
                        children: [
                          for (final (n, (i, f)) in faq.indexed) ...[
                            if (n > 0) const Divider(height: 1, color: AppColors.line),
                            _Faq(q: f.$1, a: f.$2, open: _open == i, onTap: () => setState(() => _open = _open == i ? -1 : i)),
                          ],
                        ],
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(24)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Still need help?',
                            style: ts(16, w: W.black, c: AppColors.white),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Chat with us · replies in ~2 min',
                            style: ts(13, w: W.medium, c: AppColors.white.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                    RoundButton(
                      icon: AppIcon.phone,
                      size: 46,
                      iconSize: 20,
                      bg: AppColors.forest2,
                      fg: AppColors.white,
                      tooltip: 'Call support',
                      onTap: () => showToast(context, 'Calling Freshly support…'),
                    ),
                    const SizedBox(width: 8),
                    RoundButton(
                      icon: AppIcon.chat,
                      size: 46,
                      iconSize: 20,
                      bg: AppColors.lime,
                      fg: AppColors.forest,
                      tooltip: 'Chat',
                      onTap: () => showToast(context, 'A team member will reply shortly'),
                    ),
                  ],
                ),
              ),
            ]).expand((w) => [w, const SizedBox(height: 16)]),
          ],
        ),
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq({required this.q, required this.a, required this.open, required this.onTap});
  final String q, a;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    scale: 0.99,
    onTap: onTap,
    child: AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(q, style: ts(14, w: W.bold)),
                ),
                const SizedBox(width: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: open ? AppColors.forest : AppColors.cream, shape: BoxShape.circle),
                  child: AnimatedRotation(
                    turns: open ? 0.125 : 0,
                    duration: const Duration(milliseconds: 280),
                    child: Ic(AppIcon.plus, size: 14, color: open ? AppColors.lime : AppColors.ink),
                  ),
                ),
              ],
            ),
            if (open) ...[const SizedBox(height: 8), Text(a, style: ts(13, c: AppColors.muted, lh: 20))],
          ],
        ),
      ),
    ),
  );
}
