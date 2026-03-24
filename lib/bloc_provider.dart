import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/core/di/services_locator.dart';
import 'package:olam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olam/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:olam/features/home/presentation/bloc/home_bloc.dart';
import 'package:olam/features/kassa/presentation/bloc/kassa_bloc.dart';

class MyBlocProvider extends StatelessWidget {
  const MyBlocProvider({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<MahsulotlarBloc>(create: (_) => sl<MahsulotlarBloc>()),
        BlocProvider<MijozlarBloc>(create: (_) => sl<MijozlarBloc>()),
        BlocProvider<PostMijozBloc>(create: (_) => sl<PostMijozBloc>()),
        BlocProvider<SotuvlarBloc>(create: (_) => sl<SotuvlarBloc>()),
        BlocProvider<PostSotuvBloc>(create: (_) => sl<PostSotuvBloc>()),
        BlocProvider<DeleteSotuvBloc>(create: (_) => sl<DeleteSotuvBloc>()),
        BlocProvider<PostSotuvElementBloc>(create: (_) => sl<PostSotuvElementBloc>()),
        BlocProvider<YakunlashSotuvBloc>(create: (_) => sl<YakunlashSotuvBloc>()),
        BlocProvider<KassaBloc>(create: (_) => sl<KassaBloc>()),
        BlocProvider<BugungiSotuvBloc>(create: (_) => sl<BugungiSotuvBloc>()),
        BlocProvider<QarzdorBloc>(create: (_) => sl<QarzdorBloc>()),
        BlocProvider<KirimBloc>(create: (_) => sl<KirimBloc>()),
        BlocProvider<CustomerBloc>(create: (_) => sl<CustomerBloc>()),
      ],
      child: child,
    );
  }
}