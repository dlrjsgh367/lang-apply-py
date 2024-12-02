import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';
import 'package:chodan_flutter_app/features/menu/widgets/event_list_widget.dart';
import 'package:chodan_flutter_app/models/address_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  late Future<void> _allAsyncTasks;

  bool isLoading = true;
  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;
  List<BoardModel> eventList = [];
  int total = 0;

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      getEventList(page),
      savePageLog(),
    ]);
  }

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

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.event.type);
  }

  getEventList(int page) async {
    ApiResultModel result =
        await ref.read(menuControllerProvider.notifier).getEventList(page);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          total = result.page['total'];
        });
        List<BoardModel> data = result.data;

        if (page == 1) {
          eventList = [...data];
          ref.read(eventListProvider.notifier).update((state) => eventList);
        } else {
          // alarmList = [...alarmList, ...data];
          ref
              .read(eventListProvider.notifier)
              .update((state) => [...state, ...data]);
        }
        lastPage = result.page['lastPage'];
        isLazeLoading = false;
      }
    }
  }

  Future _loadMore() async {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        getEventList(page);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BoardModel> eventList = ref.watch(eventListProvider);
    List<DefineModel> industryList = ref.watch(industryListProvider);
    List<AddressModel> areaList = ref.watch(areaListProvider);
    return Scaffold(
      appBar: const CommonAppbar(
        title: '이벤트',
      ),
      body: isLoading
          ? const Loader()
          : eventList.isEmpty
              ? const CommonEmpty(text: '이벤트가 없습니다.')
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: LazyLoadScrollView(
                        onEndOfPage: () => _loadMore(),
                        child: CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 8.w),
                              sliver: SliverToBoxAdapter(
                                child: Text(
                                  "총 $total건",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: CommonColors.gray66,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  childCount: eventList.length,
                                  (context, index) {
                                    BoardModel eventItem = eventList[index];
                                    return EventListWidget(
                                        boardItem: eventItem);
                                  },
                                ),
                              ),
                            ),
                            const BottomPadding(),
                          ],
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
