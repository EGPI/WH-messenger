import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/message_screen_controller.dart';

class MessageInputBar extends ConsumerStatefulWidget {
  final int conversationId;

  const MessageInputBar({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends ConsumerState<MessageInputBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();

    _focusNode.dispose();

    super.dispose();
  }

  void _onTextChanged() {
    final nextHasText = _controller.text.trim().isNotEmpty;

    if (nextHasText == _hasText) return;

    setState(() {
      _hasText = nextHasText;
    });
  }

  Future<void> _send() async {
    final text = _controller.text;
    final trimmed = text.trim();

    if (trimmed.isEmpty) return;

    final currentUserId = ref.read(
      authControllerProvider.select((state) => state.user?.id),
    );

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to send.')),
      );
      return;
    }

    _controller.clear();

    await ref
        .read(messageScreenControllerProvider(widget.conversationId).notifier)
        .sendMessage(
      senderId: currentUserId,
      body: trimmed,
    );

    if (mounted) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isSending = ref.watch(
      messageScreenControllerProvider(widget.conversationId)
          .select((state) => state.isSending),
    );

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FF),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.08),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SendButton(
              enabled: _hasText,
              isSending: isSending,
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final bool isSending;
  final VoidCallback onPressed;

  const _SendButton({
    required this.enabled,
    required this.isSending,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: enabled ? colorScheme.primary : Colors.grey.shade300,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onPressed : null,
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: isSending
                ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}