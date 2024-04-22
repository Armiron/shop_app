import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/orders_screen.dart';
import './screens/cart_screen.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Products()),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProvider(create: (context) => Orders())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
          CartScreen.routeName: (context) => const CartScreen(),
          OrdersScreen.routeName: (context) => const OrdersScreen(),
        },
        home: const ProductsOverviewScreen(),
      ),
    );
  }
}
