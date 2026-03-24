import 'package:olam/features/auth/data/model/auth_model.dart';

abstract class AuthRemoteDataSource{
  Future<AuthModel> loginWorker({required String login,required String password,});
}