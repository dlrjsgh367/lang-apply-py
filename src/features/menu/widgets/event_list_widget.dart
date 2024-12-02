import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EventListWidget extends StatelessWidget {
  const EventListWidget({required this.boardItem, super.key});

  final BoardModel boardItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/event/${boardItem.key}');
      },
      child: Container(
        padding: EdgeInsets.only(top: 12.w, bottom: 40.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              width: 1.w,
              color: CommonColors.grayF2,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (boardItem.files.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.w),
                child: SizedBox(
                  height: 80.w,
                  child: ExtendedImgWidget(
                    imgUrl: boardItem.files[0].url,
                    imgFit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(
              height: 12.w,
            ),
            Text(
              boardItem.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                color: CommonColors.gray4d,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${ConvertService.convertDateISOtoString(boardItem.startDate, ConvertService.YYYY_MM_DD)} ~ ${ConvertService.convertDateISOtoString(boardItem.endDate, ConvertService.YYYY_MM_DD)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: CommonColors.gray80,
              ),
            )
          ],
        ),
      ),
    );
  }
}
