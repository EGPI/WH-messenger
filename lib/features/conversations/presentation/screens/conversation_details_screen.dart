import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/conversation_api.dart';
import '../../data/user_search_models.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/conversation_details_controller.dart';
import '../providers/conversation_details_providers.dart';

class ConversationDetailsScreen extends ConsumerStatefulWidget {
  final int conversationId;

  const ConversationDetailsScreen({
    super.key,
    required this.conversationId,
  });

  static const routePath = '/conversations/:conversationId/details';

  @override
  ConsumerState<ConversationDetailsScreen> createState() =>
      _ConversationDetailsScreenState();
}

class _ConversationDetailsScreenState
    extends ConsumerState<ConversationDetailsScreen> {
  bool _didLoad = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(_loadOnce);
  }

  void _loadOnce() {
    if (_didLoad) return;

    _didLoad = true;

    ref
        .read(
      conversationDetailsControllerProvider(widget.conversationId).notifier,
    )
        .loadDetails();
  }

  Future<void> _refresh() {
    return ref
        .read(
      conversationDetailsControllerProvider(widget.conversationId).notifier,
    )
        .loadDetails(refresh: true);
  }

  Future<void> _confirmRemoveMember({
    required int userId,
    required String name,
  }) async {
    final safeName = name.trim().isEmpty ? 'this member' : name.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove member?'),
          content: Text('Remove $safeName from this conversation?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    await ref
        .read(
      conversationDetailsControllerProvider(widget.conversationId).notifier,
    )
        .removeMember(userId: userId);
  }

  Future<void> _openAddMemberSheet({
    required Set<int> existingUserIds,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddMemberSheet(
          conversationId: widget.conversationId,
          existingUserIds: existingUserIds,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      conversationDetailsControllerProvider(widget.conversationId)
          .select((state) => state.errorMessage),
          (previous, next) {
        if (next == null || next == previous) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      },
    );

    final state = ref.watch(
      conversationDetailsControllerProvider(widget.conversationId),
    );

    final conversationAsync = ref.watch(
      conversationDetailsLocalConversationProvider(widget.conversationId),
    );

    final participantsAsync = ref.watch(
      localConversationParticipantsProvider(widget.conversationId),
    );

    final currentUserId = ref.watch(
      authControllerProvider.select((state) => state.user?.id),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Chat details'),
        backgroundColor: Colors.white.withValues(alpha: 0.80),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: const SizedBox.expand(),
          ),
        ),
      ),
      body: Stack(
        children: [
          const _DetailsBackground(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: conversationAsync.when(
                data: (conversation) {
                  final type = conversation?.type ?? 'direct';
                  final title = _conversationTitle(
                    type: type,
                    title: conversation?.title,
                  );
                  final myRole = conversation?.myRole;

                  return participantsAsync.when(
                    data: (participants) {
                      if (state.isLoading && participants.isEmpty) {
                        return const _DetailsLoadingView();
                      }

                      final activeParticipants = participants;

                      final otherUsers = type == 'direct'
                          ? activeParticipants
                          .where((item) => item.user.id != currentUserId)
                          .toList(growable: false)
                          : const [];

                      final otherUser = otherUsers.isEmpty ? null : otherUsers.first;

                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                        children: [
                          _DetailsHeroCard(
                            title: type == 'direct' && otherUser != null
                                ? otherUser.user.name
                                : title,
                            subtitle: _subtitleForType(
                              type: type,
                              memberCount: activeParticipants.length,
                              myRole: myRole,
                            ),
                            type: type,
                            isRefreshing: state.isRefreshing,
                          ),
                          const SizedBox(height: 14),
                          if (type == 'direct')
                            _DirectUserSection(
                              otherUser: otherUser,
                            )
                          else ...[
                            _ConversationInfoSection(
                              title: title,
                              type: type,
                              myRole: myRole,
                              memberCount: activeParticipants.length,
                            ),
                            const SizedBox(height: 14),
                            _MembersSection(
                              participants: activeParticipants,
                              currentUserId: currentUserId,
                              canManageMembers: _canManageMembers(myRole),
                              removingUserId: state.removingUserId,
                              promotingUserId: state.promotingUserId,
                              onAddMember: () {
                                _openAddMemberSheet(
                                  existingUserIds: activeParticipants
                                      .map((item) => item.user.id)
                                      .whereType<int>()
                                      .toSet(),
                                );
                              },
                              onRemove: (userId, name) {
                                _confirmRemoveMember(
                                  userId: userId,
                                  name: name,
                                );
                              },
                              onPromote: (userId) {
                                ref
                                    .read(
                                  conversationDetailsControllerProvider(widget.conversationId).notifier,
                                )
                                    .promoteMember(userId: userId);
                              },
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const _DetailsLoadingView(),
                    error: (_, _) => const _DetailsErrorView(),
                  );
                },
                loading: () => const _DetailsLoadingView(),
                error: (_, _) => const _DetailsErrorView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _conversationTitle({
    required String type,
    required String? title,
  }) {
    final trimmed = title?.trim();

    if (trimmed != null && trimmed.isNotEmpty) return trimmed;

    if (type == 'announcement') return 'Announcement';
    if (type == 'group') return 'Group chat';

    return 'Direct chat';
  }

  String _subtitleForType({
    required String type,
    required int memberCount,
    required String? myRole,
  }) {
    if (type == 'direct') return 'Direct chat';

    final role = myRole?.trim();

    final roleText = role == null || role.isEmpty ? 'member' : role;
    final memberText = '$memberCount member${memberCount == 1 ? '' : 's'}';

    if (type == 'announcement') {
      return 'Announcement • $memberText • You are $roleText';
    }

    return 'Group • $memberText • You are $roleText';
  }

  bool _canManageMembers(String? myRole) {
    final role = myRole?.trim().toLowerCase();

    return role == 'owner' || role == 'admin';
  }
}

class _DetailsHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String type;
  final bool isRefreshing;

  const _DetailsHeroCard({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = _iconForType(type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            const Color(0xFF0D47A1),
          ],
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
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.trim().isEmpty ? 'Chat' : title.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          if (isRefreshing)
            const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    if (type == 'announcement') return Icons.campaign_rounded;
    if (type == 'group') return Icons.groups_rounded;

    return Icons.person_rounded;
  }
}

class _DirectUserSection extends StatelessWidget {
  final dynamic otherUser;

  const _DirectUserSection({
    required this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    if (otherUser == null) {
      return const _InfoCard(
        icon: Icons.person_search_rounded,
        title: 'User details unavailable',
        subtitle: 'Pull down to refresh chat details.',
      );
    }

    final user = otherUser.user;

    return _InfoCard(
      icon: Icons.person_rounded,
      title: user.name.trim().isEmpty ? 'Unknown user' : user.name.trim(),
      subtitle: user.email,
      footer: user.phone == null || user.phone!.trim().isEmpty
          ? null
          : user.phone!.trim(),
    );
  }
}

class _ConversationInfoSection extends StatelessWidget {
  final String title;
  final String type;
  final String? myRole;
  final int memberCount;

  const _ConversationInfoSection({
    required this.title,
    required this.type,
    required this.myRole,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = type == 'announcement' ? 'Announcement' : 'Group';

    return _InfoCard(
      icon: type == 'announcement'
          ? Icons.campaign_rounded
          : Icons.groups_rounded,
      title: title,
      subtitle: '$typeLabel chat',
      footer:
      '$memberCount member${memberCount == 1 ? '' : 's'} • Role: ${myRole ?? 'member'}',
    );
  }
}

class _MembersSection extends StatelessWidget {
  final List<dynamic> participants;
  final int? currentUserId;
  final bool canManageMembers;
  final int? removingUserId;
  final int? promotingUserId;
  final VoidCallback onAddMember;
  final void Function(int userId, String name) onRemove;
  final ValueChanged<int> onPromote;

  const _MembersSection({
    required this.participants,
    required this.currentUserId,
    required this.canManageMembers,
    required this.removingUserId,
    required this.promotingUserId,
    required this.onRemove,
    required this.onPromote,
    required this.onAddMember,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const _InfoCard(
        icon: Icons.group_off_rounded,
        title: 'No members found',
        subtitle: 'Pull down to refresh members.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.94),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  color: Color(0xFF1565C0),
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Members',
                    style: TextStyle(
                      color: Color(0xFF102033),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (canManageMembers)
                  TextButton.icon(
                    onPressed: onAddMember,
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: const Text(
                      'Add',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
              ],
            ),
          ),
          for (final item in participants)
            _MemberTile(
              name: item.user.name,
              email: item.user.email,
              role: item.participant.role,
              userId: item.user.id,
              isMe: item.user.id == currentUserId,
              canManageMembers: canManageMembers,
              isRemoving: removingUserId == item.user.id,
              isPromoting: promotingUserId == item.user.id,
              onRemove: () => onRemove(
                item.user.id,
                item.user.name,
              ),
              onPromote: () => onPromote(item.user.id),
            ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final int userId;
  final String name;
  final String email;
  final String? role;
  final bool isMe;
  final bool canManageMembers;
  final bool isRemoving;
  final bool isPromoting;
  final VoidCallback onRemove;
  final VoidCallback onPromote;

  const _MemberTile({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.isMe,
    required this.canManageMembers,
    required this.isRemoving,
    required this.isPromoting,
    required this.onRemove,
    required this.onPromote,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final safeName = name.trim().isEmpty ? 'Unknown user' : name.trim();
    final initials = _initials(safeName);

    final normalizedRole = role?.trim().toLowerCase();
    final isOwner = normalizedRole == 'owner';
    final isAdmin = normalizedRole == 'admin';
    final isBusy = isRemoving || isPromoting;

    final canShowActions = canManageMembers && !isMe && !isOwner;
    final canPromote = canShowActions && !isAdmin;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  const Color(0xFF42A5F5),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? '$safeName (You)' : safeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF102033),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7A90),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _RolePill(role: role),
          if (canShowActions) ...[
            const SizedBox(width: 4),
            if (isBusy)
              const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              PopupMenuButton<String>(
                tooltip: 'Member actions',
                onSelected: (value) {
                  if (value == 'promote') {
                    onPromote();
                    return;
                  }

                  if (value == 'remove') {
                    onRemove();
                  }
                },
                itemBuilder: (context) {
                  return [
                    if (canPromote)
                      const PopupMenuItem(
                        value: 'promote',
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings_rounded),
                            SizedBox(width: 10),
                            Text('Promote to admin'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove_rounded),
                          SizedBox(width: 10),
                          Text('Remove member'),
                        ],
                      ),
                    ),
                  ];
                },
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF6B7A90),
                ),
              ),
          ],
        ],
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

class _RolePill extends StatelessWidget {
  final String? role;

  const _RolePill({
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final safeRole = role?.trim().isEmpty ?? true ? 'member' : role!.trim();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        safeRole,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? footer;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.94),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: colorScheme.primary.withValues(alpha: 0.10),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.trim().isEmpty ? 'Unknown' : title.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF102033),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7A90),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                if (footer != null && footer!.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    footer!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsLoadingView extends StatelessWidget {
  const _DetailsLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: index == 0 ? 100 : 76,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
        );
      },
    );
  }
}

class _DetailsErrorView extends StatelessWidget {
  const _DetailsErrorView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
      children: const [
        _InfoCard(
          icon: Icons.error_outline_rounded,
          title: 'Could not load details',
          subtitle: 'Pull down to refresh and try again.',
        ),
      ],
    );
  }
}

class _AddMemberSheet extends ConsumerStatefulWidget {
  final int conversationId;
  final Set<int> existingUserIds;

  const _AddMemberSheet({
    required this.conversationId,
    required this.existingUserIds,
  });

  @override
  ConsumerState<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<_AddMemberSheet> {
  late final TextEditingController _searchController;

  Timer? _debounceTimer;

  bool _isSearching = false;
  String? _errorMessage;
  List<UserSearchResultModel> _users = const [];

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
      _searchUsers(_searchController.text);
    });
  }

  Future<void> _searchUsers(String query) async {
    final trimmed = query.trim();

    if (trimmed.length < 2) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _errorMessage = null;
        _users = const [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final response = await ref.read(conversationApiProvider).searchUsers(
        query: trimmed,
        perPage: 20,
      );

      final filtered = response.data
          .where((user) => !widget.existingUserIds.contains(user.id))
          .toList(growable: false);

      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _users = filtered;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _errorMessage = 'Could not search users.';
      });
    }
  }

  Future<void> _addUser(UserSearchResultModel user) async {
    await ref
        .read(
      conversationDetailsControllerProvider(widget.conversationId).notifier,
    )
        .addMember(userId: user.id);

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final isAdding = ref.watch(
      conversationDetailsControllerProvider(widget.conversationId)
          .select((state) => state.isAddingMember),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FBFF),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8D4E3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add member',
                        style: TextStyle(
                          color: Color(0xFF102033),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: _AddMemberSearchBox(
                  controller: _searchController,
                  isSearching: _isSearching,
                ),
              ),
              Flexible(
                child: _AddMemberResults(
                  query: _searchController.text.trim(),
                  users: _users,
                  isSearching: _isSearching,
                  isAdding: isAdding,
                  errorMessage: _errorMessage,
                  onAdd: _addUser,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMemberSearchBox extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;

  const _AddMemberSearchBox({
    required this.controller,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE4ECF7),
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
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: Color(0xFF102033),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Search users',
          hintStyle: const TextStyle(
            color: Color(0xFF8A98AA),
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
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
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

class _AddMemberResults extends StatelessWidget {
  final String query;
  final List<UserSearchResultModel> users;
  final bool isSearching;
  final bool isAdding;
  final String? errorMessage;
  final ValueChanged<UserSearchResultModel> onAdd;

  const _AddMemberResults({
    required this.query,
    required this.users,
    required this.isSearching,
    required this.isAdding,
    required this.errorMessage,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return const _AddMemberInfoView(
        icon: Icons.person_add_alt_1_rounded,
        title: 'Search for people',
        subtitle: 'Type a name or email to add someone.',
      );
    }

    if (query.length < 2) {
      return const _AddMemberInfoView(
        icon: Icons.search_rounded,
        title: 'Keep typing',
        subtitle: 'Search requires at least 2 characters.',
      );
    }

    if (errorMessage != null) {
      return _AddMemberInfoView(
        icon: Icons.error_outline_rounded,
        title: 'Search failed',
        subtitle: errorMessage!,
      );
    }

    if (users.isEmpty && isSearching) {
      return const _AddMemberLoadingList();
    }

    if (users.isEmpty) {
      return const _AddMemberInfoView(
        icon: Icons.search_off_rounded,
        title: 'No users found',
        subtitle: 'Try another name or email.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _AddMemberUserTile(
            user: user,
            enabled: !isAdding,
            onTap: () => onAdd(user),
          ),
        );
      },
    );
  }
}

class _AddMemberUserTile extends StatelessWidget {
  final UserSearchResultModel user;
  final bool enabled;
  final VoidCallback onTap;

  const _AddMemberUserTile({
    required this.user,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final safeName = user.name.trim().isEmpty ? 'Unknown user' : user.name;
    final initials = _initials(safeName);

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.92),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        const Color(0xFF42A5F5),
                      ],
                    ),
                  ),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AddMemberUserText(
                    name: safeName,
                    email: user.email,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.person_add_alt_1_rounded,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
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

class _AddMemberUserText extends StatelessWidget {
  final String name;
  final String email;

  const _AddMemberUserText({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.trim().isEmpty ? 'Unknown user' : name.trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF102033),
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF6B7A90),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AddMemberInfoView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AddMemberInfoView({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.94),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 44,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF102033),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7A90),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddMemberLoadingList extends StatelessWidget {
  const _AddMemberLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          height: 78,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
        );
      },
    );
  }
}

class _DetailsBackground extends StatelessWidget {
  const _DetailsBackground();

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
            top: -120,
            right: -80,
            child: _BlurCircle(
              size: 240,
              color: Color(0xFF90CAF9),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -90,
            child: _BlurCircle(
              size: 250,
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
            color: color.withValues(alpha: 0.24),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}