import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

enum SnackBarType { success, error, info }

showMySnackBar({required BuildContext context, required String message, required SnackBarType type}) {
  showTopSnackBar(Overlay.of(context), type==SnackBarType.success?CustomSnackBar.success(
    messagePadding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 2.sp),
    maxLines: 5,
    message: message, backgroundColor: Colors.green):CustomSnackBar.error(
      messagePadding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2.sp),
      maxLines: 5,
      message: message, backgroundColor: Colors.red)
      );
}
