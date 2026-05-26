import 'photo_item.dart';

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

// ─── Photos Listing Models ───────────────────────────────────────────────────

class PhotosListRequest {
  final String uuid;

  const PhotosListRequest({required this.uuid});

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
    };
  }
}

class PhotosListResponse {
  final bool success;
  final String message;
  final PhotosListData data;

  const PhotosListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PhotosListResponse.fromJson(Map<String, dynamic> json) {
    return PhotosListResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: PhotosListData.fromJson(
        json['data'] is Map<String, dynamic> ? json['data'] : {},
      ),
    );
  }
}

class PhotosListData {
  final List<PhotoItem> grid;
  final int total;

  const PhotosListData({
    required this.grid,
    required this.total,
  });

  factory PhotosListData.fromJson(Map<String, dynamic> json) {
    final list = json['grid'] as List?;
    return PhotosListData(
      grid: list
              ?.map((e) => PhotoItem.fromJson(e is Map<String, dynamic> ? e : {}))
              .toList() ??
          [],
      total: _parseInt(json['total']),
    );
  }
}

// ─── Photo Saving Models ─────────────────────────────────────────────────────

class PhotoSaveResponse {
  final bool success;
  final String message;
  final PhotoItem? data;

  const PhotoSaveResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PhotoSaveResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return PhotoSaveResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: rawData is Map<String, dynamic> ? PhotoItem.fromJson(rawData) : null,
    );
  }
}

// ─── Photo Removing Models ───────────────────────────────────────────────────

class PhotoRemoveResponse {
  final bool success;
  final String message;

  const PhotoRemoveResponse({
    required this.success,
    required this.message,
  });

  factory PhotoRemoveResponse.fromJson(Map<String, dynamic> json) {
    return PhotoRemoveResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
    );
  }
}
