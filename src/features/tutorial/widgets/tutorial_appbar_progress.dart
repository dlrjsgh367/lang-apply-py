import 'dart:math';

import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TutorialAppbarProgress extends StatelessWidget {
  final int data;

  const TutorialAppbarProgress({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(24.w, 24.w),
      painter: _TutorialProgressPainter(data),
    );
  }
}

class _TutorialProgressPainter extends CustomPainter {
  final int data;

  _TutorialProgressPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect01 =
        Rect.fromLTWH(2.w, 2.w, size.width - 4.w, size.height - 4.w);
    Rect rect02 = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    canvas.drawArc(rect01, -pi * 1 / 2, pi * 2 * data / 100, true,
        Paint()..color = CommonColors.red);
    canvas.drawArc(
      rect02,
      0,
      pi * 2,
      false,
      Paint()
        ..color = CommonColors.red
        ..strokeWidth = 1.5.w
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round, // 둥근 스트로크 끝
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
