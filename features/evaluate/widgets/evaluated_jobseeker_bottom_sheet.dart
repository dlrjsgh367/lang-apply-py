import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/rating_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EvaluatedJobSeekerBottomSheet extends ConsumerStatefulWidget {
  const EvaluatedJobSeekerBottomSheet({
    super.key,
    required this.company,
    required this.ratingKey,
  });

  final String company;
  final int ratingKey;

  @override
  ConsumerState<EvaluatedJobSeekerBottomSheet> createState() => _EvaluatedJobSeekerBottomSheetState();
}

class _EvaluatedJobSeekerBottomSheetState extends ConsumerState<EvaluatedJobSeekerBottomSheet> {
  late RatingModel ratingDetailData;
  bool isLoading = true;

  Widget _buildRatingStars(int rating) {
    return RatingBar.builder(
      itemSize: 19.w,
      initialRating: rating / 2,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (_) {},
      ignoreGestures: true, // 사용자 입력 무시
    );
  }


  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getRatedEvaluateDetail()]);
  }

  @override
  void initState() {
    super.initState();

    _getAllAsyncTasks().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  getRatedEvaluateDetail() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref.read(mypageControllerProvider.notifier).getCompanyRatedEvaluateDetail(userInfo.key, widget.ratingKey);
      if (result.status == 200) {
        if (result.type == 1) {
          ratingDetailData = result.data;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
    ? Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, CommonSize.keyboardMediaHeight(context)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 14.w, 0, 14.w),
                child: Text(
                  localization.myEvaluation,
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
                    '${(ratingDetailData.welfareSalary + ratingDetailData.workingEnvironment + ratingDetailData.workLifeBalance + ratingDetailData.corporateCulture + ratingDetailData.promotionOpportunity) / 5}',
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
                localization.evaluationForData(widget.company),
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
                            localization.benefitsAndSalary,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        _buildRatingStars(ratingDetailData.welfareSalary),
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            textAlign: TextAlign.right,
                            '${ratingDetailData.welfareSalary}.0',
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
                        _buildRatingStars(ratingDetailData.workingEnvironment),
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            textAlign: TextAlign.right,
                            '${ratingDetailData.workingEnvironment}.0',
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
                        _buildRatingStars(ratingDetailData.workLifeBalance),
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            textAlign: TextAlign.right,
                            '${ratingDetailData.workLifeBalance}.0',
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
                        _buildRatingStars(ratingDetailData.corporateCulture),
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            textAlign: TextAlign.right,
                            '${ratingDetailData.corporateCulture}.0',
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
                        _buildRatingStars(ratingDetailData.promotionOpportunity),
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            textAlign: TextAlign.right,
                            '${ratingDetailData.promotionOpportunity}.0',
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
                child: Text(
                  '"${ratingDetailData.comment}"',
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.4,
                    color: CommonColors.gray66,
                  ),
                ),
              ),
              SizedBox(height: 28.w),
              CommonButton(
                confirm: true,
                onPressed: () {
                  context.pop();
                },
                text: localization.closed,
              ),
              SizedBox(height: CommonSize.footerBottom),
            ],
          ),
        ),
      )
    :  const SizedBox();
  }
}
