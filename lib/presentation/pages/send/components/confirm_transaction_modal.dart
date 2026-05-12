import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/presentation/pages/send/components/transfer_success_modal.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math' as math;

import '../../../../core/constants/network_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/datasources/mining_remote_datasource.dart';
import '../../../../data/datasources/staking_remote_datasource.dart';
import '../../../../data/domain/entities/network_model.dart';
import '../../../../data/domain/entities/supported_assets.dart';
import '../../../../data/domain/models/network_fee.dart';
import '../../../../data/domain/models/send_payload.dart';
import '../../../../data/services/transaction_service.dart';
import '../../../../data/utils/assets/token_factory.dart';
import '../../../../data/utils/logger.dart';
import '../../../../data/utils/my_currency_utils.dart';
import '../../../../data/utils/network/gas_fee_check.dart';
import '../../../providers/balance_controller.dart';
import '../../../providers/wallet_controller.dart';
import '../../../widgets/info/row_info.dart';
import '../../../widgets/overlay_utils.dart';
import '../../../widgets/snackbar/my_snackbar.dart';
import '../../home/components/coin_image.dart';

class ConfirmTransactionModal extends StatelessWidget {
  ConfirmTransactionModal({super.key,required this.sendPayload});
  SendPayload sendPayload;
  late SupportedCoin token;
  late NetworkModel chain;
  late WalletController walletController;
  late BalanceController balanceController;

  @override
  Widget build(BuildContext context) {
    walletController=Provider.of<WalletController>(context,listen: false);
    balanceController=Provider.of<BalanceController>(context,listen: false);
    token=sendPayload.asset!;
    chain=sendPayload.asset!.networkModel!;
    double amountInFiat=sendPayload.amountInFiat??0.0;
    String recipientAddress=sendPayload.recipient_address??"";
    String fromAddress=walletController.currentWallet!.walletAddress??"";
    int decimal=sendPayload.asset!.decimal??0;
    double amount=sendPayload.amount??0.0;
    NetworkFee? fee=sendPayload.fee;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
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
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9E6FF),
                      shape: BoxShape.circle,
                    ),
                    child: CoinImage(
                      imageUrl: chain.imageUrl,
                      width: 80,
                      height: 80,
                    )
                ),
                // if (isPolygon)
                Positioned(
                  bottom: -5,
                  right: -5,
                  child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: CoinImage(
                        imageUrl: chain.imageUrl,
                        width: 24,
                        height: 24,
                      )
                  ),
                ),
              ],
            ),
            20.verticalSpace,
            Text(
              'Confirm Transaction',
              style: TextStyle(
                color: const Color(0xFF2D2D2D),
                fontSize: 22,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w700,
              ),
            ),
            10.sp.verticalSpace,
            Text(
              'Review and confirm your transaction\nbefore sending.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF757575),
                fontSize: 14,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/swapduo.png',
                  width: 39,
                  height: 22,
                ),
                10.horizontalSpace,
                Text(
                  '${MyCurrencyUtils.formatCurrency2(amount)} ${token.symbol} (${chain.chainSymbol})',
                  style: TextStyle(
                    color: const Color(0xFF2D2D2D),
                    fontSize: 24,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            5.sp.verticalSpace,
            Text(
              '≈ \$${MyCurrencyUtils.formatCurrency2(amountInFiat)} USD',
              style: TextStyle(
                color: const Color(0xFF757575),
                fontSize: 14,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w500,
              ),
            ),
            15.sp.verticalSpace,
            Container(
              padding: EdgeInsets.all(16),
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RowInfo(label: "From", value: "${fromAddress.substring(0, 10)}...${fromAddress.substring(fromAddress.length - 10)}"),
                  5.sp.verticalSpace,
                  RowInfo(label: "To", value: '${recipientAddress.substring(0, 10)}...${recipientAddress.substring(recipientAddress.length - 10)}'),
                  5.sp.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Network',
                        style: TextStyle(
                          color: const Color(0xFF757575),
                          fontSize: 14,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // if (isPolygon)
                         CoinImage(
                             imageUrl: sendPayload.asset!.networkModel!.imageUrl,
                             height: 20,
                             width: 20
                         ),
                          8.horizontalSpace,
                          Text(
                            chain.chainName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF792A90),
                              fontSize: 14,
                              fontFamily: 'Satoshi',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            5.sp.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Network Fee',
                  style: TextStyle(
                    color: const Color(0xFF757575),
                    fontSize: 14,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                fee!=null?Text(
                  '\$ ${MyCurrencyUtils.formatCurrency2(amountInFiat)} ${sendPayload.asset!.networkModel!.chainSymbol}',
                  style: TextStyle(
                    color: const Color(0xFF2D2D2D),
                    fontSize: 14,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w600,
                  ),
                ):const SizedBox(),
              ],
            ),
            5.sp.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: const Color(0xFF2D2D2D),
                    fontSize: 16,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                fee!=null?Text(
                  '${MyCurrencyUtils.formatCurrency2(amount+fee.feeInCrypto)} ${sendPayload.asset!.symbol}',
                  style: TextStyle(
                    color: const Color(0xFF2D2D2D),
                    fontSize: 16,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                  ),
                ):Text(
                  '${MyCurrencyUtils.formatCurrency2(amount)} ${sendPayload.asset!.symbol}',
                  style: TextStyle(
                    color: const Color(0xFF2D2D2D),
                    fontSize: 16,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            10.sp.verticalSpace,
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  sendTx(context);
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
                  'Send token',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            10.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/security-safe.png',
                  width: 16,
                  height: 16,
                ),
                Text(
                  'Your transaction is secured by a smart contract',
                  style: TextStyle(
                    color: const Color(0xFF7E7E7E),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            20.sp.verticalSpace,
          ],
        ),
      ),
    );
  }


  Future<void> _showSuccessModal(BuildContext context,SendPayload sendPayload)async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransferSuccessModal(
        token: sendPayload.asset!,
        chain: sendPayload.asset!.networkModel!,
        amount: sendPayload.amount??0.0,
        recipientAddress: sendPayload.recipient_address??"",
      ),
    );
  }

  Future<void> sendTx(BuildContext context) async {
    try{
      TokenFactory _tokenFactory=TokenFactory();
      NetworkFee? fee = sendPayload.fee;
      int decimal = sendPayload.asset!.decimal!;
      NetworkModel network=sendPayload.asset!.networkModel!;
      double recipientAmount = sendPayload.amount??0.0;
      double totalAmount = ((recipientAmount) * math.pow(10, decimal));
      logger("Total amount: $totalAmount",runtimeType.toString());
      if(fee==null){
        logger("Fee is null", runtimeType.toString());
        return ;
      }
      bool isGas=GasFeeCheck.gasFeeCheck(bCtr: balanceController, feeInCrypto: fee.feeInCrypto, chainCurrency: network.chainCurrency);
      SupportedCoin asset=sendPayload.asset!;
      if(isGas){
        showOverlay(context);
        String resultId = '';
         // Mining payment: sign locally, backend handles on-chain submission
          String signedTx = '';
          if(asset.coinType==CoinType.TOKEN||asset.coinType==CoinType.WRAPPED_TOKEN){
            final String abi = await rootBundle.loadString("abi/token/token_contract.json");
            String contractAddress = sendPayload.asset!.contractAddress!;
            String assetName = sendPayload.asset!.name;
            String privateKey = sendPayload.asset!.privateKey!;
            final credentials = await _tokenFactory.getCredentials(privateKey);
            final contract = await _tokenFactory.intContract(abi, contractAddress, assetName);
            final sendFunction = contract.function('transfer');
            Transaction transaction0 = Transaction.callContract(
                contract: contract,
                function: sendFunction,
                from: credentials.address,
                gasPrice: EtherAmount.inWei(fee.gasPrice),
                maxGas: fee.maxGas,
                parameters: [
                  EthereumAddress.fromHex(sendPayload.recipient_address!),
                  BigInt.from(totalAmount)
                ]
            );
            signedTx = await TransactionService().signTx(transaction: transaction0, credentials: credentials, asset: asset);
          }else{
            String toAddress = sendPayload.recipient_address!;
            String privateKey = sendPayload.asset!.privateKey!;
            final credentials = await _tokenFactory.getCredentials(privateKey);
            Transaction tx=Transaction(
              to: EthereumAddress.fromHex(toAddress),
              value: EtherAmount.fromBigInt(EtherUnit.wei, BigInt.from(totalAmount)),
              from: credentials.address,
              gasPrice: EtherAmount.inWei(fee.gasPrice),
              maxGas: fee.maxGas,
            );
            signedTx = await TransactionService().signTx(transaction: tx, credentials: credentials, asset: asset);
          }

          logger("Transaction signed. Submitting to backend...", runtimeType.toString());

          // Send signed tx + payment data to backend for on-chain submission
          if (sendPayload.isUplinePayment) {
            final stakingDatasource = ServiceLocator.instance.stakingRemoteDataSource;
            final result = await stakingDatasource.submitUplinePayment(
              supId: sendPayload.uplinePaymentId!,
              chainId: network.chainId,
              txData: "0x$signedTx",
            );
            logger("Upline payment submitted via backend: $result", runtimeType.toString());
            resultId = sendPayload.uplinePaymentId!;
          } else if (sendPayload.isStakingPayment) {
            final stakingDatasource = ServiceLocator.instance.stakingRemoteDataSource;
            final result = await stakingDatasource.submitStakingPayment(
              stakingId: sendPayload.stakingId!,
              amount: sendPayload.amount ?? 0.0,
              chainId: network.chainId,
              txData: "0x$signedTx",
              rewardSymbol: sendPayload.rewardSymbol,
            );
            logger("Staking payment submitted via backend: $result", runtimeType.toString());
            resultId = sendPayload.stakingId!;
          } else {
            final datasource = ServiceLocator.instance.miningRemoteDataSource;
            final result = await datasource.submitPayment(
              minId: sendPayload.minId!,
              amount: sendPayload.amount ?? 0.0,
              chainId: network.chainId,
              txData: "0x$signedTx",
              rewardSymbol: sendPayload.rewardSymbol,
            );
            logger("Mining payment submitted via backend: $result", runtimeType.toString());
            resultId = sendPayload.minId!;
          }


        hideOverlay(context);
        sendPayload.txId = resultId;
        await _showSuccessModal(context, sendPayload);
        if (context.mounted) {
          Navigator.of(context).pop(resultId);
        }
      }else{
        hideOverlay(context);
        String nativeCoin=sendPayload.asset!.networkModel!.chainCurrency;
        String message="Insufficient $nativeCoin for gas, top up your balance to proceed";
        logger(message, runtimeType.toString());
        showMySnackBar(context: context, message: message, type: SnackBarType.error);
        return ;
      }
    }catch(e){
      hideOverlay(context);
      showMySnackBar(context: context, message: "An error occurred, make sure you have enough gas fee for this transaction and try again", type: SnackBarType.error);
      logger(e.toString(), runtimeType.toString());
    }
  }
}
