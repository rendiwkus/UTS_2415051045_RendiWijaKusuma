import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../models/product_model.dart';
import '../repositories/farm_repository.dart';
import '../repositories/product_repository.dart';
import '../services/supabase_service.dart';

/// State Management untuk Katalog Pangan & Transaksi Supabase REFARM AgroStore
class OrderProvider extends ChangeNotifier {
  final FarmRepository _farmRepository;
  final ProductRepository? _legacyProductRepository;

  OrderProvider({
    FarmRepository? farmRepository,
    ProductRepository? repository,
    SupabaseService? supabaseService,
  }) : _farmRepository =
           farmRepository ?? FarmRepository(supabaseService: supabaseService),
       _legacyProductRepository = repository;

  // State Katalog Produk (Fase 1)
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // State Pesanan Database Supabase (Fase 2)
  List<OrderModel> _ordersList = [];
  bool _isLoadingOrders = false;
  bool _isSubmittingOrder = false;
  String? _orderErrorMessage;

  // Getters Katalog
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Getters Pesanan
  List<OrderModel> get ordersList => _ordersList;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isSubmittingOrder => _isSubmittingOrder;
  String? get orderErrorMessage => _orderErrorMessage;

  /// Daftar produk yang sudah disaring berdasarkan kategori aktif dan kata kunci pencarian
  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = product.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Memuat data katalog produk dari repository / REST API
  Future<void> loadCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = _legacyProductRepository == null
          ? await _farmRepository.getCatalogProducts()
          : await _legacyProductRepository.getProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat katalog pangan: $e';
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  // =========================================================================
  // Fitur Supabase Database CRUD (Fase 2)
  // =========================================================================

  /// Mengambil daftar pesanan dari tabel Supabase
  Future<void> fetchOrdersFromDatabase() async {
    _isLoadingOrders = true;
    _orderErrorMessage = null;
    notifyListeners();

    try {
      _ordersList = await _farmRepository.getOrderHistory();
      _isLoadingOrders = false;
      notifyListeners();
    } catch (e) {
      _isLoadingOrders = false;
      _orderErrorMessage = 'Gagal memuat riwayat pesanan: $e';
      notifyListeners();
    }
  }

  /// Membuat pesanan baru ke Supabase
  Future<bool> submitNewOrder(OrderModel order) async {
    _isSubmittingOrder = true;
    _orderErrorMessage = null;
    notifyListeners();

    try {
      await _farmRepository.submitOrder(order);
      // Sinkronisasi ulang data pesanan lokal
      try {
        _ordersList = await _farmRepository.getOrderHistory();
      } catch (_) {}
      _isSubmittingOrder = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmittingOrder = false;
      _orderErrorMessage = 'Gagal menyimpan pesanan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Memperbarui detail pesanan yang sudah ada (alamat, tanggal kirim, catatan)
  Future<bool> updateExistingOrder(
    String id,
    String newAddress,
    DateTime newDate,
    String? newNotes,
  ) async {
    _isLoadingOrders = true;
    _orderErrorMessage = null;
    notifyListeners();

    try {
      final formattedDate =
          "${newDate.year.toString().padLeft(4, '0')}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}";
      await _farmRepository.modifyOrder(id, {
        'delivery_address': newAddress,
        'delivery_date': formattedDate,
        'notes': newNotes,
      });

      // Update state lokal
      final index = _ordersList.indexWhere((o) => o.id == id);
      if (index != -1) {
        _ordersList[index] = _ordersList[index].copyWith(
          deliveryAddress: newAddress,
          deliveryDate: newDate,
          notes: newNotes,
        );
      }
      _isLoadingOrders = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingOrders = false;
      _orderErrorMessage = 'Gagal memperbarui pesanan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Membatalkan / menghapus pesanan berdasarkan ID
  Future<bool> cancelOrder(String id) async {
    _isLoadingOrders = true;
    _orderErrorMessage = null;
    notifyListeners();

    try {
      await _farmRepository.removeOrder(id);
      _ordersList.removeWhere((o) => o.id == id);
      _isLoadingOrders = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingOrders = false;
      _orderErrorMessage = 'Gagal membatalkan pesanan: $e';
      notifyListeners();
      return false;
    }
  }
}
