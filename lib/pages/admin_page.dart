import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import '../blocs/admin/admin_bloc.dart';
import '../blocs/admin/admin_event.dart';
import '../blocs/admin/admin_state.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/product/product_event.dart';
import '../blocs/product/product_state.dart';
import '../widgets/root_layout.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RootLayout(
      onRefresh: () => context.read<ProductBloc>().add(FetchProductsRequested()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AdminBloc, AdminState>(
            listener: (context, state) {
              if (state is AdminSuccess) {
                // Refresh product list after any admin action
                context.read<ProductBloc>().add(FetchProductsRequested());
              }
            },
          ),
        ],
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: () => _showProductDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (productState is ProductLoading && productState is! ProductLoaded) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (productState is ProductLoaded) {
                        return ListView.builder(
                          itemCount: productState.products.length,
                          itemBuilder: (context, index) {
                            final product = productState.products[index];
                            return ListTile(
                              leading: Image.network(product.image, width: 40),
                              title: Text(product.title),
                              subtitle: Text('\$${product.price}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.teal),
                                    onPressed: () => _showProductDialog(context, product: product),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => context.read<AdminBloc>().add(DeleteProductRequested(product.id!)),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return const Center(child: Text("No products available"));
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showProductDialog(BuildContext context, {Product? product}) {
    final titleController = TextEditingController(text: product?.title ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final catController = TextEditingController(text: product?.category ?? '');
    final imageController = TextEditingController(text: product?.image ?? 'https://i.pravatar.cc');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Update Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: catController, decoration: const InputDecoration(labelText: 'Category')),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: 'Image URL')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newProduct = Product(
                id: product?.id,
                title: titleController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                description: descController.text,
                category: catController.text,
                image: imageController.text,
              );
              if (product == null) {
                context.read<AdminBloc>().add(AddProductRequested(newProduct));
              } else {
                context.read<AdminBloc>().add(UpdateProductRequested(newProduct));
              }
              Navigator.pop(context);
            },
            child: Text(product == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}
