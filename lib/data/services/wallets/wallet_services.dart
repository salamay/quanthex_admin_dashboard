

import 'package:wallet/wallet.dart' as wallet;
import 'package:web3dart/web3dart.dart';
import '../../domain/entities/wallet_model.dart';
import '../../utils/logger.dart';

enum WalletType{
  SINGLE,
  MULTI
}
class WalletServices{

  WalletServices._internal();
  static WalletServices? instance;

  static WalletServices getInstance() {
    if(instance==null){
      logger("Creating new instance of WalletServices","WalletServices");
    }
    instance ??= WalletServices._internal();
    return instance!;
  }

  Future<String> generateMnemonic({String? passphrase,required int strength})async{
    try{
      final mnemonic = wallet.generateMnemonic(strength: strength);
      var mn=mnemonic.join(' ');
      return mn;
    }catch(e){
      logger(e.toString(),"WalletServices");
      throw Exception("Unable to generate mnemonic");
    }
  }


   Future<WalletModel> createWallet({String? passphrase,required int strength})async{
    try{
      String mnemonic=await generateMnemonic(passphrase: passphrase,strength: strength);
      String path="m/44'/60'/0'/0/0";
      Map<String,String> keys=await getAddressesByMnemonic(mnemonic: mnemonic,path: path,passphrase: "");
      String walletAddress=keys["address"]??"";
      String hash=walletAddress.toString();
      WalletModel walletModel=WalletModel(mnemonic:mnemonic,chainId: "1", walletAddress: walletAddress, privateKey: keys["private_key"],hash: hash);
      return walletModel;
    }catch(e){
      logger(e.toString(),"WalletServices");
      throw Exception(e.toString());
    }
  }
  Future<WalletModel> importFromMnemonic(String mnemonic)async{
    try{
      logger("Importing wallet by private key","WalletServices");
      String path="m/44'/60'/0'/0/0";
      Map<String,String> keys=await getAddressesByMnemonic(mnemonic: mnemonic,path: path,passphrase: "");
      String walletAddress=keys["address"]??"";
      String hash = walletAddress.toString();
      WalletModel walletModel=WalletModel(mnemonic:mnemonic,chainId: "1", walletAddress: keys["address"], privateKey: keys["private_key"],hash: hash);
      return walletModel;
    }catch(e){
      logger(e.toString(),"WalletServices");
      throw Exception(e);
    }
  }

  Future<Map<String,String>> getAddressesByMnemonic({required String mnemonic,required String path,required String? passphrase})async{
    try{
      final seed = wallet.mnemonicToSeed(mnemonic.split(" "));
      final master = wallet.ExtendedPrivateKey.master(seed, wallet.xprv);
      final root = master.forPath(path);
      final pKey = wallet.PrivateKey((root as wallet.ExtendedPrivateKey).key);
      final publicKey = wallet.ethereum.createPublicKey(pKey);
      final address = wallet.ethereum.createAddress(publicKey);
      String privateKey=bytesToHex(EthPrivateKey.fromInt(pKey.value).privateKey);
      return {
        "address":address,
        "private_key":privateKey
      };
    }catch(e){
      print(e);
      throw Exception(e);
    }
  }
  
 
  
}