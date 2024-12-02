import 'package:chodan_flutter_app/core/back_listener.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/apply/screens/apply_list_screen.dart';
import 'package:chodan_flutter_app/features/apply/screens/receive_list_screen.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_bottom_appbar.dart';
import 'package:chodan_flutter_app/widgets/appbar/red_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/features/apply/controller/apply_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  const ApplyScreen({this.tab, super.key});

  final String? tab;

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen>
    with BackButtonEvent, Alerts {
  int activeTab = 0;
  int unReadCount = 0;
  bool isLoading = false;
  late Future<void> _allAsyncTasks;

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getUserData(),
      getUnReadCount(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((value) {
      if (mounted) {
        setState(() {
          if (widget.tab != null && widget.tab == 'apply') {
            setTab(1);
          }
          isLoading = false;
        });
      }
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
  }

  setTab(data) {
    setState(() {
      activeTab = data;
      isLoading = true;
    });
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            backPress();
          }
        },
        child: Scaffold(
          appBar: RedAppbar(
            setTab: setTab,
            activeTab: activeTab,
            tabTitleArr: [localization.jobPostApplied, localization.receivedProposal],
            type: 'jobseeker',
            unCount: unReadCount,
          ),
          bottomNavigationBar: const CommonBottomAppbar(type: 'apply'),
          body: isLoading
              ? const Loader()
              : activeTab == 0
                  ? const ApplyListScreen()
                  : ReceiveListScreen(
                      getUnReadCount: getUnReadCount,
                      unReadCount: unReadCount,
                    ),
        ));
  }
}
