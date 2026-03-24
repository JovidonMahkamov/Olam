
import 'package:olam/features/customer/domain/entity/customer_entity.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerEntity> customers;
  final bool hasMore;

  CustomerLoaded({
    required this.customers,
    required this.hasMore,
  });
}

class CustomerError extends CustomerState {
  final String message;

  CustomerError(this.message);
}