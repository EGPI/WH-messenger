import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'new_group_chat_screen.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/user_search_models.dart';
import '../providers/new_direct_chat_controller.dart';
import 'new_announcement_chat_screen.dart';

// note that this screen is the first one implemented for create new chat
// and we added new group chat screen import to appear in here also as modal
// to choose between them

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
    final keyboardBottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final currentUserId = ref.watch(
      authControllerProvider.select((state) => state.user?.id),
    );

    final users = state.users
        .where((user) => user.id != currentUserId)
        .toList(growable: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('New chat'),
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
          const _NewChatBackground(),
          SafeArea(
            child: Column(
              children: [
                _HeroCard(
                  isSearching: state.isSearching,
                  isCreating: state.isCreating,
                ),
                _SearchBox(
                  controller: _searchController,
                  isSearching: state.isSearching,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Column(
                    children: [
                      _ActionCard(
                        icon: Icons.group_add_rounded,
                        title: 'New group',
                        subtitle: 'Start a chat with multiple people',
                        onTap: () {
                          context.push(NewGroupChatScreen.routePath);
                        },
                      ),
                      const SizedBox(height: 10),
                      _ActionCard(
                        icon: Icons.campaign_rounded,
                        title: 'New announcement',
                        subtitle: 'Create a one-way announcement chat',
                        onTap: () {
                          context.push(NewAnnouncementChatScreen.routePath);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _UsersList(
                    users: users,
                    isSearching: state.isSearching,
                    isCreating: state.isCreating,
                    query: _searchController.text.trim(),
                    keyboardBottomInset: keyboardBottomInset,
                    onUserTap: _openDirectChat,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final bool isSearching;
  final bool isCreating;

  const _HeroCard({
    required this.isSearching,
    required this.isCreating,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String statusText = 'Search people and start a conversation';

    if (isSearching) {
      statusText = 'Searching people...';
    } else if (isCreating) {
      statusText = 'Opening chat...';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
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
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                ),
              ),
              child: const Icon(
                Icons.person_search_rounded,
                color: Colors.white,
                size: 29,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start something new',
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
                    statusText,
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
              child: isSearching || isCreating
                  ? const SizedBox.square(
                key: ValueKey('busy'),
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
                  : Container(
                key: const ValueKey('ready'),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.92),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
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
                      color: colorScheme.primary.withValues(alpha: 0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF102033),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8A98AA),
              ),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.94),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          autofocus: false,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            color: Color(0xFF102033),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Search by name or email',
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
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  final List<UserSearchResultModel> users;
  final bool isSearching;
  final bool isCreating;
  final String query;
  final double keyboardBottomInset;
  final ValueChanged<UserSearchResultModel> onUserTap;

  const _UsersList({
    required this.users,
    required this.isSearching,
    required this.isCreating,
    required this.query,
    required this.keyboardBottomInset,
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
      return const _UsersLoadingView();
    }

    if (users.isEmpty) {
      return const _NoUsersFoundView();
    }

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        16,
        2,
        16,
        24 + keyboardBottomInset,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _UserTile(
            user: user,
            enabled: !isCreating,
            onTap: () => onUserTap(user),
          ),
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
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.92),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19),
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
                        color: colorScheme.primary.withValues(alpha: 0.16),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: _UserText(
                    name: user.name,
                    email: user.email,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: colorScheme.primary,
                    size: 18,
                  ),
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
            color: Color(0xFF102033),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.1,
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

class _UsersLoadingView extends StatelessWidget {
  const _UsersLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: _UserSkeletonTile(),
        );
      },
    );
  }
}

class _UserSkeletonTile extends StatelessWidget {
  const _UserSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
      child: Row(
        children: [
          _SkeletonBox(
            width: 52,
            height: 52,
            radius: 19,
            color: Colors.grey.shade200,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                  width: 140,
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
    return const _CenteredInfoView(
      icon: Icons.search_off_rounded,
      title: 'No users found',
      subtitle: 'Try another name or email.',
      iconColor: Color(0xFF8A98AA),
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
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 42),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.92),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withValues(alpha: 0.12),
                      const Color(0xFF42A5F5).withValues(alpha: 0.14),
                    ],
                  ),
                ),
                child: Icon(
                  icon,
                  size: 42,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF102033),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
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

class _NewChatBackground extends StatelessWidget {
  const _NewChatBackground();

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