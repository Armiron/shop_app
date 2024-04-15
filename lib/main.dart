import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Products(),
      child: MaterialApp(
        title: 'MyShop',
        theme: ThemeData(
          fontFamily: 'Lato',
          primarySwatch: Colors.purple,
          colorScheme: const ColorScheme(
            primary: Colors.purple,
            background: Colors.black,
            brightness: Brightness.light,
            error: Colors.redAccent,
            secondary: Colors.deepOrange,
            onSecondary: Colors.orangeAccent,
            onBackground: Colors.black,
            onError: Colors.red,
            onPrimary: Colors.white,
            surface: Colors.black,
            onSurface: Colors.black12,
          ),
        ),
        routes: {
          ProductDetailScreen.routeName: (context) =>
              const ProductDetailScreen(),
        },
        home: ProductsOverviewScreen(),
      ),
    );
  }
}
