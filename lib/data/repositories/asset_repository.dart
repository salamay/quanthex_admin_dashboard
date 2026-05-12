import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/network_constants.dart';
import '../domain/entities/supported_assets.dart';
import '../utils/logger.dart';

class AssetRepo {
  AndroidOptions _getAndroidOptions() => const AndroidOptions(encryptedSharedPreferences: true);
  static AssetRepo? _instance;
  AssetRepo._internal();

  static FlutterSecureStorage? _storage;

  static AssetRepo getInstance() {
    if (_instance == null) {
      logger("Creating new instance of AssetRepo", "AssetRepo");
    }
    _instance ??= AssetRepo._internal();
    if (_storage == null) {
      logger("Initializing FlutterSecureStorage", "AssetRepo");
    }
    _storage ??= FlutterSecureStorage(aOptions: _instance!._getAndroidOptions());
    return _instance!;
  }

  Future<void> saveAssets({required String walletAddress,required List<SupportedCoin> newTokens}) async {
    log("Saving scanned asset ");
    // newTokens.removeWhere((e)=>e.coinType==CoinType.NATIVE_TOKEN);
    try {
      List<SupportedCoin> cachedAssets = await getScannedAssets(walletAddress);
      if (cachedAssets.isNotEmpty) {
        for (SupportedCoin token in newTokens) {
          if (token.coinType == CoinType.NATIVE_TOKEN) {
            if(cachedAssets.indexWhere((element) => element.networkModel?.chainId == token.networkModel!.chainId && element.symbol == token.symbol) == -1){
              cachedAssets.add(token);
            }
          } else {
            int index = cachedAssets.indexWhere((element) {
              return element.contractAddress!.toLowerCase() == token.contractAddress!.toLowerCase();
            });
            if (index == -1) {
              //If the token is not in the cache, add it to the cache
              cachedAssets.add(token);
            } else {
              //If the token is already in the cache, update the existing token
            }
          }
          
        }
      } else {
        cachedAssets = newTokens;
      }
      List<Map<String, dynamic>> data = cachedAssets.map((e) => e.toJson()).toList();
      await _storage!.write(key: walletAddress, value: json.encode(data));
    } catch (e) {
      log("Error saving scanned asset: $e");
    }
  }

  Future<List<SupportedCoin>> getScannedAssets(String walletAddress) async {
    log("Getting coins from local storage ");
    try {
      String? data = await _storage!.read(key: walletAddress);
      if (data == null) {
        return [];
      }
      if (data.isNotEmpty) {
        List<dynamic> results = jsonDecode(data);
        return results.map((e) => SupportedCoin.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      log("Error getting saved asset: $e");
      return [];
    }
  }

  Future<bool> isCacheAssetEmpty(String walletAddress) async {
    List<SupportedCoin> scannedToken = await getScannedAssets(walletAddress);
   
    log("Cache assets: ${scannedToken.length}");
    if (scannedToken.isNotEmpty) {
      return false;
    } else {
      return true;
    }
  }
}
