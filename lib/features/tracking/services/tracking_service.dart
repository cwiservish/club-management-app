import 'package:flutter/material.dart';
import '../models/tracking_item.dart';

class TrackingService {
  List<TrackingItem> getItems() => const [
        TrackingItem(label: 'Season Goals', current: 27, total: 40, color: Color(0xFF10B981)),
        TrackingItem(label: 'Training Sessions', current: 18, total: 24, color: Color(0xFF1A56DB)),
        TrackingItem(label: 'Team Attendance', current: 88, total: 100, color: Color(0xFF8B5CF6)),
        TrackingItem(label: 'Tournament Points', current: 25, total: 36, color: Color(0xFFF59E0B)),
      ];
}
