class NetworkFee{
  double feeInCrypto=0;
  double feeInFiat=0;
  BigInt gasPrice=BigInt.zero;
  int maxGas=0;
  String symbol="";
  NetworkFee({required this.feeInCrypto, required this.feeInFiat,required this.gasPrice,required this.symbol,required this.maxGas});
}