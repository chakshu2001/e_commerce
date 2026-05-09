import 'package:equatable/equatable.dart';

abstract class ProductDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProductDetailRequested extends ProductDetailEvent {
  final int id;
  FetchProductDetailRequested(this.id);
  @override
  List<Object?> get props => [id];
}
