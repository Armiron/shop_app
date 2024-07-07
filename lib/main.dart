import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth.dart';
import './screens/orders_screen.dart';
import './screens/cart_screen.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                Auth()), // This one has to be first so the others can depend on it
        ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products(null, '', []),
            update: (context, auth, previousProducts) => Products(
                  auth.token,
                  auth.userId,
                  previousProducts == null ? [] : previousProducts.items,
                )),
        ChangeNotifierProxyProvider<Auth, Cart>(
          create: (context) => Cart(null, {}),
          update: (context, auth, previousCart) =>
              Cart(auth.token, previousCart == null ? {} : previousCart.items),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders(null, []),
          update: (context, auth, previousOrders) => Orders(
              auth.token, previousOrders == null ? [] : previousOrders.orders),
        )
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
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
            // ProductsOverviewScreen.ro
            ProductDetailScreen.routeName: (context) =>
                const ProductDetailScreen(),
            CartScreen.routeName: (context) => const CartScreen(),
            OrdersScreen.routeName: (context) => const OrdersScreen(),
            UserProductsScreen.routeName: (context) =>
                const UserProductsScreen(),
            EditProductScreen.routeName: (context) => const EditProductScreen(),
          },
          home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
        ),
      ),
    );
  }
}
