class FileItem {
  final String id;
  final String name;
  final String size;
  final String date;
  final int clubTeamFileId;
  final int teamId;
  final int uploadedBy;
  final String uploadedByType;
  final String createdAt;
  final String updatedAt;
  final String fileUrl;

  const FileItem({
    required this.id,
    required this.name,
    required this.size,
    required this.date,
    required this.clubTeamFileId,
    required this.teamId,
    required this.uploadedBy,
    required this.uploadedByType,
    required this.createdAt,
    required this.updatedAt,
    required this.fileUrl,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['club_team_file_id'];
    final idString = rawId != null ? rawId.toString() : '';
    final nameString = _parseString(json['file'] ?? json['name']);
    final createdAtString = _parseString(json['created_at']);
    
    // Dynamically build a nice readable file type size label e.g. "PNG File", "PDF File"
    String sizeLabel = 'File';
    if (nameString.isNotEmpty) {
      final extIndex = nameString.lastIndexOf('.');
      if (extIndex != -1 && extIndex < nameString.length - 1) {
        final ext = nameString.substring(extIndex + 1).toUpperCase();
        sizeLabel = '$ext File';
      }
    }

    return FileItem(
      id: idString,
      name: nameString,
      size: sizeLabel,
      date: _formatDate(createdAtString),
      clubTeamFileId: _parseInt(json['club_team_file_id']),
      teamId: _parseInt(json['team_id']),
      uploadedBy: _parseInt(json['uploaded_by']),
      uploadedByType: _parseString(json['uploaded_by_type']),
      createdAt: createdAtString,
      updatedAt: _parseString(json['updated_at']),
      fileUrl: _parseString(json['file_url']),
    );
  }

  // Crash-proof type-safe parsing helpers
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String _formatDate(String isoString) {
    if (isoString.isEmpty) return 'N/A';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return isoString;
    
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (dt.month < 1 || dt.month > 12) return isoString;
    final month = months[dt.month - 1];
    return '$month ${dt.day}, ${dt.year}';
  }
}
