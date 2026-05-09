import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCartRequested extends CartEvent {}

class AddToCartRequested extends CartEvent {
  final Product product;
  AddToCartRequested(this.product);
  @override
  List<Object?> get props => [product];
}

class ClearCartRequested extends CartEvent {}
