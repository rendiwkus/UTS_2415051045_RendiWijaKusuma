import 'package:flutter_test/flutter_test.dart';
import 'package:uts_2415051045_rendiwijakusuma/models/product_model.dart';

void main() {
  group('ProductModel Freshness Estimation Engine Tests', () {
    test('Category Sembako always returns "Tahan Lama"', () {
      final sembako = ProductModel(
        id: 'S01',
        name: 'Beras Premium',
        category: 'Sembako',
        price: 70000,
        stockAvailable: 100,
        isPreOrder: false,
        processedAt: DateTime.now().subtract(const Duration(days: 30)),
        maxFreshDays: 180,
        imageUrl: '',
      );

      expect(sembako.freshnessStatus, 'Tahan Lama');
    });

    test('Freshly cut protein (> 0.75) returns "Sangat Segar (Fresh Cut/Harvested)"', () {
      final now = DateTime.now();
      // 2 days max fresh = 48 hours. Processed 4 hours ago.
      // (48 - 4) / 48 = 44 / 48 = 0.916 (> 0.75)
      final ayam = ProductModel(
        id: 'A01',
        name: 'Daging Ayam',
        category: 'Daging Unggas',
        price: 36000,
        stockAvailable: 20,
        isPreOrder: false,
        processedAt: now.subtract(const Duration(hours: 4)),
        maxFreshDays: 2,
        imageUrl: '',
      );

      expect(ayam.freshnessPercentage, greaterThan(0.75));
      expect(ayam.freshnessStatus, 'Sangat Segar (Fresh Cut/Harvested)');
    });

    test('Chilled protein (0.40 < pct <= 0.75) returns "Kondisi Baik (Chilled Storage)"', () {
      final now = DateTime.now();
      // 3 days max fresh = 72 hours. Processed 36 hours ago.
      // (72 - 36) / 72 = 0.50 (between 0.40 and 0.75)
      final sapi = ProductModel(
        id: 'B01',
        name: 'Daging Sapi',
        category: 'Daging Merah',
        price: 130000,
        stockAvailable: 10,
        isPreOrder: false,
        processedAt: now.subtract(const Duration(hours: 36)),
        maxFreshDays: 3,
        imageUrl: '',
      );

      expect(sapi.freshnessPercentage, greaterThan(0.40));
      expect(sapi.freshnessPercentage, lessThanOrEqualTo(0.75));
      expect(sapi.freshnessStatus, 'Kondisi Baik (Chilled Storage)');
    });

    test('Aging protein (pct <= 0.40) returns "Segera Dikonsumsi"', () {
      final now = DateTime.now();
      // 2 days max fresh = 48 hours. Processed 40 hours ago.
      // (48 - 40) / 48 = 8 / 48 = 0.166 (<= 0.40)
      final bebek = ProductModel(
        id: 'C01',
        name: 'Daging Bebek',
        category: 'Daging Unggas',
        price: 45000,
        stockAvailable: 5,
        isPreOrder: true,
        processedAt: now.subtract(const Duration(hours: 40)),
        maxFreshDays: 2,
        imageUrl: '',
      );

      expect(bebek.freshnessPercentage, lessThanOrEqualTo(0.40));
      expect(bebek.freshnessStatus, 'Segera Dikonsumsi');
    });

    test('Percentage is clamped to 0.0 when expired and 1.0 when newly processed', () {
      final now = DateTime.now();
      // Expired product
      final expired = ProductModel(
        id: 'E01',
        name: 'Expired Meat',
        category: 'Daging Merah',
        price: 50000,
        stockAvailable: 0,
        isPreOrder: false,
        processedAt: now.subtract(const Duration(days: 10)),
        maxFreshDays: 2,
        imageUrl: '',
      );
      expect(expired.freshnessPercentage, 0.0);

      // Just processed
      final fresh = ProductModel(
        id: 'F01',
        name: 'Instant Meat',
        category: 'Daging Merah',
        price: 50000,
        stockAvailable: 10,
        isPreOrder: false,
        processedAt: now,
        maxFreshDays: 2,
        imageUrl: '',
      );
      expect(fresh.freshnessPercentage, 1.0);
    });

    test('toJson and fromJson correctly serialize and deserialize ProductModel', () {
      final original = ProductModel(
        id: 'T01',
        name: 'Telur Ayam',
        category: 'Telur',
        price: 54000,
        stockAvailable: 30,
        isPreOrder: false,
        processedAt: DateTime(2026, 11, 10, 10, 0, 0),
        maxFreshDays: 14,
        imageUrl: 'https://example.com/egg.jpg',
      );

      final jsonMap = original.toJson();
      final reconstructed = ProductModel.fromJson(jsonMap);

      expect(reconstructed.id, original.id);
      expect(reconstructed.name, original.name);
      expect(reconstructed.category, original.category);
      expect(reconstructed.price, original.price);
      expect(reconstructed.stockAvailable, original.stockAvailable);
      expect(reconstructed.isPreOrder, original.isPreOrder);
      expect(reconstructed.maxFreshDays, original.maxFreshDays);
      expect(reconstructed.imageUrl, original.imageUrl);
    });
  });
}

