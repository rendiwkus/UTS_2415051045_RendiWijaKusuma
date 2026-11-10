import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  final http.Client _client;

  // Endpoint REST API untuk katalog produk
  static const String apiUrl = 'https://api.mockfly.dev/mocks/96f502b8/refarm/products';

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data katalog produk via REST API HTTP GET.
  /// Mengonversi payload JSON menjadi `List<ProductModel>`.
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _client.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> list = decoded is List ? decoded : (decoded['products'] ?? []);
        final products = list
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            // Menegakkan aturan domain PRD 2.1: Kategori 'Sayuran' wajib ditiadakan
            .where((p) => p.category.toLowerCase() != 'sayuran')
            .toList();

        if (products.isNotEmpty) {
          return products;
        }
        return getMockProducts();
      } else {
        // Fallback jika response non-200
        return getMockProducts();
      }
    } catch (_) {
      // Fallback aman jika offline atau timeout
      return getMockProducts();
    }
  }

  /// Data katalog default terstruktur sesuai spesifikasi PRD Fase 1
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
