import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/models/evaluate_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyEvaluateWidget extends StatelessWidget {
  const CompanyEvaluateWidget({
    required this.title,
    required this.evaluateData,
    super.key});

  final String title;
  final EvaluateModel evaluateData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20.w, 0, 20.w, CommonSize.keyboardMediaHeight(context)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 14.w, 0, 14.w),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.black,
                ),
              ),
            ),
            SizedBox(height: 20.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon/IconFullStarActive.png',
                  width: 32.w,
                  height: 32.w,
                ),
                SizedBox(width: 14.w),
                Text(
                  '${evaluateData.totalAvg}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 36.sp,
                    height: 1.5,
                    color: CommonColors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.w),
            Text(
              localization.subjectiveFeedbackFromMembers,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: CommonColors.grayB2,
              ),
            ),
            SizedBox(height: 24.w),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localization.welfareAndSalary,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray66,
                          ),
                        ),
                      ),
                      RatingBar.builder(
                        itemSize: 30.0,
                        initialRating: evaluateData.welfareSalary / 2,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                        itemBuilder: (context, _) => Image.asset(
                          'assets/images/icon/IconFullStarActive.png',
                          width: 19.w,
                          height: 19.w,
                        ),
                        ignoreGestures : true,
                        onRatingUpdate: (rating) {
                        },
                      ),
                      SizedBox(
                        width: 40.w,
                        child: Text(
                          textAlign: TextAlign.right,
                          '${evaluateData.welfareSalary}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray4d,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.w),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localization.workEnvironment,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray66,
                          ),
                        ),
                      ),
                      RatingBar.builder(
                        itemSize: 30.0,
                        initialRating: evaluateData.workingEnvironment / 2,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                        itemBuilder: (context, _) => Image.asset(
                          'assets/images/icon/IconFullStarActive.png',
                          width: 19.w,
                          height: 19.w,
                        ),
                        ignoreGestures : true,
                        onRatingUpdate: (rating) {
                        },
                      ),
                      SizedBox(
                        width: 40.w,
                        child: Text(
                          textAlign: TextAlign.right,
                          '${evaluateData.workingEnvironment}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray4d,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.w),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localization.workLifeBalance,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray66,
                          ),
                        ),
                      ),
                      RatingBar.builder(
                        itemSize: 30.0,
                        initialRating: evaluateData.workLifeBalance / 2,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                        itemBuilder: (context, _) => Image.asset(
                          'assets/images/icon/IconFullStarActive.png',
                          width: 19.w,
                          height: 19.w,
                        ),
                        ignoreGestures : true,
                        onRatingUpdate: (rating) {
                        },
                      ),
                      SizedBox(
                        width: 40.w,
                        child: Text(
                          textAlign: TextAlign.right,
                          '${evaluateData.workLifeBalance}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray4d,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.w),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localization.companyCulture,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray66,
                          ),
                        ),
                      ),
                      RatingBar.builder(
                        itemSize: 30.0,
                        initialRating: evaluateData.corporateCulture / 2,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                        itemBuilder: (context, _) => Image.asset(
                          'assets/images/icon/IconFullStarActive.png',
                          width: 19.w,
                          height: 19.w,
                        ),
                        ignoreGestures : true,
                        onRatingUpdate: (rating) {
                        },
                      ),
                      SizedBox(
                        width: 40.w,
                        child: Text(
                          textAlign: TextAlign.right,
                          '${evaluateData.corporateCulture}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray4d,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.w),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localization.promotionOpportunitiesAndPotential,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray66,
                          ),
                        ),
                      ),
                      RatingBar.builder(
                        itemSize: 30.0,
                        initialRating: evaluateData.promotionOpportunity / 2,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                        itemBuilder: (context, _) => Image.asset(
                          'assets/images/icon/IconFullStarActive.png',
                          width: 19.w,
                          height: 19.w,
                        ),
                        ignoreGestures : true,
                        onRatingUpdate: (rating) {
                        },
                      ),
                      SizedBox(
                        width: 40.w,
                        child: Text(
                          textAlign: TextAlign.right,
                          '${evaluateData.promotionOpportunity}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray4d,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.w),
                ],
              ),
            ),
            SizedBox(height: 13.w),
            for(int i = 0; i<evaluateData.commentList.length;i++)
              Container(
                padding: EdgeInsets.fromLTRB(0, 20.w, 0, 20.w),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: CommonColors.gray100,
                      width: 1.w,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ConvertService.convertDateISOtoString(evaluateData.commentList[0]['createAt'], ConvertService.YYYY_MM_DD_HH_MM_dot),
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.4,
                        color: CommonColors.grayB2,
                      ),
                    ),
                    SizedBox(height: 8.w,),
                    Text(
                      localization.positiveCompanyAtmosphere,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.4,
                        color: CommonColors.gray66,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 28.w),
            CommonButton(
              confirm: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: localization.closed,
            ),
            SizedBox(height: CommonSize.footerBottom),
          ],
        ),
      ),
    );
  }
}
