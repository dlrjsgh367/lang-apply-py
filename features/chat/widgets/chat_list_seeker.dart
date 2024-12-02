import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/company_img_widget.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChatListSeeker extends StatelessWidget {
  ChatListSeeker({super.key, required this.data});

  var data;

  returnLastChatDate(DateTime chatDate) {
    DateTime now = DateTime.now();

    if (DateFormat('yyyy-MM-dd').format(chatDate) ==
        DateFormat('yyyy-MM-dd').format(now)) {
      return DateFormat('HH:mm').format(chatDate);
    } else if (DateTime(now.year, now.month, now.day - 1) ==
        DateFormat('yyyy-MM-dd').format(chatDate)) {
      return '어제';
    } else {
      return DateFormat('MM-dd').format(chatDate);
    }
  }

  checkCompanyProfileImage() {
    Map<String, dynamic> profile = data.partnerInfo.companyProfiles;
    return profile.isNotEmpty && profile['${data.companyKey}'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 16.w, 0, 16.w),
          decoration: BoxDecoration(
              color: CommonColors.white,
              border: Border(
                  bottom: BorderSide(width: 1.w, color: CommonColors.grayF7))),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.push('/company/${data.partnerInfo.key}');
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  width: 60.w,
                  height: 60.w,
                  clipBehavior: Clip.hardEdge,
                  child: checkCompanyProfileImage()
                      ? CompanyImgWidget(
                          imgUrl: data.partnerInfo
                              .companyProfiles['${data.companyKey}'],
                          color: Color(ConvertService.returnBgColor(
                              data.partnerInfo.color)),
                          text: data.partnerInfo.companyName,
                          imgWidth: 64.w,
                          imgHeight: 64.w,
                        )
                      : data.partnerInfo.companyImg['key'] != 0
                          ? CompanyImgWidget(
                              imgUrl: data.partnerInfo.companyImg['url'],
                              color: Color(ConvertService.returnBgColor(
                                  data.partnerInfo.color)),
                              text: data.partnerInfo.companyName,
                              imgWidth: 64.w,
                              imgHeight: 64.w,
                            )
                          : Image.asset(
                              'assets/images/icon/imgProfileRecruiter.png',
                              fit: BoxFit.cover,
                            ),
                ),
              ),
              SizedBox(
                width: 16.w,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.push('/chat/detail/${data.id}');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.partnerInfo.companyName,
                              // data.partnerInfo.companyName == ''
                              //     ? data.partnerInfo.name
                              //     : data.partnerInfo.companyName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: CommonColors.gray4d,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${returnLastChatDate(data.updated.toDate())}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CommonColors.grayB2,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4.w,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              data.msg['lastMsg'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: CommonColors.gray80,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          if (data.count > 0)
                            Container(
                              width: 18.w,
                              height: 18.w,
                              clipBehavior: Clip.hardEdge,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CommonColors.red),
                              child: Text(
                                '${data.count}',
                                style: TextStyle(
                                  color: CommonColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
