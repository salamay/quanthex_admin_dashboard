import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class Loading extends StatelessWidget {
  double? size;
  Loading({Key? key,this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(
        color: Colors.orange,
        size: size ?? 30.sp
      ),
    );
  }
}
