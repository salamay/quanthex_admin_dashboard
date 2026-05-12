import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
class MyFadeEffect extends StatelessWidget {
  MyFadeEffect({super.key,required this.child,this.duration,this.isStopped});

  Widget child;
  Duration? duration;
  bool? isStopped;

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(
          duration: duration?? const Duration(milliseconds: 500),
        ),
      ],
      child: child,
      onComplete: (animationController){
        // bool stopped=isStopped??false;
        // if(!stopped){
        //   animationController.reverse();
        //   return;
        // }
      },
    );
  }
}
