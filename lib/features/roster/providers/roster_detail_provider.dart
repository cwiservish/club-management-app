import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/roster_member.dart';
import 'roster_provider.dart';

/// Resolves a [RosterMember] by its [id] from the global roster list.
/// Auto-disposes when the detail page is no longer in the tree.
final rosterDetailProvider =
    Provider.autoDispose.family<RosterMember, String>((ref, id) {
  return ref
      .watch(rosterProvider)
      .allMembers
      .firstWhere((m) => m.id == id);
});
