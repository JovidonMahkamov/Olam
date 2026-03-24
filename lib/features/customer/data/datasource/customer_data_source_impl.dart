import 'package:olam/core/networks/api_urls.dart';
import 'package:olam/core/networks/dio_client.dart';
import 'package:olam/features/customer/data/datasource/customer_data_source.dart';
import 'package:olam/features/customer/data/model/customer_response_model.dart';

class CustomerDatasourceImpl implements CustomerDataSource {
  final DioClient dioClient;

  CustomerDatasourceImpl(this.dioClient);

  @override
  Future<CustomerResponseModel> getCustomers({
    String? q,
    bool? qarzdorlar,
    int? sahifa,
  }) async {
    final response = await dioClient.get(
      ApiUrls.getCustomer,
      queryParams: {
        "q": q,
        "qarzdorlar": qarzdorlar,
        "sahifa": sahifa,
      },
    );

    return CustomerResponseModel.fromJson(response.data);
  }
}