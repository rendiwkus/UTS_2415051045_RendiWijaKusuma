import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:uts_2415051045_rendiwijakusuma/models/order_model.dart';
import 'package:uts_2415051045_rendiwijakusuma/models/product_model.dart';
import 'package:uts_2415051045_rendiwijakusuma/providers/order_provider.dart';
import 'package:uts_2415051045_rendiwijakusuma/screens/checkout_screen.dart';
import 'package:uts_2415051045_rendiwijakusuma/services/supabase_service.dart';

class MockSupabaseService extends SupabaseService {
  final List<OrderModel> createdOrders = [];
  bool shouldFail = false;

  @override
  Future<void> createOrder(OrderModel order) async {
    if (shouldFail) {
      throw Exception('Database insertion error');
    }
    createdOrders.add(order);
  }

  @override
  Future<List<OrderModel>> fetchOrders() async {
    return createdOrders;
  }
}

void main() {
  late MockSupabaseService mockSupabaseService;
  late OrderProvider provider;
  late ProductModel preOrderProduct;
  late ProductModel directProduct;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    provider = OrderProvider(supabaseService: mockSupabaseService);

    final now = DateTime.now();
    preOrderProduct = ProductModel(
      id: 'PO-1',
      name: 'Daging Bebek Segar',
      category: 'Daging Unggas',
      price: 50000,
      stockAvailable: 10,
      isPreOrder: true,
      processedAt: now,
      maxFreshDays: 2,
      imageUrl: '',
    );

    directProduct = ProductModel(
      id: 'DIR-1',
      name: 'Beras Premium 5kg',
      category: 'Sembako',
      price: 70000,
      stockAvailable: 20,
      isPreOrder: false,
      processedAt: now,
      maxFreshDays: 180,
      imageUrl: '',
    );
  });

  Widget buildTestableWidget(ProductModel product) {
    return ChangeNotifierProvider<OrderProvider>.value(
      value: provider,
      child: MaterialApp(
        home: CheckoutScreen(product: product),
      ),
    );
  }

  group('CheckoutScreen Form Validation & Submission Tests', () {
    testWidgets('Validation errors appear on empty / invalid fields', (tester) async {
      await tester.pumpWidget(buildTestableWidget(preOrderProduct));
      await tester.pumpAndSettle();

      // Tap submit without entering data
      await tester.tap(find.text('Konfirmasi Pre-Order'));
      await tester.pumpAndSettle();

      expect(find.text('Nama pemesan wajib diisi.'), findsOneWidget);
      expect(find.text('Nomor HP wajib diisi.'), findsOneWidget);
      expect(find.text('Alamat pengiriman wajib diisi.'), findsOneWidget);

      // Enter invalid short data
      await tester.enterText(find.widgetWithText(TextFormField, 'Nama Lengkap Pemesan *'), 'Al');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nomor WhatsApp / HP *'), '1234');
      await tester.enterText(find.widgetWithText(TextFormField, 'Alamat Lengkap Pengiriman *'), 'Jl. A');

      await tester.tap(find.text('Konfirmasi Pre-Order'));
      await tester.pumpAndSettle();

      expect(find.text('Nama minimal 3 karakter.'), findsOneWidget);
      expect(find.text('Nomor HP harus berupa angka 10-13 digit.'), findsOneWidget);
      expect(find.text('Alamat minimal 10 karakter untuk kejelasan kurir.'), findsOneWidget);
    });

    testWidgets('Valid submission saves to Supabase and shows success SnackBar', (tester) async {
      await tester.pumpWidget(buildTestableWidget(preOrderProduct));
      await tester.pumpAndSettle();

      // Fill in valid data
      await tester.enterText(find.widgetWithText(TextFormField, 'Nama Lengkap Pemesan *'), 'Rendi Wijakusuma');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nomor WhatsApp / HP *'), '081234567890');
      await tester.enterText(find.widgetWithText(TextFormField, 'Alamat Lengkap Pengiriman *'), 'Jl. Udayana No. 11 Singaraja Bali');
      await tester.enterText(find.widgetWithText(TextFormField, 'Catatan Khusus (Opsional)'), 'Tolong potong 4 bagian');

      // Tap Submit
      await tester.tap(find.text('Konfirmasi Pre-Order'));
      await tester.pump(); // Start async submit
      await tester.pumpAndSettle(); // Settle navigation & SnackBar

      expect(mockSupabaseService.createdOrders.length, 1);
      final created = mockSupabaseService.createdOrders.first;
      expect(created.customerName, 'Rendi Wijakusuma');
      expect(created.customerPhone, '081234567890');
      expect(created.orderType, 'pre_order');
      expect(created.deliveryAddress, 'Jl. Udayana No. 11 Singaraja Bali');
      expect(created.notes, 'Tolong potong 4 bagian');
      expect(created.totalPrice, 50000);
      expect(find.text('Pesanan "Daging Bebek Segar" berhasil dibuat!'), findsOneWidget);
    });

    testWidgets('Failed submission shows error SnackBar feedback', (tester) async {
      mockSupabaseService.shouldFail = true;

      await tester.pumpWidget(buildTestableWidget(directProduct));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nama Lengkap Pemesan *'), 'Budi Santoso');
      await tester.enterText(find.widgetWithText(TextFormField, 'Nomor WhatsApp / HP *'), '089876543210');
      await tester.enterText(find.widgetWithText(TextFormField, 'Alamat Lengkap Pengiriman *'), 'Jl. Sudirman No. 45 Denpasar');

      await tester.tap(find.text('Konfirmasi Pesanan Sekarang'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Gagal'), findsOneWidget);
    });
  });
}
