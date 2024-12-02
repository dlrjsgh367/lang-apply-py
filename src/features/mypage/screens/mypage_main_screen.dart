import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/mypage/screens/job_seeker_mypage_screen.dart';
import 'package:chodan_flutter_app/features/mypage/screens/recruiter_mypage_screen.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MypageMainScreen extends ConsumerStatefulWidget {
  MypageMainScreen({super.key});

  @override
  ConsumerState<MypageMainScreen> createState() => _MypageMainScreenState();
}

class _MypageMainScreenState extends ConsumerState<MypageMainScreen> {
  void setSilver(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('silver');
    setState(() {
      if (data == 'true') {
        prefs.setString('silver', 'true');
        ScreenUtil.init(context,
            designSize:
                const Size.fromWidth(360 - 360 * 0.1)); // 변경된 디자인 사이즈로 적용
      } else {
        prefs.setString('silver', 'false');
        ScreenUtil.init(context,
            designSize: const Size.fromWidth(360)); // 변경된 디자인 사이즈로 적용
      }
      // silverLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    return userInfo!.memberType == MemberTypeEnum.jobSeeker
        ? JobSeekerMypageScreen(
            setSilver: () {
              setSilver(context);
            },
          )
        : RecruiterMypageScreen(
            setSilver: () {
              setSilver(context);
            },
          );
  }
}
