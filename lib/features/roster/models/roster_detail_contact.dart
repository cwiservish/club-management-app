import 'roster_member.dart';

class RosterDetailContact {
  final String name;
  final String initials;
  final String relation;
  final String email;
  final String phone;

  const RosterDetailContact({
    required this.name,
    required this.initials,
    required this.relation,
    this.email = '',
    this.phone = '',
  });
}

List<RosterDetailContact> buildRosterDetailContacts(RosterMember m) {
  final name  = m.parentName ?? m.fullName;
  final parts = name.trim().split(' ');
  final initials = parts.length > 1
      ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
      : name.trim().substring(0, 2).toUpperCase();
  final relation = m.parentName != null ? 'Mom' : m.displayRole;

  return [
    RosterDetailContact(
      name: name,
      initials: initials,
      relation: relation,
      email: m.email,
      phone: m.parentPhone ?? m.phone,
    ),
  ];
}
