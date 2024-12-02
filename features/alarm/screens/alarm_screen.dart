import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/alarm/controller/alarm_controller.dart';
import 'package:chodan_flutter_app/features/alarm/widgets/alarm_list_widget.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/alarm_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class AlarmScreen extends ConsumerStatefulWidget {
  const AlarmScreen({super.key});

  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen> with Alerts {
  bool isLoading = true;
  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;

  getAlarmList(int page) async {
    UserModel? userInfo = ref.read(userProvider);
    if(userInfo != null){
      ApiResultModel result = await ref.read(alarmControllerProvider.notifier).getAlarmList(page, userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          List<AlarmModel> data = result.data;
          if (page == 1) {
            ref.read(alarmListProvider.notifier).update((state) => data);
          } else {
            ref
                .read(alarmListProvider.notifier)
                .update((state) => [...state, ...data]);
          }
          lastPage = result.page['lastPage'];
          isLazeLoading = false;
        }
      }else if (result.status != 200) {
        showDefaultToast(localization.dataCommunicationFailed);
      } else {
        if (!mounted) return null;
        showNetworkErrorAlert(context);
      }

    }else{
      if (!mounted) return null;
      context.replace('/');
    }
  }

  deleteAlarm(int alarmKey) async {
    ApiResultModel result =
        await ref.read(alarmControllerProvider.notifier).deleteAlarm(alarmKey);
    if (result.status == 200 && result.type == 1) {
      setState(() {
        List<AlarmModel> alarmListData = ref.read(alarmListProvider);
        List newAlarmList = alarmListData
            .where((AlarmModel element) => element.alarmKey != alarmKey)
            .toList();

        ref
            .read(alarmListProvider.notifier)
            .update((state) => [...newAlarmList]);
        showDefaultToast(localization.notificationDeleted);
      });
    }
  }

  readAllAlarm() async {
    ApiResultModel result = await ref.read(alarmControllerProvider.notifier).readAllAlarm();
  }

  Future _loadMore() async {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        getAlarmList(page);
      });
    }
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      getAlarmList(page),
    ]).then((value) {
      readAllAlarm();
      savePageLog();
      getUserData(ref);
    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  getUserData(WidgetRef ref) async {
    ApiResultModel result =
        await ref.read(authControllerProvider.notifier).getUserData();
    if (result.type == 1) {
      if (result.status == 200) {
        setState(() {
          ref.read(userProvider.notifier).update((state) => result.data);
        });
      }
    }
  }

  late Future<void> _allAsyncTasks;

  @override
  void initState() {
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<AlarmModel> alarmList = ref.watch(alarmListProvider);
    return Scaffold(
      appBar: CommonAppbar(
        title: localization.notification,
      ),
      body: isLoading
          ? const Loader()
          : alarmList.isEmpty
              ? CommonEmpty(text: localization.noNotifications)
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: LazyLoadScrollView(
                        onEndOfPage: () => _loadMore(),
                        child: CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.only(top: 16.w),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  childCount: alarmList.length,
                                  (context, index) {
                                    AlarmModel alarmItem = alarmList[index];
                                    return AlarmListWidget(
                                      alarmItem: alarmItem,
                                      idx: index,
                                      deleteAlarm: deleteAlarm,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const BottomPadding(
                              extra: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20.w,
                      right: 20.w,
                      bottom: CommonSize.commonBottom,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          color: CommonColors.grayF2,
                        ),
                        height: 48.w,
                        alignment: Alignment.center,
                        child: Text(
                          localization.notificationsLimitedToLast7Days,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray80,
                          ),
                        ),
                      ),
                    ),
                    if (isLazeLoading)
                      Positioned(
                        bottom: CommonSize.commonBottom,
                        child: const Loader(),
                      ),
                  ],
                ),
    );
  }
}
