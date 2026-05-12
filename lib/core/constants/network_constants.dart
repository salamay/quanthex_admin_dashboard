
import '../../data/domain/entities/network_model.dart';
import '../network/api_constants.dart';
import 'crypto_constants.dart';

enum CoinType{
  TOKEN,COIN,NATIVE_TOKEN,WRAPPED_TOKEN,UN_DEFINED
}
enum NetworkType{
  supported,
  custom,
  undefined
}
enum ChainUnit{
  satoshi,ethers,wei,matic
}
const int chain_id_eth=1;
const int chain_id_pol=137;
const int chain_id_bsc=56;
const int chain_id_arb=42161;
const int chain_id_avax=43114;

String binance = "Binance Smart Chain";
String ethereum = "Ethereum";
String polygon = "Polygon";
String boorio = "Boorio";
String arbitrum_one = "Arbitrum One";
String arb = "ARB";
String avalanche = "Avalanche C-Chain";
String avax = "AVAX";

NetworkModel chain_bsc = NetworkModel(chainName: binance, imageUrl: "https://assets.coingecko.com/coins/images/825/large/binance-coin-logo.png", chainId: 56 ,chainSymbol: bsc,rpcUrl: ApiConstants.BSCRpc,websocketUrl: ApiConstants.BSCRpcSocket,unit: ChainUnit.ethers.name,chainCurrency: bnb,nativeCoinId: "1839",scanUrl: "https://bscscan.com",scanName: "Bsc scan",minimumCurrency: 0.001,networkType: NetworkType.supported,isCustom: false);
NetworkModel chain_eth= NetworkModel(chainName: eth, imageUrl: "https://assets.coingecko.com/coins/images/279/large/ethereum.png", chainId: 1, chainSymbol: eth,rpcUrl: ApiConstants.ETHRpc,websocketUrl: ApiConstants.ETHRpcSocket,unit: ChainUnit.ethers.name,chainCurrency: eth,nativeCoinId: "1027",scanUrl: "https://etherscan.io",scanName: "Ether scan",minimumCurrency: 0.003,networkType: NetworkType.supported,isCustom: false);
NetworkModel chain_polygon= NetworkModel(chainName: polygon, imageUrl: "https://assets.coingecko.com/coins/images/4713/large/matic-token-icon.png", chainId: 137, chainSymbol: pol,rpcUrl: ApiConstants.polygonRpc,websocketUrl: ApiConstants.polygonRpcSocket,unit: ChainUnit.matic.name,chainCurrency: pol,nativeCoinId: "28321",scanUrl: "https://polygonscan.com",scanName: "Polygon scan",minimumCurrency: 0.003,networkType: NetworkType.supported,isCustom: false);
// NetworkModel chain_boorio= NetworkModel(chain_name: boorio, image_url: "https://res.cloudinary.com/djwu7p6ti/image/upload/v1728944636/boorio1635924679097_ptjzdo.png", chain_id: 800710, chain_symbol: boorio,rpcUrl: ApiConstants.boorioRpc,unit: ChainUnit.ethers.name,chain_currency: boorio,nativeCoinId: "",scanUrl: "https://explorer.boorio.tech/",scanName: "Boorio scan",minimumCurrency: 0.003,networkType: NetworkType.supported,isCustom: false);
NetworkModel chain_arbitrum = NetworkModel(chainName: arbitrum_one, imageUrl: "https://s2.coinmarketcap.com/static/img/coins/64x64/11841.png", chainId: 42161 ,chainSymbol: arb,rpcUrl: ApiConstants.arbitrumRpc,websocketUrl: ApiConstants.arbitrumRpcSocket,unit: ChainUnit.ethers.name,chainCurrency: arb,nativeCoinId: "1839",scanUrl: "https://arbiscan.io",scanName: "Arbiscan",minimumCurrency: 0.001,networkType: NetworkType.supported,isCustom: false);
NetworkModel chain_avalanche = NetworkModel(chainName: avalanche, imageUrl: "https://s2.coinmarketcap.com/static/img/coins/64x64/5805.png", chainId: 43114 ,chainSymbol: avax,rpcUrl: ApiConstants.avalancheRpc,websocketUrl: ApiConstants.avalancheRpcSocket,unit: ChainUnit.ethers.name,chainCurrency: avax,nativeCoinId: "5805",scanUrl: "https://avascan.info/blockchain/c",scanName: "Avascan",minimumCurrency: 0.001,networkType: NetworkType.supported,isCustom: false);

