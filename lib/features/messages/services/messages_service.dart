import 'package:flutter/material.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/enums/thread_type.dart';
import '../../../core/enums/message_type.dart';

DateTime _ts(int hoursAgo, int minsAgo) =>
    DateTime.now().subtract(Duration(hours: hoursAgo, minutes: minsAgo));

class MessagesService {
  List<ChatThread> getThreads() {
    return [
      ChatThread(
        id: 't1',
        name: 'U14 Boys — Team Chat',
        lastMessage: 'Coach: Remember warm-up at 9:30 tomorrow!',
        lastMessageTime: _ts(0, 10),
        unreadCount: 3,
        isPinned: true,
        type: ThreadType.team,
        avatarColor: const Color(0xFF1A56DB),
        avatarInitials: 'U14',
      ),
      ChatThread(
        id: 't2',
        name: 'Club Announcements',
        lastMessage: 'Spring tournament registration closes Friday.',
        lastMessageTime: _ts(1, 0),
        unreadCount: 1,
        isPinned: true,
        type: ThreadType.announcement,
        avatarColor: const Color(0xFFF59E0B),
        avatarInitials: '📢',
      ),
      ChatThread(
        id: 't3',
        name: 'Carlos Martinez',
        lastMessage: 'See you at practice 👍',
        lastMessageTime: _ts(2, 30),
        type: ThreadType.direct,
        avatarColor: const Color(0xFF1A56DB),
        avatarInitials: 'CM',
        isOnline: true,
      ),
      ChatThread(
        id: 't4',
        name: 'Sarah Johnson',
        lastMessage: 'Can you send the lineup for Saturday?',
        lastMessageTime: _ts(5, 0),
        unreadCount: 2,
        type: ThreadType.direct,
        avatarColor: const Color(0xFF8B5CF6),
        avatarInitials: 'SJ',
      ),
      ChatThread(
        id: 't5',
        name: 'Coaching Staff',
        lastMessage: 'Confirmed: Field 3 is booked.',
        lastMessageTime: _ts(24, 0),
        type: ThreadType.team,
        avatarColor: const Color(0xFF10B981),
        avatarInitials: 'CS',
      ),
      ChatThread(
        id: 't6',
        name: 'Oliver Davis',
        lastMessage: 'Ill be there!',
        lastMessageTime: _ts(26, 0),
        type: ThreadType.direct,
        avatarColor: const Color(0xFF0EA5E9),
        avatarInitials: 'OD',
        isOnline: true,
      ),
      ChatThread(
        id: 't7',
        name: 'James Miller',
        lastMessage: 'Thanks coach',
        lastMessageTime: _ts(48, 0),
        isMuted: true,
        type: ThreadType.direct,
        avatarColor: const Color(0xFFF97316),
        avatarInitials: 'JM',
      ),
    ];
  }

  List<ChatMessage> getMessages(String threadId) {
    return [
      ChatMessage(
        id: 'm1', senderId: 'coach',
        senderName: 'Carlos Martinez', senderInitials: 'CM',
        senderColor: const Color(0xFF1A56DB),
        text: 'Hey team! Quick reminder about tomorrows game vs Riverside FC.',
        type: MessageType.text, timestamp: _ts(2, 40), isMe: false,
      ),
      ChatMessage(
        id: 'm2', senderId: 'coach',
        senderName: 'Carlos Martinez', senderInitials: 'CM',
        senderColor: const Color(0xFF1A56DB),
        text: 'Please arrive at the field by 9:30 AM for warm-up. Game kicks off at 10:00.',
        type: MessageType.text, timestamp: _ts(2, 39), isMe: false,
      ),
      ChatMessage(
        id: 'm3', senderId: 'me',
        senderName: 'You', senderInitials: 'JD',
        senderColor: const Color(0xFF0EA5E9),
        text: 'Got it coach! Will be there early 💪',
        type: MessageType.text, timestamp: _ts(2, 35), isMe: true, isRead: true,
      ),
      ChatMessage(
        id: 'm4', senderId: 'sarah',
        senderName: 'Sarah Johnson', senderInitials: 'SJ',
        senderColor: const Color(0xFF8B5CF6),
        text: 'Ive attached the match day lineup.',
        type: MessageType.text, timestamp: _ts(2, 20), isMe: false,
      ),
      ChatMessage(
        id: 'm5', senderId: 'sarah',
        senderName: 'Sarah Johnson', senderInitials: 'SJ',
        senderColor: const Color(0xFF8B5CF6),
        fileName: 'Lineup_Mar29.pdf', fileSize: '245 KB',
        type: MessageType.file, timestamp: _ts(2, 19), isMe: false,
      ),
      ChatMessage(
        id: 'm6', senderId: 'me',
        senderName: 'You', senderInitials: 'JD',
        senderColor: const Color(0xFF0EA5E9),
        text: 'Thanks! Looking good 👌',
        type: MessageType.text, timestamp: _ts(2, 10), isMe: true,
        isRead: true, reactionEmoji: '👍',
      ),
      ChatMessage(
        id: 'm7', senderId: 'coach',
        senderName: 'Carlos Martinez', senderInitials: 'CM',
        senderColor: const Color(0xFF1A56DB),
        text: 'Remember warm-up at 9:30 tomorrow!',
        type: MessageType.text, timestamp: _ts(0, 10), isMe: false,
      ),
    ];
  }
}
