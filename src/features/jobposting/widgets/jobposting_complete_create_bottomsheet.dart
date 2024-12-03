import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/jobposting_edit_enum.dart';
import 'package:chodan_flutter_app/enum/jobposting_manage_tap_enum.dart';
import 'package:chodan_flutter_app/models/premium_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/custom_sliver_header_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class JobpostingCompleteCreateBottomsheet extends StatelessWidget {
  const JobpostingCompleteCreateBottomsheet(
      {
        required this.type,
        required this.matchData,
        required this.areaTopData,
      super.key});

  final String type;
  final PremiumModel matchData;

  final PremiumModel areaTopData;


  String messageContent(String type) {
    if (type == JobpostingEditEnum.create.path) {
      return localization.11;
    }
    if (type == JobpostingEditEnum.update.path) {
      return localization.12;
    }
    if (type == JobpostingEditEnum.reregister.path) {
      return localization.13;
    }
    return localization.14;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.w, 8.w, 0.w, CommonSize.commonBottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TitleBottomSheet(title: messageContent(type), redirect: type == JobpostingEditEnum.create.path ? '/jobpostingmanage?tab=${JobpostingManageTapEnum.waitingPermission.tabIndex}' : null,),
            SizedBox(
              height: 20.w,
            ),

            Text(
              '사장님들을 위한 상품을 적용해보세요!\n채용 속도 UP! 딱 맞는 구직자를 찾을 확률 UP!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: CommonColors.gray66,
              ),
            ),
            SizedBox(
              height: 28.w,
            ),
            Padding(padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20.w, 20.w, 10.w, 20.w),
                    decoration: BoxDecoration(
                      color: CommonColors.white,
                      borderRadius: BorderRadius.circular(12.w),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 8.w,
                            offset: Offset(2.w, 2.w),
                            color: Color.fromRGBO(0, 0, 0, 0.06)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '직무와 딱 맞는 인재를\n하루 만에 찾아 추천까지 해주는',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.gray66,
                                ),
                              ),
                              Text(
                                localization.17,
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/images/default/imgMichin.png',
                          width: 120.w,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20.w, 20.w, 10.w, 20.w),
                    decoration: BoxDecoration(
                      color: CommonColors.white,
                      borderRadius: BorderRadius.circular(12.w),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 8.w,
                            offset: Offset(2.w, 2.w),
                            color: Color.fromRGBO(0, 0, 0, 0.06)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '선택한 5개 지역에서\n채용공고 목록을 상단 노출해주는',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.gray66,
                                ),
                              ),
                              Text(
                                localization.19,
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                            flex: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/default/imgShow.png',
                                  width: 72.w,
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.w,),
                  // ExtendedImgWidget(
                  //   imgUrl: matchData.files[0].url,
                  //   imgWidth: CommonSize.vw,
                  //   imgHeight: 50,
                  // ),
                  // ExtendedImgWidget(
                  //     imgUrl: areaTopData.files[0].url,
                  //     imgWidth: CommonSize.vw,
                  //     imgHeight: 50),
                  CommonButton(
                    fontSize: 15,
                    onPressed: () {
                      context.push('/my/premium');
                    },
                    confirm: true,
                    text: localization.20,
                    width: CommonSize.vw,
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
