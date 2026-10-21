import 'package:flutter/widgets.dart';

import 'svg_path.dart';

/// One drawable shape in a vector illustration or icon.
///
/// When [tintFill] / [tintStroke] are true the shape is painted with the
/// widget's tint color (like `currentColor` in SVG).
class VShape {
  const VShape(this.path, {this.fill, this.stroke, this.strokeWidth = 0, this.opacity = 1, this.tintFill = false, this.tintStroke = false});

  final Path path;
  final Color? fill;
  final Color? stroke;
  final double strokeWidth;
  final double opacity;
  final bool tintFill;
  final bool tintStroke;
}

VShape vp(String d, {Color? fill, Color? stroke, double sw = 0, double op = 1}) =>
    VShape(parseSvgPath(d), fill: fill, stroke: stroke, strokeWidth: sw, opacity: op);

VShape vc(double cx, double cy, double r, {Color? fill, Color? stroke, double sw = 0, double op = 1}) => VShape(
  Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
  fill: fill,
  stroke: stroke,
  strokeWidth: sw,
  opacity: op,
);

VShape ve(double cx, double cy, double rx, double ry, {Color? fill, double op = 1}) => VShape(
  Path()..addOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2)),
  fill: fill,
  opacity: op,
);

VShape vr(double x, double y, double w, double h, {double rx = 0, Color? fill, Color? stroke, double sw = 0, double op = 1}) => VShape(
  Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(rx))),
  fill: fill,
  stroke: stroke,
  strokeWidth: sw,
  opacity: op,
);

class VectorPainter extends CustomPainter {
  VectorPainter(this.shapes, this.viewBox, {this.tint = const Color(0xFF000000), this.strokeScale = 1});

  final List<VShape> shapes;
  final Size viewBox;
  final Color tint;
  final double strokeScale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / viewBox.width, size.height / viewBox.height);
    for (final s in shapes) {
      final fill = s.tintFill ? tint : s.fill;
      if (fill != null) {
        canvas.drawPath(
          s.path,
          Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.fill
            ..color = fill.withValues(alpha: fill.a * s.opacity),
        );
      }
      final stroke = s.tintStroke ? tint : s.stroke;
      if (stroke != null && s.strokeWidth > 0) {
        canvas.drawPath(
          s.path,
          Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.stroke
            ..strokeWidth = s.strokeWidth * strokeScale
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = stroke.withValues(alpha: stroke.a * s.opacity),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(VectorPainter old) =>
      old.shapes != shapes || old.tint != tint || old.viewBox != viewBox || old.strokeScale != strokeScale;
}

/// Paints a list of [VShape]s scaled from [viewBox] into a [width] x [height] box.
class VectorArt extends StatelessWidget {
  const VectorArt(this.shapes, {super.key, required this.viewBox, required this.width, double? height, this.tint = const Color(0xFF000000)})
    : height = height ?? width;

  final List<VShape> shapes;
  final Size viewBox;
  final double width;
  final double height;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, height),
        painter: VectorPainter(shapes, viewBox, tint: tint),
      ),
    );
  }
}
