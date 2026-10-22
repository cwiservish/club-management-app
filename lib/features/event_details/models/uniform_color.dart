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

/// Active palette. Starts as the server's default palette and is replaced by
/// the API's `uniform_colors` once the event dropdown options load.
List<UniformColor> kUniformColors = List.of(_kDefaultUniformColors);

const List<UniformColor> _kDefaultUniformColors = [
  UniformColor(name: 'No color set', color: Colors.transparent, isNone: true),
  UniformColor(name: 'White', color: Color(0xFFFFFFFF)),
  UniformColor(name: 'Cream', color: Color(0xFFF1E9D2)),
  UniformColor(name: 'Silver', color: Color(0xFFC7CCD1)),
  UniformColor(name: 'Gray', color: Color(0xFF9AA0A6)),
  UniformColor(name: 'Charcoal', color: Color(0xFF3F444B)),
  UniformColor(name: 'Black', color: Color(0xFF20242A)),
  UniformColor(name: 'Columbia', color: Color(0xFF9BCBEB)),
  UniformColor(name: 'Royal', color: Color(0xFF2456C4)),
  UniformColor(name: 'Navy', color: Color(0xFF1F2A5A)),
  UniformColor(name: 'Teal', color: Color(0xFF0D7E83)),
  UniformColor(name: 'Red', color: Color(0xFFE02020)),
  UniformColor(name: 'Scarlet', color: Color(0xFFCE1126)),
  UniformColor(name: 'Cardinal', color: Color(0xFFA01A3C)),
  UniformColor(name: 'Maroon', color: Color(0xFF6E1F2E)),
  UniformColor(name: 'Pink', color: Color(0xFFF48FB1)),
  UniformColor(name: 'Hot Pink', color: Color(0xFFE5097F)),
  UniformColor(name: 'Purple', color: Color(0xFF582C83)),
  UniformColor(name: 'Lime', color: Color(0xFF6ABF1D)),
  UniformColor(name: 'Kelly', color: Color(0xFF1E8E3E)),
  UniformColor(name: 'Forest', color: Color(0xFF1B4D2E)),
  UniformColor(name: 'Optic Yellow', color: Color(0xFFF2EA0A)),
  UniformColor(name: 'Gold', color: Color(0xFFFDB913)),
  UniformColor(name: 'Vegas Gold', color: Color(0xFFC5B358)),
  UniformColor(name: 'Orange', color: Color(0xFFF4511E)),
  UniformColor(name: 'Burnt Orange', color: Color(0xFFBF5700)),
  UniformColor(name: 'Brown', color: Color(0xFF5D4037)),
  UniformColor(name: 'Khaki', color: Color(0xFFC9B18C)),
];

/// Replaces the palette with the API's `uniform_colors` ({label, value "#hex"}).
/// "No color set" is always kept as the first entry. Ignored if the list is empty.
void applyUniformPalette(List<({String label, String hex})> colors) {
  final parsed = <UniformColor>[];
  for (final c in colors) {
    final color = hexToColor(c.hex);
    if (color != null) parsed.add(UniformColor(name: c.label, color: color));
  }
  if (parsed.isEmpty) return;
  kUniformColors = [_kDefaultUniformColors.first, ...parsed];
}

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
