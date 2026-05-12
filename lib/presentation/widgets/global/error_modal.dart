import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import 'MyFadeSlideEffect.dart';


class ErrorModal extends StatelessWidget {
  ErrorModal({super.key,required this.callBack, this.message, this.textColor, this.buttonColor});
  String? message;
  Function callBack;
  Color? textColor;
  Color? buttonColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyFadeSlideEffect(
                child: Text(
                  'An error occurred, check your internet connection and try again. If the problem persists, please contact support.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor ?? Colors.black87,
                    fontSize: 14,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 16,),
              ElevatedButton(
                onPressed: ()async{
                  callBack();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
