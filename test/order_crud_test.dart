import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:uts_2415051045_rendiwijakusuma/models/order_model.dart';
import 'package:uts_2415051045_rendiwijakusuma/providers/order_provider.dart';
import 'package:uts_2415051045_rendiwijakusuma/screens/edit_order_screen.dart';
import 'package:uts_2415051045_rendiwijakusuma/screens/order_history_screen.dart';
import 'package:uts_2415051045_rendiwijakusuma/services/supabase_service.dart';

class MockCrudSupabaseService extends SupabaseService {
  final List<OrderModel> orders = [];

  MockCrudSupabaseService(List<OrderModel> initialOrders) {
    orders.addAll(initialOrders);
  }

  @override
  Future<List<OrderModel>> fetchOrders() async {
    return List.from(orders);
  }

  @override
  Future<void> updateOrder(String id, Map<String, dynamic> data) async {
    final idx = orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      orders[idx] = orders[idx].copyWith(
        deliveryAddress: data['delivery_address'] as String?,
        notes: data['notes'] as String?,
      );
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    orders.removeWhere((o) => o.id == id);
  }
}

void main() {
  late MockCrudSupabaseService mockService;
  late OrderProvider provider;
  late OrderModel sampleOrder;

  setUp(() {
    sampleOrder = OrderModel(
      id: 'ORDER-123',
      customerName: 'Rendi Test',
      customerPhone: '081234567890',
      productName: 'Daging Ayam Broiler Segar',
      category: 'Daging Unggas',
      quantity: 2,
      orderType: 'direct',
      deliveryAddress: 'Jl. Ahmad Yani No. 10 Singaraja',
      deliveryDate: DateTime(2026, 11, 15),
      notes: 'Bungkus rapi',
      totalPrice: 72000,
      status: 'Pending',
    );

    mockService = MockCrudSupabaseService([sampleOrder]);
    provider = OrderProvider(supabaseService: mockService);
  });

  Widget buildTestableWidget(Widget child) {
    return ChangeNotifierProvider<OrderProvider>.value(
      value: provider,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Order CRUD Screens (Edit & History) Tests', () {
    testWidgets('OrderHistoryScreen displays order details and chip', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OrderHistoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Daging Ayam Broiler Segar'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Rp 72000'), findsOneWidget);
      expect(find.textContaining('Jl. Ahmad Yani'), findsOneWidget);
    });

    testWidgets('Canceling order triggers confirmation AlertDialog before deletion', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OrderHistoryScreen()));
      await tester.pumpAndSettle();

      // Tap Batal button on card
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Verify AlertDialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Batalkan Pesanan?'), findsOneWidget);

      // Confirm cancellation
      await tester.tap(find.text('Ya, Batalkan'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify SnackBar feedback
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('berhasil dibatalkan'), findsOneWidget);

      // Verify empty state is now displayed
      expect(find.text('Belum Ada Pesanan'), findsOneWidget);
      expect(mockService.orders, isEmpty);
    });

    testWidgets('EditOrderScreen pre-fills data and successfully updates', (tester) async {
      await tester.pumpWidget(buildTestableWidget(EditOrderScreen(order: sampleOrder)));
      await tester.pumpAndSettle();

      expect(find.text('Ubah Detail Pesanan'), findsOneWidget);
      expect(find.text('Jl. Ahmad Yani No. 10 Singaraja'), findsOneWidget);

      // Change address
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Alamat Lengkap Pengiriman *'),
        'Jl. Gajah Mada No. 88 Singaraja Baru',
      );

      // Tap Simpan
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(mockService.orders.first.deliveryAddress, 'Jl. Gajah Mada No. 88 Singaraja Baru');
      expect(find.textContaining('berhasil diperbarui'), findsOneWidget);
    });
  });
}

