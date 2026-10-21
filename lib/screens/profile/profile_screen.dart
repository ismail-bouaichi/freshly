import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../widgets/common.dart';

/// 11 · Profile
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    void go(String r) => Navigator.of(context).pushNamed(r);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 130),
        children: staggered(stepMs: 70, [
          Row(
            children: [
              Expanded(
                child: Text('Profile', style: ts(28, w: W.black, ls: -0.8)),
              ),
              RoundButton(icon: AppIcon.settings, tooltip: 'Settings', onTap: () => go(Routes.settings)),
            ],
          ),
          _ProfileCard(app: app, onEdit: () => go(Routes.editProfile)),
          Pressable(
            scale: 0.98,
            onTap: () => go(Routes.payments),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.tintLime, borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  const IconBox(AppIcon.sparkle, bg: AppColors.lime, fg: AppColors.forest, size: 44, iconSize: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Freshly Plus', style: ts(15, w: W.black)),
                        Text(
                          'Free delivery on every order',
                          style: ts(12, w: W.medium, c: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const Pill('Try free', bg: AppColors.forest, fg: AppColors.white, ph: 14, pv: 8),
                ],
              ),
            ),
          ),
          GroupCard(
            children: [
              ListRow(
                icon: AppIcon.receipt,
                title: 'My orders',
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Pill('2 active', ph: 10, pv: 4, size: 11), SizedBox(width: 8), Chevron()],
                ),
                onTap: () => go(Routes.orders),
              ),
              ListRow(icon: AppIcon.pin, title: 'Addresses', trailing: const Chevron(), onTap: () => go(Routes.addresses)),
              ListRow(icon: AppIcon.card, title: 'Payment methods', trailing: const Chevron(), onTap: () => go(Routes.payments)),
              ListRow(
                icon: AppIcon.bell,
                title: 'Notifications',
                trailing: AppToggle(value: app.notif['push']!, onChanged: (v) => app.setNotif('push', v)),
                onTap: () => go(Routes.notifications),
              ),
              ListRow(icon: AppIcon.gift, title: 'Invite friends · get \$5', trailing: const Chevron(), onTap: () => go(Routes.invite)),
              ListRow(icon: AppIcon.help, title: 'Help & support', trailing: const Chevron(), onTap: () => go(Routes.help)),
            ],
          ),
          Pressable(
            scale: 0.98,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Log out?'),
                  content: const Text('Your cart and saved items will be here when you come back.'),
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
                        'Log out',
                        style: ts(14, w: W.bold, c: AppColors.berry),
                      ),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) Navigator.of(context).pushNamedAndRemoveUntil(Routes.signIn, (_) => false);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(22)),
              child: Row(
                children: [
                  const IconBox(AppIcon.logout, bg: AppColors.tintBerry, fg: AppColors.berry),
                  const SizedBox(width: 14),
                  Text(
                    'Log out',
                    style: ts(15, w: W.bold, c: AppColors.berry),
                  ),
                ],
              ),
            ),
          ),
        ]).expand((w) => [w, const SizedBox(height: 16)]).toList(),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.app, required this.onEdit});
  final AppState app;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        color: AppColors.forest,
        padding: const EdgeInsets.all(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(right: -70, top: -90, child: Dot(size: 200, color: AppColors.lime.withValues(alpha: 0.1))),
            Column(
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'avatar',
                      child: Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle),
                        child: Text(
                          app.initials,
                          style: ts(22, w: W.black, c: AppColors.forest),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.name,
                            style: ts(18, w: W.black, c: AppColors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            app.email,
                            style: ts(13, w: W.medium, c: AppColors.white.withValues(alpha: 0.7)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Pressable(
                      onTap: onEdit,
                      child: const Pill('Edit', bg: AppColors.lime, fg: AppColors.forest, ph: 14, pv: 7),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    for (final (i, s) in const [('24', 'Orders'), ('\$86', 'Saved'), ('1,240', 'Points')].indexed) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              Text(
                                s.$1,
                                style: ts(18, w: W.black, c: AppColors.white),
                              ),
                              Text(
                                s.$2,
                                style: ts(12, w: W.medium, c: AppColors.white.withValues(alpha: 0.65)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
