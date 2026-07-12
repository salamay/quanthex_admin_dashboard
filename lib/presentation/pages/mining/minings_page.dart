import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/mining_provider.dart';
import 'package:quanthex_admin/presentation/widgets/load_more_indicator.dart';
import 'components/mining_list_item.dart';
import 'components/mining_list_shimmer.dart';
import 'components/mining_empty_state.dart';
import 'components/mining_error_state.dart';
import 'components/mining_filter_bar.dart';

/// Embeddable minings view (no Scaffold/AppBar) for use inside HomePage drawer layout.
class MiningsView extends StatefulWidget {
  const MiningsView({super.key});

  @override
  State<MiningsView> createState() => _MiningsViewState();
}

class _MiningsViewState extends State<MiningsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MiningProvider>().fetchMinings();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MiningProvider>().loadMore();
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
        const MiningFilterBar(),
        Expanded(
          child: Consumer<MiningProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const MiningListShimmer();
              }

              if (provider.hasError) {
                return MiningErrorState(
                  message: provider.errorMessage,
                  onRetry: () => provider.fetchMinings(refresh: true),
                );
              }

              if (provider.minings.isEmpty) {
                return const MiningEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => provider.fetchMinings(refresh: true),
                child: Column(
                  children: [
                    // Total count header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        'Showing ${provider.minings.length} of ${provider.total} minings',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    // List
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: provider.minings.length +
                            (provider.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.minings.length) {
                            return const LoadMoreIndicator();
                          }
                          return MiningListItem(
                            record: provider.minings[index],
                            index: provider.total - index - 1,
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
