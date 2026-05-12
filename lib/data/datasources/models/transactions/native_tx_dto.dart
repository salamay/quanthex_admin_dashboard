class NativeTxDto {
  String? hash;
  String? nonce;
  String? transactionIndex;

  String? fromAddressEntity;
  String? fromAddressEntityLogo;
  String? fromAddress;
  String? fromAddressLabel;

  String? toAddressEntity;
  String? toAddressEntityLogo;
  String? toAddress;
  String? toAddressLabel;

  String? value;
  String? gas;
  String? gasPrice;
  String? input;

  String? receiptCumulativeGasUsed;
  String? receiptGasUsed;
  String? receiptContractAddress;
  String? receiptRoot;
  String? receiptStatus;

  String? blockTimestamp;
  String? blockNumber;
  String? blockHash;

  List<dynamic>? transferIndex;
  String? transactionFee;

  NativeTxDto({
    this.hash,
    this.nonce,
    this.transactionIndex,
    this.fromAddressEntity,
    this.fromAddressEntityLogo,
    this.fromAddress,
    this.fromAddressLabel,
    this.toAddressEntity,
    this.toAddressEntityLogo,
    this.toAddress,
    this.toAddressLabel,
    this.value,
    this.gas,
    this.gasPrice,
    this.input,
    this.receiptCumulativeGasUsed,
    this.receiptGasUsed,
    this.receiptContractAddress,
    this.receiptRoot,
    this.receiptStatus,
    this.blockTimestamp,
    this.blockNumber,
    this.blockHash,
    this.transferIndex,
    this.transactionFee,
  });

  factory NativeTxDto.fromJson(Map<String, dynamic> json) {
    return NativeTxDto(
      hash: json['hash']?.toString(),
      nonce: json['nonce']?.toString(),
      transactionIndex: json['transaction_index']?.toString(),
      fromAddressEntity: json['from_address_entity']?.toString(),
      fromAddressEntityLogo: json['from_address_entity_logo']?.toString(),
      fromAddress: json['from_address']?.toString(),
      fromAddressLabel: json['from_address_label']?.toString(),
      toAddressEntity: json['to_address_entity']?.toString(),
      toAddressEntityLogo: json['to_address_entity_logo']?.toString(),
      toAddress: json['to_address']?.toString(),
      toAddressLabel: json['to_address_label']?.toString(),
      value: json['value']?.toString(),
      gas: json['gas']?.toString(),
      gasPrice: json['gas_price']?.toString(),
      input: json['input']?.toString(),
      receiptCumulativeGasUsed: json['receipt_cumulative_gas_used']?.toString(),
      receiptGasUsed: json['receipt_gas_used']?.toString(),
      receiptContractAddress: json['receipt_contract_address']?.toString(),
      receiptRoot: json['receipt_root']?.toString(),
      receiptStatus: json['receipt_status']?.toString(),
      blockTimestamp: json['block_timestamp']?.toString(),
      blockNumber: json['block_number']?.toString(),
      blockHash: json['block_hash']?.toString(),
      transferIndex: json['transfer_index'],
      transactionFee: json['transaction_fee']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'nonce': nonce,
      'transaction_index': transactionIndex,
      'from_address_entity': fromAddressEntity,
      'from_address_entity_logo': fromAddressEntityLogo,
      'from_address': fromAddress,
      'from_address_label': fromAddressLabel,
      'to_address_entity': toAddressEntity,
      'to_address_entity_logo': toAddressEntityLogo,
      'to_address': toAddress,
      'to_address_label': toAddressLabel,
      'value': value,
      'gas': gas,
      'gas_price': gasPrice,
      'input': input,
      'receipt_cumulative_gas_used': receiptCumulativeGasUsed,
      'receipt_gas_used': receiptGasUsed,
      'receipt_contract_address': receiptContractAddress,
      'receipt_root': receiptRoot,
      'receipt_status': receiptStatus,
      'block_timestamp': blockTimestamp,
      'block_number': blockNumber,
      'block_hash': blockHash,
      'transfer_index': transferIndex,
      'transaction_fee': transactionFee,
    };
  }

  NativeTxDto copyWith({
    String? hash,
    String? nonce,
    String? transactionIndex,
    String? fromAddressEntity,
    String? fromAddressEntityLogo,
    String? fromAddress,
    String? fromAddressLabel,
    String? toAddressEntity,
    String? toAddressEntityLogo,
    String? toAddress,
    String? toAddressLabel,
    String? value,
    String? gas,
    String? gasPrice,
    String? input,
    String? receiptCumulativeGasUsed,
    String? receiptGasUsed,
    String? receiptContractAddress,
    String? receiptRoot,
    String? receiptStatus,
    String? blockTimestamp,
    String? blockNumber,
    String? blockHash,
    List<dynamic>? transferIndex,
    String? transactionFee,
  }) {
    return NativeTxDto(
      hash: hash ?? this.hash,
      nonce: nonce ?? this.nonce,
      transactionIndex: transactionIndex ?? this.transactionIndex,
      fromAddressEntity: fromAddressEntity ?? this.fromAddressEntity,
      fromAddressEntityLogo: fromAddressEntityLogo ?? this.fromAddressEntityLogo,
      fromAddress: fromAddress ?? this.fromAddress,
      fromAddressLabel: fromAddressLabel ?? this.fromAddressLabel,
      toAddressEntity: toAddressEntity ?? this.toAddressEntity,
      toAddressEntityLogo: toAddressEntityLogo ?? this.toAddressEntityLogo,
      toAddress: toAddress ?? this.toAddress,
      toAddressLabel: toAddressLabel ?? this.toAddressLabel,
      value: value ?? this.value,
      gas: gas ?? this.gas,
      gasPrice: gasPrice ?? this.gasPrice,
      input: input ?? this.input,
      receiptCumulativeGasUsed: receiptCumulativeGasUsed ?? this.receiptCumulativeGasUsed,
      receiptGasUsed: receiptGasUsed ?? this.receiptGasUsed,
      receiptContractAddress: receiptContractAddress ?? this.receiptContractAddress,
      receiptRoot: receiptRoot ?? this.receiptRoot,
      receiptStatus: receiptStatus ?? this.receiptStatus,
      blockTimestamp: blockTimestamp ?? this.blockTimestamp,
      blockNumber: blockNumber ?? this.blockNumber,
      blockHash: blockHash ?? this.blockHash,
      transferIndex: transferIndex ?? this.transferIndex,
      transactionFee: transactionFee ?? this.transactionFee,
    );
  }
}
