import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/title_item.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/border_checkbox.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SetStatusScreen extends ConsumerStatefulWidget {
  const SetStatusScreen({super.key});

  @override
  ConsumerState<SetStatusScreen> createState() => _SetStatusScreenState();
}

class _SetStatusScreenState extends ConsumerState<SetStatusScreen> {
  List<UserModel> memberStatusList = [];
  int memberStatus = 0;

  bool isLoading = true;

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getUserData(),
      getStatusList(),
    ]);
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  String checkMember() {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo!.memberType == MemberTypeEnum.jobSeeker) {
      return 'ROLE_JOBSEEKER';
    } else {
      return 'ROLE_RECRUITER';
    }
  }

  String checkMemberString() {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo!.memberType == MemberTypeEnum.jobSeeker) {
      return localization.718;
    } else {
      return localization.719;
    }
  }

  @override
  void initState() {
    super.initState();
    _getAllAsyncTasks().then((_) {
      UserModel? userInfo = ref.read(userProvider);
      if (userInfo != null) {
        memberStatus = memberStatusList.where((status) => status.name == userInfo.memberStatus).toList().first.key;
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  getUserData() async {
    ApiResultModel result = await ref.read(authControllerProvider.notifier).getUserData();
    if (result.status == 200) {
      if (result.type == 1) {
        ref.read(userProvider.notifier).update((state) => result.data);
      }
    }
  }

  getStatusList() async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getStatusList(checkMember());
    if (result.status == 200) {
      if (result.type == 1) {
        List<UserModel> resultData = result.data;
        setState(() {
          memberStatusList = [...resultData];
        });
      }
    }
  }

  updateStatus() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .updateStatus(memberStatus, userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          if (mounted) {
            context.pop();
            getUserData();
            showDefaultToast(localization.709);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(
        title: '${checkMemberString()} 상태 변경',
      ),
      body: !isLoading
          ? Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomScrollView(
                    slivers: [
                      TitleItem(title: '${checkMemberString()} 상태'),
                      SliverList(
                        // RadioListTile(
                        //   title: Text(memberStatusData.name),
                        //   value: memberStatusData.key,
                        //   groupValue: memberStatus,
                        //   onChanged: (value) {
                        //     setState(() {
                        //       memberStatus = value!;
                        //     });
                        //   },
                        // );
                        delegate: SliverChildBuilderDelegate(
                          childCount: memberStatusList.length,
                          (context, index) {
                            var memberStatusData = memberStatusList[index];
                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                  20.w, index == 0 ? 0 : 10.w, 20.w, 0),
                              child: BorderCheck(
                                text: memberStatusData.name,
                                value: memberStatusData.key == memberStatus,
                                onChanged: (value) {
                                  setState(() {
                                    memberStatus = memberStatusData.key;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 20.w,
                  right: 20.w,
                  bottom: CommonSize.commonBottom,
                  child: CommonButton(
                    confirm: true,
                    onPressed: () {
                      updateStatus();
                    },
                    fontSize: 15,
                    text: localization.714,
                  ),
                ),
              ],
            )
          : const Loader(),
    );
  }
}
