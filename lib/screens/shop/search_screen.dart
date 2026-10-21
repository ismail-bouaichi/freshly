import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons.dart';
import '../../core/motion.dart';
import '../../core/produce.dart';
import '../../core/svg_path.dart';
import '../../core/theme.dart';
import '../../data/app_state.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import '../../widgets/shop.dart';

/// 13–16 · Search: focused state (recents + trending), live results with
/// suggestions and removable filters, the filters sheet, and a helpful
/// no-results state — one screen, driven by the query.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.args});
  final SearchArgs args;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final _ctrl = TextEditingController(text: widget.args.query);
  final _focus = FocusNode();

  String get q => _ctrl.text.trim();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.args.openFilters) {
        _openFilters();
      } else {
        _focus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _setQuery(String s, {bool submit = true}) {
    _ctrl.text = s;
    _ctrl.selection = TextSelection.collapsed(offset: s.length);
    if (submit) {
      AppScope.read(context).addRecent(s);
      _focus.unfocus();
    }
  }

  Future<void> _openFilters() async {
    _focus.unfocus();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: AppColors.forest.withValues(alpha: 0.55),
      builder: (_) => FiltersSheet(query: q),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final hasQuery = q.isNotEmpty;
    final matches = Catalog.all.where((p) => p.matches(q)).toList();
    final results = app.filters.apply(matches);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    child: hasQuery
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: RoundButton(icon: AppIcon.chevronLeft, onTap: () => Navigator.of(context).maybePop(), tooltip: 'Back'),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Expanded(child: _field()),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: ScaleTransition(scale: a, child: c),
                    ),
                    child: hasQuery
                        ? Padding(
                            key: const ValueKey('f'),
                            padding: const EdgeInsets.only(left: 10),
                            child: RoundButton(
                              icon: AppIcon.sliders,
                              bg: AppColors.forest,
                              fg: AppColors.lime,
                              size: 52,
                              badge: app.filters.activeCount,
                              tooltip: 'Filters',
                              onTap: _openFilters,
                            ),
                          )
                        : Pressable(
                            key: const ValueKey('c'),
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Text(
                                'Cancel',
                                style: ts(15, w: W.bold, c: AppColors.leafDark),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                layoutBuilder: heroSafeSwitcherLayout,
                child: !hasQuery
                    ? _Discover(key: const ValueKey('discover'), onPick: _setQuery)
                    : matches.isEmpty
                    ? _NoResults(key: ValueKey('none-$q'), query: q)
                    : _Results(
                        key: const ValueKey('results'),
                        query: q,
                        matches: matches,
                        results: results,
                        onSuggestion: _setQuery,
                        onFilters: _openFilters,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field() => Hero(
    tag: widget.args.heroTag,
    child: Material(
      type: MaterialType.transparency,
      child: Container(
        height: 54,
        padding: const EdgeInsets.only(left: 16, right: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.leaf, width: 1.5),
        ),
        child: Row(
          children: [
            const Ic(AppIcon.search, size: 20, color: AppColors.leafDark),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                textInputAction: TextInputAction.search,
                onSubmitted: (s) => AppScope.read(context).addRecent(s),
                style: ts(15, w: W.bold),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Search fruits, veggies, herbs…',
                  hintStyle: ts(14, w: W.medium, c: AppColors.muted),
                ),
              ),
            ),
            if (_ctrl.text.isNotEmpty)
              Pressable(
                onTap: () {
                  _ctrl.clear();
                  _focus.requestFocus();
                },
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.line, shape: BoxShape.circle),
                  child: const Ic(AppIcon.x, size: 12),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// 13 · Focused search — recent searches and trending items.
class _Discover extends StatelessWidget {
  const _Discover({super.key, required this.onPick});
  final void Function(String) onPick;

  static const _trendMeta = ['+128% searches', 'Pesto season is here', 'Just harvested'];

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (app.recentSearches.isNotEmpty) ...[
          Entrance(
            child: SectionHeader('Recent searches', action: 'Clear all', onAction: app.clearRecents),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (i, r) in app.recentSearches.indexed)
                Entrance(
                  delay: Entrance.step(i, startMs: 150, stepMs: 50),
                  scale: 0.7,
                  offset: Offset.zero,
                  child: Pressable(
                    onTap: () => onPick(r),
                    child: Pill(
                      r,
                      bg: AppColors.white,
                      fg: AppColors.ink,
                      icon: AppIcon.clock,
                      iconColor: AppColors.muted,
                      size: 13,
                      border: AppColors.line,
                      ph: 12,
                      pv: 8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        Entrance(
          delay: const Duration(milliseconds: 160),
          child: Row(
            children: [
              Text('Trending this week', style: ts(17, w: W.black, ls: -0.3)),
              const SizedBox(width: 6),
              const Ic(AppIcon.flame, size: 16, color: AppColors.tangerine),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final (i, p) in Catalog.trending.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Entrance(
              delay: Entrance.step(i, startMs: 300, stepMs: 80),
              offset: const Offset(60, 0),
              child: Pressable(
                scale: 0.98,
                onTap: () => Navigator.of(context).pushNamed(Routes.product, arguments: ProductArgs(p, 'art-trend-${p.id}')),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        child: Text(
                          '${i + 1}',
                          style: ts(14, w: W.black, c: AppColors.muted),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ProduceTile(produce: p.art, tint: p.tint, size: 40, artSize: 32, radius: 12, heroTag: 'art-trend-${p.id}'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: ts(14, w: W.bold)),
                            Text(
                              _trendMeta[i],
                              style: ts(12, w: W.medium, c: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      const Ic(AppIcon.chevronRight, size: 18, color: AppColors.muted),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 14),
        Entrance(
          delay: const Duration(milliseconds: 520),
          child: Text('Browse by category', style: ts(17, w: W.black, ls: -0.3)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in Category.values) CategoryChip(label: c.label, produce: c.art, active: false, onTap: () => onPick(c.label)),
          ],
        ),
      ],
    );
  }
}

/// 14 · Results — suggestions, active filters, count + sort, grid.
class _Results extends StatelessWidget {
  const _Results({
    super.key,
    required this.query,
    required this.matches,
    required this.results,
    required this.onSuggestion,
    required this.onFilters,
  });
  final String query;
  final List<Product> matches;
  final List<Product> results;
  final void Function(String) onSuggestion;
  final VoidCallback onFilters;

  List<String> _suggestions() {
    final s = query.toLowerCase();
    final out = <String>{};
    for (final p in Catalog.all) {
      if (p.name.toLowerCase().contains(s)) out.add(p.name.toLowerCase());
      for (final k in p.keywords) {
        if (k.contains(s) && k != s) out.add(k);
      }
    }
    return out.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final f = app.filters;
    final chips = <(String, VoidCallback)>[
      for (final c in f.categories) (c.label, () => app.setFilters(f.copy()..categories.remove(c))),
      if (f.price.start > 0 || f.price.end < SearchFilters.maxPrice)
        (
          f.price.start == 0 ? 'Under \$${f.price.end.round()}' : '\$${f.price.start.round()} – \$${f.price.end.round()}',
          () => app.setFilters(f.copy()..price = const RangeValues(0, SearchFilters.maxPrice)),
        ),
      for (final t in f.tags) (t.label, () => app.setFilters(f.copy()..tags.remove(t))),
    ];
    final sugg = _suggestions();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (sugg.isNotEmpty)
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: sugg.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Entrance(
                delay: Entrance.step(i, stepMs: 50),
                offset: const Offset(40, 0),
                child: Pressable(
                  onTap: () => onSuggestion(sugg[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.tintLeaf, borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      children: [
                        const Ic(AppIcon.search, size: 13, color: AppColors.leafDark),
                        const SizedBox(width: 6),
                        HighlightText(
                          sugg[i],
                          match: query,
                          style: ts(13, w: W.medium, c: AppColors.muted),
                          highlight: ts(13, w: W.black, c: AppColors.leafDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Entrance(
                delay: Entrance.step(i, startMs: 150, stepMs: 60),
                scale: 0.6,
                offset: Offset.zero,
                child: Pressable(
                  onTap: chips[i].$2,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
                    decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      children: [
                        Text(
                          chips[i].$1,
                          style: ts(13, w: W.bold, c: AppColors.white),
                        ),
                        const SizedBox(width: 6),
                        const Ic(AppIcon.x, size: 14, color: AppColors.lime),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: HighlightText(
                '${results.length} result${results.length == 1 ? '' : 's'} for "$query"',
                match: query,
                style: ts(14, w: W.bold),
                highlight: ts(14, w: W.black, c: AppColors.leafDark),
              ),
            ),
            PopupMenuButton<SortBy>(
              initialValue: f.sort,
              color: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              onSelected: (s) => app.setFilters(f.copy()..sort = s),
              itemBuilder: (_) => [
                for (final s in SortBy.values)
                  PopupMenuItem(
                    value: s,
                    child: Text(s.label, style: ts(14, w: s == f.sort ? W.bold : W.medium)),
                  ),
              ],
              child: Row(
                children: [
                  Text(
                    f.sort == SortBy.popular
                        ? 'Popular'
                        : f.sort == SortBy.priceLow
                        ? 'Price ↑'
                        : 'Price ↓',
                    style: ts(13, w: W.bold, c: AppColors.leafDark),
                  ),
                  const SizedBox(width: 4),
                  const Ic(AppIcon.chevronDown, size: 16, color: AppColors.leafDark),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                Text('${matches.length} match${matches.length == 1 ? '' : 'es'} hidden by your filters', style: ts(15, w: W.bold)),
                const SizedBox(height: 14),
                OutlineButton(label: 'Clear filters', icon: AppIcon.x, onTap: () => app.setFilters(f.copy()..clear())),
              ],
            ),
          )
        else
          ProductGrid(key: ValueKey('${results.map((p) => p.id).join()}-${f.sort}'), products: results, heroScope: 'search', startMs: 200),
      ],
    );
  }
}

/// 16 · No results — explain, offer a notification, suggest alternatives.
class _NoResults extends StatelessWidget {
  const _NoResults({super.key, required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final notify = app.notifyMe.contains(query.toLowerCase());
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      children: [
        SizedBox(
          height: 196,
          child: LayoutBuilder(
            builder: (context, c) {
              final cx = c.maxWidth / 2;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: cx - 90,
                    top: 8,
                    child: Entrance(
                      scale: 0.4,
                      offset: Offset.zero,
                      child: const Dot(size: 180, color: AppColors.tintLemon),
                    ),
                  ),
                  Positioned(
                    left: cx - 48,
                    top: 50,
                    child: Entrance(
                      delay: const Duration(milliseconds: 200),
                      scale: 0.3,
                      rotate: -20,
                      offset: Offset.zero,
                      duration: const Duration(milliseconds: 800),
                      child: const _Wiggle(
                        child: SizedBox(
                          width: 96,
                          height: 96,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle, boxShadow: AppShadows.soft),
                            child: Center(child: Ic(AppIcon.search, size: 52, color: AppColors.muted)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: cx + 34,
                    top: 40,
                    child: Entrance(
                      delay: const Duration(milliseconds: 900),
                      offset: const Offset(0, 10),
                      child: Bob(
                        amplitude: 3,
                        child: Text(
                          '?',
                          style: ts(22, w: W.black, c: AppColors.tangerine),
                        ),
                      ),
                    ),
                  ),
                  for (final (i, a) in [
                    (Produce.lemon, 58.0, -130.0, 110.0, -16.0),
                    (Produce.basil, 54.0, 82.0, 104.0, 14.0),
                    (Produce.strawberry, 44.0, 70.0, 10.0, -10.0),
                  ].indexed)
                    Positioned(
                      left: cx + a.$3,
                      top: a.$4,
                      child: Entrance(
                        delay: Duration(milliseconds: 350 + i * 100),
                        scale: 0.3,
                        offset: Offset.zero,
                        child: Bob(
                          phase: i * 0.3,
                          child: Transform.rotate(
                            angle: figmaRot(a.$5),
                            child: ProduceArt(a.$1, size: a.$2),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Entrance(
          delay: const Duration(milliseconds: 550),
          child: Column(
            children: [
              Text.rich(
                TextSpan(
                  text: 'No matches for "',
                  children: [
                    TextSpan(
                      text: query,
                      style: ts(22, w: W.black, c: AppColors.leafDark),
                    ),
                    const TextSpan(text: '"'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: ts(22, w: W.black, ls: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                "It isn't in season near you yet. Get a ping when it lands, or try these fresh picks instead.",
                textAlign: TextAlign.center,
                style: ts(14, c: AppColors.muted, lh: 22),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Entrance(
          delay: const Duration(milliseconds: 630),
          child: PrimaryButton(
            label: notify ? "We'll let you know" : "Notify me when it's in",
            kind: ButtonStyleKind.lime,
            done: notify,
            trailing: AppIcon.bell,
            onTap: () {
              app.toggleNotify(query);
              if (!notify) showToast(context, "We'll notify you when $query is in season");
            },
          ),
        ),
        const SizedBox(height: 22),
        Entrance(delay: const Duration(milliseconds: 700), child: const SectionHeader('You might like')),
        const SizedBox(height: 12),
        const ProductGrid(products: [Catalog.oranges, Catalog.lemons], heroScope: 'noresults', startMs: 750),
      ],
    );
  }
}

/// Magnifier "searching" wiggle.
class _Wiggle extends StatefulWidget {
  const _Wiggle({required this.child});
  final Widget child;
  @override
  State<_Wiggle> createState() => _WiggleState();
}

class _WiggleState extends State<_Wiggle> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!motionReduced(context) && !_c.isAnimating) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (_, child) {
      final t = _c.value;
      // Shake during the first 40% of each cycle, then rest.
      final a = t < 0.4 ? math.sin(t / 0.4 * math.pi * 4) * 0.22 * (1 - t / 0.4) : 0.0;
      return Transform.rotate(angle: a, child: child);
    },
  );
}

/// 15 · Filters sheet.
class FiltersSheet extends StatefulWidget {
  const FiltersSheet({super.key, required this.query});
  final String query;
  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late SearchFilters _f;
  bool _init = false;

  static const _hist = <double>[10, 18, 28, 36, 30, 24, 16, 26, 20, 12, 8, 6];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    _f = AppScope.read(context).filters.copy();
  }

  @override
  Widget build(BuildContext context) {
    final count = _f.apply(Catalog.all.where((p) => p.matches(widget.query))).length;
    Widget label(String t) => Text(t, style: ts(15, w: W.black, ls: -0.2));
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.paddingOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: staggered(stepMs: 50, offset: const Offset(0, 16), [
            const SheetHandle(),
            Row(
              children: [
                Expanded(
                  child: Text('Filters', style: ts(22, w: W.black, ls: -0.5)),
                ),
                Pressable(
                  onTap: () => setState(() => _f = SearchFilters()),
                  child: Text(
                    'Reset',
                    style: ts(14, w: W.bold, c: AppColors.leafDark),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label('Category'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in Category.values)
                      CategoryChip(
                        label: c.label,
                        produce: c.art,
                        active: _f.categories.contains(c),
                        onTap: () => setState(() => _f.categories.contains(c) ? _f.categories.remove(c) : _f.categories.add(c)),
                      ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: label('Price range')),
                    Text(
                      '\$${_f.price.start.round()} – \$${_f.price.end.round()}',
                      style: ts(14, w: W.black, c: AppColors.leafDark),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < _hist.length; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        Expanded(
                          child: Entrance(
                            delay: Duration(milliseconds: 250 + i * 30),
                            offset: const Offset(0, 14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              height: _hist[i],
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: _inRange(i) ? AppColors.leaf.withValues(alpha: 0.4) : AppColors.line,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                RangeSlider(
                  values: _f.price,
                  min: 0,
                  max: SearchFilters.maxPrice,
                  divisions: 20,
                  onChanged: (v) => setState(() => _f.price = v),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label('Preferences'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in Tag.values)
                      FilterPill(
                        label: t.label,
                        active: _f.tags.contains(t),
                        showCheck: true,
                        inactiveBg: AppColors.cream,
                        onTap: () => setState(() => _f.tags.contains(t) ? _f.tags.remove(t) : _f.tags.add(t)),
                      ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                label('Sort by'),
                const SizedBox(height: 4),
                for (final s in SortBy.values)
                  Pressable(
                    scale: 0.98,
                    onTap: () => setState(() => _f.sort = s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.label,
                              style: ts(14, w: s == _f.sort ? W.bold : W.medium, c: s == _f.sort ? AppColors.ink : AppColors.muted),
                            ),
                          ),
                          RadioDot(selected: s == _f.sort),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: OutlineButton(
                    label: 'Clear',
                    height: 64,
                    onTap: () {
                      AppScope.read(context).setFilters(SearchFilters()..clear());
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Show $count result${count == 1 ? '' : 's'}',
                    onTap: () {
                      AppScope.read(context).setFilters(_f);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ]).expand((w) => [w, const SizedBox(height: 18)]).toList(),
        ),
      ),
    );
  }

  bool _inRange(int bin) {
    final center = (bin + 0.5) / _hist.length * SearchFilters.maxPrice;
    return center >= _f.price.start && center <= _f.price.end;
  }
}
