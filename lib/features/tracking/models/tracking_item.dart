import 'package:flutter/material.dart';

class TrackingItem {
  final String label;
  final int current;
  final int total;
  final Color color;

  const TrackingItem({
    required this.label,
    required this.current,
    required this.total,
    required this.color,
  });
}
