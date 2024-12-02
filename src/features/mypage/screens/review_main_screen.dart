import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/mypage/screens/review_company_screen.dart';
import 'package:chodan_flutter_app/features/mypage/screens/review_jobseeker_screen.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class ReviewMainScreen extends ConsumerStatefulWidget {
  const ReviewMainScreen({super.key});
  @override
  ConsumerState<ReviewMainScreen> createState() => _ReviewMainScreenState();
}

class _ReviewMainScreenState extends ConsumerState<ReviewMainScreen> {
  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    return userInfo!.memberType == MemberTypeEnum.jobSeeker
        ? const ReviewCompanyScreen() // 구직자 => 회사 리뷰
        : const ReviewJobSeekerScreen() // 구인자 => 구직자 리뷰
    ;
  }
}