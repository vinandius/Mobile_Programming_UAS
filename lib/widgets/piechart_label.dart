import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/category_stats.dart';

/// Pie chart penuh dengan garis penunjuk tipis (berwarna sesuai irisan) ke luar,
/// diikuti tulisan nama kategori dan persentasenya.
class PiechartLabel extends StatelessWidget {
  final List<CategoryStat> stats;
  final double height;

  const PiechartLabel({super.key, required this.stats, this.height = 280});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _PiePainter(stats)),
    );
  }
}

class _LabelItem {
  final Offset edge;
  final Offset elbow;
  final double endX;
  final bool right;
  final TextPainter name;
  final TextPainter pct;
  final Color color;
  double y;

  _LabelItem(
    this.edge,
    this.elbow,
    this.endX,
    this.right,
    this.name,
    this.pct,
    this.color,
  ) : y = elbow.dy;

  double get height => name.height + pct.height;
}

class _PiePainter extends CustomPainter {
  final List<CategoryStat> stats;
  _PiePainter(this.stats);

  TextPainter _line(String text, double maxWidth, {bool bold = false}) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 11,
          height: 1.25,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width * 0.22, size.height / 2 - 30);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final separator = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    const radialLead = 30.0;
    const sideLead = 4.0;
    const straightLead = 25.0;
    const curve = 2.0;
    final items = <_LabelItem>[];
    final starts = <double>[];
    var start = -pi / 2;

    // 1) irisan + data label
    for (final s in stats) {
      final sweep = s.percent / 100 * 2 * pi;
      final color = colorForCategory(s.category);
      starts.add(start);

      canvas.drawArc(rect, start, sweep, true, Paint()..color = color);

      final mid = start + sweep / 2;
      final dx = cos(mid);
      final dy = sin(mid);
      final right = dx >= 0;

      final edge = center + Offset(dx * radius, dy * radius);
      final elbow =
          center +
          Offset(dx * (radius + radialLead), dy * (radius + radialLead));
      final endX = elbow.dx + (right ? sideLead : -sideLead);

      final pctText = s.percent < 1 ? '<1%' : '${s.percent.round()}%';
      final maxWidth = max(30.0, right ? size.width - endX - 8 : endX - 8);

      items.add(
        _LabelItem(
          edge,
          elbow,
          endX,
          right,
          _line(s.category, maxWidth),
          _line(pctText, maxWidth, bold: true),
          color,
        ),
      );
      start += sweep;
    }

    // 2) garis putih pemisah antar irisan (satu di atas pie untuk irisan pertama)
    for (final a in starts) {
      canvas.drawLine(
        center,
        center + Offset(cos(a) * radius, sin(a) * radius),
        separator,
      );
    }

    // 3) cegah label bertumpuk: urutkan per sisi, dorong ke bawah bila rapat
    for (final side in [true, false]) {
      final group = items.where((i) => i.right == side).toList()
        ..sort((a, b) => a.y.compareTo(b.y));

      for (var i = 1; i < group.length; i++) {
        final minY =
            group[i - 1].y + (group[i - 1].height + group[i].height) / 2 + 2;
        if (group[i].y < minY) group[i].y = minY;
      }
      // kalau terlalu ke bawah, tarik kembali supaya tetap di dalam kanvas
      for (var i = group.length - 1; i >= 0; i--) {
        final maxY = i == group.length - 1
            ? size.height - group[i].height / 2
            : group[i + 1].y - (group[i + 1].height + group[i].height) / 2 - 2;
        if (group[i].y > maxY) group[i].y = maxY;
      }
    }

    // 4) garis penunjuk (lurus keluar dari pie, lalu melengkung) + tulisan
    for (final i in items) {
      final linePaint = Paint()
        ..color = i.color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // arah radial dari pusat pie ke titik tepi irisan
      final dir = (i.edge - center) / radius;
      final straightEnd = center + dir * (radius + straightLead);

      final path = Path()
        ..moveTo(i.edge.dx, i.edge.dy)
        ..lineTo(straightEnd.dx, straightEnd.dy) // bagian lurus
        ..cubicTo(
          straightEnd.dx + dir.dx * curve, // lanjut searah radial
          straightEnd.dy + dir.dy * curve,
          i.endX + (i.right ? -curve : curve), // mendekat secara horizontal
          i.y,
          i.endX,
          i.y,
        );
      canvas.drawPath(path, linePaint);

      final top = i.y - i.height / 2;
      if (i.right) {
        final x = i.endX + 4;
        i.name.paint(canvas, Offset(x, top));
        i.pct.paint(canvas, Offset(x, top + i.name.height));
      } else {
        final x = i.endX - 4; // rata kanan: tulisan berakhir di garis
        i.name.paint(canvas, Offset(x - i.name.width, top));
        i.pct.paint(canvas, Offset(x - i.pct.width, top + i.name.height));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) => true;
}
