
import 'package:coingecko_api/coingecko_api.dart';
import 'package:coingecko_api/coingecko_result.dart' as coingecko;
import 'package:coingecko_api/data/coin.dart' as coingecko_coin;
import 'package:coingecko_api/helpers/credentials/pro_credentials.dart';
import 'package:dio/dio.dart';
import 'package:quanthex_admin/core/network/api_client.dart';
import 'dart:math' as math;
import '../../../core/constants/crypto_constants.dart';
import '../../../core/constants/network_constants.dart';
import '../../../core/network/api_constants.dart';
import '../../../presentation/providers/balance_controller.dart';
import '../../datasources/models/scan_token.dart';
import '../../datasources/models/transactions/erc20_transfer_dto.dart';
import '../../datasources/models/transactions/native_tx_dto.dart';
import '../../domain/entities/network_model.dart';
import '../../domain/entities/supported_assets.dart';
import '../../domain/models/balance/platform_data.dart';
import '../../utils/logger.dart';
import '../../utils/network/chain_parse.dart';
import '../../utils/network/network_utils.dart';

Map<int, List<String>> defaultTokens = {
  1: ethTokenAddresses,
  56: bscTokenAddresses,
  137: polygonTokenAddresses,
};

class AssetService{

  CoinGeckoApi coingeckoApi = CoinGeckoApi(credentials: ProCredentials(apiKey: ApiClient.coinGecko));
  /// Maps chain IDs to their hardcoded top-30 token address lists.
  static const Map<int, List<String>> _chainTokens = {
    chain_id_eth: ethTokenAddresses,
    chain_id_bsc: bscTokenAddresses,
    chain_id_pol: polygonTokenAddresses,
  };
  static AssetService? _instance;
  AssetService._internal();

  static AssetService getInstance() {
    if(_instance==null){
      logger("Creating AssetService instance","AssetService");
    }
    _instance ??= AssetService._internal();
    return _instance!;
  }

  /// Returns popular tokens for [network] by looking up the hardcoded
  /// top-30 address list and enriching them via Moralis metadata.
  Future<List<SupportedCoin>> getTokens({
    required NetworkModel network,
    required String address,
    required String privateKey,
  }) async {
    try {
      String chainSymbol = network.chainSymbol.toUpperCase();
      int chainId = network.chainId;
      logger("Swap: Getting tokens for $chainSymbol (chainId $chainId)", runtimeType.toString());

      List<String>? addresses = _chainTokens[chainId];
      if (addresses == null || addresses.isEmpty) {
        throw Exception('No default token list for chain $chainSymbol (chainId $chainId)');
      }

      logger("Swap: Using ${addresses.length} hardcoded addresses for $chainSymbol", runtimeType.toString());

      // ── Enrich with Moralis metadata (existing flow) ──
      List<SupportedCoin> assets = await AssetService.getInstance().scanTokens(
        network: network,
        addresses: addresses,
        chainSymbol: chainSymbol,
        walletAddress: address,
        privateKey: privateKey,
      );
      return assets;
    } catch (e) {
      logger("${network.chainSymbol}: $e", runtimeType.toString());
      throw Exception(e);
    }
  }

  Future<List<ScannedToken>> getTokenInfo({required List<String> addresses,required String chainSymbol}) async {
    try{
      logger("Scanning token on $chainSymbol",runtimeType.toString());
      Uri uri=Uri.parse(ApiConstants.moralisTokenMetadata);
      Uri finalUri=uri.replace(
          queryParameters: {
            "chain":ChainParse.getMoralisChainName(chainSymbol),
            "addresses":addresses,
          });
      Response? response = await ApiClient().get(finalUri.toString(), headers: {"Content-Type": "application/json","X-API-Key":ApiClient.moralisKey});
      logger("Scanning token: Response code ${response!.statusCode}",runtimeType.toString());
      if (response.statusCode == 200) {
        List<ScannedToken> scannedTokens=List.from(response.data).map((e) => ScannedToken.fromJson(e)).toList();
        print(response.data);
        logger("Scanned token: ${scannedTokens.length}",runtimeType.toString());
        return scannedTokens;
      } else {
        return [];
      }
    }catch(e){
      logger(e.toString(),runtimeType.toString());
      return [];
    }
  }

  Future<coingecko_coin.Coin?> getTokenMetaDatabyId({required String id}) async {
    try {
      logger("Getting token metadata by coin id: $id", runtimeType.toString());
      coingecko.CoinGeckoResult<coingecko_coin.Coin?> result = await coingeckoApi.coins.getCoinData(id: id);
      logger(result.toString(),runtimeType.toString());
      logger("Getting token metadata by id : ${result.data}", runtimeType.toString());
      return result.data;
    } catch (e) {
      logger(e.toString(), runtimeType.toString());
      throw Exception("Error getting token metadata: $e");
    }
  }



  SupportedCoin getNativeCoin({required NetworkModel network,required String walletAddress,required String privateKey}){
    try{
      logger("Getting native coin: ${network.chainId}",runtimeType.toString());
      SupportedCoin nativeToken=SupportedCoin(
        name: network.chainName,
        symbol: network.chainCurrency.toUpperCase(),
        image: network.imageUrl,
        walletAddress: walletAddress,
        privateKey: privateKey,
        networkModel: network,
        coinType: CoinType.NATIVE_TOKEN,
        decimal: 18,
        contractAddress: "",
        marketCap: double.infinity
      );
      return nativeToken;
    }catch(e){
      logger("Error getting native token: $e",runtimeType.toString());
      throw Exception("Error getting native token: $e");
    }
  }


  Future<void> getQuotes({required BalanceController balanceController,required List<SupportedCoin> assets})async{
    Map<String,PlatformData>? existingPlatform=balanceController.platforms;
    if(existingPlatform.isEmpty){
      existingPlatform= await balanceController.getAssetsPlatform();
    }
    if(existingPlatform!=null){
        //This is used to get the quotes for tokens
        List<SupportedCoin> tokens=assets.where((e)=>e.coinType==CoinType.TOKEN||e.coinType==CoinType.WRAPPED_TOKEN).toList();
        await balanceController.getTokenQuotes(tokens: tokens);
        List<SupportedCoin> nativeAssets=assets.where((e)=>e.coinType==CoinType.NATIVE_TOKEN).toList();
        //This is used to get the quotes for native assets
        Map<String,String> mappedData=NetworkUtils.mapSymbolToPlatformId(assets: assets, existingPlatform: existingPlatform);
        var data=await balanceController.getQuotesByIds(p: mappedData);

    }
  }


  Future<List<SupportedCoin>> scanTokens({required NetworkModel network,required List<String> addresses,required String chainSymbol,required String walletAddress,required String privateKey}) async {
    try{
      logger("Scanning token on $chainSymbol",runtimeType.toString());
      if(addresses.isEmpty){
        logger("No addresses to scan",runtimeType.toString());
        return [];
      }
      Uri uri=Uri.parse(ApiConstants.moralisTokenMetadata);
      Uri finalUri=uri.replace(
          queryParameters: {
            "chain":ChainParse.getMoralisChainName(chainSymbol),
            "addresses":addresses,
          });
      Response? response = await ApiClient().get(finalUri.toString(),headers:  {"Content-Type": "application/json","X-API-Key":ApiClient.moralisKey});
      logger("Scanning token: Response code ${response!.statusCode}",runtimeType.toString());
      if (response.statusCode == 200) {
        List<ScannedToken> scannedTokens=List.from(response.data).map((e) => ScannedToken.fromJson(e)).toList();
        logger("Scanned token: ${scannedTokens.length}",runtimeType.toString());
        final filteredTokens = scannedTokens.where((token) => token.logo != null).toList();
        List<SupportedCoin> assets=filteredTokens.map((e){
          return SupportedCoin(
            name: e.name!,
            symbol: e.symbol!.toUpperCase(),
            image: e.logo??network.imageUrl,
            walletAddress: walletAddress,
            privateKey: privateKey,
            networkModel: network,
            coinType: CoinType.TOKEN,
            decimal: int.parse(e.decimals!),
            contractAddress: e.address!.toLowerCase(),
            marketCap: double.parse(e.marketCap??"0"),
          );
        }).toList();
        return assets;
      } else {
        logger(response.data.toString(),runtimeType.toString());
        return [];
      }
    }catch(e){
      logger(e.toString(),runtimeType.toString());
      throw Exception("Error scanning tokens: $e");
    }
  }



  Future<Map<String,dynamic>> getErc20Transfers({required String address, required String chainSymbol,required String cursor,required int limit,required List<String> contractAddresses}) async {
    try {
      logger("Getting ERC20 transfers for $address on $chainSymbol", runtimeType.toString());
      Uri uri = Uri.parse("${ApiConstants.moralisErc20Transfers}/$address/erc20/transfers");
      Uri finalUri = uri.replace(queryParameters: {"chain": ChainParse.getMoralisChainName(chainSymbol), "limit": limit.toString(),"order": "DESC", "contract_addresses": contractAddresses});
      Response? response = await ApiClient().get(finalUri.toString(),headers:  {"Content-Type": "application/json", "X-API-Key": ApiClient.moralisKey});
      logger("Getting ERC20 transfers: Response code ${response!.statusCode}", runtimeType.toString());
      logger("Getting ERC20 transfers: ${response.data}", runtimeType.toString());
      if (response.statusCode == 200) {
        List<Erc20TransferDto> transfers = List.from(response.data["result"]).map((e) => Erc20TransferDto.fromJson(e)).toList();
        logger("Getting ERC20 transfers: ${transfers.length}", runtimeType.toString());
        return {"transfers": transfers, "cursor": response.data["cursor"]};
      } else {
        return {"transfers": [], "cursor": ""};
      }
    } catch (e) {
      logger(e.toString(), runtimeType.toString());
      throw Exception("Error getting ERC20 transfers: $e");
    }
  }

  Future<Map<String, dynamic>> getNativeTransfers({required String address, required String chainSymbol, required String cursor, required int limit}) async {
    try {
      logger("Getting ERC20 transfers for $address on $chainSymbol", runtimeType.toString());
      Uri uri = Uri.parse("${ApiConstants.moralisNativeTransfers}/$address");
      Uri finalUri = uri.replace(queryParameters: {"chain": ChainParse.getMoralisChainName(chainSymbol), "limit": limit.toString(), "order": "DESC"});
      Response? response = await ApiClient().get(finalUri.toString(), headers:  {"Content-Type": "application/json", "X-API-Key": ApiClient.moralisKey});
      logger("Getting ERC20 transfers: Response code ${response!.statusCode}", runtimeType.toString());
      logger("Getting ERC20 transfers: ${response.data}", runtimeType.toString());
      if (response.statusCode == 200) {
        List<NativeTxDto> transfers = List.from(response.data["result"]).map((e) => NativeTxDto.fromJson(e)).toList();
        logger("Getting ERC20 transfers: ${transfers.length}", runtimeType.toString());
        return {"transfers": transfers, "cursor": response.data["cursor"]};
      } else {
        return {"transfers": [], "cursor": ""};
      }
    } catch (e) {
      logger(e.toString(), runtimeType.toString());
      throw Exception("Error getting ERC20 transfers: $e");
    }
  }


}