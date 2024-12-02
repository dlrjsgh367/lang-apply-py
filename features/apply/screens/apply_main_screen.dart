import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/apply/screens/apply_recruiter_screen.dart';
import 'package:chodan_flutter_app/features/apply/screens/apply_screen.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class ApplyMainScreen extends ConsumerStatefulWidget {
  const ApplyMainScreen({this.tab, super.key});

  final String? tab;

  @override
  ConsumerState<ApplyMainScreen> createState() => _ApplyMainScreenState();
}

class _ApplyMainScreenState extends ConsumerState<ApplyMainScreen> {
  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    return userInfo != null
        ? userInfo!.memberType == MemberTypeEnum.jobSeeker
            ? ApplyScreen(tab: widget.tab)
            : ApplyRecruiterScreen(tab: widget.tab)
        : const Loader();
  }
}
