// ignore_for_file: depend_on_referenced_packages
import 'package:test/test.dart';
import 'package:playbook365/features/messages/models/chat_member.dart';
import 'package:playbook365/features/messages/models/chat_channel.dart';
import 'package:playbook365/features/messages/models/save_channel_models.dart';
import 'package:playbook365/features/messages/models/member_list_models.dart';
import 'package:playbook365/features/messages/models/remove_channel_models.dart';

void main() {
  group('Save Channel Models Tests', () {
    test('SaveChannelRequest toJson is formatted correctly', () {
      final request = SaveChannelRequest(
        teamUuid: 'team-123',
        name: 'test-channel',
        users: [
          SaveChannelUser(memberId: 1, memberType: 'Coach'),
          SaveChannelUser(memberId: 2, memberType: 'Parent'),
        ],
        chatChannelId: 10,
      );

      final json = request.toJson();
      expect(json['team_uuid'], 'team-123');
      expect(json['name'], 'test-channel');
      expect(json['id'], 10);
      expect(json['users'], isList);
      expect((json['users'] as List)[0]['member_id'], 1);
      expect((json['users'] as List)[0]['member_type'], 'Coach');
    });

    test('SaveChannelResponse parses valid JSON safely', () {
      final json = {
        'success': true,
        'message': 'Saved successfully',
        'channel': {
          'chat_channel_id': 33,
          'uuid': 'channel-uuid-1',
          'name': 'general',
          'unread_count': 0,
          'permission': 'ReadWrite',
        }
      };

      final response = SaveChannelResponse.fromJson(json);
      expect(response.success, true);
      expect(response.message, 'Saved successfully');
      expect(response.channel, isNotNull);
      expect(response.channel!.chatChannelId, 33);
      expect(response.channel!.name, 'general');
    });

    test('SaveChannelResponse handles null and missing fields defensively', () {
      final json = <String, dynamic>{};
      final response = SaveChannelResponse.fromJson(json);
      expect(response.success, false);
      expect(response.message, '');
      expect(response.channel, isNull);
    });
  });

  group('Member List Models Tests', () {
    test('MemberListRequest toJson is formatted correctly', () {
      final request = MemberListRequest(
        teamUuid: 'team-456',
        isDm: 0,
        q: 'PRI',
        chatChannelId: 15,
      );

      final json = request.toJson();
      expect(json['team_uuid'], 'team-456');
      expect(json['isDm'], 0);
      expect(json['q'], 'PRI');
      expect(json['chat_channel_id'], 15);
    });

    test('MemberListResponse parses valid JSON safely', () {
      final json = {
        'success': true,
        'message': 'Success',
        'data': {
          'grid': [
            {
              'uuid': 'user-1',
              'email': 'user1@example.com',
              'name': 'Trish John',
              'member_id': 819,
              'member_type': 'Team Coach',
              'permissions': 'ReadWrite',
            }
          ],
          'total': 1,
        }
      };

      final response = MemberListResponse.fromJson(json);
      expect(response.success, true);
      expect(response.message, 'Success');
      expect(response.data, isNotNull);
      expect(response.data!.total, 1);
      expect(response.data!.grid, isNotEmpty);
      expect(response.data!.grid[0].name, 'Trish John');
      expect(response.data!.grid[0].memberId, 819);
    });

    test('MemberListResponse handles missing fields and nulls safely', () {
      final json = <String, dynamic>{};
      final response = MemberListResponse.fromJson(json);
      expect(response.success, false);
      expect(response.message, '');
      expect(response.data, isNull);
    });
  });

  group('Remove Channel Models Tests', () {
    test('RemoveChannelRequest toJson is formatted correctly', () {
      final request = RemoveChannelRequest(
        teamUuid: 'team-789',
        id: 75,
      );

      final json = request.toJson();
      expect(json['team_uuid'], 'team-789');
      expect(json['id'], 75);
    });

    test('RemoveChannelResponse parses valid JSON safely', () {
      final json = {
        'success': true,
        'message': 'Deleted successfully',
      };

      final response = RemoveChannelResponse.fromJson(json);
      expect(response.success, true);
      expect(response.message, 'Deleted successfully');
    });

    test('RemoveChannelResponse handles null and missing fields defensively', () {
      final json = <String, dynamic>{};
      final response = RemoveChannelResponse.fromJson(json);
      expect(response.success, false);
      expect(response.message, '');
    });
  });

  group('ChatChannel Model Tests', () {
    test('ChatChannel parses can_edit = true from JSON', () {
      final json = {
        'chat_channel_id': 1,
        'uuid': 'channel-1',
        'name': 'general',
        'unread_count': 0,
        'permission': 'ReadWrite',
        'can_edit': true,
      };

      final channel = ChatChannel.fromJson(json);
      expect(channel.canEdit, true);
    });

    test('ChatChannel parses can_edit = false from JSON', () {
      final json = {
        'chat_channel_id': 1,
        'uuid': 'channel-1',
        'name': 'general',
        'unread_count': 0,
        'permission': 'Read',
        'can_edit': false,
      };

      final channel = ChatChannel.fromJson(json);
      expect(channel.canEdit, false);
    });

    test('ChatChannel defaults can_edit to true when missing', () {
      final json = {
        'chat_channel_id': 1,
        'uuid': 'channel-1',
        'name': 'general',
        'unread_count': 0,
        'permission': 'Read',
      };

      final channel = ChatChannel.fromJson(json);
      expect(channel.canEdit, true);
    });

    test('ChatChannel parses chatChannelId from id when chat_channel_id is missing', () {
      final json = {
        'id': 42,
        'uuid': 'channel-1',
        'name': 'general',
        'unread_count': 0,
        'permission': 'Read',
      };

      final channel = ChatChannel.fromJson(json);
      expect(channel.chatChannelId, 42);
    });
  });
}
