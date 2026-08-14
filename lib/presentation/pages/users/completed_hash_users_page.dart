import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quanthex_admin/core/di/service_locator.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/models/completed_hash_user_model.dart';
import 'package:quanthex_admin/data/domain/models/user_model.dart';
import 'package:quanthex_admin/presentation/widgets/load_more_indicator.dart';

// ─── Hash tiers ──────────────────────────────────────────────────────────────

enum HashTier {
  gigaHash(6, 'Giga Hash'),
  teraHash(36, 'Tera Hash'),
  petaHash(216, 'Peta Hash');

  final int minReferrals;
  final String label;
  const HashTier(this.minReferrals, this.label);
}

// ─── Main page ───────────────────────────────────────────────────────────────

class CompletedHashUsersPage extends StatefulWidget {
  /// When non-null, only users whose packageName matches are shown.
  final String? packageName;

  const CompletedHashUsersPage({super.key, this.packageName});

  @override
  State<CompletedHashUsersPage> createState() => _CompletedHashUsersPageState();
}

class _CompletedHashUsersPageState extends State<CompletedHashUsersPage> {
  final ScrollController _scrollController = ScrollController();

  HashTier _selectedTier = HashTier.gigaHash;
  List<CompletedHashUserModel> _users = [];
  int _total = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';

  static const int _pageSize = 20;

  /// Filtered list based on packageName prop.
  List<CompletedHashUserModel> get _filteredUsers {
    if (widget.packageName == null) return _users;
    return _users
        .where((u) => u.packageName == widget.packageName)
        .toList();
  }

  bool get _hasMore => _users.length < _total;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchUsers();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _selectTier(HashTier tier) {
    if (tier == _selectedTier) return;
    setState(() {
      _selectedTier = tier;
      _users = [];
      _total = 0;
    });
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final response = await ServiceLocator.instance.userRepository.getCompletedHashUsers(
        minReferrals: _selectedTier.minReferrals,
        offset: 0,
        limit: _pageSize,
      );
      setState(() {
        _users = response.data;
        _total = response.total;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load users. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final response =
          await ServiceLocator.instance.userRepository.getCompletedHashUsers(
        minReferrals: _selectedTier.minReferrals,
        offset: _users.length,
        limit: _pageSize,
      );
      setState(() {
        _users.addAll(response.data);
        _total = response.total;
      });
    } catch (_) {}
    finally {
      setState(() => _isLoadingMore = false);
    }
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
    final filtered = _filteredUsers;

    return Column(
      children: [
        // Filter chips
        Container(
          width: double.infinity,
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: HashTier.values.map((tier) {
              final isSelected = _selectedTier == tier;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    '${tier.label} (${tier.minReferrals})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  showCheckmark: false,
                  onSelected: (_) => _selectTier(tier),
                ),
              );
            }).toList(),
          ),
        ),
        Container(height: 1, color: AppColors.border),
        // Total count
        if (!_isLoading && !_hasError)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primaryFaint,
            child: Text(
              widget.packageName != null
                  ? '${filtered.length} ${widget.packageName} user${filtered.length == 1 ? '' : 's'} completed ${_selectedTier.label}'
                  : '$_total user${_total == 1 ? '' : 's'} completed ${_selectedTier.label}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        // Content
        Expanded(child: _buildContent(filtered)),
      ],
    );
  }

  Widget _buildContent(List<CompletedHashUserModel> users) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchUsers,
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

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline,
                size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              widget.packageName != null
                  ? 'No ${widget.packageName} users have completed ${_selectedTier.label}'
                  : 'No users have completed ${_selectedTier.label}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUsers,
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: users.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(
          height: 1, color: AppColors.divider, indent: 16, endIndent: 16,
        ),
        itemBuilder: (context, index) {
          if (index == users.length) {
            return const LoadMoreIndicator();
          }
          final user = users[index];
          return _CompletedHashUserItem(
            user: user,
            index: users.length - index,
            formattedDate: _formatDate(user.userCreatedAt),
            tierLabel: _selectedTier.label,
            onTap: () {
              final userModel = UserModel(
                uid: user.uid,
                email: user.email,
                accountStatus: user.accountStatus,
                roles: user.roles,
                userCreatedAt: user.userCreatedAt,
                regVia: user.regVia,
                referralCode: user.referralCode,
                profileCreatedAt: user.profileCreatedAt,
                profileUpdatedAt: user.profileUpdatedAt,
              );
              context.push(AppRoutes.userDetail, extra: userModel);
            },
          );
        },
      ),
    );
  }
}

// ─── User item ───────────────────────────────────────────────────────────────

class _CompletedHashUserItem extends StatelessWidget {
  final CompletedHashUserModel user;
  final int index;
  final String formattedDate;
  final String tierLabel;
  final VoidCallback onTap;

  const _CompletedHashUserItem({
    required this.user,
    required this.index,
    required this.formattedDate,
    required this.tierLabel,
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
                      Icon(Icons.people_outline,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${user.directReferralCount} referrals',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                      if (user.packageName != null &&
                          user.packageName!.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.inventory_2_outlined,
                            size: 12, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          user.packageName!,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                      const SizedBox(width: 10),
                      Icon(Icons.calendar_today,
                          size: 11, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
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
                color: AppColors.statusActive.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tierLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.statusActive,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
