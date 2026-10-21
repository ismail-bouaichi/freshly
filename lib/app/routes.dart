import 'package:flutter/cupertino.dart';

import '../data/models.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/order/checkout_screen.dart';
import '../screens/order/order_placed_screen.dart';
import '../screens/order/tracking_screen.dart';
import '../screens/profile/addresses_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/help_center_screen.dart';
import '../screens/profile/invite_screen.dart';
import '../screens/profile/my_orders_screen.dart';
import '../screens/profile/notifications_screen.dart';
import '../screens/profile/payment_methods_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/shell.dart';
import '../screens/shop/cart_screen.dart';
import '../screens/shop/product_detail_screen.dart';
import '../screens/shop/search_screen.dart';

abstract final class Routes {
  static const onboarding = '/';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const shell = '/app';
  static const product = '/product';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const placed = '/order-placed';
  static const tracking = '/tracking';
  static const search = '/search';
  static const editProfile = '/profile/edit';
  static const orders = '/profile/orders';
  static const addresses = '/profile/addresses';
  static const payments = '/profile/payments';
  static const notifications = '/profile/notifications';
  static const invite = '/profile/invite';
  static const help = '/profile/help';
  static const settings = '/profile/settings';
}

class ProductArgs {
  const ProductArgs(this.product, this.heroTag);
  final Product product;
  final String heroTag;
}

class SearchArgs {
  const SearchArgs({this.heroTag = 'search-home', this.openFilters = false, this.query = ''});
  final String heroTag;
  final bool openFilters;
  final String query;
}

/// Maps route names to screens + the transitions designed in the prototype:
/// push (slide), fade-through (shared-element hero), and sheet-style slide-up.
Route<dynamic> onGenerateRoute(RouteSettings s) {
  final a = s.arguments;
  return switch (s.name) {
    Routes.onboarding => _fade(s, const OnboardingScreen()),
    Routes.signIn => _up(s, const SignInScreen()),
    Routes.signUp => _up(s, const SignUpScreen()),
    Routes.shell => _fade(s, MainShell(initialTab: a is int ? a : 0), ms: 520),
    Routes.product => _fade(s, ProductDetailScreen(args: a! as ProductArgs), ms: 520),
    Routes.cart => _up(s, const CartScreen()),
    Routes.checkout => _push(s, const CheckoutScreen()),
    Routes.placed => _fade(s, const OrderPlacedScreen(), ms: 600),
    Routes.tracking => _push(s, const TrackingScreen()),
    Routes.search => _fade(s, SearchScreen(args: a is SearchArgs ? a : const SearchArgs()), ms: 380),
    Routes.editProfile => _up(s, const EditProfileScreen()),
    Routes.orders => _push(s, const MyOrdersScreen()),
    Routes.addresses => _push(s, const AddressesScreen()),
    Routes.payments => _push(s, const PaymentMethodsScreen()),
    Routes.notifications => _push(s, const NotificationsScreen()),
    Routes.invite => _push(s, const InviteScreen()),
    Routes.help => _push(s, const HelpCenterScreen()),
    Routes.settings => _push(s, const SettingsScreen()),
    _ => _fade(s, MainShell(initialTab: 0)),
  };
}

/// iOS-style push with swipe-back.
Route<T> _push<T>(RouteSettings s, Widget page) => CupertinoPageRoute<T>(settings: s, builder: (_) => page);

/// Fade-through with a slight scale — lets Hero animations carry the motion.
Route<T> _fade<T>(RouteSettings s, Widget page, {int ms = 420}) => PageRouteBuilder<T>(
  settings: s,
  transitionDuration: Duration(milliseconds: ms),
  reverseTransitionDuration: Duration(milliseconds: (ms * 0.8).round()),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, anim, _, child) {
    final c = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    return FadeTransition(
      opacity: c,
      child: ScaleTransition(scale: Tween(begin: 0.97, end: 1.0).animate(c), child: child),
    );
  },
);

/// Slides up from the bottom like a sheet (Cart, auth, edit profile).
Route<T> _up<T>(RouteSettings s, Widget page) => PageRouteBuilder<T>(
  settings: s,
  transitionDuration: const Duration(milliseconds: 520),
  reverseTransitionDuration: const Duration(milliseconds: 380),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, anim, _, child) {
    final c = CurvedAnimation(parent: anim, curve: Curves.easeOutQuart, reverseCurve: Curves.easeInCubic);
    return SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(c),
      child: child,
    );
  },
);
