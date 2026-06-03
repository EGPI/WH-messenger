import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'new_group_chat_screen.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/user_search_models.dart';
import '../providers/new_direct_chat_controller.dart';
import 'new_announcement_chat_screen.dart';

//note that this screen is the first on eimplemented for create new chat and we added new groupchat screen import to appear in here also as modal to choose between them


class NewDirectChatScreen extends ConsumerStatefulWidget {
  const NewDirectChatScreen({super.key});

  static const routePath = '/new-chat';

  @override
  ConsumerState<NewDirectChatScreen> createState() =>
      _NewDirectChatScreenState();
}

class _NewDirectChatScreenState extends ConsumerState<NewDirectChatScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();

    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      ref
          .read(newDirectChatControllerProvider.notifier)
          .searchUsers(_searchController.text);
    });
  }

  Future<void> _openDirectChat(UserSearchResultModel user) async {
    final conversationId = await ref
        .read(newDirectChatControllerProvider.notifier)
        .createOrOpenDirectChat(userId: user.id);

    if (!mounted || conversationId == null) return;

    context.pushReplacement('/conversations/$conversationId');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      newDirectChatControllerProvider.select((state) => state.errorMessage),
          (previous, next) {
        if (next == null || next == previous) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      },
    );

    final state = ref.watch(newDirectChatControllerProvider);

    final currentUserId = ref.watch(
      authControllerProvider.select((state) => state.user?.id),
    );

    final users = state.users
        .where((user) => user.id != currentUserId)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New chat'),
      ),
      body: Column(
        children: [
          _SearchBox(
            controller: _searchController,
            isSearching: state.isSearching,
          ),
          _NewGroupRow(
            onTap: () {
              context.push(NewGroupChatScreen.routePath);
            },
          ),
          _NewAnnouncementRow(
            onTap: () {
              context.push(NewAnnouncementChatScreen.routePath);
            },
          ),
          Expanded(
            child: _UsersList(
              users: users,
              isSearching: state.isSearching,
              isCreating: state.isCreating,
              query: _searchController.text.trim(),
              onUserTap: _openDirectChat,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewAnnouncementRow extends StatelessWidget {
  final VoidCallback onTap;

  const _NewAnnouncementRow({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.campaign_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'New announcement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewGroupRow extends StatelessWidget {
  final VoidCallback onTap;

  const _NewGroupRow({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.group_add_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'New group',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;

  const _SearchBox({
    required this.controller,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7FF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
        child: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search by name or email',
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.primary,
            ),
            suffixIcon: isSearching
                ? const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  final List<UserSearchResultModel> users;
  final bool isSearching;
  final bool isCreating;
  final String query;
  final ValueChanged<UserSearchResultModel> onUserTap;

  const _UsersList({
    required this.users,
    required this.isSearching,
    required this.isCreating,
    required this.query,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return const _NewChatHintView();
    }

    if (query.length < 2) {
      return const _SmallQueryView();
    }

    if (users.isEmpty && isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (users.isEmpty) {
      return const _NoUsersFoundView();
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        indent: 72,
      ),
      itemBuilder: (context, index) {
        final user = users[index];

        return _UserTile(
          user: user,
          enabled: !isCreating,
          onTap: () => onUserTap(user),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserSearchResultModel user;
  final bool enabled;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = _initials(user.name);

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                initials,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _UserText(
                name: user.name,
                email: user.email,
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) return '?';

    final words = trimmed
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();

    if (words.isEmpty) return '?';

    if (words.length == 1) {
      return words.first.characters.first.toUpperCase();
    }

    return '${words.first.characters.first}${words[1].characters.first}'
        .toUpperCase();
  }
}

class _UserText extends StatelessWidget {
  final String name;
  final String email;

  const _UserText({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final safeName = name.trim().isEmpty ? 'Unknown user' : name.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          safeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _NewChatHintView extends StatelessWidget {
  const _NewChatHintView();

  @override
  Widget build(BuildContext context) {
    return _CenteredInfoView(
      icon: Icons.person_search_rounded,
      title: 'Search for someone',
      subtitle: 'Type at least 2 characters to start a direct chat.',
      iconColor: Theme.of(context).colorScheme.primary,
    );
  }
}

class _SmallQueryView extends StatelessWidget {
  const _SmallQueryView();

  @override
  Widget build(BuildContext context) {
    return _CenteredInfoView(
      icon: Icons.search_rounded,
      title: 'Keep typing',
      subtitle: 'Search requires at least 2 characters.',
      iconColor: Theme.of(context).colorScheme.primary,
    );
  }
}

class _NoUsersFoundView extends StatelessWidget {
  const _NoUsersFoundView();

  @override
  Widget build(BuildContext context) {
    return _CenteredInfoView(
      icon: Icons.search_off_rounded,
      title: 'No users found',
      subtitle: 'Try another name or email.',
      iconColor: Colors.grey,
    );
  }
}

class _CenteredInfoView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  const _CenteredInfoView({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 58,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}