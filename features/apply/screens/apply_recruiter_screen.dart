import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/apply/screens/apply_recruiter_list_screen.dart';
import 'package:chodan_flutter_app/features/apply/screens/receive_recruiter_list_screen.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_bottom_appbar.dart';
import 'package:chodan_flutter_app/widgets/appbar/red_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/features/apply/controller/apply_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplyRecruiterScreen extends ConsumerStatefulWidget {
  const ApplyRecruiterScreen({super.key, this.tab});

  final String? tab;

  @override
  ConsumerState<ApplyRecruiterScreen> createState() =>
      _ApplyRecruiterScreenState();
}

class _ApplyRecruiterScreenState extends ConsumerState<ApplyRecruiterScreen> {
  int activeTab = 0;
  int unReadCount = 0;
  bool isLoading = false;
  late Future<void> _allAsyncTasks;

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getUnReadCount(),
      getUserData(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((_) {
      if (widget.tab != null && widget.tab == 'apply') {
        activeTab = 1;
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    if (token != null) {
      ApiResultModel result =
          await ref.read(authControllerProvider.notifier).getUserData();
      if (result.type == 1) {
        setState(() {
          ref.read(userProvider.notifier).update((state) => result.data);
          ref.read(userAuthProvider.notifier).update((state) => result.data);
        });
      }
    }
  }

  getUnReadCount() async {
    setState(() {
      isLoading = true;
    });
    ApiResultModel result =
        await ref.read(applyControllerProvider.notifier).getUnReadCount();
    if (result.type == 1) {
      setState(() {
        unReadCount = result.data;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  setTab(data) {
    setState(() {
      savePageLog();
      activeTab = data;
      getUserData();
      getUnReadCount();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: RedAppbar(
          setTab: setTab,
          activeTab: activeTab,
          tabTitleArr: [localization.applicant, localization.sentProposal],
          type: 'recruiter',
          unCount: unReadCount,
        ),
        bottomNavigationBar: const CommonBottomAppbar(type: 'apply'),
        body: isLoading
            ? const Loader()
            : activeTab == 0
                ? ReceiveRecruiterListScreen(unReadCount: unReadCount)
                : const ApplyRecruiterListScreen());
  }
}
