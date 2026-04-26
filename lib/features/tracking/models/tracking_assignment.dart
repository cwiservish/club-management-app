enum AssignmentStatus { completed, pending }

class TrackingAssignment {
  final String title;
  final String assignee;
  final AssignmentStatus status;

  const TrackingAssignment({
    required this.title,
    required this.assignee,
    required this.status,
  });
}
