import 'package:flutter/widgets.dart';

import 'vector_art.dart';

/// Hand-drawn produce illustrations (120×120) — the `Produce/*` components.
enum Produce { strawberry, avocado, carrot, lemon, tomato, broccoli, basil, apple, orange }

const _white = Color(0xFFFFFFFF);
const _leafGreen = Color(0xFF2BB673);
const _stemGreen = Color(0xFF1E8A4F);

List<VShape> _build(Produce p) => switch (p) {
  Produce.strawberry => [
    vp('M60 110C36 100 18 76 21 52C23 37 38 31 60 33C82 31 97 37 99 52C102 76 84 100 60 110Z', fill: const Color(0xFFEF4A5F)),
    vp('M60 110C40 101 26 84 23 66C32 84 46 96 60 101C74 96 88 84 97 66C94 84 80 101 60 110Z', fill: const Color(0xFFD63650)),
    for (final s in const [
      [42, 52],
      [60, 48],
      [78, 52],
      [50, 66],
      [70, 66],
      [38, 74],
      [82, 74],
      [60, 82],
      [48, 90],
      [72, 90],
    ])
      ve(s[0].toDouble(), s[1].toDouble(), 2.2, 3.2, fill: const Color(0xFFFFE3B3)),
    vp(
      'M60 38C51 25 38 22 28 27C37 31 44 35 49 40C40 40 33 45 31 52C43 50 52 45 60 42C68 45 77 50 89 52C87 45 80 40 71 40C76 35 83 31 92 27C82 22 69 25 60 38Z',
      fill: _leafGreen,
    ),
    vp('M59 38C58 29 61 20 66 13', stroke: _stemGreen, sw: 4.5),
    ve(40, 62, 5, 10, fill: _white, op: 0.35),
  ],
  Produce.avocado => [
    vp('M60 8C43 8 35 30 29 52C22 76 25 108 60 112C95 108 98 76 91 52C85 30 77 8 60 8Z', fill: const Color(0xFF2F6B2A)),
    vp('M60 16C47 16 41 34 37 54C32 76 35 101 60 104C85 101 88 76 83 54C79 34 73 16 60 16Z', fill: const Color(0xFFB9DE6A)),
    vp('M60 24C50 24 45 39 42 56C38 76 41 95 60 97C79 95 82 76 78 56C75 39 70 24 60 24Z', fill: const Color(0xFFE6F6A9)),
    vc(60, 72, 17, fill: const Color(0xFF8B5A2B)),
    vc(54, 66, 5, fill: const Color(0xFFB47D46)),
  ],
  Produce.carrot => [
    vp(
      'M44 40C44 36 48 34 60 34C72 34 76 36 76 40C76 60 66 96 62 108C61 111 59 111 58 108C54 96 44 60 44 40Z',
      fill: const Color(0xFFFF8A3D),
    ),
    vp('M50 52H60M54 68H64M56 84H62', stroke: const Color(0xFFE06A1F), sw: 3),
    vp('M60 36C56 24 48 14 40 12C44 22 50 30 58 38Z', fill: _leafGreen),
    vp('M60 36C60 22 62 10 66 4C70 14 68 26 62 38Z', fill: const Color(0xFF1E9E5A)),
    vp('M62 38C68 26 78 18 86 16C82 26 74 34 64 40Z', fill: _leafGreen),
    ve(52, 46, 3, 7, fill: _white, op: 0.35),
  ],
  Produce.lemon => [
    vc(15, 62, 6, fill: const Color(0xFFFFD43B)),
    vc(105, 62, 6, fill: const Color(0xFFFFD43B)),
    vp('M18 62C18 44 38 30 60 30C82 30 102 44 102 62C102 80 82 94 60 94C38 94 18 80 18 62Z', fill: const Color(0xFFFFD43B)),
    vp('M22 70C32 86 52 92 68 90C84 88 96 78 100 66C96 82 78 94 60 94C42 94 26 84 22 70Z', fill: const Color(0xFFF2B705)),
    vp('M64 30C70 18 82 14 92 16C88 26 78 32 64 32Z', fill: _leafGreen),
    ve(40, 52, 10, 5, fill: _white, op: 0.4),
  ],
  Produce.tomato => [
    vp('M60 32C87 32 105 46 105 68C105 92 85 108 60 108C35 108 15 92 15 68C15 46 33 32 60 32Z', fill: const Color(0xFFF4553F)),
    vp('M17 74C21 94 39 108 60 108C81 108 99 94 103 74C96 90 80 100 60 100C40 100 24 90 17 74Z', fill: const Color(0xFFD93D2B)),
    vp('M60 44L50 30L49 43L34 38L44 48C50 49 55 48 60 46C65 48 70 49 76 48L86 38L71 43L70 30Z', fill: _leafGreen),
    vp('M60 44V28', stroke: _stemGreen, sw: 4),
    ve(38, 64, 7, 11, fill: _white, op: 0.3),
  ],
  Produce.broccoli => [
    vp('M48 66H72L76 106C76 112 44 112 44 106Z', fill: const Color(0xFFA6D77B)),
    vp('M60 72V100M60 84L68 76M60 92L52 84', stroke: const Color(0xFF86C25A), sw: 3),
    vc(36, 58, 19, fill: const Color(0xFF2E8B3E)),
    vc(84, 58, 19, fill: const Color(0xFF2E8B3E)),
    vc(60, 40, 24, fill: const Color(0xFF3FA34D)),
    vc(48, 64, 16, fill: const Color(0xFF3FA34D)),
    vc(72, 64, 16, fill: const Color(0xFF3FA34D)),
    vc(52, 32, 6, fill: const Color(0xFF5BBF68)),
    vc(30, 52, 5, fill: const Color(0xFF4BAF5A)),
    vc(80, 50, 5, fill: const Color(0xFF5BBF68)),
  ],
  Produce.basil => [
    vp('M60 112V22', stroke: _stemGreen, sw: 4),
    vp('M58 42C44 42 32 34 28 20C44 20 55 28 58 42Z', fill: const Color(0xFF3FB66B)),
    vp('M62 58C76 58 88 50 92 36C78 36 66 44 62 58Z', fill: _leafGreen),
    vp('M58 76C42 76 30 66 26 52C42 52 55 62 58 76Z', fill: _leafGreen),
    vp('M62 92C78 92 90 82 94 68C78 68 66 78 62 92Z', fill: const Color(0xFF3FB66B)),
    vp('M60 26C53 18 53 9 60 3C67 9 67 18 60 26Z', fill: const Color(0xFF5CCB82)),
    vp(
      'M57 41C48 36 40 30 33 23M63 57C72 52 80 46 87 39M57 75C46 70 38 63 31 55M63 91C74 86 82 79 89 71',
      stroke: _stemGreen,
      sw: 1.6,
      op: 0.6,
    ),
  ],
  Produce.apple => [
    vp(
      'M60 40C48 29 22 31 19 57C16 84 36 110 51 110C57 110 58 106 60 106C62 106 63 110 69 110C84 110 104 84 101 57C98 31 72 29 60 40Z',
      fill: const Color(0xFF8CCB3B),
    ),
    vp(
      'M22 70C26 92 40 110 51 110C57 110 58 106 60 106C62 106 63 110 69 110C80 110 94 92 98 70C92 88 80 100 70 100C64 100 62 97 60 97C58 97 56 100 50 100C40 100 28 88 22 70Z',
      fill: const Color(0xFF6FB02A),
    ),
    vp('M60 40C60 30 62 22 66 16', stroke: const Color(0xFF7A4E2A), sw: 4.5),
    vp('M64 26C70 14 84 10 94 14C88 24 76 30 64 26Z', fill: _leafGreen),
    ve(38, 60, 6, 11, fill: _white, op: 0.35),
  ],
  Produce.orange => [
    vc(60, 64, 44, fill: const Color(0xFFFF9A3C)),
    vp('M18 74C23 96 40 108 60 108C83 108 100 92 104 72C96 90 80 100 60 100C40 100 25 90 18 74Z', fill: const Color(0xFFF07C1E)),
    vc(60, 24, 3, fill: const Color(0xFFC9661A)),
    vp('M62 22C68 10 82 6 92 10C86 20 74 26 62 22Z', fill: _leafGreen),
    ve(40, 52, 7, 12, fill: _white, op: 0.3),
    vc(74, 56, 1.6, fill: const Color(0xFFF07C1E)),
    vc(82, 70, 1.6, fill: const Color(0xFFF07C1E)),
    vc(66, 78, 1.6, fill: const Color(0xFFF07C1E)),
    vc(50, 86, 1.6, fill: const Color(0xFFF07C1E)),
  ],
};

final Map<Produce, List<VShape>> _cache = {};
List<VShape> produceShapes(Produce p) => _cache.putIfAbsent(p, () => _build(p));

/// A produce illustration at [size] px.
class ProduceArt extends StatelessWidget {
  const ProduceArt(this.produce, {super.key, this.size = 120});

  final Produce produce;
  final double size;

  @override
  Widget build(BuildContext context) => VectorArt(produceShapes(produce), viewBox: const Size(120, 120), width: size);
}
