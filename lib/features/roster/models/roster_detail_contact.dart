import 'roster_member.dart';

class RosterDetailContact {
  final String name;
  final String initials;
  final String relation;
  final String value;
  final bool isEmail;

  const RosterDetailContact({
    required this.name,
    required this.initials,
    required this.relation,
    required this.value,
    required this.isEmail,
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
    RosterDetailContact(name: name, initials: initials, relation: relation, value: m.email, isEmail: true),
    RosterDetailContact(name: name, initials: initials, relation: relation, value: m.parentPhone ?? m.phone, isEmail: false),
  ];
}
