import 'package:flutter/material.dart';

class ChainParse  {


  static String getMoralisChainName(String chainSymbol) {
    switch (chainSymbol) {
      case 'BSC':
        return 'bsc';
      case 'ETH':
        return 'eth';
      case 'POL':
        return 'polygon';
    // Add more cases for other chains as needed
      case 'ARB':
        return 'arbitrum';
      case 'AVAX':
        return 'avalanche';
      default:
        throw Exception('Unsupported chain: $chainSymbol');
    }
  }

}
