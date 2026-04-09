import 'package:flutter/material.dart';
import '../enums/thread_type.dart';
import '../enums/message_type.dart';

class ChatThread {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final ThreadType type;
  final Color avatarColor;
  final String avatarInitials;
  final bool isOnline;

  const ChatThread({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    required this.type,
    required this.avatarColor,
    required this.avatarInitials,
    this.isOnline = false,
  });

  bool get hasUnread => unreadCount > 0;
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderInitials;
  final Color senderColor;
  final String? text;
  final MessageType type;
  final DateTime timestamp;
  final bool isMe;
  final String? fileName;
  final String? fileSize;
  final bool isRead;
  final String? reactionEmoji;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderInitials,
    required this.senderColor,
    this.text,
    required this.type,
    required this.timestamp,
    required this.isMe,
    this.fileName,
    this.fileSize,
    this.isRead = false,
    this.reactionEmoji,
  });
}
