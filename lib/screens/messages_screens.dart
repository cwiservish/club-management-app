import 'package:flutter/material.dart';

/// Club Management App — Messages + ChatDetail
/// Converted from Figma Make (Club-Management-App / Messages.tsx + ChatDetail.tsx)
/// Includes: conversation list, search, unread badges, pinned threads,
/// full chat view with bubbles, media/file attachments, message input bar.

// ─── Constants ────────────────────────────────────────────────────────────────

const _blue = Color(0xFF1A56DB);
const _green = Color(0xFF10B981);
const _amber = Color(0xFFF59E0B);
const _red = Color(0xFFEF4444);
const _purple = Color(0xFF8B5CF6);
const _gray50 = Color(0xFFF9FAFB);
const _gray100 = Color(0xFFF3F4F6);
const _gray200 = Color(0xFFE5E7EB);
const _gray400 = Color(0xFF9CA3AF);
const _gray500 = Color(0xFF6B7280);
const _gray700 = Color(0xFF374151);
const _gray900 = Color(0xFF111827);

// ─── Data Models ──────────────────────────────────────────────────────────────

enum ThreadType { team, direct, announcement }

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
  final bool isOnline; // direct only
  final List<String>? memberAvatars; // group only

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
    this.memberAvatars,
  });
}

enum MessageType { text, image, file, announcement }

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

// ─── Sample Data ──────────────────────────────────────────────────────────────

final List<ChatThread> _threads = [
   ChatThread(
    id: 't1',
    name: 'U14 Boys — Team Chat',
    lastMessage: 'Coach: Remember warm-up at 9:30 tomorrow!',
    lastMessageTime: _ts(0, 10),
    unreadCount: 3,
    isPinned: true,
    type: ThreadType.team,
    avatarColor: _blue,
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
    avatarColor: _amber,
    avatarInitials: '📢',
  ),
   ChatThread(
    id: 't3',
    name: 'Carlos Martinez',
    lastMessage: 'See you at practice 👍',
    lastMessageTime: _ts(2, 30),
    unreadCount: 0,
    type: ThreadType.direct,
    avatarColor: _blue,
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
    avatarColor: _purple,
    avatarInitials: 'SJ',
    isOnline: false,
  ),
   ChatThread(
    id: 't5',
    name: 'Coaching Staff',
    lastMessage: 'Confirmed: Field 3 is booked.',
    lastMessageTime: _ts(24, 0),
    unreadCount: 0,
    type: ThreadType.team,
    avatarColor: _green,
    avatarInitials: 'CS',
  ),
   ChatThread(
    id: 't6',
    name: 'Oliver Davis',
    lastMessage: 'Ill be there!',
    lastMessageTime: _ts(26, 0),
    unreadCount: 0,
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
    unreadCount: 0,
    isMuted: true,
    type: ThreadType.direct,
    avatarColor: const Color(0xFFF97316),
    avatarInitials: 'JM',
    isOnline: false,
  ),
];

// fake DateTime helpers
DateTime _ts(int hoursAgo, int minsAgo) {
  return DateTime.now()
      .subtract(Duration(hours: hoursAgo, minutes: minsAgo));
}

final List<ChatMessage> _messages = [
  ChatMessage(
    id: 'm1',
    senderId: 'coach',
    senderName: 'Carlos Martinez',
    senderInitials: 'CM',
    senderColor: _blue,
    text: 'Hey team! Quick reminder about tomorrows game vs Riverside FC.',
    type: MessageType.text,
    timestamp: _ts(2, 40),
    isMe: false,
  ),
  ChatMessage(
    id: 'm2',
    senderId: 'coach',
    senderName: 'Carlos Martinez',
    senderInitials: 'CM',
    senderColor: _blue,
    text: 'Please arrive at the field by 9:30 AM for warm-up. Game kicks off at 10:00.',
    type: MessageType.text,
    timestamp: _ts(2, 39),
    isMe: false,
  ),
  ChatMessage(
    id: 'm3',
    senderId: 'me',
    senderName: 'You',
    senderInitials: 'JD',
    senderColor: const Color(0xFF0EA5E9),
    text: 'Got it coach! Will be there early 💪',
    type: MessageType.text,
    timestamp: _ts(2, 35),
    isMe: true,
    isRead: true,
  ),
  ChatMessage(
    id: 'm4',
    senderId: 'sarah',
    senderName: 'Sarah Johnson',
    senderInitials: 'SJ',
    senderColor: _purple,
    text: 'Ive attached the match day lineup.',
    type: MessageType.text,
    timestamp: _ts(2, 20),
    isMe: false,
  ),
  ChatMessage(
    id: 'm5',
    senderId: 'sarah',
    senderName: 'Sarah Johnson',
    senderInitials: 'SJ',
    senderColor: _purple,
    fileName: 'Lineup_Mar29.pdf',
    fileSize: '245 KB',
    type: MessageType.file,
    timestamp: _ts(2, 19),
    isMe: false,
  ),
  ChatMessage(
    id: 'm6',
    senderId: 'me',
    senderName: 'You',
    senderInitials: 'JD',
    senderColor: const Color(0xFF0EA5E9),
    text: 'Thanks! Looking good 👌',
    type: MessageType.text,
    timestamp: _ts(2, 10),
    isMe: true,
    isRead: true,
    reactionEmoji: '👍',
  ),
  ChatMessage(
    id: 'm7',
    senderId: 'coach',
    senderName: 'Carlos Martinez',
    senderInitials: 'CM',
    senderColor: _blue,
    text: 'Remember warm-up at 9:30 tomorrow!',
    type: MessageType.text,
    timestamp: _ts(0, 10),
    isMe: false,
  ),
];

// ─── Time Formatting ──────────────────────────────────────────────────────────

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${dt.month}/${dt.day}';
}

String _chatTimestamp(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final suffix = dt.hour < 12 ? 'AM' : 'PM';
  if (diff.inDays == 0) return '$h:$m $suffix';
  if (diff.inDays == 1) return 'Yesterday $h:$m $suffix';
  return '${dt.month}/${dt.day} $h:$m $suffix';
}

String _daySeparator(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  return '${_monthNames[dt.month - 1]} ${dt.day}';
}

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

// ══════════════════════════════════════════════════════════════════════════════
// 1. MESSAGES SCREEN (thread list)
// ══════════════════════════════════════════════════════════════════════════════

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;
  int _navIndex = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<ChatThread> get _filtered {
    final q = _searchQuery.toLowerCase();
    final tab = _tabController.index;
    return _threads.where((t) {
      final matchSearch = q.isEmpty ||
          t.name.toLowerCase().contains(q) ||
          t.lastMessage.toLowerCase().contains(q);
      final matchTab = tab == 0 ||
          (tab == 1 && t.type == ThreadType.team) ||
          (tab == 2 && t.type == ThreadType.direct);
      return matchSearch && matchTab;
    }).toList();
  }

  int get _totalUnread =>
      _threads.fold(0, (sum, t) => sum + t.unreadCount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _gray50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(child: _buildThreadList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMessageSheet(),
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.edit_outlined),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _gray900,
            ),
          ),
          if (_totalUnread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_totalUnread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.group_add_outlined, color: _gray500),
            onPressed: () {},
            tooltip: 'New Group',
          ),
        ],
      ),
    );
  }

  // ── Search ────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search messages…',
          hintStyle: const TextStyle(color: _gray400, fontSize: 14),
          prefixIcon:
              const Icon(Icons.search, color: _gray400, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child:
                      const Icon(Icons.close, color: _gray400, size: 18),
                )
              : null,
          filled: true,
          fillColor: _gray100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        labelColor: _blue,
        unselectedLabelColor: _gray400,
        indicatorColor: _blue,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Groups'),
          Tab(text: 'Direct'),
        ],
      ),
    );
  }

  // ── Thread List ───────────────────────────────────────────────────────────

  Widget _buildThreadList() {
    final threads = _filtered;
    final pinned = threads.where((t) => t.isPinned).toList();
    final others = threads.where((t) => !t.isPinned).toList();

    if (threads.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline,
                size: 48, color: _gray400),
            const SizedBox(height: 12),
            const Text('No messages',
                style: TextStyle(
                    color: _gray500,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search'
                  : 'Tap the compose button to start',
              style: const TextStyle(color: _gray400, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (pinned.isNotEmpty) ...[
          _listSectionHeader('Pinned'),
          ...pinned.map((t) => _buildThreadTile(t)),
          _listSectionHeader('Recent'),
        ],
        ...others.map((t) => _buildThreadTile(t)),
      ],
    );
  }

  Widget _listSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _gray400,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildThreadTile(ChatThread thread) {
    final hasUnread = thread.unreadCount > 0;

    return Dismissible(
      key: Key(thread.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: _red,
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async => false, // prevent actual dismiss in demo
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(thread: thread),
          ),
        ),
        child: Container(
          color: hasUnread
              ? const Color(0xFFFAFBFF)
              : Colors.white,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildAvatar(thread),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (thread.isPinned)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.push_pin,
                                size: 12, color: _gray400),
                          ),
                        Expanded(
                          child: Text(
                            thread.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _gray900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _relativeTime(thread.lastMessageTime),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                hasUnread ? _blue : _gray400,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (thread.isMuted)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.volume_off_outlined,
                                size: 13, color: _gray400),
                          ),
                        Expanded(
                          child: Text(
                            thread.lastMessage,
                            style: TextStyle(
                              fontSize: 13,
                              color: hasUnread
                                  ? _gray700
                                  : _gray400,
                              fontWeight: hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${thread.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ChatThread thread) {
    final isAnnouncement = thread.type == ThreadType.announcement;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: isAnnouncement
              ? _amber.withOpacity(0.15)
              : thread.avatarColor.withOpacity(0.15),
          child: isAnnouncement
              ? const Text('📢', style: TextStyle(fontSize: 18))
              : Text(
                  thread.avatarInitials,
                  style: TextStyle(
                    color: thread.avatarColor,
                    fontSize: thread.type == ThreadType.team ? 12 : 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        if (thread.type == ThreadType.direct)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: thread.isOnline ? _green : _gray400,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        if (thread.type == ThreadType.team)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.group,
                  size: 9, color: Colors.white),
            ),
          ),
      ],
    );
  }

  // ── New Message Sheet ─────────────────────────────────────────────────────

  void _showNewMessageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _gray100,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('New Message',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _gray900)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search people…',
                  hintStyle:
                      const TextStyle(color: _gray400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      color: _gray400, size: 20),
                  filled: true,
                  fillColor: _gray100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: _threads
                    .where((t) => t.type == ThreadType.direct)
                    .map((t) => ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                t.avatarColor.withOpacity(0.15),
                            child: Text(t.avatarInitials,
                                style: TextStyle(
                                    color: t.avatarColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ),
                          title: Text(t.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _gray900)),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ChatDetailScreen(thread: t)));
                          },
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    const items = [
      (Icons.home_outlined, Icons.home, 'Home'),
      (Icons.calendar_today_outlined, Icons.calendar_today, 'Schedule'),
      (Icons.people_outline, Icons.people, 'Roster'),
      (Icons.chat_bubble_outline, Icons.chat_bubble, 'Messages'),
      (Icons.more_horiz, Icons.more_horiz, 'More'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = i == _navIndex;
              final item = items[i];
              return GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          isActive ? item.$2 : item.$1,
                          color: isActive ? _blue : _gray400,
                          size: 24,
                        ),
                        if (i == 3 && _totalUnread > 0)
                          Positioned(
                            top: -4,
                            right: -6,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                  color: _red,
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  '$_totalUnread',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$3,
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive ? _blue : _gray400,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 2. CHAT DETAIL SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class ChatDetailScreen extends StatefulWidget {
  final ChatThread thread;

  const ChatDetailScreen({super.key, required this.thread});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showAttachMenu = false;
  final List<ChatMessage> _localMessages = List.from(_messages);

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _localMessages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me',
        senderName: 'You',
        senderInitials: 'JD',
        senderColor: const Color(0xFF0EA5E9),
        text: text,
        type: MessageType.text,
        timestamp: DateTime.now(),
        isMe: true,
        isRead: false,
      ));
      _inputController.clear();
      _showAttachMenu = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _gray50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_showAttachMenu) _buildAttachMenu(),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    final thread = widget.thread;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: _gray700, size: 18),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: InkWell(
        onTap: () => _showThreadInfo(),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      thread.avatarColor.withOpacity(0.15),
                  child: Text(
                    thread.avatarInitials,
                    style: TextStyle(
                        color: thread.avatarColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                if (thread.type == ThreadType.direct)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: thread.isOnline ? _green : _gray400,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(thread.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _gray900)),
                Text(
                  thread.type == ThreadType.direct
                      ? (thread.isOnline ? 'Online' : 'Offline')
                      : '${_threads.where((t) => t.type == ThreadType.team).length + 3} members',
                  style: TextStyle(
                      fontSize: 11,
                      color: thread.isOnline && thread.type == ThreadType.direct
                          ? _green
                          : _gray400),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: _gray500),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: _gray500),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: _gray500),
          onPressed: () => _showMoreMenu(),
        ),
      ],
    );
  }

  // ── Message List ──────────────────────────────────────────────────────────

  Widget _buildMessageList() {
    // Group consecutive messages by sender, inject day separators
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _localMessages.length,
      itemBuilder: (_, i) {
        final msg = _localMessages[i];
        final prev = i > 0 ? _localMessages[i - 1] : null;

        // Day separator
        final showDay = prev == null ||
            !_sameDay(msg.timestamp, prev.timestamp);

        // Show sender avatar/name for group chats: first in a run or new day
        final showSender = !msg.isMe &&
            (prev == null ||
                prev.senderId != msg.senderId ||
                showDay);

        return Column(
          children: [
            if (showDay) _buildDaySeparator(msg.timestamp),
            _buildMessageBubble(msg, showSender),
          ],
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDaySeparator(DateTime dt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const Expanded(child: Divider(color: _gray200)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _daySeparator(dt),
              style: const TextStyle(
                  fontSize: 12,
                  color: _gray400,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const Expanded(child: Divider(color: _gray200)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool showSender) {
    final isMe = msg.isMe;

    return Padding(
      padding: EdgeInsets.only(
        top: showSender ? 10 : 2,
        bottom: msg.reactionEmoji != null ? 14 : 2,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Sender avatar (left side, non-me)
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: showSender
                  ? CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          msg.senderColor.withOpacity(0.15),
                      child: Text(msg.senderInitials,
                          style: TextStyle(
                              color: msg.senderColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    )
                  : const SizedBox(width: 32),
            ),

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Sender name (group chat only, non-me)
                if (showSender && !isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      msg.senderName,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _gray500),
                    ),
                  ),

                // Bubble content
                GestureDetector(
                  onLongPress: () => _showMessageMenu(msg),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildBubbleContent(msg, isMe),
                      // Reaction
                      if (msg.reactionEmoji != null)
                        Positioned(
                          bottom: -12,
                          right: isMe ? 8 : null,
                          left: isMe ? null : 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 4)
                              ],
                            ),
                            child: Text(msg.reactionEmoji!,
                                style: const TextStyle(fontSize: 13)),
                          ),
                        ),
                    ],
                  ),
                ),

                // Timestamp + read receipt
                Padding(
                  padding:
                      const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _chatTimestamp(msg.timestamp),
                        style: const TextStyle(
                            fontSize: 10, color: _gray400),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          msg.isRead
                              ? Icons.done_all
                              : Icons.done,
                          size: 12,
                          color: msg.isRead ? _blue : _gray400,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Spacer right side for non-me (prevents full width)
          if (!isMe) const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(ChatMessage msg, bool isMe) {
    final bubbleBg = isMe ? _blue : Colors.white;
    final textColor = isMe ? Colors.white : _gray900;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 18),
    );

    // File message
    if (msg.type == MessageType.file) {
      return Container(
        constraints:
            const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? _blue : Colors.white,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.white.withOpacity(0.2)
                    : _blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.insert_drive_file_outlined,
                  color: isMe ? Colors.white : _blue, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.fileName ?? 'File',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    msg.fileSize ?? '',
                    style: TextStyle(
                        fontSize: 11,
                        color: isMe
                            ? Colors.white70
                            : _gray400),
                  ),
                ],
              ),
            ),
            Icon(Icons.download_outlined,
                color: isMe ? Colors.white70 : _gray400,
                size: 18),
          ],
        ),
      );
    }

    // Text message
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleBg,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        msg.text ?? '',
        style: TextStyle(
            fontSize: 14, color: textColor, height: 1.4),
      ),
    );
  }

  // ── Message Context Menu ──────────────────────────────────────────────────

  void _showMessageMenu(ChatMessage msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reaction strip
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['👍', '❤️', '😂', '😮', '😢', '🙏']
                    .map((e) => GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(e,
                              style: const TextStyle(
                                  fontSize: 26)),
                        ))
                    .toList(),
              ),
            ),
            const Divider(height: 1, color: _gray100),
            _menuItem(Icons.reply_outlined, 'Reply', _gray700),
            _menuItem(Icons.content_copy_outlined, 'Copy', _gray700),
            if (msg.isMe)
              _menuItem(Icons.delete_outline, 'Delete', _red),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color)),
      onTap: () => Navigator.pop(context),
    );
  }

  // ── Attach Menu ───────────────────────────────────────────────────────────

  Widget _buildAttachMenu() {
    final actions = [
      (Icons.image_outlined, 'Photo', const Color(0xFF0EA5E9)),
      (Icons.camera_alt_outlined, 'Camera', _green),
      (Icons.attach_file_outlined, 'File', _purple),
      (Icons.location_on_outlined, 'Location', _amber),
      (Icons.contact_page_outlined, 'Contact', _blue),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () => setState(() => _showAttachMenu = false),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: a.$3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(a.$1, color: a.$3, size: 22),
                ),
                const SizedBox(height: 6),
                Text(a.$2,
                    style: const TextStyle(
                        fontSize: 11, color: _gray500)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Input Bar ─────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? 10
            : MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attach button
          GestureDetector(
            onTap: () =>
                setState(() => _showAttachMenu = !_showAttachMenu),
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: _showAttachMenu
                    ? _blue.withOpacity(0.1)
                    : _gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showAttachMenu ? Icons.close : Icons.add,
                color: _showAttachMenu ? _blue : _gray500,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: _gray100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _inputController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                    fontSize: 14, color: _gray900),
                decoration: const InputDecoration(
                  hintText: 'Message…',
                  hintStyle:
                      TextStyle(color: _gray400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send / mic button
          ValueListenableBuilder(
            valueListenable: _inputController,
            builder: (_, value, __) {
              final hasText = value.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: hasText ? _sendMessage : () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: hasText ? _blue : _gray100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasText ? Icons.send : Icons.mic_outlined,
                    color: hasText ? Colors.white : _gray500,
                    size: 18,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Thread Info Sheet ─────────────────────────────────────────────────────

  void _showThreadInfo() {
    final thread = widget.thread;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: _gray100,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor:
                      thread.avatarColor.withOpacity(0.15),
                  child: Text(thread.avatarInitials,
                      style: TextStyle(
                          color: thread.avatarColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(thread.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _gray900)),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  thread.type == ThreadType.direct
                      ? (thread.isOnline ? '● Online' : 'Offline')
                      : 'Group · 8 members',
                  style: TextStyle(
                      fontSize: 13,
                      color: thread.isOnline &&
                              thread.type == ThreadType.direct
                          ? _green
                          : _gray400),
                ),
              ),
              const SizedBox(height: 24),
              // Actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _infoAction(Icons.volume_off_outlined, 'Mute'),
                  const SizedBox(width: 24),
                  _infoAction(Icons.search, 'Search'),
                  const SizedBox(width: 24),
                  _infoAction(Icons.push_pin_outlined, 'Pin'),
                  const SizedBox(width: 24),
                  _infoAction(Icons.exit_to_app, 'Leave',
                      color: _red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoAction(IconData icon, String label,
      {Color color = _blue}) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuItem(
                Icons.search, 'Search in Conversation', _gray700),
            _menuItem(Icons.notifications_outlined,
                'Mute Notifications', _gray700),
            _menuItem(
                Icons.push_pin_outlined, 'Pin Conversation', _gray700),
            _menuItem(Icons.delete_outline,
                'Delete Conversation', _red),
          ],
        ),
      ),
    );
  }
}

// ─── Entry point (standalone testing) ────────────────────────────────────────

void main() {
  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Messages',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _blue),
      fontFamily: 'Inter',
    ),
    home: MessagesScreen(),
  ));
}
