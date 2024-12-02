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

class EvaluatedCompanyBottomSheet extends ConsumerStatefulWidget {
  const EvaluatedCompanyBottomSheet({
    super.key,
    required this.name,
    required this.ratingKey,
  });

  final String name;
  final int ratingKey;

  @override
  ConsumerState<EvaluatedCompanyBottomSheet> createState() => _EvaluatedCompanyBottomSheetState();
}

class _EvaluatedCompanyBottomSheetState extends ConsumerState<EvaluatedCompanyBottomSheet> {
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
      ApiResultModel result = await ref.read(mypageControllerProvider.notifier).getJobSeekerRatedEvaluateDetail(userInfo.key, widget.ratingKey);
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
                    '${(ratingDetailData.jobSkill + ratingDetailData.responsibility + ratingDetailData.teamwork + ratingDetailData.kindnessRespect + ratingDetailData.diligenceEthics) / 5}',
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
                localization.evaluationForData(widget.name),
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
                            localization.workAbility,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        _buildRatingStars(ratingDetailData.jobSkill),
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            textAlign: TextAlign.right,
                            '${ratingDetailData.jobSkill}.0',
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
                            localization.responsibility,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        _buildRatingStars(ratingDetailData.responsibility),
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            textAlign: TextAlign.right,
                            '${ratingDetailData.responsibility}.0',
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
                            localization.teamwork,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        _buildRatingStars(ratingDetailData.teamwork),
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            textAlign: TextAlign.right,
                            '${ratingDetailData.teamwork}.0',
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
                            localization.kindnessAndRespect,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        _buildRatingStars(ratingDetailData.kindnessRespect),
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            textAlign: TextAlign.right,
                            '${ratingDetailData.kindnessRespect}.0',
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
                            localization.diligenceAndSincerity,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        _buildRatingStars(ratingDetailData.diligenceEthics),
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            textAlign: TextAlign.right,
                            '${ratingDetailData.diligenceEthics}.0',
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
    : const SizedBox();
  }
}
