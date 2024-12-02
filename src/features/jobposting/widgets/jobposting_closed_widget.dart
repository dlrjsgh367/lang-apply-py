import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/jobposting_edit_enum.dart';
import 'package:chodan_flutter_app/features/jobposting/service/jobposting_service.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/posting_tag_widget.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class JobpostingClosedWidget extends StatelessWidget {
  const JobpostingClosedWidget(
      {required this.jobpostItem,
      required this.deleteJobposting,
      required this.reregisterJobposting,
        required this.pushAfterFunc,
        required this.showEventModal,
      super.key});

  final JobpostModel jobpostItem;
  final Function deleteJobposting;

  final Function reregisterJobposting;
  final Function pushAfterFunc;

  final Function showEventModal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/jobpost/${jobpostItem.key}');
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.w, 10.w, 20.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(color: CommonColors.grayF7, width: 1.w),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PostingTag(
                  type: localization.closed,
                  // type: widget.type,
                ),
                SizedBox(
                  width: 8.w,
                ),
                Expanded(
                  child: Text(
                    jobpostItem.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton(
                  padding: EdgeInsets.zero,
                  color: CommonColors.white,
                  elevation: 1,
                  shadowColor: CommonColors.black,
                  surfaceTintColor: CommonColors.white,
                  child: Image.asset(
                    'assets/images/appbar/iconSetting.png',
                    width: 20.w,
                    height: 20.w,
                  ),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        onTap: () {
                          context.push(
                              '/mypage/jobposting/${JobpostingEditEnum.reregister.path}/${jobpostItem.key}').then((_){
                             pushAfterFunc();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            localization.repostJobPost,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.black2b,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {
                          deleteJobposting(jobpostItem.key);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            localization.delete,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.black2b,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
            SizedBox(
              height: 16.w,
            ),
            Row(
              children: [
                SizedBox(
                  width: 4.w,
                ),
                SizedBox(
                  width: 60.w,
                  child: Text(
                    localization.jobPostType,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CommonColors.gray80,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    jobpostItem.type.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CommonColors.gray4d,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 4.w,
            ),
            Row(
              children: [
                SizedBox(
                  width: 4.w,
                ),
                SizedBox(
                  width: 60.w,
                  child: Text(
                    localization.appliedProduct,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CommonColors.gray80,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    JobpostingService.applyPremiumItem(
                        michinMatching: jobpostItem.michinMatching,
                        areaTop: jobpostItem.areaTop),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CommonColors.gray4d,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 4.w,
            ),
            Row(
              children: [
                SizedBox(
                  width: 4.w,
                ),
                SizedBox(
                  width: 60.w,
                  child: Text(
                    localization.registrationDate,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CommonColors.gray80,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    ConvertService.convertDateISOtoString(
                        jobpostItem.createdAt, ConvertService.YYYY_MM_DD_HH_MM),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CommonColors.gray4d,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
