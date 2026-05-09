import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import '../blocs/product_detail/product_detail_bloc.dart';
import '../blocs/product_detail/product_detail_event.dart';
import '../blocs/product_detail/product_detail_state.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../widgets/root_layout.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    if (product.id != null) {
      context.read<ProductDetailBloc>().add(FetchProductDetailRequested(product.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialProduct = ModalRoute.of(context)!.settings.arguments as Product;

    return RootLayout(
      child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          final product = state is ProductDetailLoaded ? state.product : initialProduct;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(product.image, height: 300, fit: BoxFit.contain),
                ),
                const SizedBox(height: 20),
                Text(
                  product.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Category: ${product.category}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(product.description),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CartBloc>().add(AddToCartRequested(product));
                    },
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
