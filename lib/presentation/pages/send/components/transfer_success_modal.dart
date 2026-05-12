import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/domain/entities/network_model.dart';
import '../../../../data/domain/entities/supported_assets.dart';
import '../../home/components/coin_image.dart';


class TransferSuccessModal extends StatelessWidget {
  final SupportedCoin token;
  final NetworkModel chain;
  final double amount;
  final String recipientAddress;
  final String? message; // Optional custom message

  const TransferSuccessModal({
    super.key,
    required this.token,
    required this.chain,
    required this.amount,
    required this.recipientAddress,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final truncatedAddress = recipientAddress.length > 20
        ? '${recipientAddress.substring(0, 10)}...${recipientAddress.substring(recipientAddress.length - 10)}'
        : recipientAddress;
    final displayMessage = message ??
        'Transfer of $amount ${token.symbol} to $truncatedAddress is successfully completed';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 30),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CoinImage(
                        imageUrl: token.image,
                        height: 60,
                        width: 60
                    ),
                    Positioned(
                      left: -40,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF792A90),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              15.sp.horizontalSpace,
              Text(
                '-$amount ${token.symbol}',
                style: TextStyle(
                  color: const Color(0xFF2D2D2D),
                  fontSize: 20,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          20.sp.verticalSpace,
          Text(
            displayMessage,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: const Color(0xFF2D2D2D),
              fontSize: 16,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          10.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CoinImage(
                  imageUrl: token.networkModel!.imageUrl,
                width: 20,
                height: 20,
              ),
              8.horizontalSpace,
              Text(
                chain.chainName,
                style: TextStyle(
                  color: const Color(0xFF757575),
                  fontSize: 14,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
            ],
          ),
          30.sp.verticalSpace,
          Row(
            children: [
              // Expanded(
              //   child: Container(
              //     height: 50,
              //     decoration: BoxDecoration(
              //       color: const Color(0xFFF9E6FF),
              //       borderRadius: BorderRadius.circular(50),
              //     ),
              //     child: Center(
              //       child: Text(
              //         'Receipt',
              //         style: TextStyle(
              //           color: const Color(0xFF792A90),
              //           fontSize: 15,
              //           fontFamily: 'Satoshi',
              //           fontWeight: FontWeight.w700,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // 15.horizontalSpace,
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: (){
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            ],
          ),
          20.sp.verticalSpace,
        ],
      ),
    );
  }
}

