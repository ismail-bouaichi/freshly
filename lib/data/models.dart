import 'package:flutter/painting.dart';

import '../core/produce.dart';
import '../core/theme.dart';

enum Category {
  fruits('Fruits', Produce.apple),
  veggies('Veggies', Produce.carrot),
  herbs('Herbs', Produce.basil),
  exotic('Exotic', Produce.avocado);

  const Category(this.label, this.art);
  final String label;
  final Produce art;
}

enum Tag {
  organic('Organic'),
  local('Local farms'),
  seasonal('Seasonal'),
  sale('On sale'),
  pesticideFree('Pesticide-free');

  const Tag(this.label);
  final String label;
}

enum SortBy {
  popular('Most popular'),
  priceLow('Price: low to high'),
  priceHigh('Price: high to low');

  const SortBy(this.label);
  final String label;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    this.oldPrice,
    required this.art,
    required this.tint,
    required this.categories,
    this.tags = const {},
    this.rating = 4.8,
    this.reviews = '1.2k',
    this.kcal = 40,
    this.water = '85%',
    this.vitamin = 'Vit C',
    this.picked = 'Today',
    required this.description,
    this.keywords = const [],
    this.popularity = 50,
  });

  final String id;
  final String name;
  final String unit;
  final double price;
  final double? oldPrice;
  final Produce art;
  final Color tint;
  final Set<Category> categories;
  final Set<Tag> tags;
  final double rating;
  final String reviews;
  final int kcal;
  final String water;
  final String vitamin;
  final String picked;
  final String description;
  final List<String> keywords;
  final int popularity;

  bool matches(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return true;
    return name.toLowerCase().contains(s) || keywords.any((k) => k.contains(s));
  }
}

class Address {
  const Address({required this.id, required this.label, required this.lines, required this.icon, required this.tint, required this.color});
  final String id;
  final String label;
  final String lines;
  final String icon; // home | work | heart
  final Color tint;
  final Color color;
}

enum OrderStatus { packing, onTheWay, delivered }

class Order {
  const Order({required this.id, required this.items, required this.total, required this.status, required this.when});
  final String id;
  final List<Product> items;
  final double total;
  final OrderStatus status;
  final String when;
}

class Basket {
  const Basket({required this.name, required this.note, required this.items});
  final String name;
  final String note;
  final Map<String, int> items;
}

String money(double v) => '\$${v.toStringAsFixed(2)}';

const tintCycle = [
  AppColors.tintBerry,
  AppColors.tintLime,
  AppColors.tintOrange,
  AppColors.tintMint,
  AppColors.tintLemon,
  AppColors.tintLeaf,
];
