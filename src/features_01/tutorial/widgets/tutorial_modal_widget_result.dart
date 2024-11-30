import 'dart:convert';

import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/tutorial_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialModalWidget extends ConsumerStatefulWidget {
  const TutorialModalWidget({
    super.key,
    required this.type,
    required this.idx,
    required this.percent,
    required this.message,
    this.photoUrl,
  });

  final String type;
  final int idx;
  final int percent;
  final String message;
  final String? photoUrl;

  @override
  ConsumerState<TutorialModalWidget> createState() =>
      _TutorialModalWidgetState();
}

class _TutorialModalWidgetState extends ConsumerState<TutorialModalWidget> {
  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, CommonSize.commonBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const TitleBottomSheet(
            title: localization.profileNotYetComplete,
            hasClose: false,
          ),
          Flexible(
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(top: 12.w),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TutorialProgressImg(
                          data: widget.percent,
                          type: widget.type,
                          imgUrl: widget.photoUrl,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(0, 8.w, 0, 20.w),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      '${widget.percent}% 완료',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.red,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(5.w, 8.w, 5.w, 12.w),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.grayB2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
            child: Row(
              children: [
                BorderButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    DateTime today = DateTime.now();
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(today);
                    Map<String, dynamic> tutorialBanner = {
                      "name": 'tutorial',
                      "notShowData": formattedDate,
                    };
                    await prefs.setString('popupTutorial${userInfo!.key}',
                        jsonEncode(tutorialBanner));
                    context.pop();
                  },
                  width: 96.w,
                  text: localization.tryAgainTomorrow,
                  fontSize: 13.sp,
                ),
                SizedBox(
                  width: 8.w,
                ),
                Expanded(
                  child: CommonButton(
                    onPressed: () {
                      context.pop();
                      if (widget.type == 'jobSeeker') {
                        context.push('/tutorial/jobseeker/${widget.idx}');
                      } else {
                        context.push('/tutorial/recruiter/${widget.idx}');
                      }
                    },
                    text: localization.startSetup,
                    fontSize: 15,
                    confirm: true,
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
