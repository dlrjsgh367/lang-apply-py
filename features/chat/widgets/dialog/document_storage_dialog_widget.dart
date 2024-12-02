import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/common/video_thumnail_widget.dart';
import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_contract_viewer_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_media_detail_widget.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/chat_file_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/tabs/common_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentStorageDialogWidget extends ConsumerStatefulWidget {
  const DocumentStorageDialogWidget({
    super.key,
    required this.uuid,
    required this.chatUsers,
    required this.showVacationDialog,
    required this.showResignationDialog,
    required this.showParentAgreeDialog,
    required this.showSalaryDialog,
  });

  final String uuid;
  final Map<String, dynamic> chatUsers;
  final Function showVacationDialog;
  final Function showResignationDialog;
  final Function showParentAgreeDialog;
  final Function showSalaryDialog;

  @override
  ConsumerState<DocumentStorageDialogWidget> createState() =>
      _DocumentStorageDialogWidgetState();
}

class _DocumentStorageDialogWidgetState
    extends ConsumerState<DocumentStorageDialogWidget>
    with SingleTickerProviderStateMixin, Files {
  int lastPage = 0;
  int currentPage = 1;
  bool isLazeLoading = false;

  int lastDocPage = 0;
  int currentDocPage = 1;
  bool isDocLazeLoading = false;

  late TabController _tabController;
  ScrollController tabScrollController = ScrollController();

  List fileList = [];
  List mediaList = [];

  @override
  void initState() {
    _tabController = TabController(
        length: 2,
        vsync: this,
        animationDuration: const Duration(milliseconds: 0));
    _tabController.animation?.addListener(() {});

    Future(() {
      getChatFileList('file', 1);
      getChatFileList('media', 1);
    });

    super.initState();
  }

  getChatFileList(String type, int? page) async {
    UserModel? userInfo = ref.read(userProvider);

    ApiResultModel? result;

    if (type == 'file') {
      result = await ref.read(chatControllerProvider.notifier).getChatFileList(
          widget.uuid,
          userInfo!.memberType == MemberTypeEnum.jobSeeker
              ? 'JOBSEEKER'
              : 'RECRUITER');
    } else {
      result = await ref.read(chatControllerProvider.notifier).getChatMediaList(
          widget.uuid,
          userInfo!.memberType == MemberTypeEnum.jobSeeker
              ? 'JOBSEEKER'
              : 'RECRUITER',
          page!);
    }

    if (result.type == 1) {
      if (type == 'file') {
        setState(() {
          lastDocPage = result!.page['lastPage'];
          if (currentDocPage == 1) {
            fileList = [];
          }
          for (var list in result.data) {
            ChatMediaModel file = ChatMediaModel.fromJson(list);
            // if(file.attachment != null){
            fileList.add(file);
            // }
          }
        });
      } else {
        setState(() {
          lastPage = result!.page['lastPage'];
          if (currentPage == 1) {
            mediaList = [];
          }
          for (var list in result.data) {
            ChatMediaModel file = ChatMediaModel.fromJson(list);
            if (file.attachment != null) {
              mediaList.add(file);
            }
          }
        });
      }
    } else if (result.status != 200) {
      if (!mounted) return null;
      showErrorAlert('알림', '데이터 통신에 실패했습니다.');
    } else {
      if (!mounted) return null;
      showErrorAlert('알림', '데이터 통신에 실패했습니다.');
    }

    setState(() {
      isLazeLoading = false;
      isDocLazeLoading = false;
    });
  }

  showErrorAlert(String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: title,
            alertContent: content,
            alertConfirm: '확인',
            alertCancel: '취소',
            onConfirm: () {
              context.pop(context);
              context.pop(context);
              context.pop(context);
            },
            onCancel: () {
              context.pop(context);
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  showDocumentDetailDialog(String messageUuid, int jaIdx, int jpIdx) {
    showDialog(
        context: context,
        useSafeArea: false,
        builder: (BuildContext context) {
          return ChatContractViewerWidget(
            messageUuid: messageUuid,
            uuid: widget.uuid,
            chatUsers: widget.chatUsers,
            jaIdx: jaIdx,
            jpIdx: jpIdx,
          );
        });
  }

  showMediaDetailDialog(
      String type, String mediaUrl, String msgKey, String created,
      {isVideo = false}) {
    showDialog(
        context: context,
        useSafeArea: false,
        builder: (BuildContext context) {
          return ChatMediaDetailWidget(
            type: type,
            mediaUrl: mediaUrl,
            deleteChatFile: deleteChatFileAlert,
            msgKey: msgKey,
            chatUsers: widget.chatUsers,
            uuid: widget.uuid,
            isVideo: isVideo,
            created: created,
          );
        });
  }

  deleteChatFileAlert(String msgKey) {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: '사진/동영상 삭제',
            alertContent: '선택한 사진/동영상을 삭제하시겠어요? \n 삭제 후에는 복원이 불가능해요.',
            alertConfirm: '삭제',
            alertCancel: '취소',
            onConfirm: () {
              context.pop();
              deleteChatFile(msgKey);
            },
          );
        });
  }

  deleteChatFile(String msgKey) async {
    var apiUploadResult =
        await ref.read(chatControllerProvider.notifier).deleteChatFile(msgKey);

    if (apiUploadResult.type == 1) {
      await deleteSingleMessage(msgKey);
      setState(() {
        mediaList = [];
      });
      await getChatFileList('media', 1);
      await deleteSingleMessage(msgKey);
      showDefaultToast('삭제되었습니다.');
      context.pop();
    } else {
      showDefaultToast('삭제에 실패하였습니다.');
      return false;
    }
  }

  deleteSingleMessage(String msgKey) {
    if (widget.chatUsers.isNotEmpty) {
      ref
          .read(chatControllerProvider.notifier)
          .deleteMessage(widget.uuid, msgKey, widget.chatUsers);
    } else {
      showDefaultToast('메시지 삭제에 실패했습니다.');
    }
  }

  returnFileTitle(String type) {
    switch (type) {
      case 'STANDARD':
        return '표준 근로 계약서';
      case 'SALARY':
        return '급여 내역서';
      case 'RESIGNATION':
        return '사직서';
      case 'PARENT':
        return '친권자 동의서';
      case 'CONSTRUCTION':
        return '건설일용 근로자 계약서';
      case 'YOUNG':
        return '연소 근로자 계약서';
      case 'SHORT':
        return '단기간 근로자 계약서';
      case 'VACATION':
        return '휴가 신청서';
      default:
        return '표준 근로 계약서';
    }
  }

  returnFileSize(int byte) {
    if (byte >= 1000000000) {
      return '${(byte.toDouble() * 0.000000001).toStringAsFixed(2)}gb';
    } else if (byte >= 1000000) {
      return '${(byte.toDouble() * 0.000001).toStringAsFixed(2)}mb';
    } else if (byte >= 1000) {
      return '${(byte.toDouble() * 0.001).toStringAsFixed(2)}kb';
    } else {
      return '${(byte.toDouble()).toStringAsFixed(2)}byte';
    }
  }

  loadMore() {
    if (lastPage > 1 && currentPage + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        currentPage = currentPage + 1;
      });
      getChatFileList('media', currentPage);
    }
  }

  loadMoreDoc() {
    if (lastDocPage > 1 && currentDocPage + 1 <= lastDocPage) {
      setState(() {
        isDocLazeLoading = true;
        currentDocPage = currentDocPage + 1;
      });
      getChatFileList('file', currentDocPage);
    }
  }

  Future<void> _openFileManager(String date, String url) async {
    if(isOneMonthPassed(date)){
      showDefaultToast('다운로드 기간이 만료되었습니다.');
      return;
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  bool isOneMonthPassed(String date) {
    DateTime now = DateTime.now();

    DateTime createDate = DateTime.parse(date);
    DateTime oneMonthLater = DateTime(createDate.year, createDate.month + 1,
        createDate.day, createDate.hour, createDate.minute);
    return now.isAfter(oneMonthLater);
  }


  int activeTab = 0;

  @override
  Widget build(BuildContext context) {
    var roomInfo = ref.watch(chatUserRoomInfoProvider);

    return Scaffold(
      appBar: const ModalAppbar(
        title: '서류보관함',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 8.w),
            child: CommonTab(
              setTab: (data) {
                setState(() {
                  activeTab = data;
                });
              },
              activeTab: activeTab,
              tabTitleArr: ['근무 서류 및 첨부파일', '사진 및 동영상'],
            ),
          ),
          Expanded(
            child: activeTab == 0
                ? fileList.isEmpty
                    ? const CommonEmpty(text: '파일이 없습니다.')
                    : LazyLoadScrollView(
                        isLoading: isDocLazeLoading,
                        onEndOfPage: () => loadMoreDoc(),
                        child: CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    childCount: fileList.length,
                                    (context, index) {
                                  var data = fileList[index];

                                  return GestureDetector(
                                    onTap: () {
                                      if (data!.attachment != null &&
                                          data!.caContractType == 'ETC') {
                                        _openFileManager(data!.createdAt,
                                            '${ApiConstants.imageDomain}/${data!.attachment['diskDirectory']}/${data!.attachment['diskName']}');
                                      } else if (data!.caContractType ==
                                          'VACATION') {
                                        widget.showVacationDialog(
                                            data!.caMessageKey,
                                            data!.createdAt);
                                      } else if (data!.caContractType ==
                                          'SALARY') {
                                        widget.showSalaryDialog(
                                            data!.caMessageKey,
                                            data!.createdAt);
                                      } else if (data!.caContractType ==
                                          'RESIGNATION') {
                                        widget.showResignationDialog(
                                            data!.caMessageKey,
                                            data!.createdAt,
                                            null);
                                      } else if (data!.caContractType ==
                                          'PARENT') {
                                        widget.showParentAgreeDialog(
                                            data!.caMessageKey,
                                            data!.createdAt,
                                            null);
                                      } else {
                                        showDocumentDetailDialog(
                                            data!.caMessageKey,
                                            roomInfo!.jaIdx,
                                            roomInfo.jpIdx);
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: 8.w),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.w),
                                        color: Colors.transparent,
                                        border: Border.all(
                                          width: 1.w,
                                          color: CommonColors.grayF2,
                                        ),
                                      ),
                                      padding: EdgeInsets.fromLTRB(
                                          20.w, 24.w, 20.w, 24.w),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            data!.caContractType == 'ETC'
                                                ? 'assets/images/icon/iconDoc02.png'
                                                : 'assets/images/icon/iconDoc01.png',
                                            width: 24.w,
                                            height: 24.w,
                                          ),
                                          SizedBox(
                                            width: 8.w,
                                          ),
                                          Expanded(
                                            child: Text(
                                              data.attachment != null &&
                                                      data!.caContractType ==
                                                          'ETC'
                                                  ? data.attachment['name']
                                                  : returnFileTitle(
                                                      data!.caContractType),
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.gray4d),
                                            ),
                                          ),
                                          Text(
                                            DateFormat('yyyy-MM-dd HH:mm')
                                                .format(DateTime.parse(
                                                    data!.createdAt)),
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: CommonColors.gray80),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const BottomPadding(),
                          ],
                        ),
                      )
                : mediaList.isEmpty
                    ? const CommonEmpty(text: '파일이 없습니다.')
                    : LazyLoadScrollView(
                        isLoading: isLazeLoading,
                        onEndOfPage: () => loadMore(),
                        child: CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 36.w),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4.w,
                                  mainAxisSpacing: 4.w,
                                  mainAxisExtent: 104.w,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  childCount: mediaList.length,
                                  (context, index) {
                                    var data = mediaList[index];
                                    return GestureDetector(
                                      onTap: () {
                                        showMediaDetailDialog(
                                            data.attachment['type']
                                                        .split('/')
                                                        .first ==
                                                    'image'
                                                ? 'photo'
                                                : 'video',
                                            data.galleryImage['url'],
                                            data.caMessageKey,
                                            data.createdAt);
                                      },
                                      child: Container(
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4.w),
                                        ),
                                        child: data.attachment['type']
                                                    .split('/')
                                                    .first ==
                                                'image'
                                            ? ExtendedImgWidget(
                                                imgUrl:
                                                    data.galleryImage['url'],
                                                imgFit: BoxFit.cover,
                                                imgWidth:
                                                    (CommonSize.vw - 48.w) / 3,
                                                // imgHeight: 50,
                                              )
                                            : VideoThumbnailWidget(
                                                imgUrl:
                                                    data.galleryImage['url'],
                                                imgFit: BoxFit.cover,
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const BottomPadding()
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
