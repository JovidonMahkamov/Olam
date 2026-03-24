import '../model/customer_response_model.dart';

abstract class CustomerDataSource {
  Future<CustomerResponseModel> getCustomers({
    String? q,
    bool? qarzdorlar,
    int? sahifa,
  });
}