import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/staking_provider.dart';
import 'package:quanthex_admin/presentation/widgets/load_more_indicator.dart';
import 'package:quanthex_admin/presentation/pages/mining/components/mining_list_shimmer.dart';
import 'package:quanthex_admin/presentation/pages/mining/components/mining_empty_state.dart';
import 'package:quanthex_admin/presentation/pages/mining/components/mining_error_state.dart';
import 'components/staking_list_item.dart';
import 'components/staking_filter_bar.dart';

/// Embeddable stakings view (no Scaffold/AppBar) for use inside HomePage drawer layout.
class StakingsView extends StatefulWidget {
  const StakingsView({super.key});

  @override
  State<StakingsView> createState() => _StakingsViewState();
}

class _StakingsViewState extends State<StakingsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StakingProvider>().fetchStakings();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<StakingProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StakingFilterBar(),
        Expanded(
          child: Consumer<StakingProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const MiningListShimmer();
              }

              if (provider.hasError) {
                return MiningErrorState(
                  message: provider.errorMessage,
                  onRetry: () => provider.fetchStakings(refresh: true),
                );
              }

              if (provider.stakings.isEmpty) {
                return const MiningEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => provider.fetchStakings(refresh: true),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        'Showing ${provider.stakings.length} of ${provider.total} stakings',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: provider.stakings.length +
                            (provider.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.stakings.length) {
                            return const LoadMoreIndicator();
                          }
                          return StakingListItem(
                            record: provider.stakings[index],
                            index: index,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
