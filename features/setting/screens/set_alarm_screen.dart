import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/setting/screens/set_alarm_recruiter_screen.dart';
import 'package:chodan_flutter_app/features/setting/screens/set_alarm_seeker_screen.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class SetAlarmScreen extends ConsumerStatefulWidget {
  const SetAlarmScreen({super.key});

  @override
  ConsumerState<SetAlarmScreen> createState() => _SetAlarmScreenState();
}

class _SetAlarmScreenState extends ConsumerState<SetAlarmScreen> {
  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    return Scaffold(
        appBar: const CommonAppbar(
          title: '알림 설정',
        ),
        body: userInfo!.memberType == MemberTypeEnum.jobSeeker
            ? const SetAlarmSeekerScreen()
            : const SetAlarmRecruiterScreen());
  }
}
