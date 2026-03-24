import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:olam/core/route/route_names.dart';
import 'package:olam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olam/features/auth/presentation/bloc/auth_event.dart';
import 'package:olam/features/auth/presentation/bloc/auth_state.dart';

import '../widgets/elevated_wg.dart';
import '../widgets/text_field_wg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _eye = true;

  void _signInUser() {
    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login va parolni kiriting"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      LoginEvent(login: login, password: password),
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.bottomNavBar,
                (route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  'assets/splash/parda.png',
                  width: 180.w,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Image.asset(
                  'assets/splash/parda2.png',
                  width: 180.w,
                  fit: BoxFit.contain,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Tizimga kirish",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E2E2E),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Admin tomonidan berilgan login va parolni kiriting",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF9B9B9B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 26.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(14.w, 20.h, 14.w, 16.h),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300, width: 2),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(width: 10.w),
                        TextFieldWidgetBoard(
                          controller: _loginController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.none,
                          text: 'Login',
                          obscureText: false,
                          readOnly: false,
                          prefixIcon: Icon(
                            IconlyLight.login,
                            color: Color(0xffF4C747),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextFieldWidgetBoard(
                          controller: _passwordController,
                          text: "Parol kiriting",
                          obscureText: _eye,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.none,
                          readOnly: false,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xffF4C747),
                          ),
                          suffixIcon: IconButton(
                            splashRadius: 18,
                            icon: Icon(
                              _eye ? IconlyLight.hide : IconlyLight.show,
                              color: const Color(0xFFB5B5B5),
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() => _eye = !_eye);
                            },
                          ),
                        ),
                        SizedBox(height: 18.h),
                        SizedBox(
                          width: double.infinity,
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return ElevatedWidget(
                                onPressed: state is AuthLoading
                                    ? null
                                    : _signInUser,
                                text: state is AuthLoading
                                    ? 'Yuklanmoqda...'
                                    : 'Kirish',
                                backgroundColor: Color(0xffF4C747),
                                textColor: Colors.white,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}