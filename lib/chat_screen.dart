import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'chat_message.dart';
import 'config.dart';
import 'gemini_service.dart';
import 'login_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  // The person who logged in.
  final DemoUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController(); // the text box
  final _scrollController = ScrollController(); // the message list
  final _gemini = GeminiService();

  // All messages shown on screen. Changing it inside setState() updates the UI.
  final List<ChatMessage> _messages = [];
  bool _isLoading = false; // true while we wait for the AI

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    // 1) Show the user's message right away.
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // 2) Ask Gemini (this takes a moment, so we "await" it).
    String reply = '';
    bool isError = false;
    try {
      reply = await _gemini.sendMessage(List.of(_messages));
    } catch (e) {
      reply = e.toString().replaceFirst('Exception: ', '');
      isError = true;
    }

    // 3) The user may have left the screen while we waited.
    if (!mounted) return;

    // 4) Show the answer.
    setState(() {
      _messages.add(ChatMessage(text: reply, isUser: false, isError: isError));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  // Scrolls the list to the newest message.
  void _scrollToBottom() {
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

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Chat'),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            icon: const Icon(Icons.delete_outline),
            onPressed: _messages.isEmpty || _isLoading
                ? null
                : () => setState(_messages.clear),
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(name: widget.user.name)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    // +1 row for the "thinking..." bubble while loading
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const _TypingBubble();
                      }
                      return _MessageBubble(message: _messages[index]);
                    },
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  // The text box + send button at the bottom.
  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Send',
              onPressed: _isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
//  Small widgets used only by the chat screen
// ---------------------------------------------------------------

// Shown before the first message.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 56, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              'Hi $name!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// One chat bubble. User bubbles are on the right, AI bubbles on the left.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    final Color background;
    final Color foreground;
    if (message.isError) {
      background = colors.errorContainer;
      foreground = colors.onErrorContainer;
    } else if (isUser) {
      background = colors.primary;
      foreground = colors.onPrimary;
    } else {
      background = colors.secondaryContainer;
      foreground = colors.onSecondaryContainer;
    }

    final maxWidth = math.min(MediaQuery.of(context).size.width * 0.8, 600.0);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        // SelectableText lets the user copy the answer.
        child: SelectableText(
          message.text,
          style: TextStyle(color: foreground, fontSize: 15),
        ),
      ),
    );
  }
}

// The "Gemini is thinking..." bubble.
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              'Gemini is thinking...',
              style: TextStyle(color: colors.onSecondaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}
