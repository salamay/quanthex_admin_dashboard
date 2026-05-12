import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/staking_settings_provider.dart';
import 'components/settings_card.dart';

/// Embeddable staking settings view for use inside HomePage drawer layout.
class StakingSettingsView extends StatefulWidget {
  const StakingSettingsView({super.key});

  @override
  State<StakingSettingsView> createState() => _StakingSettingsViewState();
}

class _StakingSettingsViewState extends State<StakingSettingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StakingSettingsProvider>().fetchSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StakingSettingsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(provider.errorMessage, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: provider.fetchSettings,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.settings.isEmpty) {
          return const Center(
            child: Text('No staking settings found.', style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: provider.fetchSettings,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.settings.length,
            itemBuilder: (context, index) {
              return SettingsCard(
                setting: provider.settings[index],
                onUpdate: (rewardPercentage, referralsPerCycle, isActive) async {
                  final success = await provider.updateSetting(
                    ssId: provider.settings[index].ssId,
                    rewardPercentage: rewardPercentage,
                    referralsPerCycle: referralsPerCycle,
                    isActive: isActive,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Setting updated successfully' : 'Failed to update setting'),
                        backgroundColor: success ? AppColors.statusActive : AppColors.error,
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
