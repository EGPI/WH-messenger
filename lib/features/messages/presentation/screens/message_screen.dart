import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../realtime/presentation/providers/realtime_bootstrap_provider.dart';
import '../providers/message_screen_controller.dart';
import '../providers/message_screen_providers.dart';
import '../providers/outbox_connectivity_provider.dart';
import '../providers/outbox_retry_worker.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_bar.dart';
import '../widgets/older_messages_loader.dart';

class MessageScreen extends ConsumerStatefulWidget {
  final int conversationId;

  const MessageScreen({
    super.key,
    required this.conversationId,
  });

  static const routePath = '/conversations/:conversationId';

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  late final ScrollController _scrollController;

  bool _didInitialOpen = false;
  int _lastMessageCount = 0;
  bool _clearedOpenConversation = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(_openConversationOnce);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    // Do not modify providers here.
    // Provider cleanup happens from explicit navigation callbacks / post-frame PopScope.

    super.dispose();
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;

    // With reverse:true, bottom/latest messages are at pixels 0.
    return _scrollController.position.pixels <= 120;
  }

  void _scrollToBottom({
    bool animated = true,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      if (animated) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _openConversationOnce() {
    if (_didInitialOpen) return;

    _didInitialOpen = true;
    _clearedOpenConversation = false;

    ref.read(openConversationIdProvider.notifier).state = widget.conversationId;

    ref
        .read(messageScreenControllerProvider(widget.conversationId).notifier)
        .openConversation();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // With reverse:true, older messages are near maxScrollExtent.
    if (_scrollController.position.extentAfter <= 180) {
      ref
          .read(messageScreenControllerProvider(widget.conversationId).notifier)
          .loadOlderMessages();
    }
  }

  void _clearOpenConversationNow() {
    if (_clearedOpenConversation) return;

    _clearedOpenConversation = true;

    ref.read(openConversationIdProvider.notifier).state = null;
  }

  void _clearOpenConversationAfterFrame() {
    if (_clearedOpenConversation) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _clearOpenConversationNow();
    });
  }

  void _closeConversationAndGoBack() {
    _clearOpenConversationNow();

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/conversations');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(outboxConnectivityBootstrapProvider);
    ref.watch(realtimeBootstrapProvider);

    ref.listen(
      localMessagesProvider(widget.conversationId),
          (previous, next) {
        next.whenData((messages) {
          final hadNewMessage = messages.length > _lastMessageCount;
          final shouldStayAtBottom = _lastMessageCount == 0 || _isNearBottom();

          _lastMessageCount = messages.length;

          if (!hadNewMessage || !shouldStayAtBottom) return;

          _scrollToBottom(animated: _lastMessageCount > 1);
        });
      },
    );

    final conversationAsync =
    ref.watch(localConversationProvider(widget.conversationId));

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;

        _clearOpenConversationAfterFrame();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              tooltip: 'Back to chats',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _closeConversationAndGoBack,
            ),
          ),
          titleSpacing: 4,
          backgroundColor: Colors.white.withValues(alpha: 0.80),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: const SizedBox.expand(),
            ),
          ),
          title: conversationAsync.when(
            data: (conversation) {
              final type = conversation?.type;

              return _MessageAppBarTitle(
                title: _conversationTitle(
                  type: type,
                  title: conversation?.title,
                ),
                subtitle: _conversationSubtitle(type),
                type: type,
              );
            },
            loading: () {
              return const _MessageAppBarTitle(
                title: 'Chat',
                subtitle: 'Loading...',
                type: null,
              );
            },
            error: (_, _) {
              return const _MessageAppBarTitle(
                title: 'Chat',
                subtitle: '',
                type: null,
              );
            },
          ),
        ),
        body: Stack(
          children: [
            const _MessageBackground(),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: _MessagesList(
                      conversationId: widget.conversationId,
                      scrollController: _scrollController,
                    ),
                  ),
                  MessageInputBar(
                    conversationId: widget.conversationId,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _conversationTitle({
    required String? type,
    required String? title,
  }) {
    final trimmed = title?.trim();

    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }

    if (type == 'announcement') return 'Announcement';
    if (type == 'group') return 'Group chat';

    return 'Chat';
  }

  String _conversationSubtitle(String? type) {
    if (type == 'announcement') return 'Announcement chat';
    if (type == 'group') return 'Group chat';

    return 'Direct chat';
  }
}

class _MessageAppBarTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? type;

  const _MessageAppBarTitle({
    required this.title,
    required this.subtitle,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = _iconForType(type);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                const Color(0xFF42A5F5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF102033),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.15,
                ),
              ),
              if (subtitle.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7A90),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconForType(String? type) {
    if (type == 'announcement') return Icons.campaign_rounded;
    if (type == 'group') return Icons.groups_rounded;

    return Icons.person_rounded;
  }
}

class _MessagesList extends ConsumerWidget {
  final int conversationId;
  final ScrollController scrollController;

  const _MessagesList({
    required this.conversationId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(localMessagesProvider(conversationId));

    final controllerState =
    ref.watch(messageScreenControllerProvider(conversationId));

    final currentUserId = ref.watch(
      authControllerProvider.select((state) => state.user?.id),
    );
    final canSendMessages = ref.watch(
      messageSendPermissionProvider(conversationId).select(
            (permission) => permission.canSend,
      ),
    );

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty && controllerState.isInitialSyncing) {
          return const _MessagesLoadingView();
        }

        if (messages.isEmpty) {
          return const _EmptyMessagesView();
        }

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 14,
          ),
          itemCount: messages.length + 1,
          itemBuilder: (context, index) {
            if (index == messages.length) {
              return OlderMessagesLoader(
                isLoadingOlder: controllerState.isLoadingOlder,
                hasMoreOlder: controllerState.hasMoreOlder,
              );
            }

            final message = messages[messages.length - 1 - index];

            final isMine =
                currentUserId != null && message.senderId == currentUserId;

            return MessageBubble(
              key: ValueKey(
                message.serverId ?? message.clientMessageId ?? message.localId,
              ),
              message: message,
              isMine: isMine,
              showSenderName: false,
              onRetry: !canSendMessages || message.clientMessageId == null
                  ? null
                  : () {
                ref
                    .read(outboxRetryWorkerProvider.notifier)
                    .retryFailedMessage(
                  clientMessageId: message.clientMessageId!,
                );
              },
            );
          },
        );
      },
      loading: () {
        return const _MessagesLoadingView();
      },
      error: (_, _) {
        return const _MessagesLocalErrorView();
      },
    );
  }
}

class _MessagesLoadingView extends StatelessWidget {
  const _MessagesLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      itemCount: 8,
      itemBuilder: (context, index) {
        final isMine = index.isEven;

        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: index % 3 == 0 ? 190 : 250,
            height: index % 2 == 0 ? 58 : 76,
            margin: EdgeInsets.only(
              left: isMine ? 70 : 0,
              right: isMine ? 0 : 70,
              top: 5,
              bottom: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.74),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomLeft: Radius.circular(isMine ? 22 : 6),
                bottomRight: Radius.circular(isMine ? 6 : 22),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyMessagesView extends StatelessWidget {
  const _EmptyMessagesView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.94),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.14),
                      const Color(0xFF42A5F5).withValues(alpha: 0.18),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 42,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No messages yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF102033),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Send the first message and start the conversation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7A90),
                  fontSize: 14.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessagesLocalErrorView extends StatelessWidget {
  const _MessagesLocalErrorView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 46,
              color: Color(0xFFE53935),
            ),
            SizedBox(height: 14),
            Text(
              'Could not load local messages.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF102033),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBackground extends StatelessWidget {
  const _MessageBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEAF4FF),
            Color(0xFFF8FBFF),
            Color(0xFFEFF6FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -130,
            right: -85,
            child: _BlurCircle(
              size: 245,
              color: Color(0xFF90CAF9),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -95,
            child: _BlurCircle(
              size: 270,
              color: Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.22),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}