import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/mypage/screens/document_jobseeker_screen.dart';
import 'package:chodan_flutter_app/features/mypage/screens/document_recruiter_screen.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class DocumentMainScreen extends ConsumerStatefulWidget {
  const DocumentMainScreen({super.key});
  @override
  ConsumerState<DocumentMainScreen> createState() => _DocumentMainScreenState();
}

class _DocumentMainScreenState extends ConsumerState<DocumentMainScreen> {

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    return userInfo!.memberType == MemberTypeEnum.jobSeeker
        ? const DocumentJobSeekerScreen()
        : const DocumentRecruiterScreen()
    ;
  }
}