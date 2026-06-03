import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'new_direct_chat_screen.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../messages/presentation/providers/message_screen_providers.dart';
import '../../../messages/presentation/providers/outbox_connectivity_provider.dart';
import '../../../realtime/presentation/providers/realtime_bootstrap_provider.dart';
import '../../../sync/presentation/providers/chat_sync_bootstrap_provider.dart';
import '../../../sync/presentation/providers/chat_sync_controller.dart';
import '../providers/conversations_controller.dart';
import '../providers/conversations_providers.dart';
import '../widgets/conversation_tile.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  static const routePath = '/conversations';

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  bool _scheduledClearOpenConversation = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref
          .read(conversationsControllerProvider.notifier)
          .syncConversations();

      await ref.read(chatSyncControllerProvider.notifier).syncNow();
    });
  }

  void _clearOpenConversationAfterBuild() {
    if (_scheduledClearOpenConversation) return;

    _scheduledClearOpenConversation = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(openConversationIdProvider.notifier).state = null;

      _scheduledClearOpenConversation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Keep automatic retry/sync/realtime listeners alive while this screen is mounted.
    ref.watch(outboxConnectivityBootstrapProvider);
    ref.watch(chatSyncBootstrapProvider);
    ref.watch(realtimeBootstrapProvider);

    // Conversation list visible = no conversation is currently open.
    // Delayed because Riverpod does not allow provider mutation during build.
    _clearOpenConversationAfterBuild();

    ref.listen(
      conversationsControllerProvider.select((state) => state.errorMessage),
          (previous, next) {
        if (next == null || next == previous) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      },
    );

    final conversationsAsync = ref.watch(localConversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: const [
          _LogoutButton(),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const _EmptyConversationsView();
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: conversations.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              indent: 78,
            ),
            itemBuilder: (context, index) {
              final conversation = conversations[index];

              return ConversationTile(
                key: ValueKey(conversation.id),
                conversation: conversation,
                onTap: () {
                  context.push('/conversations/${conversation.id}');
                },
              );
            },
          );
        },
        loading: () {
          return const _InitialLocalLoadingView();
        },
        error: (_, _) {
          return const _LocalDatabaseErrorView();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Later: open user search / create conversation flow.
          context.push(NewDirectChatScreen.routePath);
        },
        child: const Icon(Icons.chat_rounded),
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Logout',
      onPressed: () {
        ref.read(openConversationIdProvider.notifier).state = null;
        ref.read(authControllerProvider.notifier).logout();
      },
      icon: const Icon(Icons.logout_rounded),
    );
  }
}

class _EmptyConversationsView extends StatelessWidget {
  const _EmptyConversationsView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 140),
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'New chats will appear here automatically.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialLocalLoadingView extends StatelessWidget {
  const _InitialLocalLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _LocalDatabaseErrorView extends StatelessWidget {
  const _LocalDatabaseErrorView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Could not load local conversations.'),
    );
  }
}