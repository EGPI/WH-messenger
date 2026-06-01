import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/message_screen_controller.dart';
import '../providers/message_screen_providers.dart';
import '../widgets/message_bubble.dart';
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

    super.dispose();
  }

  void _openConversationOnce() {
    if (_didInitialOpen) return;

    _didInitialOpen = true;

    ref
        .read(messageScreenControllerProvider(widget.conversationId).notifier)
        .openConversation();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Top pagination.
    // When user gets close to the top, fetch older messages.
    if (_scrollController.position.pixels <= 180) {
      ref
          .read(messageScreenControllerProvider(widget.conversationId).notifier)
          .loadOlderMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      messageScreenControllerProvider(widget.conversationId)
          .select((state) => state.errorMessage),
          (previous, next) {
        if (next == null || next == previous) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      },
    );

    final conversationAsync =
    ref.watch(localConversationProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to chats',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/conversations');
            }
          },
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
          const _TemporaryInputPlaceholder(),
        ],
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
    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person_rounded,
            color: Theme.of(context).colorScheme.primary,
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
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 12,
                ),
                itemCount: messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return OlderMessagesLoader(
                      isLoadingOlder: controllerState.isLoadingOlder,
                      hasMoreOlder: controllerState.hasMoreOlder,
                    );
                  }

                  final message = messages[index - 1];
                  final isMine =
                      currentUserId != null && message.senderId == currentUserId;

                  return MessageBubble(
                    key: ValueKey(
                      message.serverId ?? message.clientMessageId ?? message.localId,
                    ),
                    message: message,
                    isMine: isMine,
                    showSenderName: false,
                  );
                },
              ),
            ),
            if (controllerState.isInitialSyncing)
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: LinearProgressIndicator(minHeight: 2),
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
              const SizedBox(height: 16),
              const Text(
                'No messages yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Messages will appear here after this conversation starts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
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

class _TemporaryInputPlaceholder extends StatelessWidget {
  const _TemporaryInputPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Message input comes next...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}