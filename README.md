# Freshly — Flutter app

The Freshly fruits, vegetables & herbs delivery app, built in Flutter from the
Figma design ("Freshly — Fruits, Veggies & Herbs App"). All 24 screens are
included and connected, with the animations from the prototype.

- **No third-party packages.** Icons and produce illustrations are drawn from the
  same vector paths as the Figma components; Plus Jakarta Sans is bundled.
- **Works offline with sample data.** A real cart, favourites, search, filters,
  addresses, wallet and settings all run on local state, ready to be swapped for
  your API.

## Run it

Requires **Flutter 3.35 or newer** (Dart 3.9+). The code was type-checked
against Flutter 3.47.

```bash
cd freshly
flutter create . --project-name freshly --platforms=android,ios   # adds the android/ and ios/ folders
flutter pub get
flutter run
```

`flutter create .` only adds missing platform files — it does not touch `lib/`,
`pubspec.yaml` or the tests. Add `web` to `--platforms` to run it in Chrome.

Tests: `flutter test` (cart maths, search filters, the SVG path parser, and an
onboarding → Home smoke test).

## Screens

| # | Screen | File |
|---|---|---|
| 01 | Onboarding — 3 swipeable pages: fresh groceries, local farms, live tracking | `screens/auth/onboarding_screen.dart` |
| 05 | Sign in | `screens/auth/sign_in_screen.dart` |
| 12 | Sign up (live email check, password strength) | `screens/auth/sign_up_screen.dart` |
| 02 | Home (auto-playing promo banners) | `screens/shop/home_screen.dart` |
| 06 | Explore (categories, tags, sort) | `screens/shop/explore_screen.dart` |
| 13–16 | Search, results, filters sheet, no results | `screens/shop/search_screen.dart` |
| 03 | Product detail | `screens/shop/product_detail_screen.dart` |
| 04 | Cart (swipe to delete, free-delivery progress) | `screens/shop/cart_screen.dart` |
| 07 | Saved (favourites & baskets) | `screens/shop/saved_screen.dart` |
| 08 | Checkout | `screens/order/checkout_screen.dart` |
| 09 | Order placed | `screens/order/order_placed_screen.dart` |
| 10 | Live tracking | `screens/order/tracking_screen.dart` |
| 11 | Profile | `screens/profile/profile_screen.dart` |
| 17–24 | Edit profile, My orders, Addresses, Payment methods, Notifications, Invite, Help center, Settings | `screens/profile/` |

Home, Shop, Saved and Profile live under the floating nav bar in `screens/shell.dart`.

## Project layout

```
lib/
  main.dart              app entry, theme, routes
  app/routes.dart        route names + transitions (push, slide-up, fade-through)
  core/
    theme.dart           colors, shadows, type — mirrors the Figma variables & styles
    icons.dart           the icon set (same paths as the Figma Icon/* components)
    produce.dart         the produce illustrations (Figma Produce/* components)
    svg_path.dart        tiny SVG path parser used by icons & illustrations
    vector_art.dart      painter for icons/illustrations/maps
    motion.dart          Entrance, Bob, Spin, Pulse, Breathe, Pressable, AnimatedMoney…
  data/
    models.dart          Product, Category, Tag, Order, Address…
    catalog.dart         sample products, baskets and orders
    app_state.dart       AppState (cart, favourites, filters, profile, settings) + AppScope
  widgets/               shared UI: buttons, pills, cards, toggles, nav bar, product card…
  screens/               auth/, shop/, order/, profile/ + shell.dart
```

## Animation

- **Entrances:** every screen cascades in (fade + slide, spring "pop" for produce) — `Entrance` in `core/motion.dart`.
- **Shared elements:** the produce flies from a card into Product detail; the search bar morphs into the Search screen; the avatar moves into Edit profile.
- **Ambient loops:** floating produce, spinning orbits, twinkling sparkles, pulsing map pins.
- **Live motion:** the courier drives the route on the tracking map while the ETA counts down; the order-placed check draws itself while produce bursts out.
- **Micro-interactions:** press-to-shrink on every tappable, animated toggles and radios, rolling quantity numbers, counting totals, bouncing cart badge, morphing nav pill.
- **Accessibility:** Settings → *Reduce motion* (or the system setting) turns decorative animation off.

## Connecting a backend

Screens only read from `Catalog` and `AppState`:

- Replace `Catalog` (in `data/catalog.dart`) with data from your API.
- Move the methods in `AppState` (`add`, `placeOrder`, `addAddress`, `topUp`, …) to call your server.
- Sign in / sign up currently simulate a request; plug in your auth provider in `sign_in_screen.dart` and `sign_up_screen.dart`.
- Payments, phone calls, chat and the photo picker show placeholder messages. Wire them to real SDKs when you're ready.

Fonts: Plus Jakarta Sans, SIL Open Font License (`assets/fonts/OFL.txt`).
