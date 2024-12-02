import 'dart:math';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/contract/service/pdf_api.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/map/service/map_service.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/features/worker/service/pdf_service.dart';
import 'package:chodan_flutter_app/features/worker/widgets/seeker_viewer_widget.dart';
import 'package:chodan_flutter_app/features/worker/widgets/worker_evaluate_widget.dart';
import 'package:chodan_flutter_app/features/worker/widgets/worker_pofile_bottom_widget.dart';
import 'package:chodan_flutter_app/features/worker/widgets/worker_profile_widget.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/evaluate_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/attachment_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ChatProfileScreen extends ConsumerStatefulWidget {
  const ChatProfileScreen({
    super.key,
    required this.idx,
  });

  final String idx;

  @override
  ConsumerState<ChatProfileScreen> createState() => _ChatProfileScreenState();
}

class _ChatProfileScreenState extends ConsumerState<ChatProfileScreen>
    with Files {
  Map<String, dynamic> currentPosition = MapService.currentPosition;
  late ProfileModel profileData;
  bool isLoading = true;
  bool isPdfDownload = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _widgetKey = GlobalKey();
  EvaluateModel? evaluateData;

  showWithdrawalAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertConfirmDialog(
          alertTitle: localization.guide,
          alertContent: localization.withdrawnMemberStatus,
          alertConfirm: localization.confirm,
          confirmFunc: () {
            context.pop();
            context.pop();
          },
        );
      },
    );
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      getProfileDetailData(),
      getJobseekerEvaluate(int.parse(widget.idx)),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _getAllAsyncTasks().then((_) {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getProfileDetailData() async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getWorkerProfile(int.parse(widget.idx));
    if (result.status == 200 && result.type == 1) {
      setState(() {
        profileData = result.data;
      });
    } else {
      if (result.status == 406) {
        showWithdrawalAlert();
      }
    }
  }

  double distanceBetween(double endLatitude, double endLongitude) {
    const double radius = 6371000.0;
    double degreesToRadians(degrees) {
      return degrees * (pi / 180);
    }

    double deltaLatitude =
        degreesToRadians(endLatitude - currentPosition['lat']);
    double deltaLongitude =
        degreesToRadians(endLongitude - currentPosition['lng']);
    double a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
        cos(degreesToRadians(currentPosition['lat'])) *
            cos(degreesToRadians(endLatitude)) *
            sin(deltaLongitude / 2) *
            sin(deltaLongitude / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radius * c / 1000;
    return double.parse(distance.toStringAsFixed(1));
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
      // isDismissible:false,
      useSafeArea: true,
      // enableDrag: false,
      builder: (BuildContext context) {
        return WorkerEvaluateWidget(
          title: localization.personalEvaluation,
          evaluateData: data,
        );
      },
    );
  }

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
          title: name,
          files: files,
          downloadFunc: downloadFile,
        );
      },
    );
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

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  generateDocument(ProfileModel profileData) async {
    setState(() {
      isPdfDownload = true;
    });
    final pdf = await PdfService.createProfilePdf(profileData);

    final pdfFile = await PdfApi.saveDocument(
        name: '${profileData.userInfo.name}${localization.resume}.pdf', pdf: pdf);
    Map<String, dynamic> fileData = {
      "url": pdfFile.path,
      "size": 0,
      "name": '${profileData.userInfo.name}${localization.resume}.pdf'
    };
    saveFile(fileData, '${profileData.userInfo.name}${localization.resume}');
  }

  saveFile(dynamic pdfFile, String fileName) async {
    var result =
        await fileChatFileUploadS3(pdfFile, 'resume', profileData.key, null);
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
      showDefaultToast(localization.resumeSaved);
    } else {
      setState(() {
        isPdfDownload = false;
      });
      showDefaultToast(localization.resumeSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(
        title: localization.candidateInformation,
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: Container(
            height: 50.w,
            color: Colors.white,
            child: !isLoading
                ? Row(
                    children: [
                      BorderButton(
                        onPressed: () {
                          context.pop();
                        },
                        text: 'text',
                        width: 115.w,
                        child: Text(
                          localization.closed,
                          style: TextStyle(
                              fontSize: 15.w,
                              color: CommonColors.gray4d,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Expanded(
                        child: CommonButton(
                          fontSize: 15,
                          onPressed: () {
                            savePageLog();
                            generateDocument(profileData);
                          },
                          text: '${localization.resume} PDF',
                          confirm: true,
                        ),
                      ),
                    ],
                  )
                : null),
      ),
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
                                    profileData: profileData,
                                    matchedStatus: true,
                                    hasChatRoom: true,
                                    showAttachment: showAttachment,
                                    showBottomEvaluate: showBottomEvaluate,
                                    evaluateData: evaluateData,
                                    currentPosition: currentPosition),
                                SizedBox(height: 16.w),
                                WorkerProfileBottomWidget(
                                    profileData: profileData,
                                    hasChatRoom: true,
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
