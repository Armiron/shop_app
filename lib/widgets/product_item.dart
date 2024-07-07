import 'package:flutter/material.dart';
import '../providers/products.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/auth.dart';
import '../screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatefulWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  const ProductItem({
    // required this.id,
    // required this.title,
    // required this.imageUrl,
    super.key,
  });

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    final product = Provider.of<Product>(context, listen: false); // to get once
    final products =
        Provider.of<Products>(context, listen: false); // to get once
    final cart = Provider.of<Cart>(context);
    final auth =
        Provider.of<Auth>(context, listen: false); // i can have auth.token
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
          footer: GridTileBar(
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.black87,
            leading: Consumer<Product>(
              // updates only the icon that changes
              builder: (context, product, child) => IconButton(
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () async {
                  try {
                    await Provider.of<Products>(context, listen: false)
                        .toggleFavoriteStatus(product.id, auth.userId);
                    setState(() {
                      product.isFavorite = !product.isFavorite;
                    });
                  } catch (e) {
                    scaffold.showSnackBar(const SnackBar(
                        content: Text(
                      'Favorite Failed!',
                      textAlign: TextAlign.center,
                    )));
                  }
                },
                color: Theme.of(context).colorScheme.error,
              ),
              child: const Text(
                  'Never changes, is given to the top function as child arg'),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // Nearest Scaffold widget not same widget tree
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Added item to cart!'),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      }),
                ));
              },
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: product.id,
              );
              // Navigator.of(context).push(MaterialPageRoute(
              //   builder: (context) => ProductDetailScreen(title: title),
              // ));
            },
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
            ),
          )),
    );
  }
}
