import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/product.dart';
import '../utils/api_client.dart';
import '../utils/cache_manager.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<FetchProductsRequested>(_onFetchProductsRequested);
    on<FetchProductDetailRequested>(_onFetchProductDetailRequested);
    on<AddToCartRequested>(_onAddToCartRequested);
    on<AddProductRequested>(_onAddProductRequested);
    on<UpdateProductRequested>(_onUpdateProductRequested);
    on<DeleteProductRequested>(_onDeleteProductRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    final token = await cacheManager.getToken();
    final products = await cacheManager.getCachedProducts();
    final cart = await cacheManager.getCart();

    emit(state.copyWith(
      token: token,
      isLoggedIn: token != null,
      products: products,
      cart: cart,
    ));

    if (products.isEmpty) {
      add(FetchProductsRequested());
    }
    if (token != null && cart.isEmpty) {
      // For simplicity, we use userId 2 as per the previous requirement
      await _fetchCart(2, emit);
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AppState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await apiClient.post('/auth/login', {
        'username': event.username,
        'password': event.password,
      });
      final data = jsonDecode(response.body);
      final token = data['token'];
      await cacheManager.saveToken(token);
      Fluttertoast.showToast(msg: "Login Successful");
      
      emit(state.copyWith(
        token: token,
        isLoggedIn: true,
        isLoading: false,
      ));

      await _fetchCart(2, emit);
    } catch (e) {
      Fluttertoast.showToast(msg: "Login Failed: $e");
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AppState> emit) async {
    await cacheManager.removeToken();
    await cacheManager.saveCart([]);
    Fluttertoast.showToast(msg: "Logged Out");
    emit(state.copyWith(
      token: null,
      isLoggedIn: false,
      cart: [],
    ));
  }

  Future<void> _onFetchProductsRequested(FetchProductsRequested event, Emitter<AppState> emit) async {
    try {
      final response = await apiClient.get('/products');
      final List<dynamic> data = jsonDecode(response.body);
      final products = data.map((item) => Product.fromJson(item)).toList();
      await cacheManager.cacheProducts(products);
      emit(state.copyWith(products: products));
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  Future<void> _onFetchProductDetailRequested(FetchProductDetailRequested event, Emitter<AppState> emit) async {
    try {
      final response = await apiClient.get('/products/${event.id}');
      final product = Product.fromJson(jsonDecode(response.body));
      emit(state.copyWith(selectedProduct: product));
    } catch (e) {
      print("Error fetching product detail: $e");
    }
  }

  Future<void> _fetchCart(int userId, Emitter<AppState> emit) async {
    try {
      final response = await apiClient.get('/carts/user/$userId');
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final cartData = data[0];
        final List<dynamic> productsInCart = cartData['products'];
        
        final cart = productsInCart.map((item) {
          final productId = item['productId'];
          final quantity = item['quantity'];
          final product = state.products.firstWhere(
            (p) => p.id == productId, 
            orElse: () => Product(id: productId, title: "Product $productId", price: 0, description: "", category: "", image: "https://via.placeholder.com/150")
          );
          return {
            'productId': productId,
            'quantity': quantity,
            'product': product.toJson()
          };
        }).toList();
        
        await cacheManager.saveCart(cart);
        emit(state.copyWith(cart: cart));
      }
    } catch (e) {
      print("Error fetching cart: $e");
    }
  }

  Future<void> _onAddToCartRequested(AddToCartRequested event, Emitter<AppState> emit) async {
    final List<Map<String, dynamic>> updatedCart = List.from(state.cart);
    int index = updatedCart.indexWhere((item) => item['productId'] == event.product.id);
    
    if (index != -1) {
      updatedCart[index] = {
        ...updatedCart[index],
        'quantity': updatedCart[index]['quantity'] + 1,
      };
    } else {
      updatedCart.add({
        'productId': event.product.id,
        'quantity': 1,
        'product': event.product.toJson()
      });
    }
    
    await cacheManager.saveCart(updatedCart);
    emit(state.copyWith(cart: updatedCart));

    try {
      await apiClient.put('/carts/7', {
        "userId": 3,
        "date": DateTime.now().toIso8601String().split('T')[0],
        "products": updatedCart.map((e) => {"productId": e['productId'], "quantity": e['quantity']}).toList()
      });
      Fluttertoast.showToast(msg: "Cart updated on server");
    } catch (e) {
      print("Error updating cart on server: $e");
    }
  }

  Future<void> _onAddProductRequested(AddProductRequested event, Emitter<AppState> emit) async {
    try {
      final response = await apiClient.post('/products', event.product.toJson());
      final newProduct = Product.fromJson(jsonDecode(response.body));
      final List<Product> updatedProducts = List.from(state.products)..add(newProduct);
      await cacheManager.cacheProducts(updatedProducts);
      emit(state.copyWith(products: updatedProducts));
      Fluttertoast.showToast(msg: "Product Added (API)");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to add product");
    }
  }

  Future<void> _onUpdateProductRequested(UpdateProductRequested event, Emitter<AppState> emit) async {
    try {
      final response = await apiClient.put('/products/${event.product.id}', event.product.toJson());
      final updatedProduct = Product.fromJson(jsonDecode(response.body));
      final List<Product> updatedProducts = state.products.map((p) => p.id == event.product.id ? updatedProduct : p).toList();
      await cacheManager.cacheProducts(updatedProducts);
      emit(state.copyWith(products: updatedProducts));
      Fluttertoast.showToast(msg: "Product Updated (API)");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to update product");
    }
  }

  Future<void> _onDeleteProductRequested(DeleteProductRequested event, Emitter<AppState> emit) async {
    try {
      await apiClient.delete('/products/${event.id}');
      final List<Product> updatedProducts = state.products.where((p) => p.id != event.id).toList();
      await cacheManager.cacheProducts(updatedProducts);
      emit(state.copyWith(products: updatedProducts));
      Fluttertoast.showToast(msg: "Product Deleted (API)");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to delete product");
    }
  }
}
