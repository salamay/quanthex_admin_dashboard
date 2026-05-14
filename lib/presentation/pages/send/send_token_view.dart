import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/network_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/domain/models/mining_record_model.dart';
import '../../../data/domain/models/staking_record_model.dart';
import '../../../data/domain/models/upline_payment_model.dart';
import '../../../data/domain/entities/network_model.dart';
import '../../../data/domain/entities/supported_assets.dart';
import '../../../data/domain/models/balance/CoinBalance.dart';
import '../../../data/domain/models/network_fee.dart';
import '../../../data/domain/models/send_payload.dart';
import '../../../data/services/transaction_service.dart';
import '../../../data/utils/assets/asset_utils.dart';
import '../../../data/utils/logger.dart';
import '../../../data/utils/my_currency_utils.dart';
import '../../providers/balance_controller.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/overlay_utils.dart';
import '../../widgets/snackbar/my_snackbar.dart';
import '../home/components/coin_image.dart';
import 'components/confirm_transaction_modal.dart';

class SendTokenView extends StatefulWidget {
  SendTokenView({super.key, required this.coin, this.miningRecord, this.stakingRecord, this.uplinePayment});

  SupportedCoin coin;
  final MiningRecordModel? miningRecord;
  final StakingRecordModel? stakingRecord;
  final UplinePaymentModel? uplinePayment;
  @override
  State<SendTokenView> createState() => _SendTokenViewState();
}

class _SendTokenViewState extends State<SendTokenView> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isAddressCorrect = false;
  String _recipientAddress = '';
  late NetworkModel _selectedChain;
  late SupportedCoin _selectedCoin;
  late BalanceController balanceController;

  @override
  void initState() {
    _selectedCoin = widget.coin;
    _selectedChain = widget.coin.networkModel!;
    balanceController = Provider.of<BalanceController>(context, listen: false);
    // Pre-fill from mining record if provided (admin pay flow)
    // Convert USDT earning to DOGE using market price
    if (widget.miningRecord != null) {
      final record = widget.miningRecord!;
      final walletAddress = record.mining?.miningWalletAddress ?? '';
      if (walletAddress.isNotEmpty) {
        _addressController.text = walletAddress;
        _validateAddress(walletAddress);
      }
      final totalEarning = record.earnings.totalEarning;
      if (totalEarning > 0) {
        final dogePrice = balanceController.priceQuotes['DOGE'];
        final dogeAmount = (dogePrice != null && dogePrice > 0)
            ? totalEarning / dogePrice
            : totalEarning;
        _amountController.text = dogeAmount.toStringAsFixed(4);
      }
    }
    // Pre-fill from staking record if provided (admin staking pay flow)
    if (widget.stakingRecord != null) {
      final record = widget.stakingRecord!;
      final walletAddress = record.staking?.stakingWalletAddress ?? '';
      if (walletAddress.isNotEmpty) {
        _addressController.text = walletAddress;
        _validateAddress(walletAddress);
      }
      final doublePayment = record.paymentStatus.doublePaymentAmount;
      if (doublePayment > 0) {
        _amountController.text = doublePayment.toStringAsFixed(4);
      }
    }
    // Pre-fill from upline payment if provided (admin upline pay flow)
    if (widget.uplinePayment != null) {
      final up = widget.uplinePayment!;
      final walletAddress = up.uplineWalletAddress ?? '';
      if (walletAddress.isNotEmpty) {
        _addressController.text = walletAddress;
        _validateAddress(walletAddress);
      }
      if (up.amount > 0) {
        _amountController.text = up.amount.toStringAsFixed(4);
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _validateAddress(String address) {
    setState(() {
      _isAddressCorrect = address.isNotEmpty;
      _recipientAddress = address;
    });
  }

  void _showAssetsModal() async {
    SupportedCoin? result = await AssetUtils.selectRewardAssets(context: context);
    if (result != null) {
      logger("Selected Coin: ${result.name}", runtimeType.toString());
      _selectedCoin = result;
      _selectedChain = result.networkModel!;
      setState(() {});
    }
  }

  Future<String?> _showConfirmTransaction(BuildContext context,SendPayload sendPayload)async {
    if (_recipientAddress.isEmpty ) {
      return null;
    }
      return await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ConfirmTransactionModal(sendPayload: sendPayload!),
      );

  }

  @override
  Widget build(BuildContext context) {
    final canSend = _recipientAddress.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Send ${_selectedCoin.symbol}',
          style: TextStyle(color: const Color(0xFF2D2D2D), fontSize: 18, fontFamily: 'Satoshi', fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height - 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  30.verticalSpace,

                  // Upline payment info banner
                  if (widget.uplinePayment != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.people_outline, size: 16, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                'Upline Payment (10%)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upline: ${widget.uplinePayment!.uplineEmail}',
                            style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Plan: ${widget.uplinePayment!.downlineStakingPlan}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Amount: \$${widget.uplinePayment!.amount.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    16.verticalSpace,
                  ],

                  // Staking info banner (when paying from staking detail)
                  if (widget.stakingRecord != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Staking Payment',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Plan: ${widget.stakingRecord!.staking?.stakingPlan ?? 'N/A'}',
                            style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'User: ${widget.stakingRecord!.staking?.email ?? 'N/A'}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Referrals: ${widget.stakingRecord!.referralCount} | Cycle: ${widget.stakingRecord!.paymentStatus.nextCycle}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    16.verticalSpace,
                  ],

                  // Mining info banner (when paying from mining detail)
                  if (widget.miningRecord != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Mining Payment',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Package: ${widget.miningRecord!.subscription?.subPackageName ?? 'N/A'}',
                            style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'User: ${widget.miningRecord!.mining?.email ?? 'N/A'}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Referrals: ${widget.miningRecord!.totalReferralCount} (${widget.miningRecord!.directReferralCount} direct, ${widget.miningRecord!.indirectReferralCount} indirect)',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    16.verticalSpace,
                  ],

                  // From Section
                  Container(
                    padding: EdgeInsets.all(16
                    ),
                    decoration: BoxDecoration(
                      // color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEAEAEA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'From',
                              style: TextStyle(color: const Color(0xFF757575), fontSize: 14
                                  , fontFamily: 'Satoshi', fontWeight: FontWeight.w500),
                            ),
                            Consumer<BalanceController>(
                              builder: (context, bCtr, child) {
                                double? priceQuotes = bCtr.priceQuotes[_selectedCoin.symbol];
                                CoinBalance? balance = _selectedCoin.coinType == CoinType.TOKEN ? bCtr.balances[_selectedCoin.contractAddress!] : bCtr.balances[_selectedCoin.symbol];
                                return balance != null
                                    ? Text(
                                        'Balance: ${!bCtr.hideBalance
                                            ? balance.balanceInCrypto != 0
                                                  ? "${MyCurrencyUtils.formatCurrency2(balance.balanceInCrypto)} ${_selectedCoin.symbol}"
                                                  : "0 ${_selectedCoin.symbol}"
                                            : "****"}',
                                        style: TextStyle(color: const Color(0xFF757575), fontSize: 14, fontFamily: 'Satoshi', fontWeight: FontWeight.w500),
                                      )
                                    : const SizedBox();
                              },
                            ),
                          ],
                        ),
                        15.verticalSpace,
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _showAssetsModal,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(color: const Color(0xFFEAEAEA)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(color: const Color(0xFF792A90).withOpacity(0.2), shape: BoxShape.circle),
                                      child: CoinImage(imageUrl: _selectedCoin.image, width: 20, height: 20),
                                    ),
                                    10.horizontalSpace,
                                    Text(
                                      _selectedCoin.name,
                                      style: TextStyle(color: const Color(0xFF2D2D2D), fontSize: 16, fontFamily: 'Satoshi', fontWeight: FontWeight.w600),
                                    ),
                                    // Spacer(),
                                    Icon(Icons.keyboard_arrow_down, size: 24, color: const Color(0xFF757575)),
                                  ],
                                ),
                              ),
                            ),
                            10.horizontalSpace,
                            Consumer<BalanceController>(
                              builder: (context, bCtr, child) {
                                double? priceQuotes = bCtr.priceQuotes[_selectedCoin.symbol];
                                return priceQuotes != null
                                    ? Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _amountController,
                                                enabled: false,
                                                style: TextStyle(color: const Color(0xFF2D2D2D), fontSize: 28, fontFamily: 'Satoshi', fontWeight: FontWeight.w700),
                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                textAlign: TextAlign.right,
                                                decoration: InputDecoration(
                                                  hintText: '0',

                                                  hintStyle: TextStyle(color: const Color(0xFF9E9E9E), fontSize: 28, fontFamily: 'Satoshi', fontWeight: FontWeight.w700),
                                                  border: InputBorder.none,
                                                ),
                                                onChanged: (value) {

                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox();
                              },
                            ),
                          ],
                        ),
                        20.verticalSpace,

                        Align(
                          alignment: Alignment.bottomRight,
                          child: Consumer<BalanceController>(
                              builder: (context, bCtr, child) {
                                double priceQuotes = bCtr.priceQuotes[_selectedCoin.symbol]??0;
                                if(_amountController.text.isNotEmpty){
                                  double amountInFiat=priceQuotes*double.parse(_amountController.text);
                                  return Text(
                                    amountInFiat > 0 ? '\$${MyCurrencyUtils.formatCurrency2(amountInFiat)}' : '',
                                    style: TextStyle(color: const Color(0xFF515151), fontSize: 12, fontFamily: 'Satoshi', fontWeight: FontWeight.bold),
                                  );
                                }else{
                                  return SizedBox();
                                }
                            }
                          ),
                        ),
                      ],
                    ),
                  ),

                  20.verticalSpace,
                  // Recipients Address
                  Text(
                    'Recipients Address',
                    style: TextStyle(color: const Color(0xFF2D2D2D), fontSize: 14, fontFamily: 'Satoshi', fontWeight: FontWeight.w500),
                  ),
                  10.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 8,
                        child: AuthTextField(
                          controller: _addressController,
                          hint: 'Enter your receiver\'s address',
                          maxLines: 1,
                          borderColor: _isAddressCorrect ? AppColors.primary : AppColors.border,
                          borderRadius: 25,
                          onChanged: _validateAddress,
                          fillColor: _isAddressCorrect ? Colors.transparent : const Color(0xFFF5F5F5),
                          filled: true,
                        ),
                      ),
                      10.horizontalSpace,

                    ],
                  ),
                  if (_isAddressCorrect) ...[
                    10.verticalSpace,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12  , vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFF9E6FF), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        'Address Correct',
                        style: TextStyle(color: const Color(0xFF792A90), fontSize: 12, fontFamily: 'Satoshi', fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                  Spacer(),
                  // 30.verticalSpace,
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: ()async{
                        if (canSend) {
                          await send(context: context);
                        }
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
                  20.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> send({required BuildContext context}) async {
    // Implement the logic to send the token
    try {
      showOverlay(context);
      CoinBalance? balance;
      SupportedCoin asset = _selectedCoin;
      String input = _amountController.text.trim();
      double amount = double.parse(input);
      String address = _addressController.text.trim();
      if (asset.coinType == CoinType.TOKEN) {
        balance = balanceController.balances[asset.contractAddress!];
      } else {
        balance = balanceController.balances[asset.symbol];
      }
      if (balance == null) {
        showMySnackBar(context: context, message: "Unable to get balance", type: SnackBarType.error);
        hideOverlay(context);
        return;
      }

      if (balance.balanceInCrypto >= amount) {
      } else {
        showMySnackBar(context: context, message: "Insufficient balance", type: SnackBarType.error);
        hideOverlay(context);
        return;
      }
      double priceQuotes = balanceController.priceQuotes[_selectedCoin.symbol]??0;
      double amountInFiat=priceQuotes*double.parse(_amountController.text);
      SendPayload sendPayload = SendPayload(
        amount: amount,
        asset: asset,
        amountInFiat: amountInFiat,
        recipient_address: address,
        minId: widget.miningRecord?.mining?.minId,
        stakingId: widget.stakingRecord?.staking?.stakingId,
        uplinePaymentId: widget.uplinePayment?.supId,
        rewardSymbol: widget.miningRecord?.subscription?.subRewardAssetSymbol
            ?? widget.stakingRecord?.staking?.stakingRewardAssetSymbol
            ?? widget.uplinePayment?.uplineRewardAssetSymbol,
      );
      NetworkFee? fee;
      try {
        double? priceQuote = balanceController.priceQuotes[asset.symbol] ?? 0;
        fee = await TransactionService().getTxInfo(priceQuote: priceQuote, asset: asset, sendPayload: sendPayload!);
        sendPayload!.fee = fee;
        logger("Estimated fee: ${fee != null ? MyCurrencyUtils.formatCurrency2(fee.feeInFiat) : "N/A"} USD", runtimeType.toString());
        // Proceed with sending the transaction using the sendPayload
      } catch (e) {
        showMySnackBar(context: context, message: "An error occurred when estimating gas, Please check the address and make sure you have good internet or enough gas fee", type: SnackBarType.error);
        hideOverlay(context);
        return;
      }
      hideOverlay(context);
      String? txId= await _showConfirmTransaction(context,sendPayload);
      if (txId != null && txId.isNotEmpty) {
        // Pop back to the previous page (MiningDetailPage) with the result
        if (context.mounted) {
          context.pop(txId);
        }
      }
    } catch (e) {
      hideOverlay(context);
      showMySnackBar(context: context, message: "An error occurred", type: SnackBarType.error);
    }
  }
}
