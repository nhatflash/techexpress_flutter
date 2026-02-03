import 'package:techexpress_flutter/models/product_spec_value.dart';

class Product {
  final String id;
  final String name;
  final String sku;
  final String categoryId;
  final String categoryName;
  final double price;
  final int stock;
  final String status;
  final String description;
  final List<String>? thumbnailUrl;
  final String? firstImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductSpecValue> specValues;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.stock,
    required this.status,
    required this.description,
    this.thumbnailUrl,
    this.firstImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.specValues
  });

  factory Product.fromDetailsJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'], 
      name: json['name'], 
      sku: json['sku'], 
      categoryId: json['categoryId'], 
      categoryName: json['categoryName'], 
      price: json['price'], 
      stock: json['stockQty'], 
      status: json['status'], 
      description: json['description'], 
      thumbnailUrl: json['thumbnailUrl'], 
      createdAt: DateTime.parse(json['createdAt']), 
      updatedAt: DateTime.parse(json['updatedAt']), 
      specValues: json['specValues']
    );
  }

  factory Product.fromListJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      price: json['price'],
      stock: json['stockQty'],
      status: json['status'],
      description: json['description'],
      firstImageUrl: json['firstImageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      specValues: []
    );
  }


}
