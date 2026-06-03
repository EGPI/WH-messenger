import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../realtime/presentation/providers/realtime_bootstrap_provider.dart';
import '../../../sync/presentation/providers/chat_sync_bootstrap_provider.dart';
import '../../../sync/presentation/providers/chat_sync_controller.dart';
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

    ref.read(openConversationIdProvider.notifier).state =
        widget.conversationId;

    ref
        .read(messageScreenControllerProvider(widget.conversationId).notifier)
        .openConversation();

    //ref.read(chatSyncControllerProvider.notifier).syncNow();
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
    //ref.watch(chatSyncBootstrapProvider);
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
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back to chats',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _closeConversationAndGoBack,
          ),
          titleSpacing: 0,
          title: conversationAsync.when(
            data: (conversation) {
              return _MessageAppBarTitle(
                title: _conversationTitle(
                  type: conversation?.type,
                  title: conversation?.title,
                ),
                subtitle: _conversationSubtitle(conversation?.type),
              );
            },
            loading: () {
              return const _MessageAppBarTitle(
                title: 'Chat',
                subtitle: 'Loading...',
              );
            },
            error: (_, _) {
              return const _MessageAppBarTitle(
                title: 'Chat',
                subtitle: '',
              );
            },
          ),
        ),
        body: Column(
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

  const _MessageAppBarTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person_rounded,
            color: colorScheme.primary,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
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
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
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

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty && controllerState.isInitialSyncing) {
          return const _MessagesLoadingView();
        }

        if (messages.isEmpty) {
          return const _EmptyMessagesView();
        }

        return Stack(
          children: [
            ColoredBox(
              color: const Color(0xFFF7FAFF),
              child: ListView.builder(
                controller: scrollController,
                reverse: true,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 12,
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
                      message.serverId ??
                          message.clientMessageId ??
                          message.localId,
                    ),
                    message: message,
                    isMine: isMine,
                    showSenderName: false,
                    onRetry: message.clientMessageId == null
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
              ),
            ),
          ],
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
    return const ColoredBox(
      color: Color(0xFFF7FAFF),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyMessagesView extends StatelessWidget {
  const _EmptyMessagesView();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7FAFF),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 58,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 16),
              Text(
                'No messages yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Messages will appear here after this conversation starts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  height: 1.35,
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
    return const ColoredBox(
      color: Color(0xFFF7FAFF),
      child: Center(
        child: Text('Could not load local messages.'),
      ),
    );
  }
}