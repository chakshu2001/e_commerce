import 'package:equatable/equatable.dart';
import '../../models/product.dart';

abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddProductRequested extends AdminEvent {
  final Product product;
  AddProductRequested(this.product);
  @override
  List<Object?> get props => [product];
}

class UpdateProductRequested extends AdminEvent {
  final Product product;
  UpdateProductRequested(this.product);
  @override
  List<Object?> get props => [product];
}

class DeleteProductRequested extends AdminEvent {
  final int id;
  DeleteProductRequested(this.id);
  @override
  List<Object?> get props => [id];
}
