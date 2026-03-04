import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:olam/core/route/route_names.dart';

import '../widgets/elevated_wg.dart';
import '../widgets/text_field_wg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? errorMessage;
  String? _passwordError;

  bool eye = true;

  void _validatePassword(String value) {
    if (value.length < 8) {
      _passwordError = "Parol kamida 8 ta belgidan iborat bo‘lishi kerak";
    } else {
      _passwordError = null;
    }
  }

  void signInUser() {
    // final email = emailController.text.trim();
    // final pass = _passwordController.text.trim();
    //
    // if (email.isEmpty) {
    //   setState(() => errorMessage = "Loginni kiriting");
    //   return;
    // }
    // setState(() => errorMessage = null);
    //
    // _validatePassword(pass);
    // if (_passwordError != null) {
    //   setState(() {});
    //   return;
    // }
    Navigator.pushNamedAndRemoveUntil(context, RouteNames.bottomNavBar, (route) => false,);
  }

  @override
  void dispose() {
    emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
                        controller: emailController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.none,
                        text: 'Login',
                        obscureText: false,
                        readOnly: false,
                        prefixIcon: Icon(IconlyLight.login,color: Color(0xffF4C747),),
                      ),
                      if (errorMessage != null) ...[
                        SizedBox(height: 6.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 12.h),
                      TextFieldWidgetBoard(
                        controller: _passwordController,
                        text: "Parol kiriting",
                        obscureText: eye,
                        errorText: _passwordError,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.none,
                        readOnly: false,
                        prefixIcon: Icon(Icons.lock_outline_rounded,color: Color(0xffF4C747)),
                        suffixIcon: IconButton(
                          splashRadius: 18,
                          icon: Icon(
                            eye ? IconlyLight.hide : IconlyLight.show,
                            color: const Color(0xFFB5B5B5),
                            size: 20.sp,
                          ),
                          onPressed: () {
                            setState(() => eye = !eye);
                          },
                        ),
                      ),
                      SizedBox(height: 18.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedWidget(
                          onPressed: signInUser,
                          text: 'Kirish',
                          backgroundColor: Color(0xffF4C747),
                          textColor: Colors.white,
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
    );
  }
}
