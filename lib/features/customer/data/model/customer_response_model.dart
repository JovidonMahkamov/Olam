import 'package:olam/features/customer/domain/entity/customer_response_entity.dart';
import 'customer_model.dart';
import 'meta_model.dart';

class CustomerResponseModel extends CustomerResponseEntity {
  CustomerResponseModel({
    required super.message,
    required super.mijozlar,
    required super.meta,
  });

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerResponseModel(
      message: json['message'],
      mijozlar: (json['data']['mijozlar'] as List)
          .map((e) => CustomerModel.fromJson(e))
          .toList(),
      meta: MetaModel.fromJson(json['data']['meta']),
    );
  }
}