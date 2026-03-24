import 'package:olam/features/customer/domain/entity/customer_response_entity.dart';
import 'package:olam/features/customer/domain/repo/customer_repo.dart';


class GetCustomerUseCase {
  final CustomerRepo repository;

  GetCustomerUseCase(this.repository);

  Future<CustomerResponseEntity> call({
    String? q,
    bool? qarzdorlar,
    int? sahifa,
  }) async {
    return await repository.getCustomers(
      q: q,
      qarzdorlar: qarzdorlar,
      sahifa: sahifa,
    );
  }
}