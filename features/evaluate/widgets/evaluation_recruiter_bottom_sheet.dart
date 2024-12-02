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

class EvaluationRecruiterBottomSheet extends ConsumerStatefulWidget {
  const EvaluationRecruiterBottomSheet({
    super.key,
    required this.company,
    required this.roomUuid,
  });

  final String company;
  final String roomUuid;

  @override
  ConsumerState<EvaluationRecruiterBottomSheet> createState() =>
      _EvaluationRecruiterBottomSheetState();
}

class _EvaluationRecruiterBottomSheetState
    extends ConsumerState<EvaluationRecruiterBottomSheet> {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  Map<String, dynamic> starRate = {
    "ejJobSkill": 0.0,
    "ejResponsibility": 0.0,
    "ejTeamwork": 0.0,
    "ejKindnessRespect": 0.0,
    "ejDiligenceEthics": 0.0,
    "ejComment": "",
  };

  jobseekerEvaluate() async {
    ApiResultModel result = await ref
        .read(evaluateControllerProvider.notifier)
        .jobseekerEvaluate(starRate, widget.roomUuid);
    if (result.type == 1) {
      showDefaultToast(localization.evaluationCompleted);
      if (!mounted) return null;
      context.pop();
    } else if (result.type == -609) {
      showDefaultToast(localization.unableToEvaluateBannedMember);
    } else if (result.type == -2201) {
      showDefaultToast(localization.evaluationAlreadySubmitted);
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
        child: KeyboardVisibilityBuilder(builder:  (context,visibility){
          return   Padding(
            padding: EdgeInsets.fromLTRB(
                20.w, 0, 20.w, CommonSize.keyboardMediaHeight(context) + (visibility ? 44 : 0)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 14.w, 0, 14.w),
                    child: Text(
                      localization.rateWithStars,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.black,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.w),
                      Text(
                        localization.rateExperienceWithWorker(widget.company),
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
                              localization.workAbility,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.gray66,
                              ),
                            ),
                          ),
                          RatingBar.builder(
                            itemSize: 30.0,
                            initialRating: starRate['ejJobSkill'] / 2,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                starRate['ejJobSkill'] = rating * 2;
                              });
                            },
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            starRate['ejJobSkill'].toString(),
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
                              localization.responsibility,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.gray66,
                              ),
                            ),
                          ),
                          RatingBar.builder(
                            itemSize: 30.0,
                            initialRating: starRate['ejResponsibility'] / 2,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                starRate['ejResponsibility'] = rating * 2;
                              });
                            },
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            starRate['ejResponsibility'].toString(),
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
                              localization.teamwork,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.gray66,
                              ),
                            ),
                          ),
                          RatingBar.builder(
                            itemSize: 30.0,
                            initialRating: starRate['ejTeamwork'] / 2,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                starRate['ejTeamwork'] = rating * 2;
                              });
                            },
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            starRate['ejTeamwork'].toString(),
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
                              localization.kindnessAndRespect,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.gray66,
                              ),
                            ),
                          ),
                          RatingBar.builder(
                            itemSize: 30.0,
                            initialRating: starRate['ejKindnessRespect'] / 2,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                starRate['ejKindnessRespect'] = rating * 2;
                              });
                            },
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            starRate['ejKindnessRespect'].toString(),
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
                              localization.diligenceAndSincerity,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.gray66,
                              ),
                            ),
                          ),
                          RatingBar.builder(
                            itemSize: 30.0,
                            initialRating: starRate['ejDiligenceEthics'] / 2,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                starRate['ejDiligenceEthics'] = rating * 2;
                              });
                            },
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            starRate['ejDiligenceEthics'].toString(),
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
                        child:  CommonKeyboardAction(
                          focusNode: textAreaNode,
                          child:
                          TextField(
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
                            cursorColor: CommonColors.black,
                            style: TextStyle(fontSize: 13.sp),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding:
                              EdgeInsets.fromLTRB(12.w, 16.w, 12.w, 16.w),
                              hintText: localization.oneLineEvaluation,
                              hintStyle: TextStyle(
                                color: CommonColors.lightBlue,
                                fontSize: 13.sp,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent, // 비활성 상태의 보더 색상 설정
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent, // 비활성 상태의 보더 색상 설정
                                ),
                              ),
                            ),
                            onChanged: (value){
                              setState(() {
                                starRate['ejComment'] = value.trim();
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
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(35.w, 13.w, 35.w, 13.w),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.w,
                                  color: CommonColors.gray300,
                                ),
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                              child: Text(
                                localization.closed,
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
                              confirm: starRate['ejComment'].isNotEmpty,
                              onPressed: () {
                                jobseekerEvaluate();
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
        }

        ) ,

      ),
    );
  }
}
