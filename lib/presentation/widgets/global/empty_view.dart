import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyView extends StatelessWidget {
  final String message;
  Color? textColor;

  EmptyView({super.key, required this.message, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor?? Color(0xFF757575), fontSize: 14, fontFamily: 'Satoshi', fontWeight: FontWeight.w400, height: 1.5),
        ),
      ),
    );
  }
}
