import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/players_list_models.dart';
import '../models/staff_list_models.dart';
import '../models/roster_member.dart';
import '../../../core/enums/member_role.dart';
import '../../../core/enums/player_position.dart';
import '../../../core/network/api_client.dart';
import '../../../core/common_providers/selected_team_provider.dart';
import '../services/roster_service.dart';

const _sentinel = Object();

class RosterState {
  final List<RosterMember> allMembers;
  final bool? _isLoading;
  bool get isLoading => _isLoading ?? false;
  final String? errorMessage;
  final String searchQuery;
  final MemberRole? roleFilter;
  final bool gridView;
  final String sortBy;
  final String staffSortBy;

  const RosterState({
    required this.allMembers,
    bool isLoading = false,
    this.errorMessage,
    required this.searchQuery,
    this.roleFilter,
    required this.gridView,
    this.sortBy = 'First Name',
    this.staffSortBy = 'First Name',
  }) : _isLoading = isLoading;

  List<RosterMember> get filtered {
    final matchSearch = (RosterMember m) {
      final matchRole = roleFilter == null || m.role == roleFilter;
      if (!matchRole) return false;
      final q = searchQuery.toLowerCase();
      return q.isEmpty ||
          m.fullName.toLowerCase().contains(q) ||
          (m.staffTitle?.toLowerCase().contains(q) ?? false) ||
          m.positionFull.toLowerCase().contains(q) ||
          (m.jerseyNumber?.toString().contains(q) ?? false);
    };

    final playersList = allMembers.where((m) => m.role == MemberRole.player && matchSearch(m)).toList();
    final staffList = allMembers.where((m) => m.role == MemberRole.staff && matchSearch(m)).toList();

    switch (sortBy) {
      case 'Last Name':
        playersList.sort((a, b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));
        break;
      case 'Position':
        playersList.sort((a, b) => a.primaryPosition.toLowerCase().compareTo(b.primaryPosition.toLowerCase()));
        break;
      case 'Gender':
        playersList.sort((a, b) => a.gender.toLowerCase().compareTo(b.gender.toLowerCase()));
        break;
      case 'Number':
        playersList.sort((a, b) => a.jerseyNo.toLowerCase().compareTo(b.jerseyNo.toLowerCase()));
        break;
      case 'First Name':
      default:
        playersList.sort((a, b) => a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase()));
        break;
    }

    switch (staffSortBy) {
      case 'Last Name':
        staffList.sort((a, b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));
        break;
      case 'Gender':
        staffList.sort((a, b) => a.gender.toLowerCase().compareTo(b.gender.toLowerCase()));
        break;
      case 'First Name':
      default:
        staffList.sort((a, b) => a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase()));
        break;
    }

    return [...playersList, ...staffList];
  }

  RosterState copyWith({
    List<RosterMember>? allMembers,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    String? searchQuery,
    Object? roleFilter = _sentinel,
    bool? gridView,
    String? sortBy,
    String? staffSortBy,
  }) {
    return RosterState(
      allMembers: allMembers ?? this.allMembers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter == _sentinel ? this.roleFilter : roleFilter as MemberRole?,
      gridView: gridView ?? this.gridView,
      sortBy: sortBy ?? this.sortBy,
      staffSortBy: staffSortBy ?? this.staffSortBy,
    );
  }
}

class RosterNotifier extends Notifier<RosterState> {
  @override
  RosterState build() {
    final activeTeam = ref.watch(selectedTeamProvider);

    // Schedule API call reactively after the widget tree builds
    if (activeTeam != null) {
      Future.microtask(() => fetchPlayers(activeTeam.uuid));
    }

    return RosterState(
      allMembers: const [],
      isLoading: activeTeam != null,
      errorMessage: null,
      searchQuery: '',
      gridView: true,
      sortBy: 'First Name',
    );
  }

  /// Fetches players and staff from the API for the selected team UUID.
  Future<void> fetchPlayers(String teamUuid) async {
    state = state.copyWith(isLoading: true, errorMessage: null, allMembers: []);
    try {
      final service = ref.read(rosterServiceProvider);
      final results = await Future.wait([
        service.fetchPlayers(teamUuid),
        service.fetchStaff(teamUuid),
      ]);

      final playersResponse = results[0] as PlayersListResponse;
      final staffResponse = results[1] as StaffListResponse;

      final playerMembers = playersResponse.data.grid.map((p) {
        return RosterMember(
          id: p.uuid,
          playerId: p.playerId,
          firstName: p.firstName,
          lastName: p.lastName,
          role: MemberRole.player,
          jerseyNumber: int.tryParse(p.jerseyNo),
          jerseyNo: p.jerseyNo,
          position: _mapPosition(p.primaryPosition),
          primaryPosition: p.primaryPosition,
          phone: '',
          email: '',
          gender: p.gender,
          attendancePercent: 85, // Mock default attendance percentage
          avatarColor: _getRandomColor(p.name),
        );
      }).toList();

      final staffMembers = staffResponse.data.grid.map((s) {
        return RosterMember(
          id: s.uuid,
          firstName: s.firstName,
          lastName: s.lastName,
          role: MemberRole.staff,
          staffTitle: 'ID: ${s.staffId}',
          phone: s.mobile,
          email: s.email,
          gender: s.genderLabel,
          jerseyNo: s.jerseyNo,
          primaryPosition: '',
          attendancePercent: 95, // Mock default staff attendance percentage
          avatarColor: _getRandomColor(s.name),
        );
      }).toList();

      // Combine both lists
      final allMembersList = [...playerMembers, ...staffMembers];

      state = state.copyWith(
        allMembers: allMembersList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Pull-to-refresh implementation.
  Future<void> refresh() async {
    final activeTeam = ref.read(selectedTeamProvider);
    if (activeTeam != null) {
      await fetchPlayers(activeTeam.uuid);
    }
  }

  void setSearch(String q) => state = state.copyWith(searchQuery: q);
  void setFilter(MemberRole? role) => state = state.copyWith(roleFilter: role);
  void toggleView() => state = state.copyWith(gridView: !state.gridView);
  void setSortBy(String sortBy) => state = state.copyWith(sortBy: sortBy);
  void setStaffSortBy(String staffSortBy) => state = state.copyWith(staffSortBy: staffSortBy);

  // ─── Helpers ──────────────────────────────────────────────────────────────

  PlayerPosition? _mapPosition(String pos) {
    final p = pos.toLowerCase().trim();
    if (p == '1' || p.contains('gk') || p.contains('goalkeeper')) return PlayerPosition.goalkeeper;
    if (p == '2' || p.contains('def') || p.contains('defender')) return PlayerPosition.defender;
    if (p == '3' || p.contains('mid') || p.contains('midfielder')) return PlayerPosition.midfielder;
    if (p == '4' || p.contains('fwd') || p.contains('forward')) return PlayerPosition.forward;
    return null;
  }

  Color _getRandomColor(String name) {
    final hash = name.hashCode;
    final colors = [
      const Color(0xFFE57373), // Red
      const Color(0xFFF06292), // Pink
      const Color(0xFFBA68C8), // Purple
      const Color(0xFF9575CD), // Deep Purple
      const Color(0xFF7986CB), // Indigo
      const Color(0xFF64B5F6), // Blue
      const Color(0xFF4FC3F7), // Light Blue
      const Color(0xFF4DD0E1), // Cyan
      const Color(0xFF4DB6AC), // Teal
      const Color(0xFF81C784), // Green
      const Color(0xFFAED581), // Light Green
      const Color(0xFFD4E157), // Lime
      const Color(0xFFFFD54F), // Amber
      const Color(0xFFFFB74D), // Orange
      const Color(0xFFFF8A65), // Deep Orange
    ];
    return colors[hash.abs() % colors.length];
  }
}

final rosterServiceProvider = Provider<RosterService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return RosterService(apiClient);
});

final rosterProvider = NotifierProvider<RosterNotifier, RosterState>(
  RosterNotifier.new,
);
