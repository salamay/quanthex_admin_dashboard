import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
class MyFadeSlideEffect extends StatelessWidget {
  MyFadeSlideEffect({super.key,required this.child,this.duration});
  Widget child;
  int? duration;
  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        SlideEffect(
            duration: Duration(milliseconds: duration??500),
            curve: Curves.easeInOut
        ),
        FadeEffect()
      ],
      child: child,
    );
  }
}
