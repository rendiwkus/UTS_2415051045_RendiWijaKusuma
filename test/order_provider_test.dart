import 'package:flutter_test/flutter_test.dart';
import 'package:uts_2415051045_rendiwijakusuma/models/product_model.dart';
import 'package:uts_2415051045_rendiwijakusuma/providers/order_provider.dart';
import 'package:uts_2415051045_rendiwijakusuma/repositories/product_repository.dart';
import 'package:uts_2415051045_rendiwijakusuma/services/api_service.dart';

class MockFailingRepository extends ProductRepository {
  @override
  Future<List<ProductModel>> getProducts() async {
    throw Exception('Connection failed');
  }
}

class MockSuccessfulRepository extends ProductRepository {
  final List<ProductModel> mockList;

  MockSuccessfulRepository(this.mockList);

  @override
  Future<List<ProductModel>> getProducts() async {
    return mockList;
  }
}

void main() {
  group('ApiService Tests', () {
    test('ApiService returns default mock products when network is unreachable', () async {
      final service = ApiService();
      final products = await service.fetchProducts();

      expect(products, isNotEmpty);
      expect(products.any((p) => p.category.toLowerCase() == 'sayuran'), isFalse);
      expect(products.any((p) => p.category == 'Daging Unggas'), isTrue);
    });
  });

  group('OrderProvider State Management Tests', () {
    late List<ProductModel> sampleData;

    setUp(() {
      final now = DateTime.now();
      sampleData = [
        ProductModel(
          id: '1',
          name: 'Ayam Segar',
          category: 'Daging Unggas',
          price: 35000,
          stockAvailable: 10,
          isPreOrder: false,
          processedAt: now,
          maxFreshDays: 2,
          imageUrl: '',
        ),
        ProductModel(
          id: '2',
          name: 'Sapi Wagyu',
          category: 'Daging Merah',
          price: 150000,
          stockAvailable: 5,
          isPreOrder: true,
          processedAt: now,
          maxFreshDays: 3,
          imageUrl: '',
        ),
        ProductModel(
          id: '3',
          name: 'Beras Pandan Wangi',
          category: 'Sembako',
          price: 65000,
          stockAvailable: 20,
          isPreOrder: false,
          processedAt: now,
          maxFreshDays: 180,
          imageUrl: '',
        ),
      ];
    });

    test('Initial state is correct', () {
      final provider = OrderProvider();
      expect(provider.products, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.selectedCategory, 'All');
      expect(provider.searchQuery, '');
    });

    test('loadCatalog successfully populates products and manages isLoading state', () async {
      final provider = OrderProvider(
        repository: MockSuccessfulRepository(sampleData),
      );

      final future = provider.loadCatalog();
      expect(provider.isLoading, isTrue);

      await future;
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.products.length, 3);
      expect(provider.filteredProducts.length, 3);
    });

    test('loadCatalog handles error appropriately', () async {
      final provider = OrderProvider(
        repository: MockFailingRepository(),
      );

      await provider.loadCatalog();

      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, contains('Gagal memuat katalog pangan'));
      expect(provider.products, isEmpty);
    });

    test('Filter by category returns only matching category products', () async {
      final provider = OrderProvider(
        repository: MockSuccessfulRepository(sampleData),
      );
      await provider.loadCatalog();

      provider.setCategory('Daging Unggas');
      expect(provider.selectedCategory, 'Daging Unggas');
      expect(provider.filteredProducts.length, 1);
      expect(provider.filteredProducts.first.name, 'Ayam Segar');

      provider.setCategory('All');
      expect(provider.filteredProducts.length, 3);
    });

    test('Search query filters products by title case-insensitively', () async {
      final provider = OrderProvider(
        repository: MockSuccessfulRepository(sampleData),
      );
      await provider.loadCatalog();

      provider.setSearchQuery('wagyu');
      expect(provider.filteredProducts.length, 1);
      expect(provider.filteredProducts.first.name, 'Sapi Wagyu');

      provider.setSearchQuery('BERAS');
      expect(provider.filteredProducts.length, 1);
      expect(provider.filteredProducts.first.name, 'Beras Pandan Wangi');

      provider.setSearchQuery('nonexistent');
      expect(provider.filteredProducts, isEmpty);
    });

    test('Combined filter: Category and Search query', () async {
      final provider = OrderProvider(
        repository: MockSuccessfulRepository(sampleData),
      );
      await provider.loadCatalog();

      provider.setCategory('Daging Merah');
      provider.setSearchQuery('Ayam');
      // Should be empty because Ayam is Daging Unggas
      expect(provider.filteredProducts, isEmpty);

      provider.setSearchQuery('Sapi');
      expect(provider.filteredProducts.length, 1);
      expect(provider.filteredProducts.first.name, 'Sapi Wagyu');
    });
  });
}

