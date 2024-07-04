import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    const urlString =
        "https://testflutterproject-719b6-default-rtdb.europe-west1.firebasedatabase.app/orders.json";
    Uri url = Uri.parse(urlString);
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        print(orderData['products']);
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime:
              DateFormat('yyyy-MM-dd hh:mm:ss').parse(orderData['dateTime']),
          // products: []
          products: (orderData['products'] as List<dynamic>)
              .map(
                (product) => CartItem(
                  id: product['id'],
                  title: product['title'],
                  quantity: product['quantity'],
                  price: product['price'],
                ),
              )
              .toList(),
        ));
      });
      _orders = loadedOrders.reversed.toList();
      print('done');
    } catch (e) {
      print(e);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const urlString =
        "https://testflutterproject-719b6-default-rtdb.europe-west1.firebasedatabase.app/orders.json";
    Uri url = Uri.parse(urlString);
    if (cartProducts.length == 0) {
      return;
    }
    try {
      final response = await http.post(url,
          body: json.encode({
            "amount": total,
            "products": cartProducts
                .map((cartItem) => {
                      'id': cartItem.id,
                      'title': cartItem.title,
                      'quantity': cartItem.quantity,
                      'price': cartItem.price,
                    })
                .toList(),
            "dateTime": DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now())
          }));
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: DateTime.now(),
        ),
      ); // To the beginning
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
