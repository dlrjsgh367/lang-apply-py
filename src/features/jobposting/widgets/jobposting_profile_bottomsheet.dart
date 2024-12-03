import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class JobpostingProfileBottomSheet extends ConsumerStatefulWidget {
  const JobpostingProfileBottomSheet(
      {required this.apply,
      required this.jobpostKey,
      required this.getProfile,
      super.key});

  final Function apply;
  final int jobpostKey;
  final Function getProfile;

  @override
  ConsumerState<JobpostingProfileBottomSheet> createState() =>
      _JobpostingProfileBottomSheetState();
}

class _JobpostingProfileBottomSheetState
    extends ConsumerState<JobpostingProfileBottomSheet> {
  int? selectedProfileKey;
  bool isLoading = false;

  String getDateTimeString(String date) {
    String formattedDate =
        DateFormat('yyyy.MM.dd HH:mm:ss').format(DateTime.parse(date));
    return formattedDate;
  }

  getProfileList() async {
    UserModel? userInfo = ref.watch(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getCompleteProfileList(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          int filteredIndex = result.data
              .indexOf((ProfileModel element) => element.mainProfile == 1);
          if (filteredIndex != -1) {
            ProfileModel data = result.data.removeAt(filteredIndex);
            result.data.insert(0, data);
          }
          setState(() {
            ref
                .read(userProfileListProvider.notifier)
                .update((state) => result.data);
            if (result.data.isNotEmpty) {
              selectedProfileKey = result.data[0].key;
            }
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future(() {
      getProfileList();
    });
  }

  @override
  void didUpdateWidget(JobpostingProfileBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    List<ProfileModel> profileList = ref.watch(userProfileListProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8.w, 0, CommonSize.commonBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const TitleBottomSheet(title: localization.49),
          profileList.isNotEmpty
              ? Flexible(
                  child: CustomScrollView(
                    shrinkWrap: true,
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: profileList.length,
                          (context, index) {
                            ProfileModel profileItem = profileList[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedProfileKey = profileItem.key;
                                });
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 1,
                                      color: CommonColors.grayF7,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              if (ConvertService
                                                  .convertIntToBool(
                                                      profileItem.mainProfile))
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 6.w),
                                                  padding: EdgeInsets.fromLTRB(
                                                      8.w, 0, 8.w, 0),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1.w,
                                                        color:
                                                            CommonColors.red),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            500.w),
                                                  ),
                                                  child: Text(
                                                    localization.50,
                                                    style: TextStyle(
                                                      color: CommonColors.red,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                ),
                                              Expanded(
                                                child: Text(
                                                  profileItem.profileTitle,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    color: CommonColors.gray66,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 6.w,
                                          ),
                                          Text(
                                            getDateTimeString(
                                                profileItem.updateAt),
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                overflow: TextOverflow.ellipsis,
                                                color: CommonColors.grayB2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    CircleCheck(
                                      readOnly: true,
                                      onChanged: (value) {},
                                      value:
                                          selectedProfileKey == profileItem.key,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(0, 32.w, 0, 32.w),
                  child: const CommonEmpty(text: localization.51),
                ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 0),
            child: profileList.isNotEmpty
                ? CommonButton(
                    fontSize: 15,
                    onPressed: () {
                      widget.apply(widget.jobpostKey, selectedProfileKey);
                      context.pop();
                    },
                    text: localization.applyForJob,
                    confirm: true,
                  )
                : CommonButton(
                    fontSize: 15,
                    onPressed: () {
                      context.push('/my/profile').then((_) {
                        getProfileList();
                        widget.getProfile();
                      });
                    },
                    text: '프로필 만들기',
                    confirm: true,
                  ),
          ),
        ],
      ),
    );
  }
}
