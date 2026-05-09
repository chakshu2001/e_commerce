import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../widgets/root_layout.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RootLayout(
      onRefresh: () => context.read<ProductBloc>().add(FetchProductsRequested()),
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading && state is! ProductLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductError) {
            return Center(child: Text(state.message));
          }
          if (state is ProductLoaded) {
            if (state.products.isEmpty) {
              return const Center(child: Text("No products found."));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(FetchProductsRequested());
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return Card(
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/product-detail',
                        arguments: product,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(product.image, fit: BoxFit.contain),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text('\$${product.price}'),
                          ElevatedButton(
                            onPressed: () => context.read<CartBloc>().add(AddToCartRequested(product)),
                            child: const Text('Add to Cart'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
