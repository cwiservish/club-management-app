import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/roster_member.dart';
import '../../../core/enums/member_role.dart';
import '../services/roster_service.dart';

const _sentinel = Object();

class RosterState {
  final List<RosterMember> allMembers;
  final String searchQuery;
  final MemberRole? roleFilter;
  final bool gridView;

  const RosterState({
    required this.allMembers,
    required this.searchQuery,
    this.roleFilter,
    required this.gridView,
  });

  List<RosterMember> get filtered {
    return allMembers.where((m) {
      final matchRole = roleFilter == null || m.role == roleFilter;
      final q = searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          m.fullName.toLowerCase().contains(q) ||
          (m.staffTitle?.toLowerCase().contains(q) ?? false) ||
          m.positionFull.toLowerCase().contains(q) ||
          (m.jerseyNumber?.toString().contains(q) ?? false);
      return matchRole && matchSearch;
    }).toList();
  }

  RosterState copyWith({
    List<RosterMember>? allMembers,
    String? searchQuery,
    Object? roleFilter = _sentinel,
    bool? gridView,
  }) {
    return RosterState(
      allMembers: allMembers ?? this.allMembers,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter == _sentinel ? this.roleFilter : roleFilter as MemberRole?,
      gridView: gridView ?? this.gridView,
    );
  }
}

class RosterNotifier extends Notifier<RosterState> {
  @override
  RosterState build() {
    return RosterState(
      allMembers: ref.read(rosterServiceProvider).getMembers(),
      searchQuery: '',
      gridView: true,
    );
  }

  void setSearch(String q) => state = state.copyWith(searchQuery: q);
  void setFilter(MemberRole? role) => state = state.copyWith(roleFilter: role);
  void toggleView() => state = state.copyWith(gridView: !state.gridView);
}

final rosterServiceProvider = Provider<RosterService>((ref) => RosterService());

final rosterProvider = NotifierProvider<RosterNotifier, RosterState>(RosterNotifier.new);
