// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:playbook365/features/roster/models/roster_member.dart';
import 'package:playbook365/features/roster/providers/roster_provider.dart';
import 'package:playbook365/core/enums/member_role.dart';

void main() {
  group('Roster Sorting Tests', () {
    final list = [
      RosterMember(
        id: '1',
        firstName: 'Zack',
        lastName: 'Brown',
        role: MemberRole.player,
        phone: '',
        email: '',
        gender: 'Male',
        primaryPosition: 'Goalkeeper',
        jerseyNo: '10',
        attendancePercent: 90,
        avatarColor: Colors.red,
      ),
      RosterMember(
        id: '2',
        firstName: 'Adam',
        lastName: 'Smith',
        role: MemberRole.player,
        phone: '',
        email: '',
        gender: 'Female',
        primaryPosition: 'Forward',
        jerseyNo: '2',
        attendancePercent: 90,
        avatarColor: Colors.blue,
      ),
      RosterMember(
        id: '3',
        firstName: 'John',
        lastName: 'Adams',
        role: MemberRole.player,
        phone: '',
        email: '',
        gender: 'Male',
        primaryPosition: 'Defender',
        jerseyNo: '1',
        attendancePercent: 90,
        avatarColor: Colors.green,
      ),
    ];

    test('Sorts by First Name alphabetically by default', () {
      final state = RosterState(
        allMembers: list,
        searchQuery: '',
        gridView: true,
        sortBy: 'First Name',
      );

      final sorted = state.filtered;
      expect(sorted[0].firstName, 'Adam');
      expect(sorted[1].firstName, 'John');
      expect(sorted[2].firstName, 'Zack');
    });

    test('Sorts by Last Name alphabetically', () {
      final state = RosterState(
        allMembers: list,
        searchQuery: '',
        gridView: true,
        sortBy: 'Last Name',
      );

      final sorted = state.filtered;
      expect(sorted[0].lastName, 'Adams');
      expect(sorted[1].lastName, 'Brown');
      expect(sorted[2].lastName, 'Smith');
    });

    test('Sorts by Position alphabetically', () {
      final state = RosterState(
        allMembers: list,
        searchQuery: '',
        gridView: true,
        sortBy: 'Position',
      );

      final sorted = state.filtered;
      expect(sorted[0].primaryPosition, 'Defender');
      expect(sorted[1].primaryPosition, 'Forward');
      expect(sorted[2].primaryPosition, 'Goalkeeper');
    });

    test('Sorts by Gender alphabetically', () {
      final state = RosterState(
        allMembers: list,
        searchQuery: '',
        gridView: true,
        sortBy: 'Gender',
      );

      final sorted = state.filtered;
      expect(sorted[0].gender, 'Female');
      expect(sorted[1].gender, 'Male');
      expect(sorted[2].gender, 'Male');
    });

    test('Sorts by Number numerically', () {
      final state = RosterState(
        allMembers: list,
        searchQuery: '',
        gridView: true,
        sortBy: 'Number',
      );

      final sorted = state.filtered;
      // '1', '2', '10' in numerical order
      expect(sorted[0].jerseyNo, '1');
      expect(sorted[1].jerseyNo, '2');
      expect(sorted[2].jerseyNo, '10');
    });
  });
}
