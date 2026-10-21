import 'dart:math' as math;
import 'dart:ui';

/// Minimal SVG path-data parser (M L H V C S Q T A Z, absolute + relative).
///
/// Lets the app draw the exact icon and produce paths from the Figma file
/// without depending on an SVG package.
Path parseSvgPath(String d) {
  final tokens = _tokenRe.allMatches(d).map((m) => m.group(0)!).toList();
  final path = Path();
  var i = 0;
  var cmd = '';
  var lastCmd = '';
  double cx = 0, cy = 0; // current point
  double sx = 0, sy = 0; // subpath start
  double lcx = 0, lcy = 0; // last control point (for S / T)

  bool isCmd(String t) => t.length == 1 && _cmdRe.hasMatch(t);
  double n() => double.parse(tokens[i++]);

  while (i < tokens.length) {
    if (isCmd(tokens[i])) {
      cmd = tokens[i++];
    } else if (cmd.isEmpty) {
      throw FormatException('Path data must start with a command', d);
    }
    final rel = cmd == cmd.toLowerCase();
    final up = cmd.toUpperCase();
    switch (up) {
      case 'M':
        var x = n(), y = n();
        if (rel) {
          x += cx;
          y += cy;
        }
        path.moveTo(x, y);
        cx = sx = x;
        cy = sy = y;
        // Following coordinate pairs are implicit line-tos.
        cmd = rel ? 'l' : 'L';
      case 'L':
        var x = n(), y = n();
        if (rel) {
          x += cx;
          y += cy;
        }
        path.lineTo(x, y);
        cx = x;
        cy = y;
      case 'H':
        var x = n();
        if (rel) x += cx;
        path.lineTo(x, cy);
        cx = x;
      case 'V':
        var y = n();
        if (rel) y += cy;
        path.lineTo(cx, y);
        cy = y;
      case 'C':
        var x1 = n(), y1 = n(), x2 = n(), y2 = n(), x = n(), y = n();
        if (rel) {
          x1 += cx;
          y1 += cy;
          x2 += cx;
          y2 += cy;
          x += cx;
          y += cy;
        }
        path.cubicTo(x1, y1, x2, y2, x, y);
        lcx = x2;
        lcy = y2;
        cx = x;
        cy = y;
      case 'S':
        var x2 = n(), y2 = n(), x = n(), y = n();
        if (rel) {
          x2 += cx;
          y2 += cy;
          x += cx;
          y += cy;
        }
        final reflect = lastCmd == 'C' || lastCmd == 'S';
        final x1 = reflect ? 2 * cx - lcx : cx;
        final y1 = reflect ? 2 * cy - lcy : cy;
        path.cubicTo(x1, y1, x2, y2, x, y);
        lcx = x2;
        lcy = y2;
        cx = x;
        cy = y;
      case 'Q':
        var x1 = n(), y1 = n(), x = n(), y = n();
        if (rel) {
          x1 += cx;
          y1 += cy;
          x += cx;
          y += cy;
        }
        path.quadraticBezierTo(x1, y1, x, y);
        lcx = x1;
        lcy = y1;
        cx = x;
        cy = y;
      case 'T':
        var x = n(), y = n();
        if (rel) {
          x += cx;
          y += cy;
        }
        final reflect = lastCmd == 'Q' || lastCmd == 'T';
        final x1 = reflect ? 2 * cx - lcx : cx;
        final y1 = reflect ? 2 * cy - lcy : cy;
        path.quadraticBezierTo(x1, y1, x, y);
        lcx = x1;
        lcy = y1;
        cx = x;
        cy = y;
      case 'A':
        final rx = n(), ry = n(), rot = n();
        final large = n() != 0, sweep = n() != 0;
        var x = n(), y = n();
        if (rel) {
          x += cx;
          y += cy;
        }
        if (rx == 0 || ry == 0) {
          path.lineTo(x, y);
        } else {
          path.arcToPoint(Offset(x, y), radius: Radius.elliptical(rx.abs(), ry.abs()), rotation: rot, largeArc: large, clockwise: sweep);
        }
        cx = x;
        cy = y;
      case 'Z':
        path.close();
        cx = sx;
        cy = sy;
      default:
        throw FormatException('Unsupported path command "$cmd"', d);
    }
    lastCmd = up;
  }
  return path;
}

final _tokenRe = RegExp(r'[a-zA-Z]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?');
final _cmdRe = RegExp(r'[MmLlHhVvCcSsQqTtAaZz]');

/// Degrees (Figma, counter-clockwise positive) → radians for Transform.rotate.
double figmaRot(double deg) => -deg * math.pi / 180;
