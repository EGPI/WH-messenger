import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/message_screen_controller.dart';
import '../providers/message_screen_providers.dart';

class MessageInputBar extends ConsumerStatefulWidget {
  final int conversationId;

  const MessageInputBar({super.key, required this.conversationId});

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
    final permission = ref.read(
      messageSendPermissionProvider(widget.conversationId),
    );

    if (!permission.canSend) {
      _focusNode.unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            permission.blockedReason ?? announcementSendBlockedReason,
          ),
        ),
      );
      return;
    }

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
        .sendMessage(senderId: currentUserId, body: trimmed);

    if (mounted) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSending = ref.watch(
      messageScreenControllerProvider(
        widget.conversationId,
      ).select((state) => state.isSending),
    );

    final sendPermission = ref.watch(
      messageSendPermissionProvider(widget.conversationId),
    );

    final canSend = sendPermission.canSend;

    return SafeArea(
      top: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.92)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 24,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!canSend)
                  _SendBlockedReasonBanner(
                    message:
                        sendPermission.blockedReason ??
                        announcementSendBlockedReason,
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: canSend
                              ? Colors.white.withValues(alpha: 0.94)
                              : const Color(0xFFF3F6FA),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: canSend
                                ? const Color(0xFFE4ECF7)
                                : const Color(0xFFD8E2EF),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.035),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          enabled: canSend,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(
                            color: Color(0xFF102033),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.28,
                          ),
                          decoration: InputDecoration(
                            hintText: canSend
                                ? 'Type a message...'
                                : sendPermission.blockedReason ??
                                      announcementSendBlockedReason,
                            hintStyle: const TextStyle(
                              color: Color(0xFF8A98AA),
                              fontWeight: FontWeight.w600,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    _SendButton(
                      enabled: canSend && _hasText,
                      isSending: isSending,
                      onPressed: _send,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SendBlockedReasonBanner extends StatelessWidget {
  final String message;

  const _SendBlockedReasonBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: enabled
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, const Color(0xFF0D47A1)],
              )
            : null,
        color: enabled ? null : const Color(0xFFD5DEEA),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isSending
                  ? const SizedBox.square(
                      key: ValueKey('sending'),
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      key: ValueKey('send'),
                      color: Colors.white,
                      size: 21,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
