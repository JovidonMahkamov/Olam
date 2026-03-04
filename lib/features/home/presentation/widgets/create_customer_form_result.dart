import 'sale_customer_model.dart';

class CreateCustomerFormResult {
  final SaleCustomerType customerType;
  final String socialType;
  final String fullName;
  final String phone;
  final String address;

  const CreateCustomerFormResult({
    required this.customerType,
    required this.socialType,
    required this.fullName,
    required this.phone,
    required this.address,
  });
}