import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isOrdering = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final ordersProvider = Provider.of<Orders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        _isOrdering = true;
                      });
                      await ordersProvider.addOrder(
                        cart.items.values.toList(),
                        cart.totalAmount,
                      );
                      cart.clear();
                      setState(() {
                        _isOrdering = false;
                      });
                    },
                    child: _isOrdering
                        ? SizedBox(
                            width: 30,
                            height: 30,
                            child: const CircularProgressIndicator())
                        : const Text(
                            'ORDER NOW',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                var cartItem = cart.items.values.toList()[index];
                return CartItem(
                  cartItem.id,
                  cart.items.keys.toList()[index],
                  cartItem.price,
                  cartItem.quantity,
                  cartItem.title,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
