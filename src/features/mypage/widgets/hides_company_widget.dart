import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/models/company_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HidesCompanyWidget extends ConsumerStatefulWidget {
  const HidesCompanyWidget(
      {required this.companyItem, required this.toggleHideCompany, super.key});

  final CompanyModel companyItem;
  final Function toggleHideCompany;

  @override
  ConsumerState<HidesCompanyWidget> createState() => _HidesCompanyWidgetState();
}

class _HidesCompanyWidgetState extends ConsumerState<HidesCompanyWidget> {
  @override
  Widget build(BuildContext context) {
    List<int> companyHidesKeyList = ref.watch(companyHidesKeyListProvider);
    return GestureDetector(
      onTap: () {
        context.push('/company/${widget.companyItem.meIdx}');
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 16.w, 0, 16.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: CommonColors.grayF7),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.w),
              child: widget.companyItem.files.isNotEmpty &&
                      widget.companyItem.files[0].key > 0 &&
                      widget.companyItem.files[0].key != null
                  ? ExtendedImgWidget(
                      imgUrl: widget.companyItem.files[0].url,
                      imgWidth: 80.w,
                      imgHeight: 80.w,
                      imgFit: BoxFit.cover,
                    )
                  : Container(
                      width: 80.w,
                      height: 80.w,
                      color: Color(ConvertService.returnBgColor(
                          widget.companyItem.color)),
                      child: Center(
                        child: Text(
                          widget.companyItem.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.gray4d,
                          ),
                        ),
                      ),
                    ),
            ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.companyItem.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: CommonColors.gray4d,
                        fontSize: 16.sp),
                  ),
                  SizedBox(height: 4.w),
                  Row(
                    children: [
                      Text(
                        localization.530,
                        style: TextStyle(
                            color: CommonColors.gray80, fontSize: 13.sp),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${widget.companyItem.jobPostingCount}건',
                        style:
                            TextStyle(color: CommonColors.red, fontSize: 13.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
            GestureDetector(
              onTap: () async {
                widget.toggleHideCompany(
                    companyHidesKeyList, widget.companyItem.jobpostKey);
              },
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.w),
                      color: companyHidesKeyList
                              .contains(widget.companyItem.jobpostKey)
                          ? CommonColors.red
                          : CommonColors.grayB2,
                    ),
                    child: Text(
                      companyHidesKeyList
                              .contains(widget.companyItem.jobpostKey)
                          ? localization.531
                          : localization.532,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 2.w,
                        color: CommonColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.w),
          ],
        ),
      ),
    );
  }
}
