import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/profile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


// TODO 언어팩 적용 x 사용하지 않는 페이지 같음. 삭제는 확인후 추후
class CompanyPostingList extends StatefulWidget {
  CompanyPostingList({super.key, required this.index});

  int index;

  @override
  State<CompanyPostingList> createState() => _CompanyPostingListState();
}

class _CompanyPostingListState extends State<CompanyPostingList> {
  void showProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CommonColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.8),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return ProfileBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.w, 24.w, 0.w, 24.w),
      decoration: widget.index == 0
          ? null
          : BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1.w,
            color: CommonColors.grayF7,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '[롯데워터파크] CAST로 해맑은 지원자를 모집합니다. 많은 지원 부탁드립니다.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.w,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: ButtonStyles.childBtn,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w, right: 0.w),
                  child: Image.asset(
                    widget.index == 0
                        ? 'assets/images/icon/iconStarActive.png'
                        : 'assets/images/icon/iconStar.png',
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.w,
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.w),
                      child: SizedBox(
                        width: 140.w,
                        height: 106.w,
                        child: Image.asset(
                          'assets/images/default/imgDefault.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8.w,
                      left: 8.w,
                      child: Container(
                        height: 24.w,
                        decoration: BoxDecoration(
                          border:
                          Border.all(width: 1.w, color: CommonColors.red),
                          color: const Color.fromRGBO(255, 255, 255, 0.7),
                          borderRadius: BorderRadius.circular(300.w),
                        ),
                        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                        alignment: Alignment.center,
                        child: Text(
                          'D-15',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: CommonColors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 8.w,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '초단네트워크',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/icon/iconPinRed.png',
                            width: 14.w,
                            height: 14.w,
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Text(
                            '2.7km',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CommonColors.gray80,
                            ),
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Expanded(
                            child: Text(
                              '경기도 이천시 이천동',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: CommonColors.gray80,
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '월급',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: CommonColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          const Expanded(
                            child: Text(
                              '2,310,000 원',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          showProfile();
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.w),
                          ),
                          fixedSize: Size.fromHeight(32.w),
                          backgroundColor: Colors.red,
                          side: const BorderSide(
                            width: 0,
                            color: Colors.transparent,
                          ),
                        ).copyWith(
                          overlayColor: ButtonStyles.overlayNone,
                        ),
                        child: Text(
                          '지원하기',
                          style: TextStyle(
                            color: CommonColors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 4.w,
              runAlignment: WrapAlignment.start,
              children: [
                for (var i = 0; i < 5; i++)
                  SizedBox(
                    height: 26.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                4.w,
                              ),
                              color: CommonColors.grayF7,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                          child: Text(
                            '서비스 > 주차유도/안내',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: CommonColors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
