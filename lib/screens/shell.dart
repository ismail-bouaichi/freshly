import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../widgets/bottom_nav.dart';
import 'profile/profile_screen.dart';
import 'shop/explore_screen.dart';
import 'shop/home_screen.dart';
import 'shop/saved_screen.dart';

/// Lets tabs switch tabs (e.g. Home "See all" → Explore with a category).
class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required this.goTab, required this.exploreCategory, required super.child});

  /// Nav index: 0 Home · 1 Shop · 2 Cart · 3 Saved · 4 Profile.
  final void Function(int navIndex, {Category? category}) goTab;
  final ValueNotifier<Category> exploreCategory;

  static ShellScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ShellScope>()!;
  static ShellScope? maybeOf(BuildContext context) => context.getInheritedWidgetOfExactType<ShellScope>();

  @override
  bool updateShouldNotify(ShellScope old) => false;
}

/// Tabs (Home, Shop, Saved, Profile) under the floating nav bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _nav = widget.initialTab == 2 ? 0 : widget.initialTab;
  final _category = ValueNotifier(Category.fruits);
  final Set<int> _visited = {};

  static int _stackIndex(int nav) => switch (nav) {
    0 => 0,
    1 => 1,
    3 => 2,
    4 => 3,
    _ => 0,
  };

  void _go(int nav, {Category? category}) {
    if (category != null) _category.value = category;
    if (nav == 2) {
      Navigator.of(context).pushNamed(Routes.cart);
      return;
    }
    AppScope.read(context).tick();
    setState(() => _nav = nav);
  }

  @override
  void dispose() {
    _category.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final idx = _stackIndex(_nav);
    _visited.add(idx);
    const tabs = [HomeScreen(), ExploreScreen(), SavedScreen(), ProfileScreen()];
    return ShellScope(
      goTab: _go,
      exploreCategory: _category,
      child: PopScope(
        canPop: _nav == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _nav = 0);
        },
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Tabs are built lazily on first visit, then kept alive.
              for (var i = 0; i < tabs.length; i++)
                Offstage(
                  offstage: i != idx,
                  child: TickerMode(
                    enabled: i == idx,
                    child: HeroMode(enabled: i == idx, child: _visited.contains(i) ? tabs[i] : const SizedBox.shrink()),
                  ),
                ),
              const Positioned(left: 0, right: 0, bottom: 0, child: NavFade()),
              Positioned(
                left: 24,
                right: 24,
                bottom: 18 + MediaQuery.paddingOf(context).bottom * 0.6,
                child: FloatingNav(index: _nav, onTap: _go, cartCount: app.cartLines, cartBump: app.cartBump),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
