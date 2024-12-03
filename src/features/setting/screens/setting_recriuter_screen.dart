import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/menu/widgets/btn_menu.dart';
import 'package:chodan_flutter_app/features/menu/widgets/title_menu.dart';
import 'package:chodan_flutter_app/features/mypage/service/logout.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingRecruiterScreen extends ConsumerStatefulWidget {
  SettingRecruiterScreen({super.key});

  @override
  ConsumerState<SettingRecruiterScreen> createState() =>
      _SettingRecruiterScreenState();
}

class _SettingRecruiterScreenState
    extends ConsumerState<SettingRecruiterScreen> {
  void setSilver(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('silver');
    setState(() {
      if (data == 'true') {
        ScreenUtil.init(context,
            designSize:
                const Size.fromWidth(360 - 360 * 0.1)); // 변경된 디자인 사이즈로 적용
      } else {
        ScreenUtil.init(context,
            designSize: const Size.fromWidth(360)); // 변경된 디자인 사이즈로 적용
      }
    });
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 16.w,
          ),
        ),
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
            context.push('/my/company/update');
          },
        ),
        if (userInfo!.loginType == 'email')
          BtnMenu(
            text: localization.411,
            tabFunc: () {
              context.push('/setting/password');
            },
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 16.w,
          ),
        ),
        TitleMenu(title: localization.668),
        BtnMenu(
          text: localization.414,
          tabFunc: () {
            context.push('/setting/alarm');
          },
        ),
        BtnMenu(
          text: localization.415,
          tabFunc: () {
            context.push('/withdrawal');
          },
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 32.w, 20.w, 0),
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
