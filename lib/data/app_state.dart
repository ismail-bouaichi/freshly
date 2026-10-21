import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import 'catalog.dart';
import 'models.dart';

class SearchFilters {
  SearchFilters({Set<Category>? categories, this.price = const RangeValues(0, 5), Set<Tag>? tags, this.sort = SortBy.popular})
    : categories = categories ?? {Category.fruits, Category.veggies},
      tags = tags ?? {Tag.organic, Tag.local};

  Set<Category> categories;
  RangeValues price;
  Set<Tag> tags;
  SortBy sort;

  static const maxPrice = 10.0;

  SearchFilters copy() => SearchFilters(categories: {...categories}, price: price, tags: {...tags}, sort: sort);

  void clear() {
    categories = {};
    price = const RangeValues(0, maxPrice);
    tags = {};
    sort = SortBy.popular;
  }

  int get activeCount => (categories.isNotEmpty ? 1 : 0) + (price.start > 0 || price.end < maxPrice ? 1 : 0) + (tags.isNotEmpty ? 1 : 0);

  List<Product> apply(Iterable<Product> items) {
    final list = items.where((p) {
      if (categories.isNotEmpty && p.categories.intersection(categories).isEmpty) return false;
      if (p.price < price.start || p.price > price.end) return false;
      if (tags.isNotEmpty && !tags.every(p.tags.contains)) return false;
      return true;
    }).toList();
    sortList(list, sort);
    return list;
  }
}

void sortList(List<Product> list, SortBy sort) {
  switch (sort) {
    case SortBy.popular:
      list.sort((a, b) => b.popularity.compareTo(a.popularity));
    case SortBy.priceLow:
      list.sort((a, b) => a.price.compareTo(b.price));
    case SortBy.priceHigh:
      list.sort((a, b) => b.price.compareTo(a.price));
  }
}

/// All app state in one notifier — cart, favorites, profile, preferences.
class AppState extends ChangeNotifier {
  // ---- profile ----
  String name = 'Sara Amrani';
  String email = 'sara@freshly.app';
  String phone = '+1 (555) 014-2290';
  Set<String> diet = {'Vegetarian', 'Organic only'};
  String get initials => name.trim().split(RegExp(r'\s+')).take(2).map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
  String get firstName => name.trim().split(' ').first;

  void updateProfile({required String name, required String email, required String phone, required Set<String> diet}) {
    this.name = name;
    this.email = email;
    this.phone = phone;
    this.diet = diet;
    notifyListeners();
  }

  // ---- cart ----
  final Map<String, int> _cart = {'strawberries': 2, 'avocado': 1, 'basil': 1};
  int _cartBump = 0;
  int get cartBump => _cartBump; // changes every time something is added (drives the badge bounce)

  List<MapEntry<Product, int>> get cartItems => _cart.entries.map((e) => MapEntry(Catalog.byId(e.key), e.value)).toList();
  int qty(Product p) => _cart[p.id] ?? 0;
  int get cartLines => _cart.length;
  int get cartUnits => _cart.values.fold(0, (a, b) => a + b);

  void add(Product p, [int n = 1]) {
    _cart[p.id] = qty(p) + n;
    _cartBump++;
    notifyListeners();
  }

  void setQty(Product p, int q) {
    if (q <= 0) {
      _cart.remove(p.id);
    } else {
      if (q > qty(p)) _cartBump++;
      _cart[p.id] = q;
    }
    notifyListeners();
  }

  void remove(Product p) => setQty(p, 0);

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void addAll(Map<String, int> items) {
    items.forEach((id, n) => _cart[id] = (_cart[id] ?? 0) + n);
    _cartBump++;
    notifyListeners();
  }

  static const freeDeliveryAt = 15.0;
  static const deliveryFee = 2.49;
  String? promoCode = 'FRESHDAY';
  static const promoValue = 1.00;

  double get subtotal => cartItems.fold(0, (s, e) => s + e.key.price * e.value);
  double get delivery => subtotal == 0 || subtotal >= freeDeliveryAt ? 0 : deliveryFee;
  double get discount => promoCode != null && subtotal > 0 ? promoValue : 0;
  double get total => (subtotal + delivery - discount).clamp(0, double.infinity);
  double get freeDeliveryProgress => (subtotal / freeDeliveryAt).clamp(0, 1);

  void removePromo() {
    promoCode = null;
    notifyListeners();
  }

  // ---- orders ----
  Order? lastOrder;
  int _orderSeq = 2482;

  Order placeOrder({required String slot, required String payment}) {
    final order = Order(
      id: '#FR-${_orderSeq++}',
      items: cartItems.map((e) => e.key).toList(),
      total: total,
      status: OrderStatus.packing,
      when: slot,
    );
    lastOrder = order;
    lastPayment = payment;
    _cart.clear();
    promoCode = 'FRESHDAY';
    notifyListeners();
    return order;
  }

  String lastPayment = 'Card';

  // ---- favorites ----
  final Set<String> favorites = {'strawberries', 'avocado', 'basil', 'lemons', 'broccoli'};
  bool isFav(Product p) => favorites.contains(p.id);
  void toggleFav(Product p) {
    favorites.contains(p.id) ? favorites.remove(p.id) : favorites.add(p.id);
    notifyListeners();
  }

  // ---- search ----
  final List<String> recentSearches = ['Avocado', 'Fresh mint', 'Dragonfruit', 'Cherry tomatoes', 'Lemons'];
  SearchFilters filters = SearchFilters();
  final Set<String> notifyMe = {};

  void addRecent(String q) {
    final t = q.trim();
    if (t.isEmpty) return;
    recentSearches.removeWhere((r) => r.toLowerCase() == t.toLowerCase());
    recentSearches.insert(0, t);
    if (recentSearches.length > 8) recentSearches.removeLast();
    notifyListeners();
  }

  void clearRecents() {
    recentSearches.clear();
    notifyListeners();
  }

  void setFilters(SearchFilters f) {
    filters = f;
    notifyListeners();
  }

  void toggleNotify(String q) {
    final k = q.toLowerCase();
    notifyMe.contains(k) ? notifyMe.remove(k) : notifyMe.add(k);
    notifyListeners();
  }

  // ---- addresses ----
  final List<Address> addresses = [
    const Address(
      id: 'home',
      label: 'Home',
      lines: '24 Olive St., Apt 3 · 2nd floor\nGate code 4521',
      icon: 'home',
      tint: AppColors.tintLeaf,
      color: AppColors.leafDark,
    ),
    const Address(
      id: 'work',
      label: 'Work',
      lines: '88 Market Ave., Floor 5\nLeave at reception',
      icon: 'work',
      tint: AppColors.tintOrange,
      color: AppColors.tangerine,
    ),
    const Address(
      id: 'parents',
      label: 'Mom & Dad',
      lines: '12 Cedar Lane\nRing the bell twice',
      icon: 'heart',
      tint: AppColors.tintBerry,
      color: AppColors.berry,
    ),
  ];
  String defaultAddress = 'home';
  Address get currentAddress => addresses.firstWhere((a) => a.id == defaultAddress, orElse: () => addresses.first);

  void setDefaultAddress(String id) {
    defaultAddress = id;
    notifyListeners();
  }

  void addAddress(String label, String lines) {
    final id = 'addr-${addresses.length + 1}-${DateTime.now().millisecondsSinceEpoch}';
    addresses.add(Address(id: id, label: label, lines: lines, icon: 'pin', tint: AppColors.tintLemon, color: AppColors.gold));
    defaultAddress = id;
    notifyListeners();
  }

  // ---- wallet & payment ----
  double wallet = 24.50;
  bool cashOnDelivery = true;
  void topUp(double v) {
    wallet += v;
    notifyListeners();
  }

  void setCash(bool v) {
    cashOnDelivery = v;
    notifyListeners();
  }

  // ---- notification preferences ----
  final Map<String, bool> notif = {
    'quiet': true,
    'orders': true,
    'courier': true,
    'offers': true,
    'season': true,
    'flash': false,
    'recipes': false,
    'newsletter': false,
    'push': true,
  };
  void setNotif(String k, bool v) {
    notif[k] = v;
    notifyListeners();
  }

  // ---- app settings ----
  String language = 'English';
  String currency = 'USD (\$)';
  String units = 'Metric (kg)';
  bool reduceMotion = false;
  bool location = true;
  bool haptics = true;

  void setSetting(String key, Object v) {
    switch (key) {
      case 'language':
        language = v as String;
      case 'currency':
        currency = v as String;
      case 'units':
        units = v as String;
      case 'reduceMotion':
        reduceMotion = v as bool;
      case 'location':
        location = v as bool;
      case 'haptics':
        haptics = v as bool;
    }
    notifyListeners();
  }

  void tick() {
    if (haptics) HapticFeedback.selectionClick();
  }
}

/// Provides [AppState] to the widget tree without any package dependency.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  /// Read and subscribe to changes.
  static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Read without subscribing (use in callbacks).
  static AppState read(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState? maybeRead(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>()?.notifier;
}
