class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stockAvailable;
  final bool isPreOrder;
  final DateTime processedAt;
  final int maxFreshDays;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stockAvailable,
    required this.isPreOrder,
    required this.processedAt,
    required this.maxFreshDays,
    required this.imageUrl,
  });

  /// Freshness Estimation Engine Formula:
  /// Percentage = clamp(((maxFreshDays * 24) - hoursElapsed) / (maxFreshDays * 24), 0.0, 1.0)
  double get freshnessPercentage {
    final totalFreshHours = maxFreshDays * 24;
    if (totalFreshHours <= 0) return 0.0;
    final hoursElapsed = DateTime.now().difference(processedAt).inHours;
    final val = (totalFreshHours - hoursElapsed) / totalFreshHours;
    return val.clamp(0.0, 1.0);
  }

  /// Status label berdasarkan persentase kesegaran & kategori
  String get freshnessStatus {
    if (category == 'Sembako') {
      return 'Tahan Lama';
    }
    final pct = freshnessPercentage;
    if (pct > 0.75) {
      return 'Sangat Segar (Fresh Cut/Harvested)';
    } else if (pct > 0.40) {
      return 'Kondisi Baik (Chilled Storage)';
    } else {
      return 'Segera Dikonsumsi';
    }
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockAvailable: json['stockAvailable'] as int? ?? 0,
      isPreOrder: json['isPreOrder'] as bool? ?? false,
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : DateTime.now(),
      maxFreshDays: json['maxFreshDays'] as int? ?? 1,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stockAvailable': stockAvailable,
      'isPreOrder': isPreOrder,
      'processedAt': processedAt.toIso8601String(),
      'maxFreshDays': maxFreshDays,
      'imageUrl': imageUrl,
    };
  }
}

