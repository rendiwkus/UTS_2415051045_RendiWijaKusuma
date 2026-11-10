import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

/// State Management untuk Katalog Pangan & Order REFARM AgroStore
/// Menggunakan ChangeNotifier sesuai spesifikasi PRD Fase 1 (Bagian 3.3)
class OrderProvider extends ChangeNotifier {
  final ProductRepository _repository;

  OrderProvider({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  // State Properties (PRD 3.3)
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Public Getters
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  /// Daftar produk yang sudah disaring berdasarkan kategori aktif dan kata kunci pencarian
  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'All' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = product.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Memuat data katalog produk dari repository / REST API
  Future<void> loadCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat katalog pangan: $e';
      notifyListeners();
    }
  }

  /// Memperbarui filter kategori yang dipilih ('All', 'Daging Unggas', dsb)
  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  /// Memperbarui kata kunci pencarian pada search bar
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }
}
