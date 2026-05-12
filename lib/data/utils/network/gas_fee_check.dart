import 'dart:developer';

import '../../../presentation/providers/balance_controller.dart';

class GasFeeCheck{

  static bool gasFeeCheck({required BalanceController bCtr, required String chainCurrency,required double feeInCrypto}){
    double balance=bCtr.balances[chainCurrency]!.balanceInCrypto;
    if(balance>=feeInCrypto){
      return true;
    }else{
     return false;
    }
  }

}