import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:olam/features/home/presentation/pages/tovar_qaytarish_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onOpenSales;
  final VoidCallback? onOpenQaytarish;

  const HomePage({
    super.key,
    required this.onOpenSales,
    this.onOpenQaytarish,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: widget.onOpenSales,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    "assets/home/Savdo.png",
                    width: 350,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              GestureDetector(
                onTap: () {
                  if (widget.onOpenQaytarish != null) {
                    widget.onOpenQaytarish!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TovarQaytarishPage()),
                    );
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    "assets/home/Tovar_qaytishi.png",
                    width: 350,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              GestureDetector(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    "assets/home/Skladga_zakaz.png",
                    width: 350,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}