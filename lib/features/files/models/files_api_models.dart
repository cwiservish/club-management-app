import 'file_item.dart';

// ─── Shared Crash-Proof Parsing Helpers ────────────────────────────────────────

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _parseString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    return lower == 'true' || lower == '1' || lower == 'yes' || lower == 'y';
  }
  return false;
}

// ─── Files Listing Models ────────────────────────────────────────────────────

class FilesListRequest {
  final String uuid;

  const FilesListRequest({required this.uuid});

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
    };
  }
}

class FilesListResponse {
  final bool success;
  final String message;
  final FilesListData data;

  const FilesListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FilesListResponse.fromJson(Map<String, dynamic> json) {
    return FilesListResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: FilesListData.fromJson(
        json['data'] is Map<String, dynamic> ? json['data'] : {},
      ),
    );
  }
}

class FilesListData {
  final List<FileItem> grid;
  final int total;

  const FilesListData({
    required this.grid,
    required this.total,
  });

  factory FilesListData.fromJson(Map<String, dynamic> json) {
    final list = json['grid'] as List?;
    return FilesListData(
      grid: list
              ?.map((e) => FileItem.fromJson(e is Map<String, dynamic> ? e : {}))
              .toList() ??
          [],
      total: _parseInt(json['total']),
    );
  }
}

// ─── File Saving Models ──────────────────────────────────────────────────────

class FileSaveResponse {
  final bool success;
  final String message;
  final FileItem? data;

  const FileSaveResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory FileSaveResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return FileSaveResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: rawData is Map<String, dynamic> ? FileItem.fromJson(rawData) : null,
    );
  }
}
