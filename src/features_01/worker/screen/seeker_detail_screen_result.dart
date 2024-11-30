import 'dart:io';
import 'dart:math';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/location_service.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/start_chat_dialog_widget.dart';
import 'package:chodan_flutter_app/features/contract/service/pdf_api.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/map/service/map_service.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/features/worker/service/pdf_service.dart';
import 'package:chodan_flutter_app/features/worker/widgets/seeker_detail_bottom_app_bar_widget.dart';
import 'package:chodan_flutter_app/features/worker/widgets/seeker_viewer_widget.dart';
import 'package:chodan_flutter_app/features/worker/widgets/worker_evaluate_widget.dart';
import 'package:chodan_flutter_app/features/worker/widgets/worker_pofile_bottom_widget.dart';
import 'package:chodan_flutter_app/features/worker/widgets/worker_profile_widget.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/chat_room_model.dart';
import 'package:chodan_flutter_app/models/evaluate_model.dart';
import 'package:chodan_flutter_app/models/job_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/report_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/attachment_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/jobposting_recruiter_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/report_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/appbar_button.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/etc/dot_line.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;

import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class SeekerDetailScreen extends ConsumerStatefulWidget {
  const SeekerDetailScreen({required this.idx, super.key});

  final String idx;

  @override
  ConsumerState<SeekerDetailScreen> createState() => SeekerDetailScreenState();
}

class SeekerDetailScreenState extends ConsumerState<SeekerDetailScreen>
    with Alerts, Files {
  List<JobpostModel> jobpostList = [];
  bool isPdfDownload = false;

  void showAttachment({required String name, required List files}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CommonColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.5),
      useSafeArea: true,
      builder: (BuildContext context) {
        return AttachmentBottomSheet(
          title: localization.attachment,
          files: files,
          downloadFunc: downloadFile,
        );
      },
    );
  }

  late Future<void> _allAsyncTasks;

  bool isLoading = true;

  ProfileModel? profileData;

  EvaluateModel? evaluateData;

  Map<String, dynamic> currentPosition = MapService.currentPosition;

  List<JobseekerModel> matchingHistory = [];

  bool isRunning = false;

  List<JobseekerModel> matchingData = [];

  bool isMichinMatching = false;
  bool hasChatRoom = false;
  ChatRoomModel? chatRoomData;

  matchingKeyProfileList() async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .matchingKeyProfileList();
    if (result.status == 200) {
      if (result.type == 1) {
        ref
            .read(matchingKeyListProvider.notifier)
            .update((state) => [...result.data]);
      }
    }
  }

  Future<void> _getAllAsyncTasks() async {
    await getWorkerProfile(int.parse(widget.idx));
    await Future.wait<void>([
      savePageLog(),
      getMatchingHistory(profileData!.userInfo.key),
      getJobseekerEvaluate(profileData!.userInfo.key),
      getJobpostingPublishingListData(),
      getCurrentLocation(),
      getAcceptProfile(int.parse(widget.idx)),
      matchingKeyProfileList(),
      getReportReasonList(),
    ]);
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  getJobseekerEvaluate(int key) async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getJobseekerEvaluate(key);
    if (result.status == 200) {
      if (result.type == 1) {
        evaluateData = result.data;
      }
    }
  }

  bool existProfile = false;

  //받은 제안
  getAcceptProfile(int profileKey) async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getAcceptProfile(profileKey);
    if (result.status == 200) {
      if (result.type == 1) {
        existProfile = result.data;
      }
    }
  }

  getMatchingHistory(int profileKey) async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getMatchingHistory(profileKey);
    if (result.status == 200) {
      if (result.type == 1) {
        matchingHistory = result.data;
      }
    }
  }

  getCurrentLocation() async {
    UserModel? userInfo = ref.read(userProvider);
    LocationService? locationService;
    if (userInfo != null) {
      locationService = LocationService(user: userInfo);
    } else {
      locationService = LocationService(user: userInfo);
    }
    Position? location = await locationService.returnCurrentLocation();
    if (location != null) {
      setState(() {
        currentPosition['lat'] = location.latitude;
        currentPosition['lng'] = location.longitude;
      });
    }
  }

  getWorkerProfile(int profileKey) async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getWorkerProfile(profileKey);
    if (result.status == 200) {
      if (result.type == 1) {
        profileData = result.data;
      }
    } else if (result.status == 409) {
      if (result.type == -1303) {
        showError('프로필 오류', '비노출 설정된 프로필입니다.');
      }
    } else {
      showError('프로필 오류', '프로필 정보를 가져오는데 실패하였습니다.');
    }
  }

  showError(String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: title,
            alertContent: content,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  toggleLikesWorker(List list, int profileKey) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    if (list.contains(profileKey)) {
      await deleteLikesWorker(profileKey);
    } else {
      await addLikesWorker(profileKey);
    }
    isRunning = false;
  }

  deleteLikesWorker(int idx) async {
    var result = await ref
        .read(workerControllerProvider.notifier)
        .deleteLikesWorker(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterLikesFunc(idx);
      }
    } else {
      showDefaultToast(localization.dataCommunicationFailed);
    }
  }

  addLikesWorker(int idx) async {
    var result =
        await ref.read(workerControllerProvider.notifier).addLikesWorker(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterLikesFunc(idx);
        return result.data;
      }
    } else {
      if (result.type == -2801) {
        showDefaultToast(localization.alreadyRegisteredFavoriteCompany);
      } else if (mounted) {
        showDefaultToast(localization.dataCommunicationFailed);
      }
    }
  }

  likeAfterLikesFunc(int key) {
    List likeList = ref.read(workerLikesKeyListProvider);
    if (likeList.contains(key)) {
      likeList.remove(key);
      showDefaultToast(localization.removedFromFavoriteCandidates);
    } else {
      likeList.add(key);
      showDefaultToast(localization.savedToFavoriteCandidates);
    }
    setState(() {
      ref
          .read(workerLikesKeyListProvider.notifier)
          .update((state) => [...likeList]);
    });
  }

  proposeJobpost(int profileKey, int jobpostKey) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    Map<String, dynamic> params = {
      "mpIdx": profileKey,
      "jpIdx": jobpostKey,
    };

    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .proposeJobpost(params);
    isRunning = false;
    if (result.status == 200) {
      if (result.type == 1) {
        showDefaultToast(localization.proposalCompleted);
      } else {
        showDefaultToast(localization.proposalFailed);
      }
    } else if (result.status == 409) {
      showDefaultToast(localization.alreadyProposedOrAppliedJobPost);
    } else if (result.status == 401) {
      if (result.type == -2504) {
        showDefaultToast(localization.memberDoesNotAcceptProposals);
      } else {
        showDefaultToast(localization.proposalForSpecificJobCategoryOnly);
      }
    } else if (result.status != 200) {
      showDefaultToast(localization.proposalFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  showBottomSuggestJobposting(int profileKey) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CommonColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      barrierColor: CommonColors.barrier,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return JobpostingRecruiterBottomSheet(
          apply: proposeJobpost,
          profileKey: profileKey,
        );
      },
    );
  }

  getJobpostingPublishingListData() async {
    UserModel? userInfo = ref.read(userProvider);
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getJobpostingAllListData(userInfo!.key);
    if (result.status == 200) {
      if (result.type == 1) {
        List<JobpostModel> data = result.data;
        jobpostList = [...data];
      }
    }
  }

  @override
  void initState() {
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((_) {
      if (mounted) {
        setState(() {
          for (JobseekerModel item in matchingHistory) {
            for (JobpostModel jobpost in jobpostList) {
              if (item.jpIdx == jobpost.key) {
                matchingData.add(item);
                if (jobpost.michinMatching.isNotEmpty) {
                  isMichinMatching = true;
                }
                break;
              }
            }
          }
          var chatRooms = ref.watch(chatUserRoomProvider);
          for (ChatRoomModel chatRoom in chatRooms) {
            if (chatRoom.partnerInfo!.uuid == profileData!.userInfo.uuid) {
              setState(() {
                hasChatRoom = true;
                chatRoomData = chatRoom;
              });
              break;
            }
          }
          isLoading = false;
        });
      }
    });
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final GlobalKey _widgetKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();

  bool _showProfileTitle = false;

  void requestStoragePermission(Function afterFunc) async {
    if (Platform.isIOS) {
      afterFunc();
      return;
    } else if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        openAppSettings();
      }
      if (status.isGranted) {
        afterFunc();
      } else {}
    }
  }

  void _scrollListener() {
    final RenderObject? renderObject =
        _widgetKey.currentContext!.findRenderObject();
    if (renderObject is RenderBox) {
      final double widgetPosition = renderObject.localToGlobal(Offset.zero).dy;
      final double scrollPosition = _scrollController.position.pixels;
      setState(() {
        if (scrollPosition >
            widgetPosition -
                CommonSize.safePaddingTop +
                200.w +
                renderObject.size.height) {
          _showProfileTitle = true; // 스크롤이 위젯 아래로 이동한 경우
        } else {
          _showProfileTitle = false; // 스크롤이 위젯 위로 이동한 경우
        }
      });
    }
  }

  showJobseekerMenuDialog(JobseekerModel data, UserInfoModel userInfo,
      bool hasChatRoom, ChatRoomModel? chatRoomData, bool isMichinMatching) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CommonColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      barrierColor: CommonColors.barrier,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return ContentBottomSheet(
          contents: [
            BottomSheetButton(
                onTap: () {
                  context.push('/jobpost/${data.jpIdx}');
                },
                text: localization.matchedJobPost),
            BottomSheetButton(
                isRed: true,
                last: true,
                onTap: () {
                  context.pop();
                  if (!hasChatRoom) {
                    showStartChatDialog(data, userInfo, isMichinMatching);
                  } else {
                    context.push('/chat/detail/${chatRoomData!.id}');
                  }
                },
                text: localization.startChat),
          ],
        );
      },
    );
  }

  showStartChatDialog(
      JobseekerModel data, UserInfoModel userInfo, bool isMichinMatching) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      elevation: 0,
      builder: (BuildContext context) {
        return StartChatDialogWidget(
            partnerUuid: userInfo.uuid,
            data: data,
            meIdx: userInfo.key,
            meName: userInfo.name,
            isMichinMatching: isMichinMatching);
      },
    );
  }

  void showBottomEvaluate(EvaluateModel data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CommonColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.5),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return WorkerEvaluateWidget(
          title: localization.personalEvaluation,
          evaluateData: data,
        );
      },
    );
  }

  generateDocument(ProfileModel profileData) async {
    final pdf = await PdfService.createProfilePdf(profileData);
    final pdfFile = await PdfApi.saveDocument(
        name: '${profileData.userInfo.name}이력서.pdf', pdf: pdf);
    Map<String, dynamic> fileData = {
      "url": pdfFile.path,
      "size": 0,
      "name": '${profileData.userInfo.name}이력서.pdf'
    };
    saveFile(fileData, '${profileData.userInfo.name}이력서');
  }

  saveFile(dynamic pdfFile, String fileName) async {
    var result =
        await fileChatFileUploadS3(pdfFile, 'resume', profileData?.key, null);
    String date = DateFormat('yyMMddHHmmss').format(DateTime.now());
    if (result != null && result != false) {
      String dir = (await getApplicationDocumentsDirectory()).path;
      await FlutterDownloader.enqueue(
        url: result['fileUrl'],
        savedDir: '$dir/',
        fileName: '${fileName}_$date.pdf',
        saveInPublicStorage: true,
      );
      setState(() {
        isPdfDownload = false;
      });
      showDefaultToast(localization.resumeSavedSuccessfully);
    } else {
      setState(() {
        isPdfDownload = false;
      });
      showDefaultToast(localization.resumeSaveFailed);
    }
  }

  ReportModel? reportReason;
  String reportDetail = '';

  reportProfile(ProfileModel profileData) async {
    UserModel? userInfo = ref.watch(userProvider);

    if (isRunning) {
      return;
    } else {
      isRunning = true;
    }
    if (reportReason == null) {
      isRunning = false;
      showDefaultToast(localization.selectReportReason);
      return;
    } else if (reportReason?.key == 5 && reportDetail == '') {
      isRunning = false;
      showDefaultToast(localization.enterReportReason);
      return;
    }

    Map<String, dynamic> params = {
      'reCategory': 2,
      'reOriginal': profileData.key,
      'reTitle': profileData.profileTitle,
      'reAccused': profileData.userInfo.key,
      'reReason': reportReason!.key,
      'reDetail': reportDetail
    };

    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .reportEventComment(params);
    isRunning = false;
    if (result.status == 200) {
      if (result.type == 1) {
        showDefaultToast(localization.reportCompleted);
        if (mounted) {
          context.pop();
        }
      }
    } else if (result.status == 401) {
      showDefaultToast(localization.cannotReportOwnProfile);
    } else if (result.status == 409) {
      showDefaultToast(localization.canReportSameProfileOncePerDay);
    } else {
      showDefaultToast(localization.dataCommunicationFailed);
    }
  }

  List<ReportModel> reportList = [];

  getReportReasonList() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getReportReasonList();
    if (result.status == 200) {
      if (result.type == 1) {
        reportList = result.data;
      }
    }
  }

  setReportDetail(String stringValue) {
    setState(() {
      reportDetail = stringValue;
    });
  }

  final TextEditingController profileReportReasonController =
      TextEditingController();

  showReport([Function? afterFunc]) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CommonColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      barrierColor: CommonColors.barrier,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter bottomState) {
          return ReportBottomSheet(
            title: localization.profileReport,
            text: localization.reportInappropriateProfileContent,
            afterFunc: afterFunc != null
                ? () {
                    afterFunc();
                  }
                : null,
            setData: (ReportModel value) {
              bottomState(() {
                setReportReason(value);
              });
            },
            groupValue: reportReason,
            selectedValue: reportReason,
            textController: profileReportReasonController,
            reportList: reportList,
            setReportDetail: (String value) {
              bottomState(() {
                setReportDetail(value);
              });
            },
          );
        });
      },
    ).whenComplete(() {
      profileReportReasonController.text = '';
      setReportReason(reportList[0]);
    });
  }

  setReportReason(ReportModel reason) {
    setState(() {
      reportReason = reason;
    });
  }

  downloadFile(String url, String fileName) {
    String fileExtension = fileName.split('.').last;
    if (fileExtension == 'pdf') {
      showDialog(
          useSafeArea: false,
          context: context,
          builder: (BuildContext context) {
            return SeekerViewerWidget(
              pdfUrl: url,
              fileName: fileName,
            );
          });
    } else {
      getDownloadFile(url, fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> workerLikesKeyList = ref.watch(workerLikesKeyListProvider);
    List<int> matchedProfileKeyList = ref.watch(matchingKeyListProvider);
    UserModel? userInfo = ref.watch(userProvider);
    return Scaffold(
      appBar: CommonAppbar(
        title: _showProfileTitle && !isLoading
            ? profileData!.profileTitle
            : localization.candidateInformation,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: AppbarButton(
              onPressed: () {
                if (!isLoading) {
                  showReport(() {
                    FocusManager.instance.primaryFocus?.unfocus();
                    reportProfile(profileData!);
                  });
                }
              },
              imgUrl: 'iconReport.png',
              plural: true,
            ),
          )
        ],
      ),
      bottomNavigationBar: profileData == null
          ? null
          : userInfo!.memberType != MemberTypeEnum.jobSeeker
              ? SeekerDetailBottomAppBarWidget(
                  profileData: profileData!,
                  matchedStatus:
                      matchedProfileKeyList.contains(profileData!.key),
                  isLoading: isLoading,
                  workerLikesKeyList: workerLikesKeyList,
                  savePageLog: savePageLog,
                  showBottomSuggestJobposting: showBottomSuggestJobposting,
                  toggleLikesWorker: toggleLikesWorker,
                  isMichinMatching: isMichinMatching,
                  chatRoomData: chatRoomData,
                  showJobseekerMenuDialog: showJobseekerMenuDialog,
                  matchingData: matchingData,
                  generateDocument: generateDocument,
                  hasChatRoom: hasChatRoom)
              : null,
      body: !isLoading
          ? Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 16.w),
                          Padding(
                            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                WorkerProfileWidget(
                                    widgetKey: _widgetKey,
                                    profileData: profileData!,
                                    matchedStatus: matchedProfileKeyList
                                        .contains(profileData!.key),
                                    hasChatRoom: hasChatRoom,
                                    showAttachment: showAttachment,
                                    showBottomEvaluate: showBottomEvaluate,
                                    evaluateData: evaluateData,
                                    currentPosition: currentPosition),
                                WorkerProfileBottomWidget(
                                    profileData: profileData!,
                                    hasChatRoom: hasChatRoom,
                                    downloadFile: downloadFile)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const BottomPadding(),
                  ],
                ),
                if (isPdfDownload) const Loader()
              ],
            )
          : const Loader(),
    );
  }
}
