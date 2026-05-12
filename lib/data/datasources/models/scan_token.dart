
// To parse this JSON data, do
//
//     final scannedToken = scannedTokenFromJson(jsonString);

import 'dart:convert';

List<ScannedToken> scannedTokenFromJson(String str) => List<ScannedToken>.from(json.decode(str).map((x) => ScannedToken.fromJson(x)));

String scannedTokenToJson(List<ScannedToken> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ScannedToken {
  String? address;
  String? addressLabel;
  String? name;
  String? symbol;
  String? decimals;
  String? logo;
  dynamic logoHash;
  String? thumbnail;
  String? totalSupply;
  String? totalSupplyFormatted;
  String? fullyDilutedValuation;
  String? blockNumber;
  int? validated;
  DateTime? createdAt;
  bool? possibleSpam;
  bool? verifiedContract;
  List<String>? categories;
  Links? links;
  int? securityScore;
  String? marketCap;

  ScannedToken({
    this.address,
    this.addressLabel,
    this.name,
    this.symbol,
    this.decimals,
    this.logo,
    this.logoHash,
    this.thumbnail,
    this.totalSupply,
    this.totalSupplyFormatted,
    this.fullyDilutedValuation,
    this.blockNumber,
    this.validated,
    this.createdAt,
    this.possibleSpam,
    this.verifiedContract,
    this.categories,
    this.links,
    this.securityScore,
    this.marketCap
  });

  factory ScannedToken.fromJson(Map<String, dynamic> json) => ScannedToken(
    address: json["address"],
    addressLabel: json["address_label"],
    name: json["name"],
    symbol: json["symbol"],
    decimals: json["decimals"],
    logo: json["logo"],
    logoHash: json["logo_hash"],
    thumbnail: json["thumbnail"],
    totalSupply: json["total_supply"],
    totalSupplyFormatted: json["total_supply_formatted"],
    fullyDilutedValuation: json["fully_diluted_valuation"],
    blockNumber: json["block_number"],
    validated: json["validated"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    possibleSpam: json["possible_spam"],
    verifiedContract: json["verified_contract"],
    categories: json["categories"] == null ? [] : List<String>.from(json["categories"]!.map((x) => x)),
    links: json["links"] == null ? null : Links.fromJson(json["links"]),
    securityScore: json["security_score"],
    marketCap: json["market_cap"],
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "address_label": addressLabel,
    "name": name,
    "symbol": symbol,
    "decimals": decimals,
    "logo": logo,
    "logo_hash": logoHash,
    "thumbnail": thumbnail,
    "total_supply": totalSupply,
    "total_supply_formatted": totalSupplyFormatted,
    "fully_diluted_valuation": fullyDilutedValuation,
    "block_number": blockNumber,
    "validated": validated,
    "created_at": createdAt?.toIso8601String(),
    "possible_spam": possibleSpam,
    "verified_contract": verifiedContract,
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x)),
    "links": links?.toJson(),
    "security_score": securityScore,
    "market_cap": marketCap,
  };
}

class Links {
  String? reddit;
  String? website;
  String? github;

  Links({
    this.reddit,
    this.website,
    this.github,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    reddit: json["reddit"],
    website: json["website"],
    github: json["github"],
  );

  Map<String, dynamic> toJson() => {
    "reddit": reddit,
    "website": website,
    "github": github,
  };
}
