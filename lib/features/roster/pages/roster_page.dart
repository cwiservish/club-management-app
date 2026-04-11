import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/member_role.dart';
import '../../../core/models/roster_member.dart';
import '../providers/roster_provider.dart';

const _blue = Color(0xFF1A56DB);
const _green = Color(0xFF10B981);
const _amber = Color(0xFFF59E0B);
const _red = Color(0xFFEF4444);
const _purple = Color(0xFF8B5CF6);
const _gray50 = Color(0xFFF9FAFB);
const _gray100 = Color(0xFFF3F4F6);
const _gray200 = Color(0xFFE5E7EB);
const _gray400 = Color(0xFF9CA3AF);
const _gray500 = Color(0xFF6B7280);
const _gray700 = Color(0xFF374151);
const _gray900 = Color(0xFF111827);

class RosterScreen extends ConsumerStatefulWidget {
  const RosterScreen({super.key});

  @override
  ConsumerState<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends ConsumerState<RosterScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rosterProvider);
    final filtered = state.filtered;
    final staff = filtered.where((m) => m.role == MemberRole.staff).toList();
    final players = filtered.where((m) => m.role == MemberRole.player).toList();

    return Scaffold(
      backgroundColor: _gray50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state),
            _buildSearchBar(state),
            _buildFilterRow(state),
            Expanded(child: _buildList(state, staff, players)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }

  Widget _buildHeader(RosterState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text('Roster',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _gray900)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Text('U14 Boys',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _blue)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => ref.read(rosterProvider.notifier).toggleView(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: _gray100, borderRadius: BorderRadius.circular(8)),
              child: Icon(
                state.gridView ? Icons.view_list_outlined : Icons.grid_view,
                size: 20,
                color: _gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(RosterState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => ref.read(rosterProvider.notifier).setSearch(v),
        decoration: InputDecoration(
          hintText: 'Search by name, position, #…',
          hintStyle: const TextStyle(color: _gray400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: _gray400, size: 20),
          suffixIcon: state.searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    ref.read(rosterProvider.notifier).setSearch('');
                  },
                  child: const Icon(Icons.close, color: _gray400, size: 18),
                )
              : null,
          filled: true,
          fillColor: _gray100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(RosterState state) {
    final total = state.allMembers.length;
    final playerCount =
        state.allMembers.where((m) => m.role == MemberRole.player).length;
    final staffCount =
        state.allMembers.where((m) => m.role == MemberRole.staff).length;

    final chips = [
      (null, 'All ($total)'),
      (MemberRole.player, 'Players ($playerCount)'),
      (MemberRole.staff, 'Staff ($staffCount)'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: chips.map((chip) {
          final isActive = state.roleFilter == chip.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () =>
                  ref.read(rosterProvider.notifier).setFilter(chip.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? _blue.withOpacity(0.1) : _gray100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? _blue : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(chip.$2,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? _blue : _gray500)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList(
      RosterState state, List<RosterMember> staff, List<RosterMember> players) {
    if (state.filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 48, color: _gray400),
            const SizedBox(height: 12),
            const Text('No members found',
                style: TextStyle(
                    color: _gray500,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(
              state.searchQuery.isNotEmpty
                  ? 'Try a different search'
                  : 'Tap + to add a member',
              style: const TextStyle(color: _gray400, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        if (staff.isNotEmpty) ...[
          _sectionHeader('Staff', staff.length),
          const SizedBox(height: 8),
          if (state.gridView)
            _buildGrid(staff)
          else
            ...staff.map(_buildListTile),
          const SizedBox(height: 16),
        ],
        if (players.isNotEmpty) ...[
          _sectionHeader('Players', players.length),
          const SizedBox(height: 8),
          if (state.gridView)
            _buildGrid(players)
          else
            ...players.map(_buildListTile),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _gray700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: _gray100, borderRadius: BorderRadius.circular(10)),
          child: Text('$count',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _gray500)),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: _gray200, thickness: 1)),
      ],
    );
  }

  Widget _buildGrid(List<RosterMember> members) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: members.length,
      itemBuilder: (_, i) => _buildGridCard(members[i]),
    );
  }

  Widget _buildGridCard(RosterMember member) {
    return GestureDetector(
      onTap: () => _showDetail(member),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 14),
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: member.avatarColor.withOpacity(0.15),
                  child: Text(member.initials,
                      style: TextStyle(
                          color: member.avatarColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
                if (member.jerseyNumber != null)
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text('#${member.jerseyNumber}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                if (!member.isActive)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _gray400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(member.firstName,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _gray900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(member.lastName,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _gray700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: member.role == MemberRole.staff
                    ? _purple.withOpacity(0.1)
                    : _blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(member.displayRole,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color:
                          member.role == MemberRole.staff ? _purple : _blue),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(RosterMember member) {
    return GestureDetector(
      onTap: () => _showDetail(member),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: member.avatarColor.withOpacity(0.15),
                  child: Text(member.initials,
                      style: TextStyle(
                          color: member.avatarColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ),
                if (member.jerseyNumber != null)
                  Positioned(
                    bottom: -3,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text('#${member.jerseyNumber}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(member.fullName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _gray900)),
                      if (!member.isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                              color: _gray100,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text('Inactive',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: _gray400,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(member.displayRole,
                      style: const TextStyle(fontSize: 12, color: _gray500)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: member.attendanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${member.attendancePercent}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: member.attendanceColor)),
                ),
                const SizedBox(height: 3),
                const Text('attendance',
                    style: TextStyle(fontSize: 10, color: _gray400)),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _gray400, size: 18),
          ],
        ),
      ),
    );
  }

  void _showDetail(RosterMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: _gray100, borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildDetailHeader(member),
                    const SizedBox(height: 20),
                    if (member.role == MemberRole.player) ...[
                      _buildStatRow(member),
                      const SizedBox(height: 20),
                      _buildAttendanceBar(member),
                      const SizedBox(height: 20),
                    ],
                    _buildContactSection(member),
                    if (member.parentName != null) ...[
                      const SizedBox(height: 16),
                      _buildParentSection(member),
                    ],
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailHeader(RosterMember member) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: member.avatarColor.withOpacity(0.15),
              child: Text(member.initials,
                  style: TextStyle(
                      color: member.avatarColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
            ),
            if (member.jerseyNumber != null)
              Positioned(
                bottom: -4,
                right: -8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text('#${member.jerseyNumber}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.fullName,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _gray900)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: member.role == MemberRole.staff
                          ? _purple.withOpacity(0.1)
                          : _blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(member.displayRole,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: member.role == MemberRole.staff
                                ? _purple
                                : _blue)),
                  ),
                  if (member.role == MemberRole.player &&
                      member.position != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: _gray100,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(member.positionLabel,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _gray500)),
                    ),
                  ],
                  if (!member.isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: _gray100,
                          borderRadius: BorderRadius.circular(6)),
                      child: const Text('Inactive',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _gray400)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(RosterMember member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _gray50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statCell('${member.goalsScored}', 'Goals', _blue),
          Container(width: 1, height: 36, color: _gray200),
          _statCell('${member.assists}', 'Assists', _green),
          Container(width: 1, height: 36, color: _gray200),
          _statCell('${member.yellowCards}', 'Yellow', _amber),
          Container(width: 1, height: 36, color: _gray200),
          _statCell('${member.redCards}', 'Red', _red),
        ],
      ),
    );
  }

  Widget _statCell(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: _gray500)),
      ],
    );
  }

  Widget _buildAttendanceBar(RosterMember member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Attendance',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _gray700)),
            Text('${member.attendancePercent}%',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: member.attendanceColor)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: member.attendancePercent / 100,
            minHeight: 8,
            backgroundColor: _gray100,
            valueColor:
                AlwaysStoppedAnimation<Color>(member.attendanceColor),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(RosterMember member) {
    return _infoCard(
      title: 'Contact',
      icon: Icons.person_outline,
      rows: [
        (Icons.phone_outlined, member.phone),
        (Icons.email_outlined, member.email),
      ],
    );
  }

  Widget _buildParentSection(RosterMember member) {
    return _infoCard(
      title: 'Parent / Guardian',
      icon: Icons.family_restroom_outlined,
      rows: [
        (Icons.person_outline, member.parentName!),
        (Icons.phone_outlined, member.parentPhone!),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required List<(IconData, String)> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _gray50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _gray400),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _gray500)),
            ],
          ),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(r.$1, size: 15, color: _gray400),
                    const SizedBox(width: 10),
                    Text(r.$2,
                        style:
                            const TextStyle(fontSize: 14, color: _gray700)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              side: const BorderSide(color: _blue),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('Message'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
