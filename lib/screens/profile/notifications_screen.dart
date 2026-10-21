import 'package:flutter/material.dart';

import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../widgets/common.dart';

/// 21 · Notifications
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    Widget t(String key) => AppToggle(value: app.notif[key]!, onChanged: (v) => app.setNotif(key, v));
    final enabled = app.notif.entries.where((e) => e.key != 'quiet' && e.key != 'push' && e.value).length;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            TopBar(title: 'Notifications', subtitle: '$enabled of 7 on'),
            const SizedBox(height: 14),
            ...staggered(stepMs: 60, [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(24)),
                child: Row(
                  children: [
                    Entrance(
                      rotate: -25,
                      offset: Offset.zero,
                      delay: const Duration(milliseconds: 200),
                      child: const IconBox(AppIcon.moon, bg: AppColors.lime, fg: AppColors.forest, size: 46, iconSize: 22, radius: 16),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quiet hours',
                            style: ts(15, w: W.bold, c: AppColors.white),
                          ),
                          Text(
                            '10:00 PM – 8:00 AM',
                            style: ts(13, w: W.medium, c: AppColors.white.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                    t('quiet'),
                  ],
                ),
              ),
              const SectionLabel('ORDERS'),
              GroupCard(
                children: [
                  ListRow(
                    icon: AppIcon.package,
                    tint: AppColors.tintLeaf,
                    iconColor: AppColors.leafDark,
                    title: 'Order updates',
                    description: 'Packing, pickup & delivery',
                    trailing: t('orders'),
                  ),
                  ListRow(
                    icon: AppIcon.truck,
                    tint: AppColors.tintMint,
                    iconColor: AppColors.leaf,
                    title: 'Courier nearby',
                    description: 'When your basket is 5 min away',
                    trailing: t('courier'),
                  ),
                ],
              ),
              const SectionLabel('DEALS'),
              GroupCard(
                children: [
                  ListRow(
                    icon: AppIcon.ticket,
                    tint: AppColors.tintOrange,
                    iconColor: AppColors.tangerine,
                    title: 'Weekly offers',
                    description: 'Fresh deals every Monday',
                    trailing: t('offers'),
                  ),
                  ListRow(
                    icon: AppIcon.leaf,
                    tint: AppColors.tintLime,
                    iconColor: AppColors.leafDark,
                    title: 'Back in season',
                    description: 'Saved items return to stock',
                    trailing: t('season'),
                  ),
                  ListRow(
                    icon: AppIcon.flame,
                    tint: AppColors.tintBerry,
                    iconColor: AppColors.berry,
                    title: 'Flash sales',
                    description: 'Limited-time price drops',
                    trailing: t('flash'),
                  ),
                ],
              ),
              const SectionLabel('OTHER'),
              GroupCard(
                children: [
                  ListRow(
                    icon: AppIcon.sparkle,
                    tint: AppColors.tintLemon,
                    iconColor: AppColors.gold,
                    title: 'Recipes & tips',
                    description: "Ideas for what's in your cart",
                    trailing: t('recipes'),
                  ),
                  ListRow(
                    icon: AppIcon.mail,
                    tint: AppColors.tintLeaf,
                    iconColor: AppColors.leafDark,
                    title: 'Email newsletter',
                    description: 'Monthly stories from our farms',
                    trailing: t('newsletter'),
                  ),
                ],
              ),
            ]).expand((w) => [w, const SizedBox(height: 14)]),
          ],
        ),
      ),
    );
  }
}
