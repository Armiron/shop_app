import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exceptions.dart';
import 'product.dart';

class Products with ChangeNotifier {
  // ignore: prefer_final_fields
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  var _showFavoritesOnly = false;
  final String? authToken;
  final String? userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((product) => product.isFavorite).toList();
    // }
    return [..._items]; // returning a copy of the items
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }
  // https://testflutterproject-719b6-default-rtdb.europe-west1.firebasedatabase.app/
  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts([bool filterByUsers = false]) async {
    final filterString =
        filterByUsers ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final urlString =
        "https://testflutterproject-719b6-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken&$filterString";
    final urlString2 =
        "https://testflutterproject-719b6-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken";
    Uri url = Uri.parse(urlString);
    Uri url2 = Uri.parse(urlString2);
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      final favoriteResponse = await http.get(url2);
      final favoriteData = json.decode(favoriteResponse.body);
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final urlString =
        "https://testflutterproject-719b6-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken";
    Uri url = Uri.parse(urlString);

    // return http // is an async and will return a future
    try {
      final response = await http.post(url,
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
            "creatorId": userId,
            // "isFavorite": product.isFavorite,
          }));
      final newProduct = Product(
        id: json.decode(response.body)["name"],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }

    // .then((response) {

    // }).catchError((error) {
    //   throw error;
    // });
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final urlString =
          "https://testflutterproject-719b6-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken";
      Uri url = Uri.parse(urlString);
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            // 'isFavorite': newProduct.isFavorite,
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final urlString =
        "https://testflutterproject-719b6-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken";
    Uri url = Uri.parse(urlString);
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
  }

  Future<void> toggleFavoriteStatus(String id, String? userId) async {
    final urlString =
        "https://testflutterproject-719b6-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$authToken";
    Uri url = Uri.parse(urlString);
    final productIndex = _items.indexWhere((element) => element.id == id);
    final product = _items[productIndex];
    if (productIndex >= 0) {
      final response =
          await http.put(url, body: json.encode(!product.isFavorite));
      if (response.statusCode >= 400) {
        _items[productIndex].isFavorite = !product.isFavorite;
        notifyListeners();
        throw HttpException('Could not save favorite.');
      }
    }
  }
}
