import 'package:equatable/equatable.dart';
import '../models/product.dart';

abstract class AppEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AppEvent {}

class LoginRequested extends AppEvent {
  final String username;
  final String password;
  LoginRequested(this.username, this.password);
  @override
  List<Object?> get props => [username, password];
}

class LogoutRequested extends AppEvent {}

class FetchProductsRequested extends AppEvent {}

class FetchProductDetailRequested extends AppEvent {
  final int id;
  FetchProductDetailRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class AddToCartRequested extends AppEvent {
  final Product product;
  AddToCartRequested(this.product);
  @override
  List<Object?> get props => [product];
}

class AddProductRequested extends AppEvent {
  final Product product;
  AddProductRequested(this.product);
  @override
  List<Object?> get props => [product];
}

class UpdateProductRequested extends AppEvent {
  final Product product;
  UpdateProductRequested(this.product);
  @override
  List<Object?> get props => [product];
}

class DeleteProductRequested extends AppEvent {
  final int id;
  DeleteProductRequested(this.id);
  @override
  List<Object?> get props => [id];
}
