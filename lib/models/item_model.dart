import 'package:flutter/material.dart';

class ItemModel {
  final String id;
  final String itemId;  // Add this field
  final String uid;
  final String name;
  final String description;
  final String country;
  final String link;
  final List<String> quantities;
  final bool isReplacement;
  final String replacementDays;
  final String replacementUnit;
  final List<Color> colors;
  final List<String> sizes;
  bool hideItem;
  final String itemStatus;
  final List<String> imageUrls;
  final double mrp;  // Add this field
  final double sellingPrice;  // Add this field
  final String stockInfo;  // Add this field

  ItemModel({
    required this.id,
    required this.itemId,
    required this.uid,
    required this.name,
    required this.description,
    required this.country,
    required this.link,
    required this.quantities,
    required this.isReplacement,
    required this.replacementDays,
    required this.replacementUnit,
    required this.colors,
    required this.sizes,
    required this.hideItem,
    required this.itemStatus,
    required this.imageUrls,
    required this.mrp,  // Add this to the constructor
    required this.sellingPrice,  // Add this to the constructor
    required this.stockInfo,  // Add this to the constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId' :itemId,
      'uid' :uid,
      'name': name,
      'description': description,
      'country': country,
      'link': link,
      'quantities': quantities,
      'isReplacement': isReplacement,
      'replacementDays': replacementDays,
      'replacementUnit': replacementUnit,
      'colors': colors.map((c) => c.value.toRadixString(16)).toList(),
      'sizes': sizes,
      'hideItem': hideItem,
      'itemStatus': itemStatus,
      'imageUrls': imageUrls,
      'mrp': mrp,  // Add this to the map
      'sellingPrice': sellingPrice,  // Add this to the map
      'stockInfo': stockInfo,  // Add this to the map
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      itemId: map['itemId'],
      uid: map['uid'],
      name: map['name'],
      description: map['description'],
      country: map['country'],
      link: map['link'],
      quantities: List<String>.from(map['quantities']),
      isReplacement: map['isReplacement'],
      replacementDays: map['replacementDays'],
      replacementUnit: map['replacementUnit'],
      colors: (map['colors'] as List).map((c) => Color(int.parse(c, radix: 16))).toList(),
      sizes: List<String>.from(map['sizes']),
      hideItem: map['hideItem'],
      itemStatus: map['itemStatus'],
      imageUrls: List<String>.from(map['imageUrls']),
      mrp: map['mrp'].toDouble(),  // Add this, convert to double
      sellingPrice: map['sellingPrice'].toDouble(),  // Add this, convert to double
      stockInfo: map['stockInfo'],  // Add this
    );
  }
}

class Business {
  String name;
  String logoUrl;
  String category;
  String description;
  String storeTimings;
  String email;
  String website;
  String gstNumber;
  String businessRole;
  
  Business({
    required this.name,
    required this.logoUrl,
    required this.category,
    required this.description,
    required this.storeTimings,
    required this.email,
    required this.website,
    required this.gstNumber,
    required this.businessRole,
  });
}