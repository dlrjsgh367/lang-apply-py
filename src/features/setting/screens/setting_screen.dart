import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/setting/screens/setting_recriuter_screen.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
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

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    return Scaffold(
      appBar: CommonAppbar(
        title: localization.217,
      ),
      // body: userInfo!.memberType == MemberTypeEnum.jobSeeker
      //     ? const SettingSeekerScreen()
      //     : const SettingRecruiterScreen(),
      body: SettingRecruiterScreen(),
    );
  }
}
