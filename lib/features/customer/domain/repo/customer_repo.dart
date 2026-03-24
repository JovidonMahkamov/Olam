import 'package:olam/features/customer/domain/entity/customer_response_entity.dart';

abstract class CustomerRepo {
  Future<CustomerResponseEntity> getCustomers({
    String? q,
    bool? qarzdorlar,
    int? sahifa,
  });}