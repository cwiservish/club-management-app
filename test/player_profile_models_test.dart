// ignore_for_file: depend_on_referenced_packages
import 'package:test/test.dart';
import 'package:playbook365/features/roster/models/player_profile_models.dart';

void main() {
  group('Player Profile Models Tests', () {
    test('PlayerModel parses is_editable true from JSON', () {
      final json = {
        'team_player_id': 1,
        'player_id': 100,
        'uuid': 'player-uuid-1',
        'first_name': 'John',
        'last_name': 'Doe',
        'name': 'John Doe',
        'date_of_birth': '2010-01-01',
        'gender': 'Male',
        'height_feet': 5,
        'height_inches': 8,
        'height_total_inches': 68,
        'jersey_no': '10',
        'image_url': 'http://image.url',
        'profile_image_url': 'http://profile.image.url',
        'profile_url': 'http://profile.url',
        'parent_verified': 'Yes',
        'parent_registered': 'Yes',
        'guest': 'No',
        'location': 'New York',
        'grad_year': '2028',
        'primary_position': 'Forward',
        'other_positions': 'Midfielder',
        'is_editable': true,
      };

      final player = PlayerModel.fromJson(json);
      expect(player.teamPlayerId, 1);
      expect(player.playerId, 100);
      expect(player.uuid, 'player-uuid-1');
      expect(player.isEditable, true);
    });

    test('PlayerModel parses is_editable false from JSON', () {
      final json = {
        'team_player_id': 2,
        'player_id': 200,
        'uuid': 'player-uuid-2',
        'is_editable': false,
      };

      final player = PlayerModel.fromJson(json);
      expect(player.teamPlayerId, 2);
      expect(player.playerId, 200);
      expect(player.uuid, 'player-uuid-2');
      expect(player.isEditable, false);
    });

    test('PlayerProfileResponse parses full response structure safely', () {
      final responseJson = {
        'success': true,
        'message': 'Loaded successfully',
        'data': {
          'player': {
            'team_player_id': 1,
            'player_id': 100,
            'uuid': 'player-uuid-1',
            'is_editable': false,
          },
          'parents': [
            {
              'id': 10,
              'customer_id': 20,
              'name': 'Jane Doe',
              'email': 'jane@example.com',
            }
          ]
        }
      };

      final response = PlayerProfileResponse.fromJson(responseJson);
      expect(response.success, true);
      expect(response.message, 'Loaded successfully');
      expect(response.data.player.isEditable, false);
      expect(response.data.parents.length, 1);
      expect(response.data.parents[0].name, 'Jane Doe');
      expect(response.data.parents[0].email, 'jane@example.com');
    });
  });
}
