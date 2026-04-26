import '../models/tracking_assignment.dart';

class TrackingService {
  List<TrackingAssignment> getAssignments() {
    return const [
      TrackingAssignment(
        title: 'Bring Orange Cones',
        assignee: 'Scarlett Garling',
        status: AssignmentStatus.completed,
      ),
      TrackingAssignment(
        title: 'Snack Duty (Oranges)',
        assignee: 'Kinsley Weston',
        status: AssignmentStatus.pending,
      ),
      TrackingAssignment(
        title: 'Team Canopy Setup',
        assignee: 'Kinley Kirkes',
        status: AssignmentStatus.completed,
      ),
      TrackingAssignment(
        title: 'First Aid Kit',
        assignee: 'Mila Chaisson',
        status: AssignmentStatus.pending,
      ),
    ];
  }
}
