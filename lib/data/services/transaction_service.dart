import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

import '../../../core/constants/network_constants.dart';

import 'dart:math' as math;

import '../domain/entities/network_model.dart';
import '../domain/entities/supported_assets.dart';
import '../domain/models/network_fee.dart';
import '../domain/models/send_payload.dart';
import '../utils/assets/client_resolver.dart';
import '../utils/assets/token_factory.dart';
import '../utils/logger.dart';

class TransactionService {
  // Add your transaction service methods here

  Future<BigInt> getChainTxFee({required String sender,required String to,required Uint8List? data,required String rpcUrl})async{
    try{
      Web3Client webClient=await ClientResolver.resolveClient(rpcUrl: rpcUrl);
      BigInt gas=await webClient.estimateGas(sender: EthereumAddress.fromHex(sender), to: EthereumAddress.fromHex(to), data: data);
      logger("Gas : ${gas.toString()}",runtimeType.toString());
      return gas;
    }catch(e){
      logger(e.toString(),runtimeType.toString());
      throw Exception("Unable to get transaction fee");
    }
  }

  Future<BigInt> getChainNetworkFee({required String rpcUrl,required int chainId})async{
    try{
      logger("Getting chain $chainId network fee",runtimeType.toString());
      Web3Client webClient=await ClientResolver.resolveClient(rpcUrl: rpcUrl);
      EtherAmount gasPrice=await webClient.getGasPrice();
      logger("Gas price in wei: ${gasPrice.getInWei.toString()}",runtimeType.toString());
      logger("Gas price in gwei: ${gasPrice.getValueInUnit(EtherUnit.gwei).toString()}",runtimeType.toString());
      if(chainId==1){
        return gasPrice.getInWei*BigInt.from(3);
      }else{
        return gasPrice.getInWei*BigInt.from(2);

      }
    }catch(e){
      logger(e.toString(),runtimeType.toString());
      throw Exception("Unable to get network fee");
    }
  }
   Future<NetworkFee> calcNetworkFee({required BigInt gas,required BigInt gasPrice,required double currentPrice,required String chainCurrency}) async {
    try {
      int maxGas = (gas).toInt();
      BigInt? totalGas = gasPrice * BigInt.from(maxGas);
      logger("Total gas in wei: $totalGas",runtimeType.toString());
      double amount = EtherAmount.fromBase10String(EtherUnit.wei, totalGas.toString()).getValueInUnit(EtherUnit.ether).toDouble();
      logger("Total gas in ether: $amount",runtimeType.toString());
      logger("Current price: $currentPrice",runtimeType.toString());
      if (currentPrice > 0) {
        double feeInFiat = amount.toDouble() * currentPrice;
        logger("Fee in Fiat: $feeInFiat",runtimeType.toString());
        double feeInCrypto = amount.toDouble();
        logger("Fee in crypto: $feeInCrypto",runtimeType.toString());
        NetworkFee networkFee = NetworkFee(feeInCrypto: feeInCrypto, feeInFiat: feeInFiat, gasPrice: gasPrice, symbol: chainCurrency, maxGas: maxGas);
        return networkFee;
      } else {
        throw Exception("Could not get fee");
      }
    } catch (e) {
      logger(e.toString(),runtimeType.toString());
      throw Exception("Could not get fee");
    }
  }

  Future<NetworkFee?> getTxInfo({required double priceQuote, required SupportedCoin asset,required SendPayload sendPayload}) async {
    try{
      TokenFactory _tokenFactory=TokenFactory();
      if(asset.coinType==CoinType.TOKEN||asset.coinType==CoinType.WRAPPED_TOKEN){
        final String abi = await rootBundle.loadString("abi/token/token_contract.json");
        String contractAddress = sendPayload.asset!.contractAddress!;
        String symbol = sendPayload.asset!.symbol;
        String toAddress = sendPayload.recipient_address!;
        String assetName = sendPayload.asset!.name;
        String privateKey = sendPayload.asset!.privateKey!;
        NetworkModel network=sendPayload.asset!.networkModel!;
        final credentials = await _tokenFactory.getCredentials(privateKey);
        final contract = await _tokenFactory.intContract(abi, contractAddress, assetName);
        final sendFunction = contract.function('transfer');
        int decimal = sendPayload.asset!.decimal!;
        double estAmount = math.pow(10, decimal).toDouble();
        Transaction transaction = Transaction.callContract(
            contract: contract,
            function: sendFunction,
            from: credentials.address,
            parameters: [
              EthereumAddress.fromHex(toAddress),
              BigInt.from(estAmount)
            ]
        );
        BigInt gas = await getChainTxFee(sender: credentials.address.with0x, to: toAddress, rpcUrl: network.rpcUrl, data: transaction.data!);
        BigInt gasPrice = await getChainNetworkFee(rpcUrl: network.rpcUrl,chainId: network.chainId);
        int maxGas = (gas.toInt() * 4).toInt();
        BigInt totalGas = gasPrice * gas;
        logger("Total gas in wei: $totalGas",runtimeType.toString());
        double amount = EtherAmount.fromBase10String(EtherUnit.wei, totalGas.toString()).getValueInUnit(EtherUnit.ether).toDouble();
        logger("Total gas in ether: $amount",runtimeType.toString());
        double currentPrice = priceQuote;
        logger("Current price: $currentPrice",runtimeType.toString());
        double feeInFiat= amount.toDouble()*currentPrice;
        logger("Fee in Fiat: $feeInFiat",runtimeType.toString());
        double feeInCrypto = amount.toDouble();
        logger("Fee in crypto: $feeInCrypto",runtimeType.toString());
        return NetworkFee(feeInCrypto: feeInCrypto, feeInFiat: feeInFiat, gasPrice: gasPrice, symbol: asset.networkModel!.chainSymbol, maxGas: maxGas);
      }else{
        NetworkModel network=sendPayload.asset!.networkModel!;
        String toAddress = sendPayload.recipient_address!;
        String privateKey = sendPayload.asset!.privateKey!;
        double amountToSend= sendPayload.amount!;
        BigInt amountInWei=BigInt.from(amountToSend*math.pow(10, 18));
        final credentials = await _tokenFactory.getCredentials(privateKey);
        Transaction tx=Transaction(
          to: EthereumAddress.fromHex(toAddress),
          value: EtherAmount.fromBigInt(EtherUnit.wei, amountInWei),
          from: credentials.address,
        );

        BigInt gas = await getChainTxFee(sender: credentials.address.with0x, to: toAddress, rpcUrl: network.rpcUrl, data: tx.data);
        BigInt gasPrice = await getChainNetworkFee(rpcUrl: network.rpcUrl,chainId: network.chainId);
        int maxGas = (gas.toInt() * 4).toInt();
        BigInt totalGas = gasPrice * gas;
        logger("Total gas in wei: $totalGas",runtimeType.toString());
        double amount = EtherAmount.fromBase10String(EtherUnit.wei, totalGas.toString()).getValueInUnit(EtherUnit.ether).toDouble();
        logger("Total gas in ether: $amount",runtimeType.toString());
        logger("Max gas in ether: $totalGas",runtimeType.toString());
        double currentPrice=priceQuote;
        double feeInFiat = amount.toDouble() * currentPrice;
        double feeInCrypto = amount.toDouble();
        logger("Current price: $currentPrice",runtimeType.toString());
        logger("Fee in crypto: $feeInCrypto",runtimeType.toString());
        logger("Fee in Fiat: $feeInFiat",runtimeType.toString());
        return NetworkFee(feeInCrypto: feeInCrypto, feeInFiat: feeInFiat, gasPrice: gasPrice, symbol: asset.networkModel!.chainSymbol, maxGas: maxGas);
      }
    }catch(e){
      logger(e.toString(),runtimeType.toString());
      throw Exception(e);
    }
  }

  Future<Transaction> getTransferTx(BuildContext context,SendPayload sendPayload) async {
    try{
      // Implement the logic to send the transaction
      TokenFactory _tokenFactory=TokenFactory();
      SupportedCoin asset = sendPayload.asset!;
      NetworkFee fee = sendPayload.fee!;
      int decimal = sendPayload.asset!.decimal!;
      // double percentage1=payload.percentage/100;
      double recipientAmount = sendPayload.amount??0.0;
      double totalAmount = ((recipientAmount) * math.pow(10, decimal));
      logger("Total amount: $totalAmount",runtimeType.toString());
      if(asset.coinType==CoinType.TOKEN||asset.coinType==CoinType.WRAPPED_TOKEN){
        final String abi = await rootBundle.loadString("abi/token/token_contract.json");
        String contractAddress = sendPayload.asset!.contractAddress!;
        String assetName = sendPayload.asset!.name;
        String privateKey = sendPayload.asset!.privateKey!;
        final credentials = await _tokenFactory.getCredentials(privateKey);
        final contract = await _tokenFactory.intContract(abi, contractAddress, assetName);
        final sendFunction = contract.function('transfer');
        //Recipient receive 80%  of the transaction while admin receives 20 %
        Transaction transaction0 = Transaction.callContract(
            contract: contract,
            function: sendFunction,
            from: credentials.address,
            gasPrice: EtherAmount.inWei(fee.gasPrice),
            maxGas: fee.maxGas,
            parameters: [
              EthereumAddress.fromHex(sendPayload.recipient_address!),
              BigInt.from(totalAmount)
            ]
        );
        return transaction0;
      }else{
        String toAddress = sendPayload.recipient_address!;
        String privateKey = sendPayload.asset!.privateKey!;
        final credentials = await _tokenFactory.getCredentials(privateKey);
        Transaction tx=Transaction(
          to: EthereumAddress.fromHex(toAddress),
          value: EtherAmount.fromBigInt(EtherUnit.wei, BigInt.from(totalAmount)),
          from: credentials.address,
          gasPrice: EtherAmount.inWei(fee.gasPrice),
          maxGas: fee.maxGas,
        );
        return tx;
      }
    }catch(e){
      logger(e.toString(), runtimeType.toString());
      throw Exception( "An error occurred while creating transaction");
    }
  }

    Future<Transaction> constructTx({required DeployedContract contract, required ContractFunction function, required Credentials credentials, required List<dynamic> params, EtherAmount? gasPrice, int? maxGas, EtherAmount? value}) async {
    if (value == null) {
      Transaction transaction = Transaction.callContract(contract: contract, function: function, gasPrice: gasPrice, maxGas: maxGas, from: credentials.address, parameters: params);
      return transaction;
    } else {
      Transaction transaction = Transaction.callContract(contract: contract, function: function, gasPrice: gasPrice, maxGas: maxGas, value: value, from: credentials.address, parameters: params);
      return transaction;
    }
  }


  Future<String> sendTx({required Transaction transaction,required Credentials credentials,required SupportedCoin asset})async{
    try{
      logger("Sending transaction",runtimeType.toString());
      int chainId=asset.networkModel!.chainId;
      Web3Client webClient=await ClientResolver.resolveClient(rpcUrl: asset.networkModel!.rpcUrl);
      Uint8List signedTransaction = await webClient.signTransaction(credentials, transaction, chainId: chainId, fetchChainIdFromNetworkId: false);
      String txId=await webClient.sendRawTransaction(signedTransaction);
      logger("TxId: $txId",runtimeType.toString());
      return txId;
    }catch(e){
      logger(e.toString(),runtimeType.toString());
      throw Exception("An error occurred while sending transaction");
    }
  }


  Future<String> sendNativeCoinTx({required Transaction tx,required String to, required Credentials credentials,required SupportedCoin asset,required int chainId}) async {
    try {
      logger("Sending Eth",runtimeType.toString());
      /// [...], you need to specify the url and your client, see example above
      Web3Client webClient=await ClientResolver.resolveClient(rpcUrl: asset.networkModel!.rpcUrl);
      return await webClient.sendTransaction(
          credentials,
          tx,
          chainId: chainId
      );
    } catch (e) {
      logger(e.toString(),runtimeType.toString());
      throw Exception("An error occurred while sending transaction");
    }
  }

  Future<String> signTx({required Transaction transaction,required Credentials credentials,required SupportedCoin asset})async{
    try{
      logger("Signing transaction",runtimeType.toString());
      int chainId=asset.networkModel!.chainId;
      Web3Client webClient=await ClientResolver.resolveClient(rpcUrl: asset.networkModel!.rpcUrl);
      Uint8List signedTransaction = await webClient.signTransaction(credentials, transaction, chainId: chainId, fetchChainIdFromNetworkId: false);
      return bytesToHex(signedTransaction);
    }catch(e){
      logger(e.toString(),runtimeType.toString());
      throw Exception("An error occurred while signing transaction");
    }
  }
  /// Checks the status of a transaction by its hash
  /// 
  /// [txHash] - The transaction hash to check
  /// [rpcUrl] - The RPC URL of the network where the transaction was sent
  /// 
  /// Returns a [TransactionStatus] object containing:
  /// - [isSuccess] - true if transaction was successful, false if failed
  /// - [isPending] - true if transaction is still pending, false if confirmed
  /// - [blockNumber] - The block number where the transaction was included (null if pending)
  /// - [gasUsed] - The amount of gas used by the transaction (null if pending)
  /// 
  /// Throws an exception if the transaction hash is invalid or network error occurs
  Future<TransactionStatus> checkTransactionStatus({
    required String txHash,
    required String rpcUrl,
  }) async {
    try {
      logger("Checking transaction status for: $txHash", runtimeType.toString());
      Web3Client webClient = await ClientResolver.resolveClient(rpcUrl: rpcUrl);
      
      // Get transaction receipt
      TransactionReceipt? receipt = await webClient.getTransactionReceipt(txHash);

      if (receipt == null) {
        // Transaction is still pending
        logger("Transaction $txHash is still pending", runtimeType.toString());
        return TransactionStatus(
          isSuccess: false,
          isPending: true,
          blockNumber: null,
          gasUsed: null,
          txHash: txHash,
        );
      }else{
        // Transaction has been mined, check status
        // Status 1 = success, Status 0 = failed
        bool isSuccess = receipt.status == true;
        logger("Transaction $txHash status: ${isSuccess ? 'SUCCESS' : 'FAILED'}", runtimeType.toString());
        if(receipt.status==true){
          // Convert BlockNum to int
          int? blockNum;
          try {
            // BlockNum can be converted to string and parsed
            blockNum = int.tryParse(receipt.blockNumber.toString());
          } catch (e) {
            logger("Error parsing block number: $e", runtimeType.toString());
          }
          logger("Block number: $blockNum", runtimeType.toString());

          return TransactionStatus(
            isSuccess: true,
            isPending: false,
            blockNumber: blockNum,
            gasUsed: receipt.gasUsed,
            txHash: txHash,
          );
        }else{
          logger("Transaction $txHash is false", runtimeType.toString());
          return TransactionStatus(
            isSuccess: false,
            isPending: false,
            blockNumber: null,
            gasUsed: null,
            txHash: txHash,
          );
        }
      }

    } catch (e) {
      logger("Error checking transaction status: $e", runtimeType.toString());
      throw Exception("An error occurred while checking transaction status: $e");
    }
  }

  /// Waits for a transaction to be confirmed and returns its status
  /// 
  /// [txHash] - The transaction hash to check
  /// [rpcUrl] - The RPC URL of the network where the transaction was sent
  /// [maxWaitTime] - Maximum time to wait in seconds (default: 60 seconds)
  /// [pollInterval] - Interval between checks in seconds (default: 2 seconds)
  /// 
  /// Returns a [TransactionStatus] object when the transaction is confirmed
  /// Throws an exception if maxWaitTime is exceeded or network error occurs
  Future<TransactionStatus> waitForTransactionConfirmation({
    required String txHash,
    required String rpcUrl,
    int maxWaitTime = 60,
    int pollInterval = 2,
  }) async {
    try {
      logger("Waiting for transaction confirmation: $txHash", runtimeType.toString());
      final startTime = DateTime.now();
      
      while (true) {
        final status = await checkTransactionStatus(txHash: txHash, rpcUrl: rpcUrl);
        
        if (!status.isPending) {
          // Transaction has been confirmed (success or failed)
          return status;
        }
        
        // Check if max wait time exceeded
        final elapsed = DateTime.now().difference(startTime).inSeconds;
        if (elapsed >= maxWaitTime) {
          logger("Max wait time exceeded for transaction: $txHash", runtimeType.toString());
          throw Exception("Transaction confirmation timeout after $maxWaitTime seconds");
        }
        
        // Wait before next check
        await Future.delayed(Duration(seconds: pollInterval));
      }
    } catch (e) {
      logger("Error waiting for transaction confirmation: $e", runtimeType.toString());
      rethrow;
    }
  }
}

/// Represents the status of a blockchain transaction
class TransactionStatus {
  final bool isSuccess;
  final bool isPending;
  final int? blockNumber;
  final BigInt? gasUsed;
  final String txHash;

  TransactionStatus({
    required this.isSuccess,
    required this.isPending,
    required this.blockNumber,
    required this.gasUsed,
    required this.txHash,
  });

  @override
  String toString() {
    if (isPending) {
      return 'TransactionStatus(pending: true, txHash: $txHash)';
    }
    return 'TransactionStatus(success: $isSuccess, blockNumber: $blockNumber, gasUsed: $gasUsed, txHash: $txHash)';
  }
}