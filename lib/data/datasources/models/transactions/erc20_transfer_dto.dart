class Erc20TransferDto {
  String? tokenName;
  String? tokenSymbol;
  String? tokenLogo;
  String? tokenDecimals;
  String? fromAddressEntity;
  String? fromAddressEntityLogo;
  String? fromAddress;
  String? fromAddressLabel;
  String? toAddressEntity;
  String? toAddressEntityLogo;
  String? toAddress;
  String? toAddressLabel;
  String? address;
  String? blockHash;
  String? blockNumber;
  String? blockTimestamp;
  String? transactionHash;
  String? transactionIndex;
  String? logIndex;
  String? value;
  bool? possibleSpam;
  String? valueDecimal;
  bool? verifiedContract;
  String? securityScore;

  Erc20TransferDto({
    this.tokenName,
    this.tokenSymbol,
    this.tokenLogo,
    this.tokenDecimals,
    this.fromAddressEntity,
    this.fromAddressEntityLogo,
    this.fromAddress,
    this.fromAddressLabel,
    this.toAddressEntity,
    this.toAddressEntityLogo,
    this.toAddress,
    this.toAddressLabel,
    this.address,
    this.blockHash,
    this.blockNumber,
    this.blockTimestamp,
    this.transactionHash,
    this.transactionIndex,
    this.logIndex,
    this.value,
    this.possibleSpam,
    this.valueDecimal,
    this.verifiedContract,
    this.securityScore,
  });

  factory Erc20TransferDto.fromJson(Map<String, dynamic> json) {
    return Erc20TransferDto(
      tokenName: json['token_name']?.toString(),
      tokenSymbol: json['token_symbol']?.toString(),
      tokenLogo: json['token_logo']?.toString(),
      tokenDecimals: json['token_decimals']?.toString(),
      fromAddressEntity: json['from_address_entity']?.toString(),
      fromAddressEntityLogo: json['from_address_entity_logo']?.toString(),
      fromAddress: json['from_address']?.toString(),
      fromAddressLabel: json['from_address_label']?.toString(),
      toAddressEntity: json['to_address_entity']?.toString(),
      toAddressEntityLogo: json['to_address_entity_logo']?.toString(),
      toAddress: json['to_address']?.toString(),
      toAddressLabel: json['to_address_label']?.toString(),
      address: json['address']?.toString(),
      blockHash: json['block_hash']?.toString(),
      blockNumber: json['block_number']?.toString(),
      blockTimestamp: json['block_timestamp']?.toString(),
      transactionHash: json['transaction_hash']?.toString(),
      transactionIndex: json['transaction_index']?.toString(),
      logIndex: json['log_index']?.toString(),
      value: json['value']?.toString(),
      possibleSpam: json['possible_spam'],
      valueDecimal: json['value_decimal']?.toString(),
      verifiedContract: json['verified_contract'],
      securityScore: json['security_score']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token_name': tokenName,
      'token_symbol': tokenSymbol,
      'token_logo': tokenLogo,
      'token_decimals': tokenDecimals,
      'from_address_entity': fromAddressEntity,
      'from_address_entity_logo': fromAddressEntityLogo,
      'from_address': fromAddress,
      'from_address_label': fromAddressLabel,
      'to_address_entity': toAddressEntity,
      'to_address_entity_logo': toAddressEntityLogo,
      'to_address': toAddress,
      'to_address_label': toAddressLabel,
      'address': address,
      'block_hash': blockHash,
      'block_number': blockNumber,
      'block_timestamp': blockTimestamp,
      'transaction_hash': transactionHash,
      'transaction_index': transactionIndex,
      'log_index': logIndex,
      'value': value,
      'possible_spam': possibleSpam,
      'value_decimal': valueDecimal,
      'verified_contract': verifiedContract,
      'security_score': securityScore,
    };
  }

  Erc20TransferDto copyWith({
    String? tokenName,
    String? tokenSymbol,
    String? tokenLogo,
    String? tokenDecimals,
    String? fromAddressEntity,
    String? fromAddressEntityLogo,
    String? fromAddress,
    String? fromAddressLabel,
    String? toAddressEntity,
    String? toAddressEntityLogo,
    String? toAddress,
    String? toAddressLabel,
    String? address,
    String? blockHash,
    String? blockNumber,
    String? blockTimestamp,
    String? transactionHash,
    String? transactionIndex,
    String? logIndex,
    String? value,
    bool? possibleSpam,
    String? valueDecimal,
    bool? verifiedContract,
    String? securityScore,
  }) {
    return Erc20TransferDto(
      tokenName: tokenName ?? this.tokenName,
      tokenSymbol: tokenSymbol ?? this.tokenSymbol,
      tokenLogo: tokenLogo ?? this.tokenLogo,
      tokenDecimals: tokenDecimals ?? this.tokenDecimals,
      fromAddressEntity: fromAddressEntity ?? this.fromAddressEntity,
      fromAddressEntityLogo: fromAddressEntityLogo ?? this.fromAddressEntityLogo,
      fromAddress: fromAddress ?? this.fromAddress,
      fromAddressLabel: fromAddressLabel ?? this.fromAddressLabel,
      toAddressEntity: toAddressEntity ?? this.toAddressEntity,
      toAddressEntityLogo: toAddressEntityLogo ?? this.toAddressEntityLogo,
      toAddress: toAddress ?? this.toAddress,
      toAddressLabel: toAddressLabel ?? this.toAddressLabel,
      address: address ?? this.address,
      blockHash: blockHash ?? this.blockHash,
      blockNumber: blockNumber ?? this.blockNumber,
      blockTimestamp: blockTimestamp ?? this.blockTimestamp,
      transactionHash: transactionHash ?? this.transactionHash,
      transactionIndex: transactionIndex ?? this.transactionIndex,
      logIndex: logIndex ?? this.logIndex,
      value: value ?? this.value,
      possibleSpam: possibleSpam ?? this.possibleSpam,
      valueDecimal: valueDecimal ?? this.valueDecimal,
      verifiedContract: verifiedContract ?? this.verifiedContract,
      securityScore: securityScore ?? this.securityScore,
    );
  }
}
