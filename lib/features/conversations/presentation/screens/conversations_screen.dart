import 'dart:ui';

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

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next)));
      },
    );

    final conversationsAsync = ref.watch(localConversationsProvider);
    final syncState = ref.watch(conversationsControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: false,
        backgroundColor: Colors.white.withValues(alpha: 0.78),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: const SizedBox.expand(),
          ),
        ),
        actions: const [_AccountMenuButton(), SizedBox(width: 8)],
      ),
      body: Stack(
        children: [
          const _ChatsBackground(),
          SafeArea(
            child: Column(
              children: [
                _ChatsHeroHeader(
                  isSyncing: syncState.isSyncing,
                  lastSyncedAt: syncState.lastSyncedAt,
                ),
                Expanded(
                  child: conversationsAsync.when(
                    data: (conversations) {
                      if (conversations.isEmpty) {
                        return const _EmptyConversationsView();
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(conversationsControllerProvider.notifier)
                              .syncConversations();

                          await ref
                              .read(chatSyncControllerProvider.notifier)
                              .syncNow();
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ConversationTile(
                                key: ValueKey(conversation.id),
                                conversation: conversation,
                                onTap: () {
                                  context.push(
                                    '/conversations/${conversation.id}',
                                  );
                                },
                              ),
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
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Later: open user search / create conversation flow.
            context.push(NewDirectChatScreen.routePath);
          },
          elevation: 0,
          icon: const Icon(Icons.chat_rounded),
          label: const Text(
            'New chat',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _ChatsHeroHeader extends StatelessWidget {
  final bool isSyncing;
  final DateTime? lastSyncedAt;

  const _ChatsHeroHeader({required this.isSyncing, required this.lastSyncedAt});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary, const Color(0xFF0D47A1)],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.22),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
              ),
              child: const Icon(
                Icons.forum_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your conversations',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isSyncing ? 'Syncing latest messages...' : _syncLabel(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: isSyncing
                  ? const SizedBox.square(
                      key: ValueKey('syncing'),
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Container(
                      key: const ValueKey('synced'),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _syncLabel() {
    if (lastSyncedAt == null) {
      return 'Ready when you are';
    }

    return 'Messages are up to date';
  }
}

class _AccountMenuButton extends ConsumerWidget {
  const _AccountMenuButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_AccountMenuAction>(
      tooltip: 'Account options',
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (action) async {
        switch (action) {
          case _AccountMenuAction.logout:
            ref.read(openConversationIdProvider.notifier).state = null;
            await ref.read(authControllerProvider.notifier).logout();
            return;
          case _AccountMenuAction.deleteAccount:
            await _confirmDeleteAccount(context, ref);
            return;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _AccountMenuAction.logout,
          child: Row(
            children: [
              Icon(Icons.logout_rounded),
              SizedBox(width: 10),
              Text('Logout'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _AccountMenuAction.deleteAccount,
          child: Row(
            children: [
              Icon(Icons.delete_forever_rounded, color: Color(0xFFD32F2F)),
              SizedBox(width: 10),
              Text(
                'Delete account',
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete account?'),
          content: const Text(
            'Your account will be disabled and you will be logged out on this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    ref.read(openConversationIdProvider.notifier).state = null;

    final deleted = await ref
        .read(authControllerProvider.notifier)
        .deleteAccount();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Account deleted successfully.'
              : ref.read(authControllerProvider).errorMessage ??
                    'Could not delete account. Please try again.',
        ),
      ),
    );
  }
}

enum _AccountMenuAction { logout, deleteAccount }

class _EmptyConversationsView extends StatelessWidget {
  const _EmptyConversationsView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 120),
        children: [
          Container(
            width: 104,
            height: 104,
            margin: const EdgeInsets.symmetric(horizontal: 100),
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
              size: 50,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'No conversations yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF102033),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 9),
          const Center(
            child: Text(
              'Start a new chat and your conversations\nwill appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7A90),
                fontSize: 14.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
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
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: 7,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _ConversationSkeletonTile(),
        );
      },
    );
  }
}

class _ConversationSkeletonTile extends StatelessWidget {
  const _ConversationSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
      ),
      child: Row(
        children: [
          _SkeletonBox(
            width: 50,
            height: 50,
            radius: 18,
            color: Colors.grey.shade200,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                  width: 150,
                  height: 13,
                  radius: 999,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 10),
                _SkeletonBox(
                  width: double.infinity,
                  height: 11,
                  radius: 999,
                  color: Colors.grey.shade100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _LocalDatabaseErrorView extends StatelessWidget {
  const _LocalDatabaseErrorView();

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
              'Could not load local conversations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF102033),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Please close and reopen the app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7A90),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatsBackground extends StatelessWidget {
  const _ChatsBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF4FF), Color(0xFFF8FBFF), Color(0xFFEFF6FF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _BlurCircle(size: 240, color: Color(0xFF90CAF9)),
          ),
          Positioned(
            bottom: -130,
            left: -90,
            child: _BlurCircle(size: 250, color: Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.24),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
