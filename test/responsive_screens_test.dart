import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:uts_2415051045_rendiwijakusuma/models/order_model.dart';
import 'package:uts_2415051045_rendiwijakusuma/models/product_model.dart';
import 'package:uts_2415051045_rendiwijakusuma/providers/order_provider.dart';
import 'package:uts_2415051045_rendiwijakusuma/repositories/product_repository.dart';
import 'package:uts_2415051045_rendiwijakusuma/screens/home_screen.dart';
import 'package:uts_2415051045_rendiwijakusuma/services/supabase_service.dart';
import 'package:uts_2415051045_rendiwijakusuma/widgets/freshness_indicator.dart';

class _SampleProductRepository extends ProductRepository {
  @override
  Future<List<ProductModel>> getProducts() async => [
    ProductModel(
      id: 'P1',
      name: 'Produk pangan dengan nama panjang untuk uji responsif',
      category: 'Daging Unggas',
      price: 60000,
      stockAvailable: 10,
      isPreOrder: false,
      processedAt: DateTime.now(),
      maxFreshDays: 2,
      imageUrl: '',
    ),
    ProductModel(
      id: 'P2',
      name: 'Produk daging merah untuk menguji filter kategori',
      category: 'Daging Merah',
      price: 125000,
      stockAvailable: 4,
      isPreOrder: true,
      processedAt: DateTime.now(),
      maxFreshDays: 3,
      imageUrl: '',
    ),
  ];
}

class _SampleSupabaseService extends SupabaseService {
  @override
  Future<List<OrderModel>> fetchOrders() async => [
    OrderModel(
      id: 'O1',
      customerName: 'Pembeli',
      customerPhone: '081234567890',
      productName: 'Pesanan dengan nama produk panjang untuk uji layar',
      category: 'Daging Unggas',
      quantity: 2,
      orderType: 'direct',
      deliveryAddress: 'Alamat pengiriman yang cukup panjang untuk menguji tampilan kartu riwayat pada layar sempit',
      deliveryDate: DateTime(2026, 11, 15),
      totalPrice: 120000,
      status: 'Pending',
    ),
  ];
}

void main() {
  for (final width in [360.0, 800.0]) {
    testWidgets('Home, catalog, and order history fit at ${width.toInt()}dp', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final provider = OrderProvider(
        repository: _SampleProductRepository(),
        supabaseService: _SampleSupabaseService(),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('1 pesanan menunggu diproses'), findsOneWidget);

      await tester.tap(find.text('Daging Merah'));
      await tester.pumpAndSettle();
      expect(provider.selectedCategory, 'Daging Merah');
      expect(find.text('Katalog Pangan Segar'), findsOneWidget);
      expect(find.byType(FreshnessIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Pesanan').first);
      await tester.pumpAndSettle();
      expect(find.text('Riwayat Pesanan Supabase'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
