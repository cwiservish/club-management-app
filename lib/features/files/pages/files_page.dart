import 'package:flutter/material.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  static const _files = [
    ('Lineup_Mar29.pdf', 'PDF', '245 KB', Color(0xFFEF4444)),
    ('Practice_Plan_Apr1.pdf', 'PDF', '180 KB', Color(0xFFEF4444)),
    ('Tournament_Registration.pdf', 'PDF', '512 KB', Color(0xFFEF4444)),
    ('Team_Photo_Spring.jpg', 'Image', '2.1 MB', Color(0xFF0EA5E9)),
    ('Season_Schedule.xlsx', 'Spreadsheet', '98 KB', Color(0xFF10B981)),
    ('Club_Waiver_2026.pdf', 'PDF', '320 KB', Color(0xFFEF4444)),
    ('Kit_Order_Form.docx', 'Document', '67 KB', Color(0xFF1A56DB)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Files'),
        actions: [
          IconButton(
              icon: const Icon(Icons.upload_file_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _files.map((f) => _FileTile(file: f)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1A56DB),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  final (String, String, String, Color) file;
  const _FileTile({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: file.$4.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.insert_drive_file_outlined, color: file.$4, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.$1,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827))),
                const SizedBox(height: 3),
                Text('${file.$2} • ${file.$3}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined,
                color: Color(0xFF9CA3AF), size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
