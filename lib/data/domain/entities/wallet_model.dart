class WalletModel {
  String? mnemonic;
  String? walletAddress;
  String? chainId;
  String? privateKey;
  String? name;
  String hash;
  WalletModel({
    this.mnemonic,
    required this.chainId,
    required this.walletAddress,
    this.privateKey,
    this.name,
    required this.hash,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    mnemonic: json['mnemonic'],
    walletAddress: json["wallet_address"],
    chainId: json["chain_id"],
    privateKey: json["private_key"],
    name: json["name"],
    hash:  json["hash"]
  );

  Map<String, dynamic> toJson() => {
    "mnemonic": mnemonic,
    "wallet_address": walletAddress,
    "chain_id": chainId,
    "private_key": privateKey,
    "name": name,
    "hash": hash
  };
}
