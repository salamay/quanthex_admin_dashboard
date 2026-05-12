import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
class MyScaleEffect extends StatelessWidget {
  MyScaleEffect({super.key,required this.child,this.duration});
  Widget child;
  int? duration;
  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        ScaleEffect(
          duration: Duration(milliseconds: duration??500),
        )
      ],
      child: child,
    );
  }
}
