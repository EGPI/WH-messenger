import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/user_search_models.dart';
import '../providers/new_group_chat_controller.dart';

class NewGroupChatScreen extends ConsumerStatefulWidget {
  const NewGroupChatScreen({super.key});

  static const routePath = '/new-group';

  @override
  ConsumerState<NewGroupChatScreen> createState() => _NewGroupChatScreenState();
}

class _NewGroupChatScreenState extends ConsumerState<NewGroupChatScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _searchController;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _searchController = TextEditingController();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();

    _titleController.dispose();

    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      ref
          .read(newGroupChatControllerProvider.notifier)
          .searchUsers(_searchController.text);
    });
  }

  Future<void> _createGroup() async {
    final conversationId = await ref
        .read(newGroupChatControllerProvider.notifier)
        .createGroup(title: _titleController.text);

    if (!mounted || conversationId == null) return;

    context.pushReplacement('/conversations/$conversationId');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      newGroupChatControllerProvider.select((state) => state.errorMessage),
          (previous, next) {
        if (next == null || next == previous) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      },
    );

    final state = ref.watch(newGroupChatControllerProvider);

    final currentUserId = ref.watch(
      authControllerProvider.select((state) => state.user?.id),
    );

    final selectedIds = state.selectedUsers.map((user) => user.id).toSet();

    final users = state.users
        .where((user) => user.id != currentUserId)
        .toList(growable: false);

    final canCreate =
        _titleController.text.trim().isNotEmpty && !state.isCreating;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New group'),
        actions: [
          TextButton(
            onPressed: canCreate ? _createGroup : null,
            child: state.isCreating
                ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text(
              'Create',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _GroupTitleField(
            controller: _titleController,
            onChanged: (_) {
              setState(() {
                // Rebuild only this screen so Create button enables/disables.
              });
            },
          ),
          if (state.selectedUsers.isNotEmpty)
            _SelectedUsersBar(
              users: state.selectedUsers,
              onRemove: (user) {
                ref
                    .read(newGroupChatControllerProvider.notifier)
                    .toggleUser(user);
              },
            ),
          _SearchBox(
            controller: _searchController,
            isSearching: state.isSearching,
          ),
          Expanded(
            child: _UsersList(
              users: users,
              selectedIds: selectedIds,
              query: _searchController.text.trim(),
              isSearching: state.isSearching,
              isCreating: state.isCreating,
              onUserTap: (user) {
                ref
                    .read(newGroupChatControllerProvider.notifier)
                    .toggleUser(user);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTitleField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _GroupTitleField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.groups_rounded,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Group name',
                border: InputBorder.none,
              ),
              maxLength: 80,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedUsersBar extends StatelessWidget {
  final List<UserSearchResultModel> users;
  final ValueChanged<UserSearchResultModel> onRemove;

  const _SelectedUsersBar({
    required this.users,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final user = users[index];

          return _SelectedUserChip(
            user: user,
            onRemove: () => onRemove(user),
          );
        },
      ),
    );
  }
}

class _SelectedUserChip extends StatelessWidget {
  final UserSearchResultModel user;
  final VoidCallback onRemove;

  const _SelectedUserChip({
    required this.user,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Chip(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
        avatar: CircleAvatar(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
          child: Text(
            _initials(user.name),
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        label: Text(
          user.name.trim().isEmpty ? 'Unknown' : user.name.trim(),
          overflow: TextOverflow.ellipsis,
        ),
        deleteIcon: const Icon(Icons.close_rounded, size: 18),
        onDeleted: onRemove,
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search members',
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
  final Set<int> selectedIds;
  final String query;
  final bool isSearching;
  final bool isCreating;
  final ValueChanged<UserSearchResultModel> onUserTap;

  const _UsersList({
    required this.users,
    required this.selectedIds,
    required this.query,
    required this.isSearching,
    required this.isCreating,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return const _GroupHintView();
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
        final isSelected = selectedIds.contains(user.id);

        return _UserTile(
          user: user,
          isSelected: isSelected,
          enabled: !isCreating,
          onTap: () => onUserTap(user),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserSearchResultModel user;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.isSelected,
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
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
              )
            else
              const Icon(Icons.circle_outlined),
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

class _GroupHintView extends StatelessWidget {
  const _GroupHintView();

  @override
  Widget build(BuildContext context) {
    return _CenteredInfoView(
      icon: Icons.group_add_rounded,
      title: 'Add members',
      subtitle: 'Search and select people to include in this group.',
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