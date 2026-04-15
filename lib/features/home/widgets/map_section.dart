import 'package:flutter/material.dart';

// ─── Map placeholder (bottom of home card) ────────────────────────────────────

class MapSection extends StatelessWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 134,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFF1E2533)),
          ),
          CustomPaint(painter: MapGridPainter(), child: const SizedBox.expand()),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_pin, color: Colors.white54, size: 28),
                SizedBox(height: 4),
                Text('Map', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Grid painter ─────────────────────────────────────────────────────────────

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()
      ..color      = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    final road = Paint()
      ..color      = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 3;

    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), light);
    }
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), light);
    }
    canvas.drawLine(
        Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.55), road);
    canvas.drawLine(
        Offset(size.width * 0.3, 0), Offset(size.width * 0.45, size.height), road);
  }

  @override
  bool shouldRepaint(_) => false;
}
