import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/menu/widgets/btn_menu.dart';
import 'package:chodan_flutter_app/features/menu/widgets/title_menu.dart';
import 'package:chodan_flutter_app/features/mypage/service/logout.dart';
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

class SettingSeekerScreen extends ConsumerStatefulWidget {
  SettingSeekerScreen({super.key, required this.setSilver});

  final Function setSilver;

  @override
  ConsumerState<SettingSeekerScreen> createState() =>
      _SettingSeekerScreenState();
}

class _SettingSeekerScreenState extends ConsumerState<SettingSeekerScreen> {
  late SharedPreferences prefs;
  late bool silver;
  bool loading = true;


  @override
  void initState() {
    super.initState();
    Future(() {
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
  showLogout() {
    showDialog(
      context: context,
      barrierColor: CommonColors.barrier,
      builder: (BuildContext context) {
        return AlertTwoButtonDialog(
          alertTitle: localization.appLogout,
          alertContent: localization.logoutDisablesNotifications,
          alertConfirm: localization.logout,
          alertCancel: localization.cancel,
          onConfirm: () {
            logout(ref, context);
            context.pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.read(userProvider);
    return

      loading
          ? const Loader():
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
                          color: const Color.fromRGBO(0, 0, 0, 0.06),
                        )
                      ]),
                  child: CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    slivers: [
                      TitleMenu(title: localization.editInformation),
                      BtnMenu(
                        text: localization.changeJobSearchStatus,
                        tabFunc: () {
                          context.push('/setting/status');
                        },
                      ),
                      BtnMenu(
                        text: localization.editMemberInfo,
                        tabFunc: () {
                          context.push('/setting/member');
                        },
                      ),
                      if (userInfo!.loginType == 'email')
                      BtnMenu(
                        noBorder: true,
                        text: localization.changePassword,
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
                  TitleMenu(title: localization.otherSettings),
                  // BtnMenu(
                  //   text: localization.silverbellService,
                  //   tabFunc: () {
                  //     context
                  //         .push('/setting/silver')
                  //         .then((value) => {setSilver(context)});
                  //   },
                  // ),

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
                                  localization.textSizeIncreaseWithSeniorThemeSection,
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
                    text: localization.notificationSettings,
                    tabFunc: () {
                      context.push('/setting/alarm');
                    },
                  ),
                  BtnMenu(
                    noBorder: true,
                    text: localization.deleteAccount,
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
              text: localization.logout,
            ),
          ),
        ),
        const BottomPadding(),
      ],
    );
  }
}
