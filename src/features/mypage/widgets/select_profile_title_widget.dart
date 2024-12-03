import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_constants.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/input_profile_title_widget.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/profile_title_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SelectProfileTitleWidget extends StatefulWidget {
  const SelectProfileTitleWidget({
    super.key,
    this.profileData,
    required this.selectedDirectInputData,
    this.setProfileData,
    this.isWrite = false,
  });

  final Map<String, dynamic>? profileData;
  final Map<String, dynamic> selectedDirectInputData;
  final Function? setProfileData;
  final bool isWrite;

  @override
  State<SelectProfileTitleWidget> createState() =>
      _SelectProfileTitleWidgetState();
}

class _SelectProfileTitleWidgetState extends State<SelectProfileTitleWidget> {
  int selectedIndex = 0;
  String profileTitle = '';

  showDirectInputAlert(String? title) {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return InputProfileTitleWidget(
          title: title,
        );
      },
    ).then((value) => {
          setState(() {
            if (widget.setProfileData != null) {
              // 프로필
              if (value != null) {
                // 직접 입력을 했을 경우,
                widget.setProfileData!('mpTitle', value);
                profileTitle = value;
                context.pop(selectedIndex);
              }
            }
          })
        });
  }

  @override
  void initState() {
    super.initState();

    if (widget.profileData != null) {
      // 프로필
      if (widget.profileData!['mpTitle'].isNotEmpty) {
        selectedIndex = widget.selectedDirectInputData['index'];
        if (selectedIndex == 4) {
          // 직접 입력 선택
          profileTitle = widget.profileData!['mpTitle'];
        }
      }
    } else {
      // 튜토리얼
      if (widget.selectedDirectInputData['index'] != -1) {
        selectedIndex = widget.selectedDirectInputData['index'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, CommonSize.commonBoard(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const TitleBottomSheet(title: localization.552),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 20.w),
              shrinkWrap: true,
              itemCount: ProfileConstants.profileTitleList.length,
              itemBuilder: (BuildContext context, int index) {
                return ProfileTitleButton(
                  active: selectedIndex == index,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  text: ProfileConstants.profileTitleList[index],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 0),
            child: CommonButton(
              onPressed: () {
                if (widget.isWrite) {
                  // 프로필
                  if (selectedIndex == 4) {
                    // 직접 입력 선택
                    showDirectInputAlert(profileTitle);
                  } else {
                    context.pop(selectedIndex);
                  }
                } else {
                  // 튜토리얼
                  context.pop(selectedIndex);
                }
              },
              text: localization.553,
              fontSize: 15,
              confirm: true,
            ),
          ),
        ],
      ),
    );
  }
}
