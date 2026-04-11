import 'package:flutter/material.dart';
import '../models/registration_item.dart';

class RegistrationService {
  List<RegistrationItem> getItems() => const [
        RegistrationItem(title: 'Team Registration', subtitle: 'Spring 2026', status: 'Registered', color: Color(0xFF10B981)),
        RegistrationItem(title: 'Player Insurance', subtitle: 'All Players', status: '16 / 16 Covered', color: Color(0xFF10B981)),
        RegistrationItem(title: 'Tournament Registration', subtitle: 'Spring Cup 2026', status: 'Pending', color: Color(0xFFF59E0B)),
        RegistrationItem(title: 'Background Checks', subtitle: 'Coaching Staff', status: '2 / 2 Complete', color: Color(0xFF10B981)),
      ];
}
