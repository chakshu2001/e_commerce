import 'package:equatable/equatable.dart';
import '../models/product.dart';

class AppState extends Equatable {
  final List<Product> products;
  final List<Map<String, dynamic>> cart;
  final bool isLoggedIn;
  final String? token;
  final Product? selectedProduct;
  final bool isLoading;
  final String? error;

  const AppState({
    this.products = const [],
    this.cart = const [],
    this.isLoggedIn = false,
    this.token,
    this.selectedProduct,
    this.isLoading = false,
    this.error,
  });

  AppState copyWith({
    List<Product>? products,
    List<Map<String, dynamic>>? cart,
    bool? isLoggedIn,
    String? token,
    Product? selectedProduct,
    bool? isLoading,
    String? error,
  }) {
    return AppState(
      products: products ?? this.products,
      cart: cart ?? this.cart,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [products, cart, isLoggedIn, token, selectedProduct, isLoading, error];
}
