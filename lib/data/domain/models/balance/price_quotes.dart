// To parse this JSON data, do
//
//     final priceQuote = priceQuoteFromJson(jsonString);

import 'dart:convert';

List<PriceQuote> priceQuoteFromJson(String str) => List<PriceQuote>.from(json.decode(str).map((x) => PriceQuote.fromJson(x)));

String priceQuoteToJson(List<PriceQuote> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PriceQuote {
  int? id;
  String? name;
  String? symbol;
  String? slug;
  int? numMarketPairs;
  DateTime? dateAdded;
  List<Tag>? tags;
  dynamic maxSupply;
  double? circulatingSupply;
  double? totalSupply;
  int? isActive;
  bool? infiniteSupply;
  dynamic platform;
  int? cmcRank;
  int? isFiat;
  dynamic selfReportedCirculatingSupply;
  dynamic selfReportedMarketCap;
  dynamic tvlRatio;
  DateTime? lastUpdated;
  Quote? quote;

  PriceQuote({
    this.id,
    this.name,
    this.symbol,
    this.slug,
    this.numMarketPairs,
    this.dateAdded,
    this.tags,
    this.maxSupply,
    this.circulatingSupply,
    this.totalSupply,
    this.isActive,
    this.infiniteSupply,
    this.platform,
    this.cmcRank,
    this.isFiat,
    this.selfReportedCirculatingSupply,
    this.selfReportedMarketCap,
    this.tvlRatio,
    this.lastUpdated,
    this.quote,
  });

  factory PriceQuote.fromJson(Map<String, dynamic> json) => PriceQuote(
    id: json["id"],
    name: json["name"],
    symbol: json["symbol"],
    slug: json["slug"],
    numMarketPairs: json["num_market_pairs"],
    dateAdded: json["date_added"] == null ? null : DateTime.parse(json["date_added"]),
    tags: json["tags"] == null ? [] : List<Tag>.from(json["tags"]!.map((x) => Tag.fromJson(x))),
    maxSupply: json["max_supply"],
    circulatingSupply: json["circulating_supply"]?.toDouble(),
    totalSupply: json["total_supply"]?.toDouble(),
    isActive: json["is_active"],
    infiniteSupply: json["infinite_supply"],
    platform: json["platform"],
    cmcRank: json["cmc_rank"],
    isFiat: json["is_fiat"],
    selfReportedCirculatingSupply: json["self_reported_circulating_supply"],
    selfReportedMarketCap: json["self_reported_market_cap"],
    tvlRatio: json["tvl_ratio"],
    lastUpdated: json["last_updated"] == null ? null : DateTime.parse(json["last_updated"]),
    quote: json["quote"] == null ? null : Quote.fromJson(json["quote"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "symbol": symbol,
    "slug": slug,
    "num_market_pairs": numMarketPairs,
    "date_added": dateAdded?.toIso8601String(),
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x.toJson())),
    "max_supply": maxSupply,
    "circulating_supply": circulatingSupply,
    "total_supply": totalSupply,
    "is_active": isActive,
    "infinite_supply": infiniteSupply,
    "platform": platform,
    "cmc_rank": cmcRank,
    "is_fiat": isFiat,
    "self_reported_circulating_supply": selfReportedCirculatingSupply,
    "self_reported_market_cap": selfReportedMarketCap,
    "tvl_ratio": tvlRatio,
    "last_updated": lastUpdated?.toIso8601String(),
    "quote": quote?.toJson(),
  };
}

class Quote {
  Usd? usd;

  Quote({
    this.usd,
  });

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    usd: json["USD"] == null ? null : Usd.fromJson(json["USD"]),
  );

  Map<String, dynamic> toJson() => {
    "USD": usd?.toJson(),
  };
}

class Usd {
  double? price;
  double? volume24H;
  double? volumeChange24H;
  double? percentChange1H;
  double? percentChange24H;
  double? percentChange7D;
  double? percentChange30D;
  double? percentChange60D;
  double? percentChange90D;
  double? marketCap;
  double? marketCapDominance;
  double? fullyDilutedMarketCap;
  dynamic tvl;
  DateTime? lastUpdated;

  Usd({
    this.price,
    this.volume24H,
    this.volumeChange24H,
    this.percentChange1H,
    this.percentChange24H,
    this.percentChange7D,
    this.percentChange30D,
    this.percentChange60D,
    this.percentChange90D,
    this.marketCap,
    this.marketCapDominance,
    this.fullyDilutedMarketCap,
    this.tvl,
    this.lastUpdated,
  });

  factory Usd.fromJson(Map<String, dynamic> json) => Usd(
    price: json["price"]?.toDouble(),
    volume24H: json["volume_24h"]?.toDouble(),
    volumeChange24H: json["volume_change_24h"]?.toDouble(),
    percentChange1H: json["percent_change_1h"]?.toDouble(),
    percentChange24H: json["percent_change_24h"]?.toDouble(),
    percentChange7D: json["percent_change_7d"]?.toDouble(),
    percentChange30D: json["percent_change_30d"]?.toDouble(),
    percentChange60D: json["percent_change_60d"]?.toDouble(),
    percentChange90D: json["percent_change_90d"]?.toDouble(),
    marketCap: json["market_cap"]?.toDouble(),
    marketCapDominance: json["market_cap_dominance"]?.toDouble(),
    fullyDilutedMarketCap: json["fully_diluted_market_cap"]?.toDouble(),
    tvl: json["tvl"],
    lastUpdated: json["last_updated"] == null ? null : DateTime.parse(json["last_updated"]),
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "volume_24h": volume24H,
    "volume_change_24h": volumeChange24H,
    "percent_change_1h": percentChange1H,
    "percent_change_24h": percentChange24H,
    "percent_change_7d": percentChange7D,
    "percent_change_30d": percentChange30D,
    "percent_change_60d": percentChange60D,
    "percent_change_90d": percentChange90D,
    "market_cap": marketCap,
    "market_cap_dominance": marketCapDominance,
    "fully_diluted_market_cap": fullyDilutedMarketCap,
    "tvl": tvl,
    "last_updated": lastUpdated?.toIso8601String(),
  };
}

class Tag {
  String? slug;
  String? name;
  String? category;

  Tag({
    this.slug,
    this.name,
    this.category,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
    slug: json["slug"],
    name: json["name"],
    category: json["category"],
  );

  Map<String, dynamic> toJson() => {
    "slug": slug,
    "name": name,
    "category": category,
  };
}
