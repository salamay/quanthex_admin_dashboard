// To parse this JSON data, do
//
//     final platformData = platformDataFromJson(jsonString);

import 'dart:convert';

List<PlatformData> platformDataFromJson(String str) => List<PlatformData>.from(json.decode(str).map((x) => PlatformData.fromJson(x)));

String platformDataToJson(List<PlatformData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PlatformData {
  String? id;
  int? chainIdentifier;
  String? name;
  String? shortname;
  String? nativeCoinId;
  Image? image;

  PlatformData({
    this.id,
    this.chainIdentifier,
    this.name,
    this.shortname,
    this.nativeCoinId,
    this.image,
  });

  factory PlatformData.fromJson(Map<String, dynamic> json) => PlatformData(
    id: json["id"],
    chainIdentifier: json["chain_identifier"],
    name: json["name"],
    shortname: json["shortname"],
    nativeCoinId: json["native_coin_id"],
    image: json["image"] == null ? null : Image.fromJson(json["image"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "chain_identifier": chainIdentifier,
    "name": name,
    "shortname": shortname,
    "native_coin_id": nativeCoinId,
    "image": image?.toJson(),
  };
}

class Image {
  String? thumb;
  String? small;
  String? large;

  Image({
    this.thumb,
    this.small,
    this.large,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
    thumb: json["thumb"],
    small: json["small"],
    large: json["large"],
  );

  Map<String, dynamic> toJson() => {
    "thumb": thumb,
    "small": small,
    "large": large,
  };
}
