import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/api_client.dart';
import '../../utils/cache_manager.dart';
import '../../models/product.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<FetchProductsRequested>(_onFetchProductsRequested);
  }

  Future<void> _onFetchProductsRequested(FetchProductsRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      // First try to load from cache
      final cachedProducts = await cacheManager.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        emit(ProductLoaded(cachedProducts));
      }

      // Then fetch from API
      final response = await apiClient.get('/products');
      final List<dynamic> data = jsonDecode(response.body);
      final products = data.map((item) => Product.fromJson(item)).toList();
      await cacheManager.cacheProducts(products);
      emit(ProductLoaded(products));
    } catch (e) {
      if (state is! ProductLoaded) {
        emit(ProductError(e.toString()));
      }
    }
  }
}
