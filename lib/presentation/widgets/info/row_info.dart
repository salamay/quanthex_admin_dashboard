import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class RowInfo extends StatelessWidget {
  RowInfo({super.key,required this.label,required this.value});
  String label;
  String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF757575),
              fontSize: 14,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: const Color(0xFF2D2D2D),
                fontSize: 14,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
