import 'package:flutter/material.dart';

class UniformColor {
  final String name;
  final Color color;
  final bool isNone;

  const UniformColor({
    required this.name,
    required this.color,
    this.isNone = false,
  });
}

const List<UniformColor> kUniformColors = [
  // Row 1
  UniformColor(name: 'No color set', color: Colors.transparent, isNone: true),
  UniformColor(name: 'White', color: Color(0xFFFFFFFF)),
  UniformColor(name: 'Cream', color: Color(0xFFF5EFEB)),
  UniformColor(name: 'Light Gray', color: Color(0xFFCFD8DC)),
  UniformColor(name: 'Slate Gray', color: Color(0xFF90A4AE)),
  UniformColor(name: 'Dark Gray', color: Color(0xFF37474F)),
  UniformColor(name: 'Black', color: Color(0xFF212121)),
  // Row 2
  UniformColor(name: 'Sky Blue', color: Color(0xFF90CAF9)),
  UniformColor(name: 'Blue', color: Color(0xFF1E88E5)),
  UniformColor(name: 'Navy Blue', color: Color(0xFF1A237E)),
  UniformColor(name: 'Teal', color: Color(0xFF00796B)),
  UniformColor(name: 'Red', color: Color(0xFFE53935)),
  UniformColor(name: 'Crimson', color: Color(0xFFC62828)),
  UniformColor(name: 'Wine', color: Color(0xFF8D0B3C)),
  // Row 3
  UniformColor(name: 'Maroon', color: Color(0xFF4A148C)),
  UniformColor(name: 'Pink', color: Color(0xFFF48FB1)),
  UniformColor(name: 'Magenta', color: Color(0xFFD81B60)),
  UniformColor(name: 'Purple', color: Color(0xFF512DA8)),
  UniformColor(name: 'Lime', color: Color(0xFF7CB342)),
  UniformColor(name: 'Green', color: Color(0xFF2E7D32)),
  UniformColor(name: 'Dark Green', color: Color(0xFF1B5E20)),
  // Row 4
  UniformColor(name: 'Yellow', color: Color(0xFFFFEB3B)),
  UniformColor(name: 'Gold', color: Color(0xFFFFC107)),
  UniformColor(name: 'Olive', color: Color(0xFF8D8D1A)),
  UniformColor(name: 'Orange', color: Color(0xFFF57C00)),
  UniformColor(name: 'Rust', color: Color(0xFFD84315)),
  UniformColor(name: 'Chocolate', color: Color(0xFF4E342E)),
  UniformColor(name: 'Tan', color: Color(0xFFD7CCC8)),
];

/// Converts a [UniformColor] to a hex string like `#RRGGBB`.
/// Returns empty string for the "No color set" entry.
String uniformColorToHex(UniformColor c) {
  if (c.isNone) return '';
  final r = c.color.red.toRadixString(16).padLeft(2, '0');
  final g = c.color.green.toRadixString(16).padLeft(2, '0');
  final b = c.color.blue.toRadixString(16).padLeft(2, '0');
  return '#$r$g$b'.toUpperCase();
}

/// Converts a hex string like `#RRGGBB` or `RRGGBB` to a Flutter [Color].
/// Returns null if the string is empty or unparseable.
Color? hexToColor(String hex) {
  if (hex.isEmpty) return null;
  final clean = hex.replaceAll('#', '');
  final value = int.tryParse(clean, radix: 16);
  if (value == null) return null;
  return Color(0xFF000000 | value);
}

/// Returns the display name for a hex color string.
/// Returns `'-'` if the hex is empty or doesn't match any palette entry.
String uniformColorName(String hex) {
  if (hex.isEmpty) return '-';
  final index = hexToColorIndex(hex);
  final color = kUniformColors[index];
  return color.isNone ? '-' : color.name;
}

/// Maps a hex string to the index of the matching entry in [kUniformColors].
/// Returns 0 (No color set) if no match is found or the string is empty.
int hexToColorIndex(String hex) {
  if (hex.isEmpty) return 0;
  final normalized = hex.toUpperCase().replaceAll('#', '');
  for (int i = 0; i < kUniformColors.length; i++) {
    final c = kUniformColors[i];
    if (c.isNone) continue;
    final r = (c.color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.color.b * 255).round().toRadixString(16).padLeft(2, '0');
    if ('$r$g$b'.toUpperCase() == normalized) return i;
  }
  return 0;
}
