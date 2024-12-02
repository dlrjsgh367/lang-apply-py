import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/evaluate/controller/evaluate_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EvaluationJobseekerChatBottomSheet extends ConsumerStatefulWidget {
  const EvaluationJobseekerChatBottomSheet({
    super.key,
    required this.company,
    required this.roomUuid,
  });

  final String company;
  final String roomUuid;

  @override
  ConsumerState<EvaluationJobseekerChatBottomSheet> createState() =>
      _EvaluationJobseekerChatBottomSheetState();
}

class _EvaluationJobseekerChatBottomSheetState
    extends ConsumerState<EvaluationJobseekerChatBottomSheet> {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  Map<String, dynamic> starRate = {
    "epWelfareSalary": 0.0,
    "epWorkingEnvironment": 0.0,
    "epCorporateCulture": 0.0,
    "epWorkLifeBalance": 0.0,
    "epPromotionOpportunity": 0.0,
    "epComment": "",
  };

  postingEvaluate(int completedType) async {
    ApiResultModel result = await ref
        .read(evaluateControllerProvider.notifier)
        .postingEvaluate(starRate, widget.roomUuid, completedType);
    if (result.status == 200) {
      if (completedType == 1) {
        showDefaultToast(localization.evaluationCompleted);
      } else {}
      if (mounted) {
        context.pop();
      }
    } else if (result.type == -2201) {
      showDefaultToast(localization.evaluationAlreadySubmitted);
      if (mounted) {
        context.pop();
      }
    } else if (result.type == -609) {
      showDefaultToast(localization.ratingNotAllowedDueToWritingRestriction);
      if (mounted) {
        context.pop();
      }
    } else {
      showDefaultToast(localization.evaluationSubmissionFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
        } else {
          if (!didPop) {
            context.pop();
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: KeyboardVisibilityBuilder(
          builder: (context, visibility) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20.w,
                  0,
                  20.w,
                  CommonSize.keyboardMediaHeight(context) +
                      (visibility ? 44 : 0)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Container(
                            color: Colors.transparent,
                            width: double.infinity,
                            height: 56.w,
                            child: Center(
                              child: Text(
                                localization.rateWithStars,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18.w,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              width: 64.w,
                              child: Image.asset(
                                'assets/images/icon/iconX.png',
                                width: 20.w,
                                height: 20.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 24.w),
                        Text(
                          localization.rateExperienceWithCompany2(widget.company),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.black2b,
                            height: 1.5.w,
                          ),
                        ),
                        SizedBox(height: 24.w),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                localization.benefitsAndSalary,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.gray66,
                                ),
                              ),
                            ),
                            RatingBar.builder(
                              itemSize: 30.0,
                              initialRating: starRate['epWelfareSalary'] / 2,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 1.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  starRate['epWelfareSalary'] = rating * 2;
                                });
                              },
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              starRate['epWelfareSalary'].toString(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.gray300,
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
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.gray66,
                                ),
                              ),
                            ),
                            RatingBar.builder(
                              itemSize: 30.0,
                              initialRating:
                                  starRate['epWorkingEnvironment'] / 2,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 1.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  starRate['epWorkingEnvironment'] = rating * 2;
                                });
                              },
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              starRate['epWorkingEnvironment'].toString(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.gray300,
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
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.gray66,
                                ),
                              ),
                            ),
                            RatingBar.builder(
                              itemSize: 30.0,
                              initialRating: starRate['epCorporateCulture'] / 2,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 1.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  starRate['epCorporateCulture'] = rating * 2;
                                });
                              },
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              starRate['epCorporateCulture'].toString(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.gray300,
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
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.gray66,
                                ),
                              ),
                            ),
                            RatingBar.builder(
                              itemSize: 30.0,
                              initialRating: starRate['epWorkLifeBalance'] / 2,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 1.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  starRate['epWorkLifeBalance'] = rating * 2;
                                });
                              },
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              starRate['epWorkLifeBalance'].toString(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.gray300,
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
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.gray66,
                                ),
                              ),
                            ),
                            RatingBar.builder(
                              itemSize: 30.0,
                              initialRating:
                                  starRate['epPromotionOpportunity'] / 2,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 1.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  starRate['epPromotionOpportunity'] =
                                      rating * 2;
                                });
                              },
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              starRate['epPromotionOpportunity'].toString(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.gray300,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7.w),
                        Container(
                          // padding: EdgeInsets.fromLTRB(12.w, 16.w, 12.w, 16.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            border: Border.all(
                              width: 1,
                              color: CommonColors.gray,
                            ),
                          ),
                          child: CommonKeyboardAction(
                            focusNode: textAreaNode,
                            child: TextFormField(
                              onTap: () {
                                ScrollCenter(textAreaKey);
                              },
                              key: textAreaKey,
                              focusNode: textAreaNode,
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              minLines: 3,
                              autocorrect: false,
                              maxLength: 100,
                              cursorColor: CommonColors.black,
                              style: TextStyle(fontSize: 13.sp),
                              decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.fromLTRB(
                                      12.w, 16.w, 12.w, 16.w),
                                  hintText: localization.oneLineEvaluation,
                                  hintStyle: TextStyle(
                                    color: CommonColors.lightBlue,
                                    fontSize: 13.sp,
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors
                                          .transparent, // 비활성 상태의 보더 색상 설정
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors
                                          .transparent, // 비활성 상태의 보더 색상 설정
                                    ),
                                  ),
                                  counterText: ''),
                              onChanged: (value) {
                                setState(() {
                                  starRate['epComment'] = value.trim();
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 39.w),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.pop();
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.fromLTRB(35.w, 13.w, 35.w, 13.w),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1.w,
                                    color: CommonColors.gray300,
                                  ),
                                  borderRadius: BorderRadius.circular(8.w),
                                ),
                                child: Text(
                                  localization.doNextTime,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.sp,
                                    color: CommonColors.gray4d,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: CommonButton(
                                confirm: starRate['epComment'].isNotEmpty,
                                onPressed: () {
                                  postingEvaluate(1);
                                },
                                text: localization.submitEvaluation,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: CommonSize.footerBottom),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
