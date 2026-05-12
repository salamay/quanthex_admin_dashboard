
import '../../domain/entities/network_model.dart';
import '../../domain/entities/supported_assets.dart';
import '../../domain/models/balance/platform_data.dart';
import '../logger.dart';

class NetworkUtils{

  static List<String > filterNetworksFromAssets({required List<SupportedCoin> assets}){
    Map<String,String> networks={};
    for(var asset in assets){
      NetworkModel? network=asset.networkModel;
      if(network!=null){
        networks[network.chainId.toString()]=network.chainName;
      }
    }
    return networks.keys.toList();
  }

  static Map<String,String> mapSymbolToPlatformId({required List<SupportedCoin> assets,required Map<String,PlatformData>? existingPlatform}){
    Map<String,int> chainSymbols={};
    for(var asset in assets){
      NetworkModel? network=asset.networkModel;
      if(network!=null){
        chainSymbols[network.chainSymbol]=network.chainId;
      }
    }
    Map<String,String> newData={};
    chainSymbols.forEach((key, value) {
      //Since value is the chainId
      //id is the platform id
      //key is the chain symbol
      String id=existingPlatform?[value.toString()]?.nativeCoinId??"";
      if(id.isNotEmpty){
        //symbol:platformId
        newData[key]=id;
      }
    });
    logger(newData.toString(), "NetworkUtils");
    return newData;
  }
}