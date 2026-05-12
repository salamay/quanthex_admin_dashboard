import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/network_constants.dart';
import '../../../../data/domain/entities/supported_assets.dart';
import '../../../../data/domain/models/balance/CoinBalance.dart';
import '../../../../data/utils/my_currency_utils.dart';
import '../../../providers/balance_controller.dart';
import 'coin_image.dart';

class AssetItem extends StatelessWidget {
  AssetItem({super.key, required this.coin});

  SupportedCoin coin;


  
  @override
  Widget build(BuildContext context) {
    return Container(
     margin: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0).withOpacity(0.5), width: 1),
      ),
      child:  Consumer<BalanceController>(
        builder: (context, bCtr, child) {
          double? priceQuotes=bCtr.priceQuotes[coin.symbol];
          CoinBalance? balance=coin.coinType==CoinType.TOKEN?bCtr.balances[coin.contractAddress!]:bCtr.balances[coin.symbol];
          return Row(
            children: [
              CoinImage(imageUrl: coin.image, height: 30, width: 30,),
              8.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.name,
                      style: TextStyle(
                        color: const Color(0xFF2D2D2D),
                        fontSize: 16,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          coin.symbol,
                          style: TextStyle(
                            color: const Color(0xFF2D2D2D),
                            fontSize: 14,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        4.horizontalSpace,
                        Text(
                          "(${coin.networkModel!.chainSymbol.toUpperCase()})",
                          style: TextStyle(
                            color: const Color(0xFF2D2D2D),
                            fontSize: 10,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    4.verticalSpace,
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  balance!=null?Text(
                    !bCtr.hideBalance?balance.balanceInCrypto!=0?MyCurrencyUtils.formatCurrency2(balance.balanceInCrypto):"0 ":"****",
                    style: TextStyle(
                      color: const Color(0xFF2D2D2D),
                      fontSize: 16,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w600,
                    ),
                  ):const SizedBox(),
                  4.verticalSpace,
                  balance!=null?Text(
                      !bCtr.hideBalance?" ${MyCurrencyUtils.format(balance.balanceInFiat,2)}":"**",
                    style: TextStyle(
                      color: const Color(0xFF757575),
                      fontSize: 12,
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w400,
                    )
                  ):const SizedBox()
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
