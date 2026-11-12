import '../models/order_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

class FarmRepository {
  final ApiService _apiService;
  final SupabaseService _supabaseService;

  FarmRepository({ApiService? apiService, SupabaseService? supabaseService})
    : _apiService = apiService ?? ApiService(),
      _supabaseService = supabaseService ?? SupabaseService();

  Future<List<ProductModel>> getCatalogProducts() {
    return _apiService.fetchProducts();
  }

  Future<List<OrderModel>> getOrderHistory() {
    return _supabaseService.fetchOrders();
  }

  Future<void> submitOrder(OrderModel order) {
    return _supabaseService.createOrder(order);
  }

  Future<void> modifyOrder(String id, Map<String, dynamic> data) {
    return _supabaseService.updateOrder(id, data);
  }

  Future<void> removeOrder(String id) {
    return _supabaseService.deleteOrder(id);
  }
}
