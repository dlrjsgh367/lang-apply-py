import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/menu/widgets/btn_menu.dart';
import 'package:chodan_flutter_app/features/menu/widgets/title_menu.dart';
import 'package:chodan_flutter_app/features/mypage/service/logout.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/etc/red_back.dart';
import 'package:chodan_flutter_app/widgets/radio/toggle_radio_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingRecruiter extends ConsumerStatefulWidget {
  SettingRecruiter({super.key,required this.setSilver});
  final Function setSilver;
  @override
  ConsumerState<SettingRecruiter> createState() =>
      _SettingRecruiterState();
}

class _SettingRecruiterState
    extends ConsumerState<SettingRecruiter> {
  late SharedPreferences prefs;
  late bool silver;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    Future(() {
      savePageLog();
      initSilver();
    });
  }
  initSilver() async {
    prefs = await SharedPreferences.getInstance();


    setState(() {
      if (prefs.getString('silver') == 'true') {
        silver = true;
      } else {
        silver = false;
      }
      loading = false;
    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  showLogout() {
    showDialog(
      context: context,
      barrierColor: CommonColors.barrier,
      builder: (BuildContext context) {
        return AlertTwoButtonDialog(
          alertTitle: localization.404,
          alertContent: localization.405,
          alertConfirm: localization.406,
          alertCancel: localization.cancel,
          onConfirm: () {
            ref.read(applyOrProposedJobpostKeyListProvider.notifier).update((state) => []);
            logout(ref, context);
            context.pop();
          },
        );
      },
    );
  }

  getRecruiterProfileData() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref.read(authControllerProvider.notifier).getRecruiterProfileData(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          ref.read(userProfileProvider.notifier).update((state) => result.data);
        }
      }
    }
  }

  void setSilver() async {
    setState(() {
      if (silver) {
        ScreenUtil.init(context,
            designSize: const Size.fromWidth(360)); // 변경된 디자인 사이즈로 적용
      } else {
        ScreenUtil.init(context,
            designSize:
            const Size.fromWidth(360 - 360 * 0.1)); // 변경된 디자인 사이즈로 적용
      }

      silver = !silver;
      prefs.setString('silver', '$silver');

      widget.setSilver();
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loader()
        :
    CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const RedBack(extraHeight: 80),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 8.w, 12.w, 12.w),
                child: Container(
                  padding: EdgeInsets.fromLTRB(0.w, 8.w, 0.w, 8.w),
                  decoration: BoxDecoration(
                      color: CommonColors.white,
                      borderRadius: BorderRadius.circular(20.w),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 16.w,
                          color: Color.fromRGBO(0, 0, 0, 0.06),
                        )
                      ]),
                  child: CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    slivers: [
                      TitleMenu(title: localization.407),
                      BtnMenu(
                        text: localization.408,
                        tabFunc: () {
                          context.push('/setting/status');
                        },
                      ),
                      BtnMenu(
                        text: localization.409,
                        tabFunc: () {
                          context.push('/setting/member');
                        },
                      ),
                      BtnMenu(
                        text: localization.editCompanyInformation,
                        tabFunc: () {
                          context.push('/my/company/update').then((_) => {getRecruiterProfileData()});
                        },
                      ),
                      BtnMenu(
                        noBorder: true,
                        text: localization.411,
                        tabFunc: () {
                          context.push('/setting/password');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12.w, 8.w, 12.w, 0.w),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(0.w, 8.w, 0.w, 8.w),
              decoration: BoxDecoration(
                  color: CommonColors.white,
                  borderRadius: BorderRadius.circular(20.w),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 16.w,
                      color: const Color.fromRGBO(0, 0, 0, 0.06),
                    )
                  ]),
              child: CustomScrollView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  TitleMenu(title: localization.412),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          color: CommonColors.white,
                          border:  Border(
                            bottom: BorderSide(
                              width:  1.w,
                              color: CommonColors.grayF7,
                            ),
                          ),
                        ),
                        height: 48.w,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                localization.413,
                                style: TextStyle(
                                  color: CommonColors.gray66,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),

                            ToggleRadioButton(
                              onChanged: (value) {
                                setSilver();
                              },
                              groupValue: true,
                              value: silver,
                            ),
                          ],
                        ),
                      )
                    ),
                  ),


                  BtnMenu(
                    text: localization.414,
                    tabFunc: () {
                      context.push('/setting/alarm');
                    },
                  ),
                  BtnMenu(
                    noBorder: true,
                    text: localization.415,
                    tabFunc: () {
                      context.push('/withdrawal');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 28.w, 20.w, 0),
          sliver: SliverToBoxAdapter(
            child: CommonButton(
              backColor: CommonColors.grayF2,
              textColor: CommonColors.gray4d,
              confirm: true,
              fontSize: 15,
              onPressed: () {
                showLogout();
              },
              text: localization.406,
            ),
          ),
        ),
        const BottomPadding(),
      ],
    );
  }
}
