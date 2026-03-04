import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class ElevatedWidget extends StatelessWidget {
  final double? size;
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  const ElevatedWidget({super.key, required this.onPressed,required this.text, this.size, required this.backgroundColor, required this.textColor,});
  @override
  Widget build (BuildContext context) {
    return SizedBox(
      width: size,
      height: 46.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: backgroundColor,
        ),
        onPressed:onPressed,
        child:  Center(
          child: Text(
            text,
            style: TextStyle (color: textColor),
          ),
        ),
      ),
    );
  }

}