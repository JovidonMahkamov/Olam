import 'package:olam/core/networks/api_urls.dart';
import 'package:olam/core/networks/dio_client.dart';
import 'package:olam/core/utils/logger.dart';
import 'package:olam/features/auth/data/datasource/remote/auth_remote_data_source.dart';
import 'package:olam/features/auth/data/model/auth_model.dart';


class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  DioClient dioClient;
  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<AuthModel> loginWorker({required String login, required String password}) async{
    try {
      final response = await dioClient.post( ApiUrls.login,
        data: {'login': login, 'parol': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        LoggerService.info('customer login successful: ${response.data}');
        return AuthModel.fromJson(response.data);
      } else {
        LoggerService.warning("customer login failed: ${response.statusCode}");
        throw Exception('customer login failed: ${response.statusCode}');
      }
    } catch (e, s) {
      LoggerService.error('Error during customer login: $e');
      print(e);
      print(s);
      rethrow;
    }
  }
}
