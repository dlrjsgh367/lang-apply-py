import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/logout.dart';
import 'package:chodan_flutter_app/features/setting/widgets/withdrawal_complete_widget.dart';
import 'package:chodan_flutter_app/features/setting/widgets/withdrawal_confirmation_widget.dart';
import 'package:chodan_flutter_app/features/setting/widgets/withdrawal_notice_widget.dart';
import 'package:chodan_flutter_app/features/setting/widgets/withdrawal_reason_widget.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/router.dart';
import 'package:chodan_flutter_app/router_notifier.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  late PageController _pageController;
  late List<Widget> withdrawalPageList;
  int withdrawalPageIndex = 0;

  bool isLoading = true;
  List<DefineModel> categoryList = [];

  Map<String, dynamic> userDeleteData = {
    'mocIdx': [],
    'moReason': '',
    'mobcDetail': '',
  };

  setUserDeleteData(String key, dynamic value) {
    userDeleteData[key] = value;
    if (key == 'moReason') {
      userDeleteData['mobcDetail'] = value;
    }
  }

  void movePage(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    _pageController
        .animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    )
        .whenComplete(() {
      setState(() {
        withdrawalPageIndex = index;
      });
    });
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getWithdrawalReasonCategoryList(),
    ]);
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  getWithdrawalReasonCategoryList() async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getWithdrawalReasonCategoryList();
    if (result.status == 200) {
      if (result.type == 1) {
        List<DefineModel> resultData = result.data;
        setState(() {
          categoryList = [...resultData];
        });
      }
    }
  }

  leaveMember() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(authControllerProvider.notifier)
          .leaveMember(userDeleteData, userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          movePage(3);
        }
      } else {
        showDefaultToast(localization.720);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _getAllAsyncTasks().then((_) {
      _pageController = PageController(initialPage: 0);
      withdrawalPageList = [
        WithdrawalConfirmationWidget(
          onPress: () {
            movePage(1);
          },
          onCancel: () {
            context.pop();
          },
        ),
        WithdrawalNoticeWidget(
          onPress: () {
            movePage(2);
          },
          onCancel: () {
            context.pop();
          },
        ),
        WithdrawalReasonWidget(
          data: categoryList,
          setData: setUserDeleteData,
          onPress: () {
            leaveMember();
          },
          onCancel: () {
            context.pop();
          },
        ),
        WithdrawalCompleteWidget(
          onPress: () async {
            logout(ref, context);
          },
        ),
      ];

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const CommonAppbar(
          title: localization.415,
        ),
        body: !isLoading
            ? PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                itemCount: withdrawalPageList.length,
                itemBuilder: (context, index) {
                  return withdrawalPageList[index];
                },
              )
            : const Loader(),
      ),
    );
  }
}
