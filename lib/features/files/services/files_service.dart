import 'package:flutter/material.dart';
import '../models/club_file.dart';

class FilesService {
  List<ClubFile> getFiles() => const [
        ClubFile(name: 'Lineup_Mar29.pdf', type: 'PDF', size: '245 KB', color: Color(0xFFEF4444)),
        ClubFile(name: 'Practice_Plan_Apr1.pdf', type: 'PDF', size: '180 KB', color: Color(0xFFEF4444)),
        ClubFile(name: 'Tournament_Registration.pdf', type: 'PDF', size: '512 KB', color: Color(0xFFEF4444)),
        ClubFile(name: 'Team_Photo_Spring.jpg', type: 'Image', size: '2.1 MB', color: Color(0xFF0EA5E9)),
        ClubFile(name: 'Season_Schedule.xlsx', type: 'Spreadsheet', size: '98 KB', color: Color(0xFF10B981)),
        ClubFile(name: 'Club_Waiver_2026.pdf', type: 'PDF', size: '320 KB', color: Color(0xFFEF4444)),
        ClubFile(name: 'Kit_Order_Form.docx', type: 'Document', size: '67 KB', color: Color(0xFF1A56DB)),
      ];
}
