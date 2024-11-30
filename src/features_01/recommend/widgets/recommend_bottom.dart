import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/contract/service/contract_service.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/user/controller/user_controller.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class RecommendBottom extends ConsumerStatefulWidget {
  const RecommendBottom(
      {super.key,
      required this.jobpostData,
      required this.scrapJobseeker,
      required this.applyJobposting});

  final JobpostRecommendModel jobpostData;
  final Function scrapJobseeker;
  final Function applyJobposting;

  @override
  ConsumerState<RecommendBottom> createState() => _RecommendBottomState();
}

class _RecommendBottomState extends ConsumerState<RecommendBottom> {
  final formatCurrency = NumberFormat('#,###');

  // returnDay() {
  //   String day = '';
  //
  //   for (var i = 0; i < widget.jobpostData.workDay.length; i++) {
  //     if (i == 0) {
  //       day = widget.jobpostData.workDay[i];
  //     } else {
  //       day = '$day, ${widget.jobpostData.workDay[i]}';
  //     }
  //   }
  //   if (widget.jobpostData.daysChangeable == 1) {
  //     if(day != ''){
  //       day = '$day / 요일 협의';
  //     }else{
  //       day = '요일 협의';
  //     }
  //   }
  //   return day;
  // }

  returnDay() {
    String day = '';

    // 요일의 순서를 정의한 배열
    List<String> dayOrder = ['월', '화', '수', '목', '금','토','일'];

    // 입력된 요일을 정의한 순서에 따라 정렬
    List sortedDays = widget.jobpostData.workDay;
    sortedDays.sort((a, b) => dayOrder.indexOf(a).compareTo(dayOrder.indexOf(b)));

    for (var i = 0; i < sortedDays.length; i++) {
      if (i == 0) {
        day = sortedDays[i];
      } else {
        day = '$day, ${sortedDays[i]}';
      }

    }

    if (widget.jobpostData.daysChangeable == 1) {
      if (day != '') {
        day = '$day / 요일 협의';
      } else {
        day = '요일 협의';
      }
    }

    return day;
  }


  returnHour() {
    String hour = '';
    List hourList = widget.jobpostData.workHour;
    for (var i = 0; i < hourList.length; i++) {
      if (i == 0) {
        hour = hourList[0];
      } else {
        if (i % 2 == 0) {
          hour = '$hour / ${hourList[i]}\n';
        } else {
          hour = '$hour / ${hourList[i]}';
        }
      }
    }

    if (widget.jobpostData.hourChangeable == 1) {
      if (hourList.length % 2 == 0) {
        hour = '$hour  시간 협의';
      } else {
        hour = '$hour / 시간 협의';
      }
    }

    return hour;
  }

  @override
  Widget build(BuildContext context) {
    List scrapList = ref.watch(userClipAnnouncementListProvider);
    List<int>applyOrProposedJobpostKeyList = ref.watch(applyOrProposedJobpostKeyListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15.w, 20.w, 15.w, 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 36.w,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icon/iconRecoMoney.png',
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Text(
                      ContractService.returnSalaryType(
                          widget.jobpostData.salaryType),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CommonColors.gray80,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${formatCurrency.format(widget.jobpostData.salary)}원',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 4.w,
              ),
              SizedBox(
                height: 36.w,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icon/iconRecoDoc.png',
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Text(
                      '근무형태',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CommonColors.gray80,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.jobpostData.workType,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 4.w,
              ),
              SizedBox(
                height: 36.w,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icon/iconRecoTime.png',
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Text(
                      '시간',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CommonColors.gray80,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        returnHour(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 4.w,
              ),
              SizedBox(
                height: 36.w,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icon/iconRecoCal.png',
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Text(
                      '요일',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CommonColors.gray80,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        returnDay(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 4.w,
              ),
              SizedBox(
                height: 36.w,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icon/iconRecoLoc.png',
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Text(
                      '위치',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CommonColors.gray80,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${widget.jobpostData.address} ${widget.jobpostData.addressDetail}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            BorderButton(
              onPressed: () {
                scrapList.contains(widget.jobpostData.key)
                    ? widget.scrapJobseeker('delete', widget.jobpostData.key)
                    : widget.scrapJobseeker('add', widget.jobpostData.key);
              },
              text: '',
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 0),
                child: Row(
                  children: [
                    Image.asset(
                      scrapList.contains(widget.jobpostData.key)
                          ? 'assets/images/icon/iconTagActive.png'
                          : 'assets/images/icon/iconTag.png',
                      width: 16.w,
                      height: 16.w,
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Text(
                      '스크랩',
                      style: TextStyle(
                          fontSize: 15.w,
                          color: CommonColors.gray4d,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
              child: CommonButton(
                confirm: !applyOrProposedJobpostKeyList.contains(widget.jobpostData.key),
                onPressed: () {
                  if(!applyOrProposedJobpostKeyList.contains(widget.jobpostData.key)){
                    widget.applyJobposting(widget.jobpostData.key);
                  }else{
                    showDefaultToast('이미 지원한 채용공고입니다.');
                  }
                },
                text: '지원하기',
              ),
            ),
          ],
        )
      ],
    );
  }
}
