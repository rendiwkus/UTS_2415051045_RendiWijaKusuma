import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<ProductModel>> getProducts() async {
    return await _apiService.fetchProducts();
  }
}

