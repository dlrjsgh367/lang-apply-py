import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Uint8List> getBytesFromWidget(GlobalKey key,
    {int width = 0, int height = 0}) async {
  RenderRepaintBoundary? boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    // RenderRepaintBoundary를 찾을 수 없을 때
    throw Exception('RenderRepaintBoundary not found');
  }
  ui.Image image = await boundary.toImage(pixelRatio: 4);

  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

class Place with ClusterItem {
  final LatLng latLng;
  final int type;
  final String salayType;
  final int key;
  final String salary;
  bool selected; // 선택 여부를 나타내는 필드

  Place({
    required this.latLng,
    required this.type,
    required this.salayType,
    required this.key,
    required this.salary,
    this.selected = false, // 기본값은 false로 설정
  });

  @override
  LatLng get location => latLng;
}

class MyClusterPainter extends CustomPainter {
  final bool selected;
  final String salaryTypeName;
  final String salary;
  final ui.Image iconInfo;
  final int count;

  MyClusterPainter({
    required this.selected,
    required this.salaryTypeName,
    required this.salary,
    required this.iconInfo,
    required this.count,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    //말풍선 네모
    const double borderWidth = 6.0;
    final Paint fillPaint = Paint()
      ..color = selected ? CommonColors.red : Colors.white
      ..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()
      ..color = CommonColors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    final Rect rect = Rect.fromLTWH(
      borderWidth / 2 + size.height / 73 * 12,
      borderWidth / 2 + size.height / 73 * 12,
      size.width - borderWidth - 2 - size.height / 73 * 12 * 2,
      (size.height / 73 * 26) - borderWidth,
    );
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(20));
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5) // 그림자 색상과 투명도 설정
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10); // 그림자의 흐림 정도 설정

// 박스 쉐도우 그리기
    canvas.drawRRect(
      rrect.shift(Offset(0, 0)), // 그림자 위치 설정
      shadowPaint, // 그림자 페인트 사용
    );
    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, borderPaint);

//말풍선 폴리곤
    final Paint polyPaint = Paint()
      ..color = selected ? CommonColors.red : Colors.white
      ..style = PaintingStyle.fill;

    final Paint borderSecPaint = Paint()
      ..color = CommonColors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final Path path = Path()
      ..moveTo(size.width / 2, (size.height / 73 * 44))
      ..lineTo(size.width / 2 + 18, (size.height / 73 * 38) - borderWidth - 2)
      ..lineTo(size.width / 2 - 18, (size.height / 73 * 38) - borderWidth - 2)
      ..close();

    canvas.drawPath(path, polyPaint);
    final Path borderPath = Path()
      ..moveTo(size.width / 2, (size.height / 73 * 44))
      ..lineTo(size.width / 2 + 15, (size.height / 73 * 38) - 2)
      ..moveTo(size.width / 2 - 15, (size.height / 73 * 38) - 2)
      ..lineTo(size.width / 2, (size.height / 73 * 44));

    canvas.drawPath(borderPath, borderSecPaint);

    // Draw the texts
    final TextSpan salaryTypeSpan = TextSpan(children: [
      TextSpan(
        text: '${salaryTypeName} ',
        style: TextStyle(
          color: selected ? Colors.white : CommonColors.gray4d,
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
      ),
      // WidgetSpan(child: SizedBox(width: 4,),),
      TextSpan(
        text: salary,
        style: TextStyle(
          color: selected ? Colors.white : CommonColors.red,
          fontSize: 40,
          fontWeight: FontWeight.w600,
        ),
      ),
    ]);

    final TextPainter salaryTypePainter = TextPainter(
      text: salaryTypeSpan,
      textDirection: TextDirection.ltr,
    );
    salaryTypePainter.layout();
    salaryTypePainter.paint(
      canvas,
      Offset(
        size.width / 2 - salaryTypePainter.width / 2,
        size.height / 73 * 26 - salaryTypePainter.height / 2,
      ),
    );
    //하단 타입 아이콘

    canvas.drawCircle(
      Offset(size.width / 2, size.height - size.height / 73 * 15),
      size.height / 73 * 10,
      shadowPaint,
    );

    canvas.drawImageRect(
      iconInfo, // 원본 이미지
      Rect.fromLTWH(
          0, 0, iconInfo.width.toDouble(), iconInfo.height.toDouble()),
      Rect.fromLTWH(
        size.width / 2 - size.height / 73 * 10,
        size.height - size.height / 73 * 25,
        size.height / 73 * 20,
        size.height / 73 * 20,
      ),
      Paint(), // Paint 객체 (optional)
    );

    // 박스 쉐도우 그리기

//우상단 카운트

    if (count >= 2) {
      Offset center = Offset(
          size.width - size.height / 73 * 12 - borderWidth * 1.5,
          size.height / 73 * 12 + borderWidth);
      double radius = math.min(size.height / 73 * 12, size.height / 73 * 12);
      Paint circlePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      // 보더 원 그리기 (빨간색)
      Paint borderCirclePaint = Paint()
        ..color = CommonColors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth * 2;
      canvas.drawCircle(center, radius, borderCirclePaint);
      canvas.drawCircle(center, radius, circlePaint);

      // 텍스트 그리기
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: count > 99 ? '+99' : '+${count}',
          style: TextStyle(
            color: CommonColors.gray4d,
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      Offset textOffset = Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2);

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
