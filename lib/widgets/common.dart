import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/icons.dart';
import '../core/motion.dart';
import '../core/produce.dart';
import '../core/theme.dart';
import '../data/models.dart';

/// Circular icon button (back, search, bell, …). Optional numeric [badge].
class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    this.onTap,
    this.bg = AppColors.white,
    this.fg = AppColors.ink,
    this.size = 48,
    this.iconSize = 22,
    this.badge,
    this.dot = false,
    this.shadow = false,
    this.tooltip,
  });

  final AppIcon icon;
  final VoidCallback? onTap;
  final Color bg;
  final Color fg;
  final double size;
  final double iconSize;
  final int? badge;
  final bool dot;
  final bool shadow;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = Pressable(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: shadow ? AppShadows.soft : null),
              child: Ic(icon, size: iconSize, color: fg),
            ),
            if (dot)
              Positioned(
                right: size * 0.2,
                top: size * 0.24,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.berry,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ),
            if (badge != null && badge! > 0) Positioned(right: -2, top: -2, child: CountBadge(count: badge!)),
          ],
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

class CountBadge extends StatelessWidget {
  const CountBadge({super.key, required this.count, this.bg = AppColors.berry, this.fg = AppColors.white});
  final int count;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => BumpOnChange(
    trigger: count,
    child: Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
      child: Text(
        '$count',
        style: ts(10, w: W.black, c: fg),
      ),
    ),
  );
}

enum ButtonStyleKind { dark, lime }

/// The pill CTA with the arrow bubble ("Button" component set: Dark / Lime).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.kind = ButtonStyleKind.dark,
    this.trailing = AppIcon.arrowRight,
    this.loading = false,
    this.done = false,
  });

  final String label;
  final VoidCallback? onTap;
  final ButtonStyleKind kind;
  final AppIcon trailing;
  final bool loading;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final dark = kind == ButtonStyleKind.dark;
    final enabled = onTap != null;
    final bg = dark ? AppColors.forest : AppColors.lime;
    final fg = dark ? AppColors.white : AppColors.forest;
    final bubble = dark ? AppColors.lime : AppColors.forest;
    final bubbleFg = dark ? AppColors.forest : AppColors.lime;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.45,
      child: Pressable(
        onTap: loading ? null : onTap,
        child: Container(
          height: 64,
          padding: const EdgeInsets.only(left: 26, right: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            boxShadow: dark && enabled ? AppShadows.float : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    label,
                    key: ValueKey(label),
                    style: ts(17, w: W.bold, c: fg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: bubble, shape: BoxShape.circle),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                  child: loading
                      ? SizedBox(
                          key: const ValueKey('l'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: bubbleFg),
                        )
                      : Ic(done ? AppIcon.check : trailing, key: ValueKey(done), size: 22, color: bubbleFg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary outline button.
class OutlineButton extends StatelessWidget {
  const OutlineButton({super.key, required this.label, this.onTap, this.icon, this.height = 56});
  final String label;
  final VoidCallback? onTap;
  final AppIcon? icon;
  final double height;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: AppColors.line, width: 1.5),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Ic(icon!, size: 20), const SizedBox(width: 10)],
          Text(label, style: ts(15, w: W.bold)),
        ],
      ),
    ),
  );
}

/// Small rounded label ("Organic", "On the way", …).
class Pill extends StatelessWidget {
  const Pill(
    this.text, {
    super.key,
    this.bg = AppColors.tintLeaf,
    this.fg = AppColors.leafDark,
    this.icon,
    this.iconColor,
    this.size = 12,
    this.weight = W.bold,
    this.ph = 12,
    this.pv = 6,
    this.border,
    this.ls,
  });
  final String text;
  final Color? bg;
  final Color fg;
  final AppIcon? icon;
  final Color? iconColor;
  final double size;
  final FontWeight weight;
  final double ph;
  final double pv;
  final Color? border;
  final double? ls;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: ph, vertical: pv),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: border == null ? null : Border.all(color: border!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Ic(icon!, size: size + 2, color: iconColor ?? fg), const SizedBox(width: 6)],
        Text(
          text,
          style: ts(size, w: weight, c: fg, ls: ls),
        ),
      ],
    ),
  );
}

/// Rounded square holding an icon (menu rows, info tiles).
class IconBox extends StatelessWidget {
  const IconBox(
    this.icon, {
    super.key,
    this.bg = AppColors.cream,
    this.fg = AppColors.ink,
    this.size = 40,
    this.iconSize = 20,
    this.radius = 14,
  });
  final AppIcon icon;
  final Color bg;
  final Color fg;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius)),
    child: Ic(icon, size: iconSize, color: fg),
  );
}

/// Back · Title · trailing — the standard top bar.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, this.subtitle, this.trailing, this.onBack, this.showBack = true});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Row(
      children: [
        if (showBack)
          RoundButton(icon: AppIcon.chevronLeft, onTap: onBack ?? () => Navigator.of(context).maybePop(), tooltip: 'Back')
        else
          const SizedBox(width: 48),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: ts(18, w: W.black, ls: -0.3),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: ts(12, w: W.medium, c: AppColors.muted),
                ),
            ],
          ),
        ),
        SizedBox(width: 48, child: trailing),
      ],
    ),
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction, this.trailing});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: ts(17, w: W.black, ls: -0.3)),
      ),
      ?trailing,
      if (action != null)
        Pressable(
          onTap: onAction,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              action!,
              style: ts(14, w: W.bold, c: AppColors.leafDark),
            ),
          ),
        ),
    ],
  );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: ts(11, w: W.black, c: AppColors.muted, ls: 1.2),
    ),
  );
}

/// White rounded card.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.white,
    this.radius = 24,
    this.shadow = false,
    this.border,
    this.borderWidth = 1.5,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final bool shadow;
  final Color? border;
  final double borderWidth;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow ? AppShadows.soft : null,
      border: Border.all(color: border ?? Colors.transparent, width: borderWidth),
    ),
    child: child,
  );
}

/// Grouped list (white card with dividers between rows).
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24)),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Divider(height: 1, thickness: 1, color: AppColors.line),
          children[i],
        ],
      ],
    ),
  );
}

/// Row inside a [GroupCard]: icon box · title/description · trailing.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.trailing,
    this.tint = AppColors.cream,
    this.iconColor = AppColors.ink,
    this.titleColor = AppColors.ink,
    this.onTap,
  });
  final AppIcon icon;
  final String title;
  final String? description;
  final Widget? trailing;
  final Color tint;
  final Color iconColor;
  final Color titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          IconBox(icon, bg: tint, fg: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ts(15, w: W.bold, c: titleColor),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: ts(12, w: W.medium, c: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
    return onTap == null ? row : Pressable(onTap: onTap, scale: 0.98, child: row);
  }
}

class Chevron extends StatelessWidget {
  const Chevron({super.key, this.value});
  final String? value;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (value != null) ...[
        Text(
          value!,
          style: ts(13, w: W.bold, c: AppColors.muted),
        ),
        const SizedBox(width: 6),
      ],
      const Ic(AppIcon.chevronRight, size: 18, color: AppColors.muted),
    ],
  );
}

/// Animated on/off switch (the "Toggle" component set).
class AppToggle extends StatelessWidget {
  const AppToggle({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: value,
    child: Pressable(
      scale: 0.94,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: value ? AppColors.leaf : AppColors.line, borderRadius: BorderRadius.circular(14)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: kGentle,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle, boxShadow: AppShadows.soft),
          ),
        ),
      ),
    ),
  );
}

class RadioDot extends StatelessWidget {
  const RadioDot({super.key, required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: 22,
    height: 22,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.white,
      border: Border.all(color: selected ? AppColors.forest : AppColors.line, width: 2),
    ),
    child: AnimatedScale(
      duration: const Duration(milliseconds: 260),
      curve: kGentle,
      scale: selected ? 1 : 0,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(color: AppColors.forest, shape: BoxShape.circle),
      ),
    ),
  );
}

class CheckBoxBox extends StatelessWidget {
  const CheckBoxBox({super.key, required this.value});
  final bool value;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      color: value ? AppColors.forest : AppColors.white,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: value ? AppColors.forest : AppColors.line, width: 1.5),
    ),
    alignment: Alignment.center,
    child: AnimatedScale(
      scale: value ? 1 : 0,
      duration: const Duration(milliseconds: 260),
      curve: kGentle,
      child: const Ic(AppIcon.check, size: 14, color: AppColors.lime),
    ),
  );
}

/// Page indicator: active pill + dots.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index, this.active = AppColors.forest, this.inactive = AppColors.line});
  final int count;
  final int index;
  final Color active;
  final Color inactive;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < count; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == index ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(color: i == index ? active : inactive, borderRadius: BorderRadius.circular(3)),
        ),
    ],
  );
}

/// Tinted rounded tile with a produce illustration.
class ProduceTile extends StatelessWidget {
  const ProduceTile({super.key, required this.produce, required this.tint, this.size = 76, this.artSize, this.radius = 18, this.heroTag});
  final Produce produce;
  final Color tint;
  final double size;
  final double? artSize;
  final double radius;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget art = ProduceArt(produce, size: artSize ?? size * 0.76);
    if (heroTag != null) art = Hero(tag: heroTag!, child: art);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(radius)),
      child: art,
    );
  }
}

/// Overlapping round thumbnails of products (orders, baskets).
class Thumbs extends StatelessWidget {
  const Thumbs({
    super.key,
    required this.items,
    this.size = 44,
    this.ring = AppColors.forest,
    this.max = 3,
    this.moreBg = AppColors.forest2,
  });
  final List<Product> items;
  final double size;
  final Color ring;
  final int max;
  final Color moreBg;

  @override
  Widget build(BuildContext context) {
    final shown = items.take(max).toList();
    final more = items.length - shown.length;
    final count = shown.length + (more > 0 ? 1 : 0);
    final overlap = size * 0.24;
    return SizedBox(
      height: size,
      width: count * size - (count - 1) * overlap,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: shown[i].tint,
                  shape: BoxShape.circle,
                  border: Border.all(color: ring, width: 3),
                ),
                child: ProduceArt(shown[i].art, size: size * 0.62),
              ),
            ),
          if (more > 0)
            Positioned(
              left: shown.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: moreBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: ring, width: 3),
                ),
                child: Text(
                  '+$more',
                  style: ts(13, w: W.black, c: AppColors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dashed ring (orbits behind produce).
class DashedCircle extends StatelessWidget {
  const DashedCircle({super.key, required this.size, required this.color, this.dash = 4, this.gap = 8, this.width = 1.5});
  final double size;
  final Color color;
  final double dash;
  final double gap;
  final double width;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _DashedPainter(color: color, dash: dash, gap: gap, width: width, radius: size / 2, circle: true),
  );
}

/// Dashed rounded-rect border around [child] ("Add new address", invite code).
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.child,
    required this.color,
    this.radius = 20,
    this.dash = 6,
    this.gap = 6,
    this.width = 1.5,
  });
  final Widget child;
  final Color color;
  final double radius;
  final double dash;
  final double gap;
  final double width;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _DashedPainter(color: color, dash: dash, gap: gap, width: width, radius: radius, circle: false),
    child: child,
  );
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({
    required this.color,
    required this.dash,
    required this.gap,
    required this.width,
    required this.radius,
    required this.circle,
  });
  final Color color;
  final double dash;
  final double gap;
  final double width;
  final double radius;
  final bool circle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    final source = Path();
    if (circle) {
      source.addOval(rect);
    } else {
      source.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = color;
    for (final ui.PathMetric m in source.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) => old.color != color || old.dash != dash || old.gap != gap;
}

/// Filled circle helper for decorative glows.
class Dot extends StatelessWidget {
  const Dot({super.key, required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Rounded segmented control with sliding indicator.
class Segmented extends StatelessWidget {
  const Segmented({super.key, required this.labels, required this.index, required this.onChanged});
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(999)),
    child: LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth / labels.length;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 340),
              curve: kGentle,
              left: index * w,
              top: 0,
              bottom: 0,
              width: w,
              child: Container(
                decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: Pressable(
                      onTap: () => onChanged(i),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: ts(14, w: W.bold, c: i == index ? AppColors.white : AppColors.muted),
                          child: Text(labels[i]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

/// Bottom-sheet drag handle.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(3)),
    ),
  );
}

void showToast(BuildContext context, String message, {String? action, VoidCallback? onAction}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 2400),
      action: action == null ? null : SnackBarAction(label: action, onPressed: onAction ?? () {}),
    ),
  );
}

/// Leaf mark + wordmark.
class FreshlyLogo extends StatelessWidget {
  const FreshlyLogo({super.key, this.size = 34, this.dark = false, this.text = 'freshly'});
  final double size;
  final bool dark;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconBox(AppIcon.leaf, bg: AppColors.lime, fg: AppColors.forest, size: size, iconSize: size * 0.53, radius: size * 0.35),
      const SizedBox(width: 8),
      Text(
        text,
        style: ts(size * 0.64, w: W.black, c: dark ? AppColors.ink : AppColors.white, ls: -0.6),
      ),
    ],
  );
}
