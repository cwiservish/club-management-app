class LeagueDetailArgs {
  final int eventDbId;
  final int schedulingMode;

  const LeagueDetailArgs({
    required this.eventDbId,
    required this.schedulingMode,
  });

  @override
  bool operator ==(Object other) =>
      other is LeagueDetailArgs &&
      other.eventDbId == eventDbId &&
      other.schedulingMode == schedulingMode;

  @override
  int get hashCode => Object.hash(eventDbId, schedulingMode);
}

class LeagueDetailResult {
  final List<Map<String, dynamic>> childSessions;

  const LeagueDetailResult({required this.childSessions});
}
