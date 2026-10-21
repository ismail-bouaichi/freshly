import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../widgets/common.dart';

/// 24 · Settings — every row works: pickers, toggles (Reduce motion really
/// turns the app's animations off), legal pages and account deletion.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pick(BuildContext context, String key, String title, List<String> options, String current) async {
    final app = AppScope.read(context);
    final v = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + MediaQuery.paddingOf(c).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 16),
            Text(title, style: ts(22, w: W.black)),
            const SizedBox(height: 8),
            for (final o in options)
              Pressable(
                scale: 0.98,
                onTap: () => Navigator.pop(c, o),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(o, style: ts(15, w: o == current ? W.bold : W.medium)),
                      ),
                      RadioDot(selected: o == current),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    if (v != null) app.setSetting(key, v);
  }

  void _legal(BuildContext context, String title) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (c) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (_, sc) => ListView(
        controller: sc,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          const SheetHandle(),
          const SizedBox(height: 16),
          Text(title, style: ts(22, w: W.black)),
          const SizedBox(height: 12),
          Text(
            'We only collect what we need to deliver your groceries: your name, contact details, delivery addresses and order history. '
            'Payment details are handled by our payment provider and never stored on our servers.\n\n'
            'Location is used to show accurate delivery slots and is never sold. You can turn it off any time in Settings.\n\n'
            'You can export or delete your data whenever you like from this screen.',
            style: ts(14, c: AppColors.muted, lh: 22),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const TopBar(title: 'Settings'),
            const SizedBox(height: 12),
            ...staggered(stepMs: 50, [
              const SectionLabel('PREFERENCES'),
              GroupCard(
                children: [
                  ListRow(
                    icon: AppIcon.globe,
                    tint: AppColors.tintLeaf,
                    iconColor: AppColors.leafDark,
                    title: 'Language',
                    trailing: Chevron(value: app.language),
                    onTap: () => _pick(context, 'language', 'Language', const ['English', 'Français', 'Español', 'العربية'], app.language),
                  ),
                  ListRow(
                    icon: AppIcon.cash,
                    tint: AppColors.tintLemon,
                    iconColor: AppColors.gold,
                    title: 'Currency',
                    trailing: Chevron(value: app.currency),
                    onTap: () => _pick(context, 'currency', 'Currency', const ['USD (\$)', 'EUR (€)', 'GBP (£)', 'MAD (DH)'], app.currency),
                  ),
                  ListRow(
                    icon: AppIcon.package,
                    tint: AppColors.tintOrange,
                    iconColor: AppColors.tangerine,
                    title: 'Units',
                    trailing: Chevron(value: app.units),
                    onTap: () => _pick(context, 'units', 'Units', const ['Metric (kg)', 'Imperial (lb)'], app.units),
                  ),
                ],
              ),
              const SectionLabel('APP'),
              GroupCard(
                children: [
                  ListRow(
                    icon: AppIcon.sparkle,
                    tint: AppColors.tintMint,
                    iconColor: AppColors.leaf,
                    title: 'Reduce motion',
                    description: 'Turn off decorative animations',
                    trailing: AppToggle(value: app.reduceMotion, onChanged: (v) => app.setSetting('reduceMotion', v)),
                  ),
                  ListRow(
                    icon: AppIcon.pin,
                    tint: AppColors.tintLeaf,
                    iconColor: AppColors.leafDark,
                    title: 'Location services',
                    description: 'For accurate delivery slots',
                    trailing: AppToggle(value: app.location, onChanged: (v) => app.setSetting('location', v)),
                  ),
                  ListRow(
                    icon: AppIcon.phone,
                    tint: AppColors.tintLemon,
                    iconColor: AppColors.gold,
                    title: 'Haptic feedback',
                    trailing: AppToggle(value: app.haptics, onChanged: (v) => app.setSetting('haptics', v)),
                  ),
                ],
              ),
              const SectionLabel('PRIVACY & LEGAL'),
              GroupCard(
                children: [
                  ListRow(
                    icon: AppIcon.shield,
                    tint: AppColors.tintLeaf,
                    iconColor: AppColors.leafDark,
                    title: 'Privacy & data',
                    trailing: const Chevron(),
                    onTap: () => _legal(context, 'Privacy & data'),
                  ),
                  ListRow(
                    icon: AppIcon.receipt,
                    tint: AppColors.tintOrange,
                    iconColor: AppColors.tangerine,
                    title: 'Terms of service',
                    trailing: const Chevron(),
                    onTap: () => _legal(context, 'Terms of service'),
                  ),
                ],
              ),
              Pressable(
                scale: 0.98,
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Delete account?'),
                      content: const Text('This permanently removes your profile, addresses and order history.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: Text(
                            'Cancel',
                            style: ts(14, w: W.bold, c: AppColors.muted),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: Text(
                            'Delete',
                            style: ts(14, w: W.bold, c: AppColors.berry),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) Navigator.of(context).pushNamedAndRemoveUntil(Routes.onboarding, (_) => false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(22)),
                  child: Row(
                    children: [
                      const IconBox(AppIcon.trash, bg: AppColors.tintBerry, fg: AppColors.berry),
                      const SizedBox(width: 14),
                      Text(
                        'Delete account',
                        style: ts(15, w: W.bold, c: AppColors.berry),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Freshly v1.0.0',
                  style: ts(12, w: W.medium, c: AppColors.muted),
                ),
              ),
            ]).expand((w) => [w, const SizedBox(height: 12)]),
          ],
        ),
      ),
    );
  }
}
