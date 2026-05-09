import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../blocs/cart/cart_state.dart';
import '../widgets/root_layout.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RootLayout(
      onRefresh: () => context.read<CartBloc>().add(LoadCartRequested()),
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading && state is! CartLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text("Your cart is empty."));
            }
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                final productData = item['product'];
                return ListTile(
                  leading: Image.network(productData['image'], width: 50),
                  title: Text(productData['title']),
                  subtitle: Text('Quantity: ${item['quantity']}'),
                  trailing: Text('\$${(productData['price'] * item['quantity']).toStringAsFixed(2)}'),
                );
              },
            );
          }
          if (state is CartError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
