import 'customer_entity.dart';
import 'meta_entity.dart';

class CustomerResponseEntity {
  final String message;
  final List<CustomerEntity> mijozlar;
  final MetaEntity meta;

  CustomerResponseEntity({
    required this.message,
    required this.mijozlar,
    required this.meta,
  });
}