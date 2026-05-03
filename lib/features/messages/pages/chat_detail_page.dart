import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common_providers/theme_provider.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/shared_widgets/app_header.dart';
import '../providers/messages_provider.dart';
import '../widgets/chat_attach_menu.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_mute_sheet.dart';

// ─── Chat Detail Screen ───────────────────────────────────────────────────────

class ChatDetailScreen extends ConsumerStatefulWidget {
  final ChatThread thread;
  const ChatDetailScreen({super.key, required this.thread});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _inputController  = TextEditingController();
  final _scrollController = ScrollController();
  bool _showAttachMenu    = false;
  bool _hasText           = false;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _inputController.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    _inputController.removeListener(_onTextChanged);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    ref.read(messagesProvider.notifier).sendMessage(text);
    _inputController.clear();
    setState(() => _showAttachMenu = false);
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

  void _showMuteMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatMuteSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final messages = ref.watch(messagesProvider).messages;

    return Scaffold(
      backgroundColor: ref.watch(messagesProvider).messages.isNotEmpty
          ? null
          : null,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppHeader(),
            ChatHeader(thread: widget.thread, onMuteTap: _showMuteMenu),
            Expanded(
              child: ChatMessageList(
                messages:         messages,
                scrollController: _scrollController,
              ),
            ),
            if (_showAttachMenu)
              ChatAttachMenu(
                onClose: () => setState(() => _showAttachMenu = false),
              ),
            ChatInputBar(
              controller:     _inputController,
              hasText:        _hasText,
              onSend:         _sendMessage,
              onToggleAttach: () =>
                  setState(() => _showAttachMenu = !_showAttachMenu),
            ),
          ],
        ),
      ),
    );
  }
}
