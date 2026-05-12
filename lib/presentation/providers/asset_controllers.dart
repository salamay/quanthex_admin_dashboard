import 'package:coingecko_api/data/coin.dart' as coingecko_coin;
import 'package:flutter/cupertino.dart';
import 'package:quanthex_admin/presentation/providers/wallet_controller.dart';

import '../../core/constants/network_constants.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/models/scan_token.dart';
import '../../data/datasources/models/transactions/erc20_transfer_dto.dart';
import '../../data/datasources/models/transactions/native_tx_dto.dart';
import '../../data/domain/entities/network_model.dart';
import '../../data/domain/entities/supported_assets.dart';
import '../../data/domain/models/balance/CoinBalance.dart';
import '../../data/repositories/asset_repository.dart';
import '../../data/services/assets/asset_service.dart';
import '../../data/utils/logger.dart';
import 'balance_controller.dart';

class AssetController extends ChangeNotifier{
  ApiClient apiClient;
  AssetController(this.apiClient);

  AssetService assetService = AssetService.getInstance();
  List<SupportedCoin> assets = [];
  Map<String, ScannedToken> scannedTokens = {};
  Map<String, coingecko_coin.Coin> tokenMetadatas = {};
  Map<String, List<Erc20TransferDto>> erc20Transfers = {};
  Map<String, List<NativeTxDto>> nativeTransfers = {};
  bool assetLoading=false;
  bool assetLoadingError=false;


  void populateAssetsByBalanceInFiat(Map<String, CoinBalance> results) {
    results.forEach((key, value) {
      int index = assets.indexWhere((element) {
        if(element.coinType == CoinType.TOKEN||element.coinType == CoinType.WRAPPED_TOKEN){
          return element.contractAddress == key;
        }
        return false;
      });
      if (index != -1) {
        SupportedCoin asset = assets[index];
        asset.balanceInFiat = value.balanceInFiat;
        asset.balanceInCrypto = value.balanceInCrypto;
        assets[index] = asset;
      }
    });
    notifyListeners();
  }

  void populateAssetsByBalanceInFiatNativeTokens(String symbol, CoinBalance balance) {
    int index = assets.indexWhere((element) => element.coinType == CoinType.NATIVE_TOKEN && element.symbol.toUpperCase() == symbol.toUpperCase());
    if (index != -1) {
      SupportedCoin asset = assets[index];
      asset.balanceInFiat = balance.balanceInFiat;
      asset.balanceInCrypto = balance.balanceInCrypto;
      assets[index] = asset;
    }
    notifyListeners();
  }

  void sortAssetsByBalanceInFiat() {
    List<SupportedCoin> tempAssets = List.from(assets);
    List<SupportedCoin> greaterThanZero = tempAssets.where((element) => element.balanceInFiat != null && element.balanceInFiat! > 0).toList();
    List<SupportedCoin> lessThanZero = tempAssets.where((element) => element.balanceInFiat != null && element.balanceInFiat! <= 0).toList();
    greaterThanZero.sort((a, b) {
      logger("a.balanceInFiat: ${a.balanceInFiat}", runtimeType.toString());
      if (a.balanceInFiat == null || b.balanceInFiat == null) {
        return 0;
      }
      return b.balanceInFiat!.compareTo(a.balanceInFiat!);
    });
    tempAssets = greaterThanZero + lessThanZero;
    assets = tempAssets;
    notifyListeners();
  }

  Future<void> getAssetsQuotes({required BalanceController balanceController, required List<SupportedCoin> assets}) async {
    await assetService.getQuotes(balanceController: balanceController, assets: assets);
  }

  Future<List<SupportedCoin>> getAllAssets({required bool isNew, required AssetService assetService, required WalletController walletController,bool shouldIndicate=true}) async {
    logger("Getting default assets", runtimeType.toString());
    try {
      if(shouldIndicate){
        assetLoading = true;
        assetLoadingError=false;
        notifyListeners();
      }
      String walletAddress = walletController.currentWallet?.walletAddress ?? "";
      String privateKey = walletController.currentWallet?.privateKey ?? "";
      List<SupportedCoin> coins = [];
      if (isNew) {
        await Future.wait(
          defaultTokens.keys.map((key) async {
            NetworkModel network;
            logger("Default tokens for chainId $key", runtimeType.toString());
            int chainId = key;
            if (chainId == chain_id_eth) {
              List<String> addresses = defaultTokens[chainId]!;
              network = chain_eth;
              List<SupportedCoin> scT = await assetService.getTokens(network: network, address: walletAddress, privateKey: privateKey);
              logger("Eth  tokens: ${scT.length}", runtimeType.toString());
              coins.addAll(scT);
            } else if (chainId == chain_id_bsc) {
              network = chain_bsc;
              List<SupportedCoin> scT = await assetService.getTokens(network: network, address: walletAddress, privateKey: privateKey);
              logger("Bsc  tokens: ${scT.length}", runtimeType.toString());
              coins.addAll(scT);
            } else if (chainId == chain_id_pol) {
              network = chain_polygon;
              List<SupportedCoin> scT = await assetService.getTokens(network: network, address: walletAddress, privateKey: privateKey);
              logger("Polygon  tokens: ${scT.length}", runtimeType.toString());
              coins.addAll(scT);
            } else {
              network = chain_eth;
              logger("Chain not supported", runtimeType.toString());
            }
            print(network.chainSymbol);
            SupportedCoin nativeToken = SupportedCoin(name: network.chainName, symbol: network.chainCurrency.toUpperCase(), image: network.imageUrl, walletAddress: walletAddress, privateKey: privateKey, networkModel: network, coinType: CoinType.NATIVE_TOKEN, decimal: 18, contractAddress: "",marketCap: double.infinity);
            coins.insert(0, nativeToken);
          }).toList(),
        );
      } else {
        List<SupportedCoin> cachedAssets = await AssetRepo.getInstance().getScannedAssets(walletAddress);
        coins.addAll(cachedAssets);
      }
      //Sort by market cap descending
      coins.sort((a, b) {
        return b.marketCap!.compareTo(a.marketCap!);
      });
      assets = coins;

      // assets = await assetService.getAllAssets(isNew: isNew, walletAddress: walletAddress, privateKey: privateKey);
      if(shouldIndicate){
        assetLoading=false;
        notifyListeners();
      }
      return assets;
    } catch (e) {
      logger("Error getting all assets: " + e.toString(), runtimeType.toString());
      if(shouldIndicate){
        assetLoading=false;
        assetLoadingError=true;
        notifyListeners();
      }
      throw Exception(e);
    }
  }

  Future<List<ScannedToken>> getScannedTokens({required String tokenAddress, required String chainSymbol}) async {
    List<ScannedToken> scannedTokens = await assetService.getTokenInfo(addresses: [tokenAddress], chainSymbol: chainSymbol);
    if (scannedTokens.isNotEmpty) {
      this.scannedTokens[tokenAddress.toLowerCase()] = scannedTokens.first;
    }
    notifyListeners();
    return scannedTokens;
  }


}