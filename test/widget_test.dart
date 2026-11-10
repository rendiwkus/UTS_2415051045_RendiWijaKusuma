import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_2415051045_rendiwijakusuma/main.dart';
import 'package:uts_2415051045_rendiwijakusuma/models/product_model.dart';
import 'package:uts_2415051045_rendiwijakusuma/screens/catalog_screen.dart';
import 'package:uts_2415051045_rendiwijakusuma/screens/product_detail_screen.dart';
import 'package:uts_2415051045_rendiwijakusuma/widgets/freshness_indicator.dart';

void main() {
  testWidgets('Smoke test: loads HomeScreen with banner and quick filters', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('REFARM AgroStore'), findsOneWidget);
    expect(find.text('Batch Potong & Panen Hari Ini'), findsOneWidget);
    expect(find.text('Fresh Guarantee'), findsOneWidget);
    expect(find.text('Sistem Kuota Pre-Order Aktif'), findsOneWidget);
  });

  testWidgets('CatalogScreen displays Single Column ListView on compact width (<600dp)', (tester) async {
    // Set screen size to mobile width (400 x 800)
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap icon storefront to navigate to CatalogScreen
    await tester.tap(find.byIcon(Icons.storefront_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(CatalogScreen), findsOneWidget);
    expect(find.byType(ListView), findsWidgets);
    expect(find.byType(GridView), findsNothing);
  });

  testWidgets('CatalogScreen displays Multi-Column GridView on wide width (>=600dp)', (tester) async {
    // Set screen size to tablet/desktop width (800 x 1000)
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap icon storefront to navigate to CatalogScreen
    await tester.tap(find.byIcon(Icons.storefront_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(CatalogScreen), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('ProductDetailScreen displays freshness gauge and action button', (tester) async {
    final sampleProduct = ProductModel(
      id: 'TEST01',
      name: 'Daging Ayam Uji',
      category: 'Daging Unggas',
      price: 35000,
      stockAvailable: 15,
      isPreOrder: true,
      processedAt: DateTime.now().subtract(const Duration(hours: 2)),
      maxFreshDays: 2,
      imageUrl: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailScreen(product: sampleProduct),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daging Ayam Uji'), findsWidgets);
    expect(find.text('Daging Unggas'), findsOneWidget);
    expect(find.text('Pre-Order Sekarang'), findsOneWidget);
    expect(find.byType(FreshnessIndicator), findsOneWidget);

    // Tap action button and verify SnackBar
    await tester.tap(find.text('Pre-Order Sekarang'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
