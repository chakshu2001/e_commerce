import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/api_client.dart';
import 'admin_event.dart';
import 'admin_state.dart';
import '../../models/product.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(AdminInitial()) {
    on<AddProductRequested>(_onAddProductRequested);
    on<UpdateProductRequested>(_onUpdateProductRequested);
    on<DeleteProductRequested>(_onDeleteProductRequested);
  }

  Future<void> _onAddProductRequested(AddProductRequested event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await apiClient.post('/products', event.product.toJson());
      Fluttertoast.showToast(msg: "Product Added (API)");
      emit(const AdminSuccess("Product Added"));
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to add product");
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onUpdateProductRequested(UpdateProductRequested event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await apiClient.put('/products/${event.product.id}', event.product.toJson());
      Fluttertoast.showToast(msg: "Product Updated (API)");
      emit(const AdminSuccess("Product Updated"));
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to update product");
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onDeleteProductRequested(DeleteProductRequested event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await apiClient.delete('/products/${event.id}');
      Fluttertoast.showToast(msg: "Product Deleted (API)");
      emit(const AdminSuccess("Product Deleted"));
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to delete product");
      emit(AdminFailure(e.toString()));
    }
  }
}
