import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';

class MiningListShimmer extends StatefulWidget {
  const MiningListShimmer({super.key});

  @override
  State<MiningListShimmer> createState() => _MiningListShimmerState();
}

class _MiningListShimmerState extends State<MiningListShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (context, index) {
            return _buildShimmerCard();
          },
        );
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(36, 36),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(120, 14),
                    SizedBox(height: 6),
                    _shimmerBox(160, 10),
                  ],
                ),
              ),
              _shimmerBox(60, 22, borderRadius: 12),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: AppColors.divider, height: 1),
          SizedBox(height: 12),
          ...List.generate(
            5,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerBox(80, 10),
                  _shimmerBox(100, 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height, {double? borderRadius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: _animation.value),
        borderRadius: BorderRadius.circular(borderRadius ?? 6),
      ),
    );
  }
}
