import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(conversationsControllerProvider.notifier).syncConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          _SyncButton(),
          _LogoutButton(),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const _EmptyConversationsView();
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(conversationsControllerProvider.notifier)
                  .syncConversations();
            },
            child: ListView.separated(
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
                    // Phase 11: navigate to message history screen.
                    // context.go('/conversations/${conversation.id}');
                    context.push('/conversations/${conversation.id}');
                  },
                );
              },
            ),
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
        },
        child: const Icon(Icons.chat_rounded),
      ),
    );
  }
}

class _SyncButton extends ConsumerWidget {
  const _SyncButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(
      conversationsControllerProvider.select((state) => state.isSyncing),
    );

    return IconButton(
      tooltip: 'Sync conversations',
      onPressed: isSyncing
          ? null
          : () {
        ref
            .read(conversationsControllerProvider.notifier)
            .syncConversations();
      },
      icon: isSyncing
          ? const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : const Icon(Icons.sync_rounded),
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
        ref.read(authControllerProvider.notifier).logout();
      },
      icon: const Icon(Icons.logout_rounded),
    );
  }
}

class _EmptyConversationsView extends ConsumerWidget {
  const _EmptyConversationsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(
      conversationsControllerProvider.select((state) => state.isSyncing),
    );

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(conversationsControllerProvider.notifier)
            .syncConversations();
      },
      child: ListView(
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
              isSyncing
                  ? 'Syncing conversations...'
                  : 'Pull down or tap sync to refresh.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
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