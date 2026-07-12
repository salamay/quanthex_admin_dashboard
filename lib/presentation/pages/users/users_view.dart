import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/models/user_model.dart';
import 'package:quanthex_admin/presentation/providers/users_provider.dart';
import 'package:quanthex_admin/presentation/widgets/load_more_indicator.dart';

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UsersProvider>();
      if (provider.users.isEmpty) {
        provider.fetchUsers();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<UsersProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final millis = int.tryParse(timestamp);
      if (millis == null) return 'N/A';
      final date = DateTime.fromMillisecondsSinceEpoch(millis);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by email or referral code...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onSubmitted: (value) {
                    context.read<UsersProvider>().setSearchQuery(value);
                    context.read<UsersProvider>().applySearch();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Consumer<UsersProvider>(
                builder: (context, provider, _) {
                  if (provider.searchQuery != null) {
                    return IconButton(
                      onPressed: () {
                        _searchController.clear();
                        provider.clearSearch();
                      },
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                      tooltip: 'Clear search',
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.border),
        // Total count
        Consumer<UsersProvider>(
          builder: (context, provider, _) {
            if (!provider.isLoading && !provider.hasError) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.primaryFaint,
                child: Text(
                  '${provider.total} user${provider.total == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // User list
        Expanded(
          child: Consumer<UsersProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (provider.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(
                        provider.errorMessage,
                        style: const TextStyle(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => provider.fetchUsers(refresh: true),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (provider.users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      Text(
                        provider.searchQuery != null ? 'No users match your search' : 'No users found',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => provider.fetchUsers(refresh: true),
                color: AppColors.primary,
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: provider.users.length + (provider.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    if (index == provider.users.length) {
                      return const LoadMoreIndicator();
                    }
                    final user = provider.users[index];
                    return _UserListItem(
                      user: user,
                      index: provider.total - index,
                      formattedDate: _formatDate(user.userCreatedAt),
                      onTap: () {
                        context.push(AppRoutes.userDetail, extra: user);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserListItem extends StatelessWidget {
  final UserModel user;
  final int index;
  final String formattedDate;
  final VoidCallback onTap;

  const _UserListItem({
    required this.user,
    required this.index,
    required this.formattedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Index number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryFaint,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (user.referralCode != null && user.referralCode!.isNotEmpty) ...[
                        Icon(Icons.link, size: 12, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          user.referralCode!,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(Icons.calendar_today, size: 11, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user.isActive
                    ? AppColors.statusActive.withOpacity(0.1)
                    : AppColors.statusPending.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.accountStatus,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: user.isActive ? AppColors.statusActive : AppColors.statusPending,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
