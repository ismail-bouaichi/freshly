import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freshly/core/svg_path.dart';
import 'package:freshly/data/app_state.dart';
import 'package:freshly/data/catalog.dart';
import 'package:freshly/main.dart';

void main() {
  group('Cart maths', () {
    test('starts with the designed basket and totals', () {
      final s = AppState();
      expect(s.cartLines, 3);
      expect(s.subtotal, closeTo(11.26, 1e-9));
      expect(s.delivery, AppState.deliveryFee); // under $15
      expect(s.total, closeTo(11.26 + AppState.deliveryFee - AppState.promoValue, 1e-9));
    });

    test('free delivery unlocks at \$15', () {
      final s = AppState()..add(Catalog.oranges, 2); // +3.98 → 15.24
      expect(s.delivery, 0);
      expect(s.freeDeliveryProgress, 1);
    });

    test('setting quantity to 0 removes the line', () {
      final s = AppState()..setQty(Catalog.basil, 0);
      expect(s.qty(Catalog.basil), 0);
      expect(s.cartLines, 2);
    });

    test('placing an order empties the cart', () {
      final s = AppState();
      final order = s.placeOrder(slot: 'Today, 4 – 5 PM', payment: 'Card');
      expect(order.items, isNotEmpty);
      expect(s.cartLines, 0);
      expect(s.lastOrder, same(order));
    });
  });

  group('Search filters', () {
    test('default filters keep organic + local fruit/veg under \$5', () {
      final results = SearchFilters().apply(Catalog.all);
      for (final p in results) {
        expect(p.price, lessThanOrEqualTo(5));
        expect(p.tags.containsAll({...SearchFilters().tags}), isTrue);
      }
    });

    test('cleared filters return everything', () {
      final f = SearchFilters()..clear();
      expect(f.apply(Catalog.all).length, Catalog.all.length);
    });
  });

  test('svg paths parse', () {
    final p = parseSvgPath('M12 5v14M5 12h14');
    expect(p.getBounds().width, closeTo(14, 0.01));
    final arc = parseSvgPath('M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z');
    expect(arc.getBounds().height, greaterThan(10));
  });

  testWidgets('onboarding → skip lands on Home', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(FreshlyApp(state: AppState()));
    // Looping animations never settle, so pump fixed time instead of pumpAndSettle.
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Start shopping'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Fresh picks'), findsOneWidget);
    expect(find.text('Strawberries'), findsWidgets);
  });
}
