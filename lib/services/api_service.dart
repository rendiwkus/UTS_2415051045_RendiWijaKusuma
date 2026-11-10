import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.jsonbin.io/v3/b'; // Fallback or mock endpoint

  Future<List<ProductModel>> fetchProducts() async {
    try {
      // In initial setup/fase 1, if endpoint is unavailable or fails, fallback to structured mock data
      final response = await http.get(
        Uri.parse('$baseUrl/mock-products'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data is List ? data : (data['products'] ?? []);
        return list.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        return getMockProducts();
      }
    } catch (_) {
      // Return initial mock catalog ensuring 4 valid categories without 'Sayuran'
      return getMockProducts();
    }
  }

  List<ProductModel> getMockProducts() {
    final now = DateTime.now();
    return [
      ProductModel(
        id: 'P001',
        name: 'Daging Ayam Broiler Segar',
        category: 'Daging Unggas',
        price: 36000,
        stockAvailable: 25,
        isPreOrder: false,
        processedAt: now.subtract(const Duration(hours: 4)),
        maxFreshDays: 2,
        imageUrl: 'https://images.unsplash.com/photo-1587593810167-a84920ea0781',
      ),
      ProductModel(
        id: 'P002',
        name: 'Daging Bebek Potong',
        category: 'Daging Unggas',
        price: 52000,
        stockAvailable: 10,
        isPreOrder: true,
        processedAt: now.subtract(const Duration(hours: 12)),
        maxFreshDays: 2,
        imageUrl: 'https://images.unsplash.com/photo-1516684732162-798a0062be99',
      ),
      ProductModel(
        id: 'P003',
        name: 'Daging Sapi Sirloin Segar',
        category: 'Daging Merah',
        price: 135000,
        stockAvailable: 15,
        isPreOrder: false,
        processedAt: now.subtract(const Duration(hours: 18)),
        maxFreshDays: 3,
        imageUrl: 'https://images.unsplash.com/photo-1603048588665-791ca8aea617',
      ),
      ProductModel(
        id: 'P004',
        name: 'Daging Kambing Muda',
        category: 'Daging Merah',
        price: 125000,
        stockAvailable: 8,
        isPreOrder: true,
        processedAt: now.subtract(const Duration(hours: 36)),
        maxFreshDays: 3,
        imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947',
      ),
      ProductModel(
        id: 'P005',
        name: 'Telur Ayam Negeri Fresh (1 Tray)',
        category: 'Telur',
        price: 54000,
        stockAvailable: 40,
        isPreOrder: false,
        processedAt: now.subtract(const Duration(days: 2)),
        maxFreshDays: 14,
        imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f',
      ),
      ProductModel(
        id: 'P006',
        name: 'Telur Bebek Asin Organik',
        category: 'Telur',
        price: 32000,
        stockAvailable: 20,
        isPreOrder: false,
        processedAt: now.subtract(const Duration(days: 3)),
        maxFreshDays: 20,
        imageUrl: 'https://images.unsplash.com/photo-1516467508483-a7212febe31a',
      ),
      ProductModel(
        id: 'P007',
        name: 'Beras Premium Rojolele 5kg',
        category: 'Sembako',
        price: 74000,
        stockAvailable: 50,
        isPreOrder: false,
        processedAt: now.subtract(const Duration(days: 10)),
        maxFreshDays: 180,
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c',
      ),
      ProductModel(
        id: 'P008',
        name: 'Minyak Goreng Sawit 2L',
        category: 'Sembako',
        price: 34000,
        stockAvailable: 35,
        isPreOrder: false,
        processedAt: now.subtract(const Duration(days: 15)),
        maxFreshDays: 365,
        imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5',
      ),
    ];
  }
}

