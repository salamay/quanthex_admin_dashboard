import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/wallet_model.dart';
import '../utils/logger.dart';

class SecureStorage {
  SecureStorage._internal();
  static SecureStorage? _instance;
  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  static FlutterSecureStorage? _storage;
  static const wallets_key = 'user_wallets_v1';
  static const current_wallet_key = 'current_wallet_v1';
  static const custom_tokens = 'user_custom_tokens';
  static const pin_key = 'pin';
  static const _key = 'persistent_device_id';
  static const _auth_token = 'Auth_Token';

  static SecureStorage getInstance() {
    if (_instance == null) {
      logger("Creating new instance of SecureStorage", "SecureStorage");
    }
    _instance ??= SecureStorage._internal();
    if (_storage == null) {
      logger("Initializing FlutterSecureStorage", "SecureStorage");
    }
    _storage ??= FlutterSecureStorage(
      aOptions: _instance!._getAndroidOptions(),
    );
    return _instance!;
  }

  Future<String> getOrCreate() async {
    var id = await _storage!.read(key: _key);
    if (id != null && id.isNotEmpty) return id;
    id = Uuid().v4();
    await _storage!.write(key: _key, value: id);
    return id;
  }

  Future<void> saveWallet(List<WalletModel> wallets) async {
    logger("Saving wallet", runtimeType.toString());
    List<WalletModel> existingWallets = [];
    String? data = await _storage!.read(key: wallets_key);
    if (data != null && data.isNotEmpty) {
      List<dynamic> decodedData = json.decode(data);
      existingWallets = decodedData
          .map((e) => WalletModel.fromJson(e))
          .toList();
      for (WalletModel wallet in wallets) {
        bool exists = existingWallets.any(
          (element) =>
              element.walletAddress == wallet.walletAddress &&
              element.chainId == wallet.chainId,
        );
        if (!exists) {
          existingWallets.add(wallet);
        }
      }
      List<dynamic> finalData = existingWallets.map((e) => e.toJson()).toList();
      await _storage!.write(key: wallets_key, value: json.encode(finalData));
    } else {
      List<dynamic> decodedData = wallets.map((e) => e.toJson()).toList();
      await _storage!.write(key: wallets_key, value: json.encode(decodedData));
    }
  }

  Future<List<WalletModel>> getWallets() async {
    logger("Getting wallet", runtimeType.toString());
    String? data = await _storage!.read(key: wallets_key);
    if (data != null && data.isNotEmpty) {
      List<dynamic> decodedData = json.decode(data);
      List<WalletModel> existingWallets = decodedData
          .map((e) => WalletModel.fromJson(e))
          .toList();
      return existingWallets;
    } else {
      return [];
    }
  }





  Future<void> savePin(String pin) async {
    logger("Saving pin", runtimeType.toString());
    await _storage!.write(key: pin_key, value: pin);
  }

  Future<String> getPin() async {
    logger("Getting pin", runtimeType.toString());
    String? pin = await _storage!.read(key: pin_key);
    return pin ?? "";
  }

  Future<void> saveAuthToken(String token) async {
    logger("Saving auth token", runtimeType.toString());
    await _storage!.write(key: _auth_token, value: token);
  }

  Future<String> getAuthToken() async {
    logger("Getting auth token", runtimeType.toString());
    String? token = await _storage!.read(key: _auth_token);
    return token ?? "";
  }

  Future<void> saveCurrentWallet(String walletAddress) async {
    logger("Saving current wallet", runtimeType.toString());
    await _storage!.write(key: current_wallet_key, value: walletAddress);
  }

  Future<String> getCurrentWallet() async {
    logger("Getting current wallet", runtimeType.toString());
    String? walletAddress = await _storage!.read(key: current_wallet_key);
    return walletAddress ?? "";
  }

  Future<void> deleteWallet(String walletAddress) async {
    logger("Deleting wallet", runtimeType.toString());
    List<WalletModel> wallets = await getWallets();
    wallets.removeWhere((wallet) => wallet.walletAddress == walletAddress);
    List<dynamic> finalData = wallets.map((e) => e.toJson()).toList();
    await _storage!.write(key: wallets_key, value: json.encode(finalData));
  }

  Future<void> updateWallet(WalletModel updatedWallet) async {
    logger("Updating wallet", runtimeType.toString());
    List<WalletModel> wallets = await getWallets();
    int index = wallets.indexWhere(
      (wallet) =>
          wallet.walletAddress == updatedWallet.walletAddress &&
          wallet.chainId == updatedWallet.chainId,
    );
    if (index != -1) {
      wallets[index] = updatedWallet;
      List<dynamic> finalData = wallets.map((e) => e.toJson()).toList();
      await _storage!.write(key: wallets_key, value: json.encode(finalData));
    }
  }
  Future<void> clearWallets() async {
    logger("Clearing wallets from secure storage", runtimeType.toString());
    await _storage!.delete(key: wallets_key);
    await _storage!.delete(key: current_wallet_key);
  }

  Future<void> clear() async {
    logger("Clearing secure storage", runtimeType.toString());
    await _storage!.deleteAll();
  }
}
