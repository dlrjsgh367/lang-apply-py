import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/consult_password_widget.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';

class MyConsultScreen extends ConsumerStatefulWidget {
  const MyConsultScreen({super.key});

  @override
  ConsumerState<MyConsultScreen> createState() => _MyConsultScreenState();
}

class _MyConsultScreenState extends ConsumerState<MyConsultScreen> with Alerts {
  List<BoardModel> boardList = [];
  bool isLoading = true;
  var isLazeLoading = false;
  var page = 1;
  var lastPage = 1;
  var total = 0;
  late Future<void> _allAsyncTasks;
  bool isSelf = false;

  _boardLoadMore() async {
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
      });
      page = page + 1;
      Future(() {
        getBoardListData(page);
      });
    }
  }

  getBoardListData(int page) async {
    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .getConsultListData(page, isSelf);
    if (result.type == 1) {
      setState(() {
        List<BoardModel> data = result.data;
        if (page == 1) {
          boardList = [...data];
        } else {
          boardList = [...boardList, ...data];
        }
        lastPage = result.page['lastPage'];
        total = result.page['total'];
        isLazeLoading = false;
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
    isLoading = false;
  }

  pushAfterFunc() {
    getBoardListData(1);
  }

  showPasswordDialog(
      BuildContext context, int idx, Set<Future<Set>> Function() afterFunc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConsultPasswordWidget(idx: idx, afterFunc: afterFunc);
      },
    );
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getBoardListData(page),
    ]);
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
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

  @override
  void dispose() {
    _allAsyncTasks.whenComplete(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: localization.225,
      ),
      body: LazyLoadScrollView(
        onEndOfPage: () => _boardLoadMore(),
        child: !isLoading
            ? Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.all(20.w),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            '노동관계 분야 전반에 대한 사항을 분석하여\n합리적인 개선방안을 제시해드려요.',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: CommonColors.black2b,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 36.w),
                        sliver: SliverToBoxAdapter(
                          child: GestureDetector(
                            onTap: () {
                              context.push('/my/consult/create').then(
                                    (_) => {pushAfterFunc()},
                                  );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.w),
                                color: CommonColors.red02,
                              ),
                              height: 60.w,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/icon/iconHeadRed.png',
                                    width: 18.w,
                                    height: 18.w,
                                  ),
                                  SizedBox(
                                    width: 6.w,
                                  ),
                                  Text(
                                    localization.265,
                                    style: TextStyle(
                                        color: CommonColors.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 6.w),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Text(
                                localization.274,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.black2b),
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Text(
                                "총 ${total}건",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray80),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          isSelf = !isSelf;
                                          getBoardListData(1);
                                        });
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        padding: EdgeInsets.fromLTRB(10.w, 10.w, 0, 10.w),
                                        child: Row(
                                          children: [
                                            Text(
                                              localization.275,
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors.gray66),
                                            ),
                                            SizedBox(width: 4.w,),
                                            Image.asset(
                                              isSelf
                                                  ? 'assets/images/icon/IconCheckActive.png'
                                                  : 'assets/images/icon/IconCheck.png',
                                              width: 20.w,
                                              height: 20.w,
                                            ),
                                          ]

                                        ),
                                      )
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      boardList.isNotEmpty
                          ? SliverPadding(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  childCount: boardList.length,
                                  (context, index) {
                                    return GestureDetector(
                                      onTap: () => {
                                        if (boardList[index].secretType == 1)
                                          {
                                            showPasswordDialog(
                                                context,
                                                boardList[index].key,
                                                () => {
                                                      context
                                                          .push(
                                                              '/my/consult/${boardList[index].key}')
                                                          .then((_) =>
                                                              {pushAfterFunc()})
                                                    })
                                          }
                                        else
                                          {
                                            context
                                                .push(
                                                    '/my/consult/${boardList[index].key}')
                                                .then(
                                                  (_) => {pushAfterFunc()},
                                                )
                                          }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: index == 0 ? 0 : 10.w),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.w),
                                          border: Border.all(
                                            width: 1.w,
                                            color: CommonColors.grayF2,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  12.w, 16.w, 12.w, 16.w),
                                              child: Row(
                                                children: [
                                                  boardList[index].boStatus ==
                                                          "DONE"
                                                      ? Container(
                                                          width: 54.w,
                                                          height: 24.w,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              width: 1.w,
                                                              color:
                                                                  CommonColors
                                                                      .red,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        500.w),
                                                          ),
                                                          child: Text(
                                                            localization.198,
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  CommonColors
                                                                      .red,
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          500
                                                                              .w),
                                                              color:
                                                                  CommonColors
                                                                      .grayF2),
                                                          alignment:
                                                              Alignment.center,
                                                          width: 70.w,
                                                          height: 24.w,
                                                          child: Text(
                                                            localization.199,
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color:
                                                                  CommonColors
                                                                      .grayB2,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                  SizedBox(
                                                    width: 4.w,
                                                  ),
                                                  if (boardList[index]
                                                          .secretType ==
                                                      1)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 4.w),
                                                      child: Image.asset(
                                                        'assets/images/icon/iconLockRed.png',
                                                        width: 18.w,
                                                        height: 18.w,
                                                      ),
                                                    ),
                                                  Expanded(
                                                    child: Text(
                                                      '${boardList[index].title}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: CommonColors
                                                            .black2b,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  Text(
                                                    DateFormat('yyyy.MM.dd')
                                                        .format(
                                                      DateTime.parse(
                                                          boardList[index]
                                                              .createdAt
                                                              .replaceAll(
                                                                  "T", " ")),
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color:
                                                          CommonColors.grayB2,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (boardList[index].boStatus ==
                                                "DONE")
                                              Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    12.w, 16.w, 12.w, 16.w),
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        top: BorderSide(
                                                            width: 1.w,
                                                            color: CommonColors
                                                                .grayF2))),
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/icon/iconReply.png',
                                                      width: 18.w,
                                                      height: 18.w,
                                                    ),
                                                    SizedBox(
                                                      width: 4.w,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        // '${boardList[index].title}',
                                                        localization.276,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          color: CommonColors
                                                              .black2b,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10.w,
                                                    ),
                                                    Text(
                                                      boardList[index]
                                                          .relatedResList != null ? DateFormat('yyyy.MM.dd').format(
                                                          DateTime.parse(boardList[index]
                                                              .relatedResList!.relatedCreatedAt
                                                              .replaceAll("T", " "))
                                                      ): '',
                                                      style: TextStyle(
                                                        fontSize: 13.sp,
                                                        color:
                                                            CommonColors.grayB2,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Column(
                                      //   children: [
                                      //     Row(
                                      //       children: [
                                      //         Text(
                                      //             '${boardList[index].secretType} ${boardList[index].title}'),
                                      //         Text(DateFormat('yyyy.MM.dd').format(
                                      //           DateTime.parse(boardList[index]
                                      //               .createdAt
                                      //               .replaceAll("T", " ")),
                                      //         ))
                                      //       ],
                                      //     ),
                                      //     Container(
                                      //       child: boardList[index].boStatus == "DONE"
                                      //           ? Row(
                                      //         children: [
                                      //           const Text("---답변입니다."),
                                      //           Text(DateFormat('yyyy.MM.dd')
                                      //               .format(
                                      //             DateTime.parse(boardList[index]
                                      //                 .updatedAt
                                      //                 .replaceAll("T", " ")),
                                      //           ))
                                      //         ],
                                      //       )
                                      //           : const SizedBox.shrink(),
                                      //     )
                                      //   ],
                                      // ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : SliverToBoxAdapter(
                              child: SizedBox(
                                  width: CommonSize.vw,
                                  height: CommonSize.vw,
                                  child: Center(
                                      child: CommonEmpty(text: localization.277))),
                            ),
                      const BottomPadding(),
                    ],
                  ),
                ],
              )
            : const Loader(),
      ),
    );
  }
}
