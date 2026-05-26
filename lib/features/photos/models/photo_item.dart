class PhotoItem {
  final int id;
  final int clubTeamFileId;
  final String file;
  final int teamId;
  final int uploadedBy;
  final String uploadedByType;
  final String createdAt;
  final String updatedAt;
  final String imageUrl;

  const PhotoItem({
    required this.id,
    required this.clubTeamFileId,
    required this.file,
    required this.teamId,
    required this.uploadedBy,
    required this.uploadedByType,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrl,
  });

  factory PhotoItem.fromJson(Map<String, dynamic> json) {
    return PhotoItem(
      id: _parseInt(json['id'] ?? json['club_team_file_id'] ?? json['club_team_gallary_id']),
      clubTeamFileId: _parseInt(json['club_team_file_id'] ?? json['club_team_gallary_id']),
      file: _parseString(json['file'] ?? json['image']),
      teamId: _parseInt(json['team_id']),
      uploadedBy: _parseInt(json['uploaded_by']),
      uploadedByType: _parseString(json['uploaded_by_type']),
      createdAt: _parseString(json['created_at']),
      updatedAt: _parseString(json['updated_at']),
      imageUrl: _parseString(json['file_url'] ?? json['image_url']),
    );
  }

  // ─── Type-Safe Parsing Helpers ────────────────────────────────────────────────

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

