import 'package:flutter/material.dart';

import '../core/icons.dart';
import '../core/motion.dart';
import '../core/theme.dart';
import 'common.dart';

class NavItem {
  const NavItem(this.icon, this.label);
  final AppIcon icon;
  final String label;
}

const navItems = [
  NavItem(AppIcon.home, 'Home'),
  NavItem(AppIcon.grid, 'Shop'),
  NavItem(AppIcon.bag, 'Cart'),
  NavItem(AppIcon.heart, 'Saved'),
  NavItem(AppIcon.user, 'Profile'),
];

/// Floating dark nav bar; the lime pill morphs to the active tab
/// (the "Bottom Nav" variants in Figma, animated between).
class FloatingNav extends StatelessWidget {
  const FloatingNav({super.key, required this.index, required this.onTap, this.cartCount = 0, this.cartBump = 0});
  final int index;
  final ValueChanged<int> onTap;
  final int cartCount;
  final int cartBump;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(36), boxShadow: AppShadows.float),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < navItems.length; i++)
            _Tab(
              item: navItems[i],
              active: i == index,
              onTap: () => onTap(i),
              badge: navItems[i].label == 'Cart' ? cartCount : 0,
              bump: cartBump,
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.active, required this.onTap, this.badge = 0, this.bump = 0});
  final NavItem item;
  final bool active;
  final VoidCallback onTap;
  final int badge;
  final int bump;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: item.label,
      selected: active,
      button: true,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: kGentle,
          height: 52,
          padding: EdgeInsets.symmetric(horizontal: active ? 14 : 10),
          decoration: BoxDecoration(color: active ? AppColors.lime : Colors.transparent, borderRadius: BorderRadius.circular(26)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Ic(item.icon, size: 22, color: active ? AppColors.forest : AppColors.white.withValues(alpha: 0.72)),
                  if (badge > 0)
                    Positioned(
                      right: -10,
                      top: -9,
                      child: BumpOnChange(
                        trigger: bump,
                        child: CountBadge(count: badge),
                      ),
                    ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 380),
                curve: kGentle,
                child: active
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label,
                          textScaler: TextScaler.noScaling,
                          style: ts(14, w: W.bold, c: AppColors.forest),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cream fade behind the floating nav so content scrolls under it softly.
class NavFade extends StatelessWidget {
  const NavFade({super.key});
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.55],
          colors: [AppColors.cream.withValues(alpha: 0), AppColors.cream],
        ),
      ),
    ),
  );
}
