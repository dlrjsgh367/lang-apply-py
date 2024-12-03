import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/models/company_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LikesCompanyWidget extends ConsumerStatefulWidget {
  const LikesCompanyWidget(
      {required this.toggleLikeCompany, required this.companyItem, super.key});

  final CompanyModel companyItem;

  final Function toggleLikeCompany;

  @override
  ConsumerState<LikesCompanyWidget> createState() => _LikesCompanyWidgetState();
}

class _LikesCompanyWidgetState extends ConsumerState<LikesCompanyWidget> {
  // List<int>
  @override
  Widget build(BuildContext context) {
    List<int> companyLikesKeyList = ref.watch(companyLikesKeyListProvider);
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
                  : SizedBox(
                      width: 80.w,
                      height: 80.w,
                      child: Image.asset(
                        'assets/images/icon/imgProfileRecruiter.png',
                        fit: BoxFit.cover,
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
                        style: TextStyle(
                            color: CommonColors.gray4d,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp),
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
                widget.toggleLikeCompany(
                    companyLikesKeyList, widget.companyItem.key);
              },
              child: Row(
                children: [
                  Image.asset(
                    companyLikesKeyList.contains(widget.companyItem.key)
                        ? 'assets/images/icon/iconHeartActive.png'
                        : 'assets/images/icon/iconHeart.png',
                    width: 24.w,
                    height: 24.w,
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
