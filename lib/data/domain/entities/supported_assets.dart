

import '../../../core/constants/network_constants.dart';
import 'network_model.dart';
// To parse this JSON data:
//
//     final supportedCoin = supportedCoinFromJson(jsonString);

import 'dart:convert';

List<SupportedCoin> supportedCoinFromJson(String str) =>
    List<SupportedCoin>.from(
        json.decode(str).map((x) => SupportedCoin.fromJson(x)));

String supportedCoinToJson(List<SupportedCoin> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SupportedCoin {
  String symbol;
  String name;
  String image;
  String? walletAddress;
  String? privateKey;
  NetworkModel? networkModel;
  int? decimal;
  CoinType? coinType;
  String? contractAddress;
  bool? isImplementedContract;
  String? implementationContractAddress;
  double? balanceInFiat;
  double? balanceInCrypto;
  double marketCap;

  SupportedCoin({
    required this.symbol,
    required this.name,
    required this.image,
    this.walletAddress,
    this.privateKey,
    this.networkModel,
    this.decimal,
    this.coinType,
    required this.contractAddress,
    this.isImplementedContract = false,
    this.implementationContractAddress,
    this.balanceInFiat,
    this.balanceInCrypto,
    required this.marketCap
  });

  /// -----------------------------
  ///          FROM JSON
  /// -----------------------------
  factory SupportedCoin.fromJson(Map<String, dynamic> json) => SupportedCoin(
    symbol: json["symbol"],
    name: json["name"],
    image: json["image"],
    walletAddress: json["wallet_address"],
    privateKey: json["private_key"],
    networkModel: json["network_model"] == null
        ? null
        : NetworkModel.fromJson(json["network_model"]),
    decimal:  json["decimal"],
    coinType: CoinType.values.firstWhere(
        (e)=>e.name.toString().toLowerCase()==json["coin_type"].toString().toLowerCase(),
      orElse: ()=>CoinType.UN_DEFINED
    ),
    contractAddress: json["contract_address"],
    isImplementedContract: json["is_implemented_contract"] ?? false,
    implementationContractAddress:
    json["implementation_contract_address"],
    balanceInFiat: json["balance_in_fiat"],
    balanceInCrypto: json["balance_in_crypto"],
    marketCap: json["market_cap"],
  );

  /// -----------------------------
  ///          TO JSON
  /// -----------------------------
  Map<String, dynamic> toJson() => {
    "symbol": symbol,
    "name": name,
    "image": image,
    "wallet_address": walletAddress,
    "private_key": privateKey,
    "network_model": networkModel?.toJson(),
    "decimal": decimal,
    "coin_type": coinType?.name,
    "contract_address": contractAddress,
    "is_implemented_contract": isImplementedContract,
    "implementation_contract_address": implementationContractAddress,
    "balance_in_fiat": balanceInFiat,
    "balance_in_crypto": balanceInCrypto,
    "market_cap": marketCap,
  };
}
