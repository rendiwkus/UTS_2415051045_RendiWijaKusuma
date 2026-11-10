import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/order_provider.dart';
import 'repositories/product_repository.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Inisialisasi Supabase
    await Supabase.initialize(
      url: 'https://cxugbrctumwpqqndmydq.supabase.co',
      anonKey: 'sb_publishable_VvWLiJxaDxcnUihjdJZiyw_b96zIymA',
    );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OrderProvider(
            repository: ProductRepository(
              apiService: ApiService(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'REFARM AgroStore',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          scaffoldBackgroundColor: Colors.grey.shade50,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
