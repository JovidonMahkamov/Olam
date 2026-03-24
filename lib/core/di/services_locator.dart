import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:olam/core/networks/dio_client.dart';
import 'package:olam/features/auth/data/datasource/local/auth_local_data_source.dart';
import 'package:olam/features/auth/data/datasource/local/auth_local_data_source_impl.dart';
import 'package:olam/features/auth/data/datasource/remote/auth_remote_data_source.dart';
import 'package:olam/features/auth/data/datasource/remote/auth_remote_data_source_impl.dart';
import 'package:olam/features/auth/data/repo/auth_repository_impl.dart';
import 'package:olam/features/auth/domain/repo/auth_repository.dart';
import 'package:olam/features/auth/domain/usecase/login_use_case.dart';
import 'package:olam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olam/features/customer/data/datasource/customer_data_source.dart';
import 'package:olam/features/customer/data/datasource/customer_data_source_impl.dart';
import 'package:olam/features/customer/data/repo/customer_repo_impl.dart';
import 'package:olam/features/customer/domain/repo/customer_repo.dart';
import 'package:olam/features/customer/domain/usecase/get_customer_use_case.dart';
import 'package:olam/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:olam/features/home/data/datasource/home_data_source.dart';
import 'package:olam/features/home/data/datasource/home_data_source_impl.dart';
import 'package:olam/features/home/data/repo/home_repo_impl.dart';
import 'package:olam/features/home/domain/repo/home_repo.dart';
import 'package:olam/features/home/domain/usecase/home_use_case.dart';
import 'package:olam/features/home/presentation/bloc/home_bloc.dart';
import 'package:olam/features/kassa/data/datasource/kassa_data_source.dart';
import 'package:olam/features/kassa/presentation/bloc/kassa_bloc.dart';

final sl = GetIt.instance;

Future<void> setup() async {
  await Hive.initFlutter();
  await GetStorage.init();

  final authBox = await Hive.openBox('authBox');

  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(authBox),
  );

  sl.registerLazySingleton<DioClient>(() => DioClient(local: sl()));

  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<CustomerDataSource>(
        () => CustomerDatasourceImpl(sl()),
  );

  sl.registerLazySingleton<HomeDataSource>(
        () => HomeDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<KassaDataSource>(
        () => KassaDataSource(dioClient: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDatasource: sl(), localDatasource: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton<CustomerRepo>(
        () => CustomerRepoImpl(sl()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GetMahsulotlarUseCase(sl()));
  sl.registerLazySingleton(() => GetMijozlarUseCase(sl()));
  sl.registerLazySingleton(() => PostMijozUseCase(sl()));
  sl.registerLazySingleton(() => GetSotuvlarUseCase(sl()));
  sl.registerLazySingleton(() => PostSotuvUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSotuvUseCase(sl()));
  sl.registerLazySingleton(() => PostSotuvElementUseCase(sl()));
  sl.registerLazySingleton(() => YakunlashSotuvUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerUseCase(sl()));

  sl.registerLazySingleton(() => AuthBloc(sl()));
  sl.registerLazySingleton(() => MahsulotlarBloc(sl()));
  sl.registerLazySingleton(() => MijozlarBloc(sl()));
  sl.registerLazySingleton(() => PostMijozBloc(sl()));
  sl.registerLazySingleton(() => SotuvlarBloc(sl()));
  sl.registerLazySingleton(() => PostSotuvBloc(sl()));
  sl.registerLazySingleton(() => DeleteSotuvBloc(sl()));
  sl.registerLazySingleton(() => PostSotuvElementBloc(sl()));
  sl.registerLazySingleton(() => YakunlashSotuvBloc(sl()));
  sl.registerLazySingleton(() => CustomerBloc(sl()));

  sl.registerLazySingleton(() => KassaBloc(dataSource: sl()));
  sl.registerLazySingleton(() => BugungiSotuvBloc(dataSource: sl()));
  sl.registerLazySingleton(() => QarzdorBloc(dataSource: sl()));
  sl.registerLazySingleton(() => KirimBloc(dataSource: sl()));
}