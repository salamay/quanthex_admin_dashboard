import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:quanthex_admin/core/network/api_constants.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

import '../../core/constants/network_constants.dart';
import '../../core/network/api_client.dart';
import '../../data/domain/entities/supported_assets.dart';
import '../../data/domain/models/balance/CoinBalance.dart';
import '../../data/domain/models/balance/platform_data.dart';
import '../../data/utils/assets/client_resolver.dart';
import '../../data/utils/assets/token_factory.dart';
import '../../data/utils/logger.dart';
import '../../data/utils/network/network_utils.dart';
import 'dart:math' as math;

class BalanceController extends ChangeNotifier{
  ApiClient apiClient;
  BalanceController(this.apiClient);
  Map<String, CoinBalance> balances = {};
  Map<String, double?> priceQuotes = {};
  Map<String, PlatformData> platforms = {};
  bool isLoadingPriceQuotes = false;
  bool hideBalance = false;
  double overallBalance = 0;
  bool balanceLoading = true;
  bool balanceLoadingError=false;


  void calculateTotalBalance(Map<String, CoinBalance> results) {
    for (var e in results.values) {
      overallBalance = overallBalance + e.balanceInFiat;
    }
    notifyListeners();
  }

  void toggleHideBalance() {
    hideBalance = !hideBalance;
    notifyListeners();
  }

  void resetOverallBalance() {
    overallBalance = 0;
    notifyListeners();
  }

  Future<Map<String, PlatformData>?> getAssetsPlatform() async {
    try {
      logger("Getting asset platforms on coingecko", runtimeType.toString());
      Uri uri = Uri.parse(ApiConstants.assetPlatform);
      Response? response = await apiClient.get(uri.toString(), headers: {"Content-Type": "application/json", "x-cg-pro-api-key": ApiClient.coinGecko});
      logger("Asset platforms: Response code ${response!.statusCode}", runtimeType.toString());
      if (response.statusCode == 200) {
        List<PlatformData> platformData = List.of(response.data).map((e) => PlatformData.fromJson(e)).toList();
        logger("Asset platforms length: ${platformData.length}", runtimeType.toString());
        for (var platform in platformData) {
          if (platform.chainIdentifier != null) {
            platforms[platform.chainIdentifier.toString()] = platform;
          }
          // You can store or process the platform data as needed
        }
        return platforms;
      } else {
        String message = response.data.toString();
        logger(message, runtimeType.toString());
        return null;
      }
    } catch (e) {
      logger(e.toString(), runtimeType.toString());
      throw Exception(e);
    }
  }

  Future<List<Map<String, double?>?>> getTokenQuotes({required List<SupportedCoin> tokens}) async {
    try{
      isLoadingPriceQuotes = true;
      notifyListeners();
      if (tokens.isEmpty) {
        logger("No assets to get quotes for", runtimeType.toString());
        isLoadingPriceQuotes = false;
        notifyListeners();
        return [];
      }
      List<String> chainIds = NetworkUtils.filterNetworksFromAssets(assets: tokens);
      List<Map<String, double?>?> data = await Future.wait(
        chainIds.map((e) async {
          String chainId = e;
          PlatformData? platform = platforms[chainId];
          if (platform == null) {
            logger("Platform id not found for chain id: $chainId", runtimeType.toString());
            return null;
          }
          String platformId = platform.id!;
          logger("Getting quotes from coingecko: $platformId for chain id: $chainId", runtimeType.toString());
          Uri uri = Uri.parse("${ApiConstants.tokenPrice}/$platformId");
          String contracts = tokens.where((e) => e.coinType == CoinType.TOKEN || e.coinType == CoinType.WRAPPED_TOKEN).map((e) => e.contractAddress!.toLowerCase()).join(",");
          Uri finalUri = uri.replace(queryParameters: {"contract_addresses": contracts, "vs_currencies": "usd"});
          Response? response = await apiClient.get(finalUri.toString(), headers: {"Content-Type": "application/json", "x-cg-pro-api-key": ApiClient.coinGecko});
          logger("Quotes (Coin gecko): Response code ${response!.statusCode}", runtimeType.toString());
          if (response.statusCode == 200) {
            tokens.map((e) {
              //convert the response to a map with lower case keys because  return data may contain upper case keys
              final data = Map<String, dynamic>.from(response.data).map((key, value) => MapEntry(key.toLowerCase(), value));
              var priceData = data[e.contractAddress?.toLowerCase()];
              if (priceData != null) {
                if(priceData['usd']!=null){
                  priceQuotes[e.symbol] = double.parse(priceData['usd'].toString());
                }
              }
            }).toList();
            isLoadingPriceQuotes = false;
            notifyListeners();
            return priceQuotes;
          } else {
            String message = response.data.toString();
            logger(message, runtimeType.toString());
            isLoadingPriceQuotes = false;
            notifyListeners();
            return null;
          }
        }),
      );
      return data;
    }catch(e){
      isLoadingPriceQuotes = false;
      notifyListeners();
      throw Exception(e);
    }
  }

  Future<Map<String, double?>> getQuotesByIds({required Map<String, String> p}) async {
    try {
      isLoadingPriceQuotes = true;
      notifyListeners();
      Map<String, String> payload = {};
      for (var key in p.keys) {
        if (key == "BSC") {
          payload["BNB"] = p["BSC"] ?? "";
        } else {
          payload[key] = p[key] ?? "";
        }
      }
      List<String> symbols = payload.keys.toList();
      if (symbols.isEmpty) {
        logger("No symbols and ids to get quotes for", runtimeType.toString());
        isLoadingPriceQuotes = false;
        notifyListeners();
        return {};
      }
      List<String> coinIds = payload.values.toList().map((id) {
        if (id == "matic-network") {
          //this is because matic has been migrated
          return "polygon-ecosystem-token";
        } else {
          isLoadingPriceQuotes = false;
          notifyListeners();
          return id;
        }
      }).toList();

      String ids = coinIds.join(",");
      logger("Getting quotes with id: $ids for symbol: $symbols", runtimeType.toString());
      Uri uri = Uri.parse(ApiConstants.quoteById);
      Uri finalUri = uri.replace(queryParameters: {"vs_currencies": 'usd', "ids": ids.toLowerCase()});
      Response? response = await apiClient.get(finalUri.toString(), headers: {"Content-Type": "application/json", "x-cg-pro-api-key": ApiClient.coinGecko});
      logger("Quotes Native (Coin gecko): Response code ${response!.statusCode}", runtimeType.toString());
      if (response.statusCode == 200) {
        logger("XXX: ${response.data.toString()}", runtimeType.toString());
        //convert the response to a map with lower case keys because  return data may contain upper case keys
        final data = Map<String, dynamic>.from(response.data).map((key, value) => MapEntry(key.toLowerCase(), value));
        Map<String, double?> tempHolder = {};
        for (var idKey in data.keys) {
          String s = payload.entries.firstWhere((element) => element.value.toLowerCase() == idKey.toLowerCase()).key;
          var priceData = data[idKey]['usd'];
          if (priceData != null) {
            priceQuotes[s] = priceData;
            tempHolder[s] = priceData;
          }
        }
        isLoadingPriceQuotes = false;
        notifyListeners();
        return tempHolder;
      } else {
        String message = response.data.toString();
        logger(message, runtimeType.toString());
        isLoadingPriceQuotes = false;
        notifyListeners();
        return {};
      }
    } catch (e) {
      isLoadingPriceQuotes = false;
      notifyListeners();
      throw Exception(e);
    }
  }

  Future<Map<String, CoinBalance>> getTokenBalance(List<SupportedCoin> assets,bool shouldIndicate) async {
    try {
      if(shouldIndicate){
        balanceLoading = true;
        balanceLoadingError=false;
        notifyListeners();
      }
      if (assets.isEmpty) {
        logger("No token to get balance for", runtimeType.toString());
        return {};
      }

      Map<String, CoinBalance> data = {};
      List<String> chainIds = NetworkUtils.filterNetworksFromAssets(assets: assets);
      for (var chainId in chainIds) {
        List<SupportedCoin> chainAssets = assets.where((e) => e.networkModel!.chainId.toString() == chainId).toList();
        String rpcUrl = chainAssets[0].networkModel!.rpcUrl;
        String address = chainAssets[0].walletAddress!;
        logger("Getting token balances for chain id: $chainId Address: $address", runtimeType.toString());
        Web3Client? webClient = await ClientResolver.resolveClient(rpcUrl: rpcUrl);
        String? providerContract = ClientResolver.resolveAaveWithChainId(chainId: int.parse(chainId));
        List<EthereumAddress> walletAddress = [EthereumAddress.fromHex(address)];
        List<EthereumAddress> contractAddresses = chainAssets.map((e) => EthereumAddress.fromHex(e.contractAddress!)).toList();
        final String abi = await rootBundle.loadString("abi/aave/aave_balance.json");
        final contract = await TokenFactory().intContract(abi, providerContract, "aaveBalance");
        final batchBalanceOf = contract.function("batchBalanceOf");
        final results = await webClient.call(contract: contract, function: batchBalanceOf, params: [walletAddress, contractAddresses]);
        List<CoinBalance> br = [];
        for (int i = 0; i < chainAssets.length; i++) {
          BigInt amount = results.first[i];
          SupportedCoin asset = chainAssets[i];
          double totalBalance = double.parse(amount.toString()) / math.pow(10, asset.decimal!);
          double usdPrice = priceQuotes[asset.symbol] ?? 0;
          logger('You have $amount ${asset.name}, Price quotes: $usdPrice', runtimeType.toString());
          double balanceInFiat = totalBalance * usdPrice;
          logger("Balance in usd: $balanceInFiat", runtimeType.toString());
          CoinBalance coinBalance = CoinBalance(balanceInCrypto: totalBalance, balanceInFiat: balanceInFiat);
          balances[asset.contractAddress!] = coinBalance;
          data[asset.contractAddress!] = coinBalance;
          br.add(coinBalance);
        }
      }
      if(shouldIndicate){
        balanceLoading = false;
        notifyListeners();
      }
      return data;
      // log("Getting ${asset.name} balance for ${walletAddress.toString()}");
    } catch (e) {
      logger("Error getting token balance: $e", runtimeType.toString());
      if(shouldIndicate){
        balanceLoading = false;
        balanceLoadingError=true;
        notifyListeners();
      }
      throw Exception(e);
    }
  }

  Future<CoinBalance?> getNativeCoinBalance({required SupportedCoin asset}) async {
    try {
      logger("Getting  balance: ${asset.symbol}", runtimeType.toString());
      Web3Client client = await ClientResolver.resolveClient(rpcUrl: asset.networkModel!.rpcUrl);
      final String address = asset.walletAddress!;
      final EtherAmount balanceAmount = await client.getBalance(EthereumAddress.fromHex(address));
      double balance = balanceAmount.getValueInUnit(EtherUnit.ether);
      logger('ETH Balance: $balance', runtimeType.toString());
      double usdPrice = priceQuotes[asset.symbol.toUpperCase()] ?? 0;
      double balanceInFiat = balance * usdPrice;
      logger("Balance in usd: $balanceInFiat", runtimeType.toString());
      CoinBalance coinBalance = CoinBalance(balanceInCrypto: balance, balanceInFiat: balanceInFiat);
      balances[asset.symbol] = coinBalance;
      return coinBalance;
    } catch (e) {
      logger("Error getting native coin balance: $e", runtimeType.toString());
      throw Exception(e);
    }
  }

  void clear() {
    balances.clear();
    // _timer.cancel();
    overallBalance = 0;
    // isSocketConnected=false;
  }

}