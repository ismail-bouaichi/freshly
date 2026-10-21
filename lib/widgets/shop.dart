import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../core/icons.dart';
import '../core/motion.dart';
import '../core/produce.dart';
import '../core/theme.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import 'common.dart';

/// Product tile used in every grid ("Product Card" component).
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.heroScope});
  final Product product;

  /// Distinguishes hero tags when the same product shows on several screens.
  final String heroScope;

  String get heroTag => 'art-$heroScope-${product.id}';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final fav = app.isFav(product);
    final q = app.qty(product);
    return Pressable(
      scale: 0.97,
      onTap: () => Navigator.of(context).pushNamed(Routes.product, arguments: ProductArgs(product, heroTag)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(26), boxShadow: AppShadows.soft),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 128,
              decoration: BoxDecoration(color: product.tint, borderRadius: BorderRadius.circular(20)),
              child: Stack(
                children: [
                  Center(
                    child: Hero(tag: heroTag, child: ProduceArt(product.art, size: 96)),
                  ),
                  if (product.oldPrice != null)
                    const Positioned(
                      left: 8,
                      top: 8,
                      child: Pill('SALE', bg: AppColors.berry, fg: AppColors.white, size: 9, weight: W.black, ph: 8, pv: 4, ls: 0.8),
                    ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Pressable(
                      onTap: () => app.toggleFav(product),
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (c, a) => ScaleTransition(
                            scale: CurvedAnimation(parent: a, curve: kGentle),
                            child: c,
                          ),
                          child: Ic(fav ? AppIcon.heartFill : AppIcon.heart, key: ValueKey(fav), size: 16, color: AppColors.berry),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: ts(15, w: W.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.unit,
                    style: ts(12, c: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      money(product.price),
                      style: ts(18, w: W.black, c: AppColors.forest),
                    ),
                  ),
                  Pressable(
                    onTap: () {
                      app.add(product);
                      showToast(
                        context,
                        '${product.name} added to cart',
                        action: 'View',
                        onAction: () => Navigator.of(context).pushNamed(Routes.cart),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: q > 0 ? AppColors.lime : AppColors.forest, borderRadius: BorderRadius.circular(13)),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                        child: q > 0
                            ? Text(
                                '$q',
                                key: ValueKey(q),
                                style: ts(15, w: W.black, c: AppColors.forest),
                              )
                            : const Ic(AppIcon.plus, key: ValueKey('plus'), size: 18, color: AppColors.lime),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two-column product grid with staggered entrance.
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products, required this.heroScope, this.startMs = 0});
  final List<Product> products;
  final String heroScope;
  final int startMs;

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.zero,
    itemCount: products.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      mainAxisExtent: 252,
    ),
    itemBuilder: (_, i) => Entrance(
      delay: Entrance.step(i, startMs: startMs, stepMs: 80),
      offset: const Offset(0, 40),
      scale: 0.92,
      child: ProductCard(product: products[i], heroScope: heroScope),
    ),
  );
}

/// Category chip with produce bubble ("Category Chip" component set).
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.label, required this.produce, required this.active, this.onTap});
  final String label;
  final Produce produce;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(7, 7, 18, 7),
      decoration: BoxDecoration(
        color: active ? AppColors.forest : AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? AppColors.forest : AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: active ? AppColors.lime : AppColors.cream, shape: BoxShape.circle),
            child: ProduceArt(produce, size: 26),
          ),
          const SizedBox(width: 10),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 260),
            style: ts(14, w: W.bold, c: active ? AppColors.white : AppColors.ink),
            child: Text(label),
          ),
        ],
      ),
    ),
  );
}

/// Filter pill (All / Seasonal / Organic …).
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.active,
    this.onTap,
    this.inactiveBg = AppColors.white,
    this.showCheck = false,
  });
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final Color inactiveBg;
  final bool showCheck;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.forest : inactiveBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? AppColors.forest : (inactiveBg == AppColors.white ? AppColors.line : inactiveBg)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            child: active && showCheck
                ? const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Ic(AppIcon.check, size: 14, color: AppColors.lime),
                  )
                : const SizedBox.shrink(),
          ),
          Text(
            label,
            style: ts(13, w: W.bold, c: active ? AppColors.white : AppColors.ink),
          ),
        ],
      ),
    ),
  );
}

/// − 1 + quantity control ("Qty Stepper" component).
class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.value, required this.onChanged, this.min = 1, this.bg = AppColors.cream, this.shadow = false});
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final Color bg;
  final bool shadow;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999), boxShadow: shadow ? AppShadows.soft : null),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RoundButton(
          icon: value <= min && min == 0 ? AppIcon.trash : AppIcon.minus,
          size: 34,
          iconSize: 16,
          onTap: value > min ? () => onChanged(value - 1) : null,
          tooltip: 'Decrease',
        ),
        SizedBox(
          width: 34,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (c, a) => SlideTransition(
              position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(a),
              child: FadeTransition(opacity: a, child: c),
            ),
            child: Text(
              '$value',
              key: ValueKey(value),
              textAlign: TextAlign.center,
              style: ts(16, w: W.black),
            ),
          ),
        ),
        RoundButton(
          icon: AppIcon.plus,
          size: 34,
          iconSize: 16,
          bg: AppColors.forest,
          fg: AppColors.lime,
          onTap: () => onChanged(value + 1),
          tooltip: 'Increase',
        ),
      ],
    ),
  );
}

/// Read-only search bar that opens the search screen (shared-element hero).
class SearchLauncher extends StatelessWidget {
  const SearchLauncher({super.key, required this.heroTag, this.hint = 'Search fruits, veggies, herbs…', this.showFilter = true});
  final String heroTag;
  final String hint;
  final bool showFilter;

  @override
  Widget build(BuildContext context) {
    void open({bool filters = false}) => Navigator.of(context).pushNamed(
      Routes.search,
      arguments: SearchArgs(heroTag: heroTag, openFilters: filters),
    );
    return Row(
      children: [
        Expanded(
          child: Pressable(
            scale: 0.98,
            onTap: open,
            child: Hero(
              tag: heroTag,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Ic(AppIcon.search, size: 20, color: AppColors.muted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          hint,
                          style: ts(14, w: W.medium, c: AppColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showFilter) ...[
          const SizedBox(width: 12),
          Pressable(
            onTap: () => open(filters: true),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(20)),
              child: const Ic(AppIcon.sliders, size: 22, color: AppColors.lime),
            ),
          ),
        ],
      ],
    );
  }
}

/// Text field styled like the Figma inputs; border turns leaf-green on focus.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.icon,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.trailing,
    this.keyboardType,
    this.onChanged,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
  });

  final AppIcon icon;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      padding: const EdgeInsets.only(left: 18, right: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: focused ? AppColors.leaf : AppColors.line, width: focused ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Ic(widget.icon, size: 20, color: focused ? AppColors.leafDark : AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              obscureText: widget.obscure,
              keyboardType: widget.keyboardType,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: widget.textInputAction,
              style: ts(15, w: W.semi, ls: widget.obscure ? 2 : null),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: ts(15, w: W.medium, c: AppColors.muted),
              ),
            ),
          ),
          if (widget.trailing != null) ...[const SizedBox(width: 8), widget.trailing!],
        ],
      ),
    );
  }
}

/// Text with every occurrence of [match] bolded/coloured (search suggestions).
class HighlightText extends StatelessWidget {
  const HighlightText(this.text, {super.key, required this.match, required this.style, required this.highlight});
  final String text;
  final String match;
  final TextStyle style;
  final TextStyle highlight;

  @override
  Widget build(BuildContext context) {
    final q = match.trim().toLowerCase();
    if (q.isEmpty) return Text(text, style: style);
    final spans = <TextSpan>[];
    final lower = text.toLowerCase();
    var start = 0;
    while (true) {
      final i = lower.indexOf(q, start);
      if (i < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (i > start) spans.add(TextSpan(text: text.substring(start, i)));
      spans.add(TextSpan(text: text.substring(i, i + q.length), style: highlight));
      start = i + q.length;
    }
    return Text.rich(TextSpan(style: style, children: spans));
  }
}

/// AnimatedSwitcher layout that disables heroes in outgoing children, so a
/// tap during the cross-fade never sees two heroes with the same tag.
Widget heroSafeSwitcherLayout(Widget? current, List<Widget> previous) => Stack(
  alignment: Alignment.topCenter,
  children: [
    for (final p in previous) HeroMode(enabled: false, child: IgnorePointer(child: p)),
    ?current,
  ],
);
