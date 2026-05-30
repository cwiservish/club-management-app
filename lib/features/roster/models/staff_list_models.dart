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

// ─── Models ───────────────────────────────────────────────────────────────────

class StaffListRequest {
  final String teamUuid;

  const StaffListRequest({
    required this.teamUuid,
  });

  Map<String, dynamic> toJson() {
    return {
      'team_uuid': teamUuid,
    };
  }
}

class StaffListResponse {
  final bool success;
  final String message;
  final StaffListData data;

  const StaffListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StaffListResponse.fromJson(Map<String, dynamic> json) {
    return StaffListResponse(
      success: _parseBool(json['success']),
      message: _parseString(json['message']),
      data: StaffListData.fromJson(
        json['data'] is Map<String, dynamic> ? json['data'] : {},
      ),
    );
  }
}

class StaffListData {
  final List<StaffModel> grid;
  final int total;

  const StaffListData({
    required this.grid,
    required this.total,
  });

  factory StaffListData.fromJson(Map<String, dynamic> json) {
    final list = json['grid'] as List?;
    return StaffListData(
      grid: list
              ?.map((e) => StaffModel.fromJson(e is Map<String, dynamic> ? e : {}))
              .toList() ??
          [],
      total: _parseInt(json['total']),
    );
  }
}

class StaffModel {
  final int id;
  final int staffId;
  final String uuid;
  final int customerId;
  final String customerUuid;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String mobile;
  final int roleId;
  final String roleLabel;
  final int gender;
  final String genderLabel;
  final String imageUrl;
  final bool isRegisteredStaff;
  final String jerseyNo;

  const StaffModel({
    required this.id,
    required this.staffId,
    required this.uuid,
    required this.customerId,
    required this.customerUuid,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.mobile,
    required this.roleId,
    required this.roleLabel,
    required this.gender,
    required this.genderLabel,
    required this.imageUrl,
    required this.isRegisteredStaff,
    required this.jerseyNo,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: _parseInt(json['id']),
      staffId: _parseInt(json['staff_id']),
      uuid: _parseString(json['uuid']),
      customerId: _parseInt(json['customer_id']),
      customerUuid: _parseString(json['customer_uuid']),
      firstName: _parseString(json['first_name']),
      lastName: _parseString(json['last_name']),
      name: _parseString(json['name']),
      email: _parseString(json['email']),
      mobile: _parseString(json['mobile']),
      roleId: _parseInt(json['role_id']),
      roleLabel: _parseString(json['role_label']),
      gender: _parseInt(json['gender']),
      genderLabel: _parseString(json['gender_label']),
      imageUrl: _parseString(json['image_url']),
      isRegisteredStaff: _parseBool(json['is_registered_staff']),
      jerseyNo: _parseString(json['jersey_no']),
    );
  }
}
