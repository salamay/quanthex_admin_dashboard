// To parse this JSON data:
//
//     final networkModel = networkModelFromJson(jsonString);

import 'dart:convert';

import '../../../core/constants/network_constants.dart';


List<NetworkModel> networkModelFromJson(String str) =>
    List<NetworkModel>.from(
        json.decode(str).map((x) => NetworkModel.fromJson(x)));

String networkModelToJson(List<NetworkModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NetworkModel {
  String chainName;
  String imageUrl;
  String chainSymbol;
  String chainCurrency;
  String rpcUrl;
  String websocketUrl;
  int chainId;
  String unit;
  String nativeCoinId;
  String scanUrl;
  String scanName;
  double minimumCurrency;
  NetworkType networkType;
  bool? isCustom;

  NetworkModel({
    required this.chainName,
    required this.imageUrl,
    required this.chainSymbol,
    required this.chainCurrency,
    required this.rpcUrl,
    required this.websocketUrl,
    required this.chainId,
    required this.unit,
    required this.nativeCoinId,
    required this.scanUrl,
    required this.scanName,
    required this.minimumCurrency,
    required this.networkType,
    this.isCustom,
  });

  /// -----------------------------
  ///          FROM JSON
  /// -----------------------------
  factory NetworkModel.fromJson(Map<String, dynamic> json) => NetworkModel(
    chainName: json["chain_name"],
    imageUrl: json["image_url"],
    chainSymbol: json["chain_symbol"],
    chainCurrency: json["chain_currency"],
    rpcUrl: json["rpc_url"],
    websocketUrl: json["websocket_url"],
    chainId: json["chain_id"],
    unit: json["unit"],
    nativeCoinId: json["native_coin_id"],
    scanUrl: json["scan_url"],
    scanName: json["scan_name"],
    minimumCurrency:json["minimum_currency"] ?? 0.0,
    networkType: NetworkType.values.firstWhere(
            (e)=>e.name.toString()==json["network_type"].toString().toLowerCase(),
        orElse: ()=>NetworkType.undefined
    ),
    isCustom: json["is_custom"],
  );

  /// -----------------------------
  ///          TO JSON
  /// -----------------------------
  Map<String, dynamic> toJson() => {
    "chain_name": chainName,
    "image_url": imageUrl,
    "chain_symbol": chainSymbol,
    "chain_currency": chainCurrency,
    "rpc_url": rpcUrl,
    "websocket_url": websocketUrl,
    "chain_id": chainId,
    "unit": unit,
    "native_coin_id": nativeCoinId,
    "scan_url": scanUrl,
    "scan_name": scanName,
    "minimum_currency": minimumCurrency,
    "network_type": networkType.name,
    "is_custom": isCustom,
  };


}