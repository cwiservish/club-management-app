import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/message_type.dart';
import '../../../core/enums/thread_type.dart';
import '../../../core/models/chat_models.dart';
import '../services/messages_service.dart';

class MessagesState {
  final List<ChatThread> threads;
  final List<ChatMessage> messages;
  final String searchQuery;
  final int activeTab;

  const MessagesState({
    required this.threads,
    required this.messages,
    required this.searchQuery,
    required this.activeTab,
  });

  List<ChatThread> get filtered {
    final q = searchQuery.toLowerCase();
    return threads.where((t) {
      final matchSearch = q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.lastMessage.toLowerCase().contains(q);
      final matchTab = activeTab == 0 ||
          (activeTab == 1 && t.type == ThreadType.team) ||
          (activeTab == 2 && t.type == ThreadType.direct);
      return matchSearch && matchTab;
    }).toList();
  }

  int get totalUnread => threads.fold(0, (sum, t) => sum + t.unreadCount);

  MessagesState copyWith({
    List<ChatThread>? threads,
    List<ChatMessage>? messages,
    String? searchQuery,
    int? activeTab,
  }) {
    return MessagesState(
      threads:     threads     ?? this.threads,
      messages:    messages    ?? this.messages,
      searchQuery: searchQuery ?? this.searchQuery,
      activeTab:   activeTab   ?? this.activeTab,
    );
  }
}

class MessagesNotifier extends Notifier<MessagesState> {
  @override
  MessagesState build() {
    final service = ref.read(messagesServiceProvider);
    return MessagesState(
      threads:     service.getThreads(),
      messages:    service.getMessages(''),
      searchQuery: '',
      activeTab:   0,
    );
  }

  void setSearch(String q) => state = state.copyWith(searchQuery: q);
  void setTab(int tab)     => state = state.copyWith(activeTab: tab);

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final newMessage = ChatMessage(
      id:              DateTime.now().millisecondsSinceEpoch.toString(),
      senderId:        'me',
      senderName:      'You',
      senderInitials:  'JD',
      senderColor:     const Color(0xFF0EA5E9), // current user constant
      text:            text.trim(),
      type:            MessageType.text,
      timestamp:       DateTime.now(),
      isMe:            true,
    );
    state = state.copyWith(messages: [...state.messages, newMessage]);
  }
}

final messagesServiceProvider =
    Provider<MessagesService>((ref) => MessagesService());

final messagesProvider =
    NotifierProvider<MessagesNotifier, MessagesState>(MessagesNotifier.new);
