




import '../entities/supported_assets.dart';
import 'network_fee.dart';

class SendPayload{
  SupportedCoin? asset;
  double? amount;
  double? amountInFiat;
  String? recipient_address;
  NetworkFee? fee;
  String? txId;
  String? minId; // Mining ID for payment tracking (admin pay flow)
  String? stakingId; // Staking ID for staking payment tracking
  String? rewardSymbol; // Reward asset symbol for payment tracking
  String? uplinePaymentId; // Upline payment ID for upline pay flow
  String? dailyRoiStakingId; // Staking ID for daily ROI payment flow

  SendPayload({this.asset, this.amount, this.recipient_address, this.fee,this.amountInFiat,this.txId, this.minId, this.stakingId, this.rewardSymbol, this.uplinePaymentId, this.dailyRoiStakingId});

  SendPayload copyWith({
    SupportedCoin? asset,
    double? amount,
    double? amountInFiat,
    String? recipient_address,
    NetworkFee? fee,
    String? txId,
    double? percentage,
    String? adminAddress,
    String? minId,
    String? stakingId,
    String? rewardSymbol,
    String? uplinePaymentId,
    String? dailyRoiStakingId,
  }){
    return SendPayload(
        asset: asset??this.asset,
        amount: amount??this.amount,
        amountInFiat: amountInFiat??this.amountInFiat,
        recipient_address: recipient_address??this.recipient_address,
        fee: fee??this.fee,
        txId: txId??this.txId,
        minId: minId??this.minId,
        stakingId: stakingId??this.stakingId,
        rewardSymbol: rewardSymbol??this.rewardSymbol,
        uplinePaymentId: uplinePaymentId??this.uplinePaymentId,
        dailyRoiStakingId: dailyRoiStakingId??this.dailyRoiStakingId,
    );
  }

  /// Whether this is a mining payment (admin pay flow).
  bool get isMiningPayment => minId != null && minId!.isNotEmpty;

  /// Whether this is a staking payment (admin pay flow).
  bool get isStakingPayment => stakingId != null && stakingId!.isNotEmpty && !isDailyRoiPayment;

  /// Whether this is an upline payment (admin pay upline flow).
  bool get isUplinePayment => uplinePaymentId != null && uplinePaymentId!.isNotEmpty;

  /// Whether this is a daily ROI payment flow.
  bool get isDailyRoiPayment => dailyRoiStakingId != null && dailyRoiStakingId!.isNotEmpty;

  /// Whether this is any admin payment flow (mining or staking or upline or daily ROI).
  bool get isAdminPayment => isMiningPayment || isStakingPayment || isUplinePayment || isDailyRoiPayment;

}