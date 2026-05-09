import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/api_client.dart';
import '../../utils/cache_manager.dart';
import '../../models/product.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<LoadCartRequested>(_onLoadCartRequested);
    on<AddToCartRequested>(_onAddToCartRequested);
    on<ClearCartRequested>(_onClearCartRequested);
  }

  Future<void> _onLoadCartRequested(LoadCartRequested event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      // 1. Load from cache first for immediate UI update
      final cachedCart = await cacheManager.getCart();
      if (cachedCart.isNotEmpty) {
        emit(CartLoaded(cachedCart));
      }

      // 2. Fetch from API: curl -X GET 'https://fakestoreapi.com/carts/1'
      final response = await apiClient.get('/carts/1');
      final Map<String, dynamic> apiData = jsonDecode(response.body);
      final List<dynamic> apiProducts = apiData['products'] ?? [];

      // Get all products from cache to match IDs with full details (title, price, image)
      final allProducts = await cacheManager.getCachedProducts();

      final List<Map<String, dynamic>> syncedCart = apiProducts.map((item) {
        final int productId = item['productId'];
        final int quantity = item['quantity'];

        // Find full product info from our products cache
        final product = allProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => Product(
            id: productId,
            title: "Product $productId",
            price: 0,
            description: "",
            category: "",
            image: "https://via.placeholder.com/150",
          ),
        );

        return {
          'productId': productId,
          'quantity': quantity,
          'product': product.toJson(),
        };
      }).toList();

      // 3. Update cache and state with synced data
      await cacheManager.saveCart(syncedCart);
      emit(CartLoaded(syncedCart));
    } catch (e) {
      // If API fails, keep showing cached data if available
      if (state is! CartLoaded) {
        emit(CartError(e.toString()));
      }
    }
  }

  Future<void> _onAddToCartRequested(AddToCartRequested event, Emitter<CartState> emit) async {
    List<Map<String, dynamic>> currentItems = [];
    if (state is CartLoaded) {
      currentItems = List.from((state as CartLoaded).items);
    } else {
      currentItems = await cacheManager.getCart();
    }

    int index = currentItems.indexWhere((item) => item['productId'] == event.product.id);
    
    if (index != -1) {
      currentItems[index] = {
        ...currentItems[index],
        'quantity': currentItems[index]['quantity'] + 1,
      };
    } else {
      currentItems.add({
        'productId': event.product.id,
        'quantity': 1,
        'product': event.product.toJson()
      });
    }
    
    // Store in Cache (Requirement 4)
    await cacheManager.saveCart(currentItems);
    emit(CartLoaded(currentItems));

    try {
      // Update through API (Requirement 5)
      // Matches curl: curl -X PUT 'https://fakestoreapi.com/carts/1' -d '{"userId": 1, "products": [{"id": 2}]}'
      await apiClient.put('/carts/1', {
        "userId": 1,
        "products": currentItems.map((e) => {"id": e['productId']}).toList()
      });
      Fluttertoast.showToast(msg: "Cart updated on server");
    } catch (e) {
      print("Error updating cart on server: $e");
    }
  }

  Future<void> _onClearCartRequested(ClearCartRequested event, Emitter<CartState> emit) async {
    await cacheManager.saveCart([]);
    emit(const CartLoaded([]));
  }
}
