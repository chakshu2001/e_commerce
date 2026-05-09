import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/api_client.dart';
import '../../models/product.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc() : super(ProductDetailInitial()) {
    on<FetchProductDetailRequested>(_onFetchProductDetailRequested);
  }

  Future<void> _onFetchProductDetailRequested(FetchProductDetailRequested event, Emitter<ProductDetailState> emit) async {
    emit(ProductDetailLoading());
    try {
      final response = await apiClient.get('/products/${event.id}');
      final product = Product.fromJson(jsonDecode(response.body));
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductDetailError(e.toString()));
    }
  }
}
