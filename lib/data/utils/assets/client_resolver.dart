import 'package:quanthex_admin/core/network/api_client.dart';
import 'package:quanthex_admin/data/utils/assets/token_factory.dart';
import 'package:web3dart/web3dart.dart';
import '../../../core/constants/network_constants.dart';
import '../../domain/entities/network_model.dart';


class ClientResolver{
  static TokenFactory _tokenFactory=TokenFactory();

  static Future<Web3Client> resolveClient({required String rpcUrl}) async {
    Web3Client? webClient=await _tokenFactory.initWebClient(rpcUrl);
    return webClient;
  }
  static NetworkModel? resolveNetworkWithChainId({required int chainId})  {
    if(chainId==chain_id_bsc){
      return chain_bsc;
    }else if(chainId==chain_id_pol){
      return chain_polygon;
    }else if(chainId==chain_id_eth){
      return chain_eth;
    }else if(chainId==chain_id_arb){
      return chain_arbitrum;
    }else if(chainId==chain_id_avax){
      return chain_avalanche;

    }else{
      return null;
    }
  }
  static String? resolveScanKey({required int chainId})  {
    if(chainId==chain_id_bsc){
      return ApiClient.ethScanKey;
    }else if(chainId==chain_id_pol){
      return ApiClient.ethScanKey;
    }else if(chainId==chain_id_eth){
      return ApiClient.ethScanKey;
    }else if(chainId==chain_id_arb){
      return null;
    }else if(chainId==chain_id_avax){
      return ApiClient.ethScanKey;

    }else{
      return ApiClient.ethScanKey;
    }
  }
  static String? resolveScanApi({required int chainId})  {
    if(chainId==chain_id_bsc){
      return "https://api.etherscan.io/v2/api";
    }else if(chainId==chain_id_pol){
      return "https://api.etherscan.io/v2/api";
    }else if(chainId==chain_id_eth){
      return "https://api.etherscan.io/v2/api";
    }else if(chainId==chain_id_arb){
      return null;
    }else if(chainId==chain_id_avax){
      return null;

    }else{
      return null;
    }
  }

  static String? resolveAaveWithChainId({required int chainId})  {
    if(chainId==chain_id_bsc){
      return "0x36616cf17557639614c1cdDb356b1B83fc0B2132";
    }else if(chainId==chain_id_pol){
      return "0xBc790382B3686abffE4be14A030A96aC6154023a";
    }else if(chainId==chain_id_eth){
      return "0xC7be5307ba715ce89b152f3Df0658295b3dbA8E2";
    }else if(chainId==chain_id_arb){
      return "0xBc790382B3686abffE4be14A030A96aC6154023a";
    }else if(chainId==chain_id_avax){
      return "0xBc790382B3686abffE4be14A030A96aC6154023a";
    }else{
      return null;
    }
  }

}