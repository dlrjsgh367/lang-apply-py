import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/etc/html_parsing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventDetailContentWidget extends StatelessWidget {
  const EventDetailContentWidget({required this.eventItem, super.key});

  final BoardModel eventItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 12.w),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: CommonColors.grayE6,
                width: 1.w,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                eventItem.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CommonColors.gray4d,
                ),
              ),
              SizedBox(
                height: 8.w,
              ),
              Row(
                children: [
                  Text(
                    '${ConvertService.convertDateISOtoString(eventItem.startDate, ConvertService.YYYY_MM_DD)} ~ ${ConvertService.convertDateISOtoString(eventItem.endDate, ConvertService.YYYY_MM_DD)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CommonColors.gray80,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
          child: HtmlParsingWidget(
            htmlCode: eventItem.content,
          ),
        ),
      ],
    );
  }
}
