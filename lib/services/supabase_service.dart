import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

/// Service layer untuk integrasi database Supabase PostgreSQL
class SupabaseService {
  final SupabaseClient? _customClient;

  SupabaseService({SupabaseClient? client}) : _customClient = client;

  SupabaseClient get _client => _customClient ?? Supabase.instance.client;

  static const String tableName = 'orders';

  /// Mengambil seluruh data pesanan dari tabel `orders` diurutkan berdasar `created_at DESC`
  Future<List<OrderModel>> fetchOrders() async {
    final response = await _client
        .from(tableName)
        .select()
        .order('created_at', ascending: false);

    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Menyimpan record pesanan baru ke tabel `orders`
  Future<void> createOrder(OrderModel order) async {
    await _client.from(tableName).insert(order.toJson());
  }

  /// Memperbarui record pesanan (alamat, tanggal kirim, catatan) berdasarkan `id`
  Future<void> updateOrder(String id, Map<String, dynamic> data) async {
    await _client.from(tableName).update(data).eq('id', id);
  }

  /// Menghapus pesanan berdasarkan `id`
  Future<void> deleteOrder(String id) async {
    await _client.from(tableName).delete().eq('id', id);
  }
}

