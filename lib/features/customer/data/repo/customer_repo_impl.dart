import 'package:olam/features/customer/data/datasource/customer_data_source.dart';
import 'package:olam/features/customer/domain/entity/customer_response_entity.dart';
import 'package:olam/features/customer/domain/repo/customer_repo.dart';


class CustomerRepoImpl implements CustomerRepo {
  final CustomerDataSource datasource;

  CustomerRepoImpl(this.datasource);

  @override
  Future<CustomerResponseEntity> getCustomers({
    String? q,
    bool? qarzdorlar,
    int? sahifa,
  }) async {
    return await datasource.getCustomers(
      q: q,
      qarzdorlar: qarzdorlar,
      sahifa: sahifa,
    );
  }
}