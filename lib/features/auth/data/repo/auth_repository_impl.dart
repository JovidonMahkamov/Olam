import 'package:olam/features/auth/data/datasource/local/auth_local_data_source.dart';
import 'package:olam/features/auth/data/datasource/remote/auth_remote_data_source.dart';
import 'package:olam/features/auth/domain/entity/auth_entity.dart';
import 'package:olam/features/auth/domain/repo/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDatasource;
  final AuthLocalDataSource localDatasource;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<AuthEntity> loginWorker({
    required String login,
    required String password,
  }) async {
    final result = await remoteDatasource.loginWorker(
      login: login,
      password: password,
    );

    await localDatasource.saveAccessToken(result.accessToken);
    await localDatasource.saveRefreshToken(result.refreshToken);
    await localDatasource.saveUserId(result.foydalanuvchi.id);

    return result;
  }
}