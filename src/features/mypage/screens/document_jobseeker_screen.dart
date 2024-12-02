import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_contract_viewer_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/resignation_dialog_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/document_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/tabs/common_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class DocumentJobSeekerScreen extends ConsumerStatefulWidget {
  const DocumentJobSeekerScreen({super.key});

  @override
  ConsumerState<DocumentJobSeekerScreen> createState() =>
      _DocumentJobSeekerScreenState();
}

class _DocumentJobSeekerScreenState
    extends ConsumerState<DocumentJobSeekerScreen> {
  int activeTab = 0;

  bool isLoading = true;

  int contractPage = 1;
  int contractLastPage = 1;
  int contractTotal = 0;
  bool isContractLazeLoading = false;

  int resignationLetterPage = 1;
  int resignationLetterLastPage = 1;
  int resignationLetterTotal = 0;
  bool isResignationLetterLazeLoading = false;

  List<DocumentModel> contractList = [];
  List<DocumentModel> resignationLetterList = [];

  setTab(data) {
    setState(() {
      activeTab = data;
    });
  }

  String getDateTimeString(String date) {
    String formattedDate =
        DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(date));
    return formattedDate;
  }

  Future _contractLoadMore() async {
    if (isContractLazeLoading) {
      return;
    }
    if (contractLastPage > 1 && contractPage + 1 <= contractLastPage) {
      setState(() {
        isContractLazeLoading = true;
        contractPage = contractPage + 1;
        getContractList(contractPage);
      });
    }
  }

  Future _resignationLetterLoadMore() async {
    if (isResignationLetterLazeLoading) {ㅊ
      return;
    }
    if (resignationLetterLastPage > 1 &&
        resignationLetterPage + 1 <= resignationLetterLastPage) {
      setState(() {
        isResignationLetterLazeLoading = true;
        resignationLetterPage = resignationLetterPage + 1;
        getResignationLetterList(resignationLetterPage);
      });
    }
  }

  showDocumentDetailDialog(
      String roomUuid, String messageUuid, int jaIdx, int jpIdx) {
    showDialog(
        context: context,
        useSafeArea: false,
        builder: (BuildContext context) {
          return ChatContractViewerWidget(
            messageUuid: messageUuid,
            uuid: roomUuid,
            jaIdx: jaIdx,
            jpIdx: jpIdx,
          );
        });
  }

  // -------------- 사직서 보기
  showResignationLetter(String roomUuid, String messageUuid, String companyName,
      dynamic created, String? signImg) async {
    String formattedDate = '';
    String signImageUrl = '';

    if (created.runtimeType == Timestamp) {
      // Timestamp를 DateTime으로 변환
      DateTime dateTime = created.toDate();

      // DateTime을 원하는 형식의 문자열로 변환
      formattedDate = '${dateTime.year.toString().padLeft(4, '0')}년 '
          '${dateTime.month.toString().padLeft(2, '0')}월 '
          '${dateTime.day.toString().padLeft(2, '0')}일';
    } else if (created.runtimeType == String) {
      // Timestamp를 DateTime으로 변환
      DateTime dateTime = DateTime.parse(created);

      // DateTime을 원하는 형식의 문자열로 변환
      formattedDate = '${dateTime.year.toString().padLeft(4, '0')}년 '
          '${dateTime.month.toString().padLeft(2, '0')}월 '
          '${dateTime.day.toString().padLeft(2, '0')}일';
    }

    if (signImg == null || signImg == '') {
      var result = await ref
          .read(chatControllerProvider.notifier)
          .getMessageData(roomUuid, messageUuid);
      if (result.isNotEmpty) {
        signImageUrl = result['files'][0]['fileUrl'];
      }
    } else {
      signImageUrl = signImg;
    }
    showResignationLetterDialog(
        roomUuid, messageUuid, companyName, formattedDate, signImageUrl);
  }

  showResignationLetterDialog(String roomUuid, String messageUuid,
      String companyName, String formattedDate, String signImageUrl) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        return ResignationDialogWidget(
          roomUuid: roomUuid,
          messageUuid: messageUuid,
          created: formattedDate,
          signImg: signImageUrl,
          partnerName: companyName,
        );
      },
    );
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getContractList(contractPage),
      getResignationLetterList(resignationLetterPage)
    ]);
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  @override
  void initState() {
    super.initState();
    _getAllAsyncTasks().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  getContractList(int contractPage) async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getContractList(contractPage, 'jobseeker', userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          List<DocumentModel> resultData = result.data;
          setState(() {
            contractList = [...resultData];
          });
        }
      }
    }
  }

  getResignationLetterList(int resignationLetterPage) async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getResignationLetterList(
              resignationLetterPage, 'jobseeker', userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          List<DocumentModel> resultData = result.data;
          setState(() {
            resignationLetterList = [...resultData];
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: '계약서/사직서',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 12.w),
            child: CommonTab(
              setTab: setTab,
              activeTab: activeTab,
              tabTitleArr: const ['계약서', '사직서'],
            ),
          ),
          if (activeTab == 0)
            !isLoading
                ? Expanded(
                    child: contractList.isNotEmpty
                        ? LazyLoadScrollView(
                            onEndOfPage: () => _contractLoadMore(),
                            child: CustomScrollView(
                              slivers: [
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    childCount: contractList.length,
                                    (context, index) {
                                      var contractData = contractList[index];
                                      return GestureDetector(
                                        onTap: () {
                                          showDocumentDetailDialog(
                                              contractData.roomUuid,
                                              contractData.messageUuid,
                                              0,
                                              contractData.postingKey);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(20.w),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: CommonColors.gray100,
                                                  width: 1.w),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      contractData.companyName,
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: CommonColors
                                                            .black2b,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    getDateTimeString(
                                                        contractData.createdAt),
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          CommonColors.grayB2,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 4.w),
                                              Text(
                                                contractData.title,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: CommonColors.gray4d,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const BottomPadding(),
                              ],
                            ),
                          )
                        : const CommonEmpty(text: '작성된 계약서가 없습니다.'),
                  )
                : const Loader(),
          if (activeTab == 1)
            !isLoading
                ? Expanded(
                    child: resignationLetterList.isNotEmpty
                        ? LazyLoadScrollView(
                            onEndOfPage: () => _resignationLetterLoadMore(),
                            child: CustomScrollView(
                              slivers: [
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    childCount: resignationLetterList.length,
                                    (context, index) {
                                      var resignationLetterData =
                                          resignationLetterList[index];
                                      return GestureDetector(
                                        onTap: () {
                                          showResignationLetter(
                                              resignationLetterData.roomUuid,
                                              resignationLetterData.messageUuid,
                                              resignationLetterData.companyName,
                                              resignationLetterData.createdAt,
                                              resignationLetterData
                                                  .signImg?.url);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(20.w),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border: Border(
                                              bottom: BorderSide(
                                                  color: CommonColors.gray100,
                                                  width: 1.w),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      resignationLetterData
                                                          .companyName,
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: CommonColors
                                                            .black2b,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    getDateTimeString(
                                                        resignationLetterData
                                                            .createdAt),
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          CommonColors.grayB2,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 4.w),
                                              Text(
                                                resignationLetterData.title,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: CommonColors.gray4d,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const BottomPadding(),
                              ],
                            ),
                          )
                        : const CommonEmpty(text: '작성된 사직서가 없습니다.'),
                  )
                : const Loader()
        ],
      ),
    );
  }
}
