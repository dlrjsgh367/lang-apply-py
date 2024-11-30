import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/contract/service/pdf_api.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/email_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MyCertificateScreen extends ConsumerStatefulWidget {
  const MyCertificateScreen({super.key});

  @override
  ConsumerState<MyCertificateScreen> createState() =>
      _MyCertificateScreenState();
}

class _MyCertificateScreenState extends ConsumerState<MyCertificateScreen>
    with Files {
  List<JobpostModel> appliedJobPosts = [];
  List<JobpostModel> checkedJobPosts = [];
  Map<String, dynamic> fileData = {'file': null};
  String email = '';

  bool isLoading = true;
  int page = 1;
  int lastPage = 1;
  int total = 0;
  bool isLazeLoading = false;

  bool isSending = false;
  bool isRunning = false;

  setEmail(String email) {
    this.email = email;
  }

  void toggleCheckedState(JobpostModel data) {
    setState(() {
      if (checkedJobPosts.contains(data)) {
        checkedJobPosts.remove(data);
      } else {
        checkedJobPosts.add(data);
      }
    });
  }

  void showJobProof(List<JobpostModel> selectedData) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
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
          return Stack(
            alignment: Alignment.center,
            children: [
              EmailBottomSheet(
                title: localization.employmentCertificateIssued,
                setData: setEmail,
                onPressed: () {
                  bottomState(() {
                    createPdf(selectedData);
                  });
                },
                isLoading: isSending,
              ),
            ],
          );
        });
      },
    );
  }

  createPdf(List<JobpostModel> selectedData) async {
    if (isSending) {
      return false;
    }
    if (isRunning) {
      return false;
    }
    setState(() {
      isSending = true;
      isRunning = true;
    });
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      fileData['file'] = await generateDocument(selectedData);
      await saveFile(fileData['file'], userInfo.key);
      setState(() {
        isSending = false;
      });
    }
  }

  Future<Map<String, dynamic>> generateDocument(
      List<JobpostModel> selectedData) async {
    final pdf = pw.Document();
    final customFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSansKR-Medium.ttf'));

    final imageData =
        await rootBundle.load('assets/images/appbar/logoChodan.png');
    final image = pw.MemoryImage(imageData.buffer.asUint8List());
    UserModel? userInfo = ref.read(userProvider);
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(50, 20, 50, 20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Image(image, height: 30),
              pw.Container(
                margin: const pw.EdgeInsets.fromLTRB(0, 10, 0, 15),
                height: 1,
                color: PdfColor.fromHex('#ededed'),
              ),
              pw.Text(
                localization.employmentCertificate,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: customFont, fontSize: 25),
              ),
              pw.SizedBox(
                height: 15,
              ),
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#eeeeee'),
                      border: pw.Border.all(
                        width: 1,
                        color: PdfColor.fromHex('#eeeeee'),
                      ),
                    ),
                    width: 150,
                    child: pw.Text(
                      localization.name,
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: customFont,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          width: 1,
                          color: PdfColor.fromHex('#eeeeee'),
                        ),
                      ),
                      child: pw.Text(
                        userInfo!.name,
                        style: pw.TextStyle(
                          fontSize: 12,
                          font: customFont,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#eeeeee'),
                      border: pw.Border.all(
                        width: 1,
                        color: PdfColor.fromHex('#eeeeee'),
                      ),
                    ),
                    width: 150,
                    child: pw.Text(
                      localization.dateOfBirth,
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: customFont,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          width: 1,
                          color: PdfColor.fromHex('#eeeeee'),
                        ),
                      ),
                      child: pw.Text(
                        userInfo!.birth,
                        style: pw.TextStyle(
                          fontSize: 12,
                          font: customFont,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#eeeeee'),
                      border: pw.Border.all(
                        width: 1,
                        color: PdfColor.fromHex('#eeeeee'),
                      ),
                    ),
                    width: 150,
                    child: pw.Text(
                      localization.address,
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: customFont,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          width: 1,
                          color: PdfColor.fromHex('#eeeeee'),
                        ),
                      ),
                      child: pw.Text(
                        '${userInfo!.address} ${userInfo!.addressDetail}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          font: customFont,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#eeeeee'),
                      border: pw.Border.all(
                        width: 1,
                        color: PdfColor.fromHex('#eeeeee'),
                      ),
                    ),
                    width: 150,
                    child: pw.Text(
                      localization.contactInfo,
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: customFont,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          width: 1,
                          color: PdfColor.fromHex('#eeeeee'),
                        ),
                      ),
                      child: pw.Text(
                        userInfo!.phoneNumber,
                        style: pw.TextStyle(
                          fontSize: 12,
                          font: customFont,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(5, 10, 5, 5),
                child: pw.Text(
                  '${userInfo!.name} 님의 취업활동 결과입니다.',
                  style: pw.TextStyle(
                    fontSize: 15,
                    font: customFont,
                  ),
                ),
              ),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#eeeeee'),
                        border: pw.Border.all(
                          width: 0.5,
                          color: PdfColor.fromHex('#e2e2e2'),
                        ),
                      ),
                      alignment: pw.Alignment.center,
                      height: 40,
                      child: pw.Text(
                        localization.applicationDate,
                        style: pw.TextStyle(
                          fontSize: 12,
                          font: customFont,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#eeeeee'),
                        border: pw.Border.all(
                          width: 0.5,
                          color: PdfColor.fromHex('#e2e2e2'),
                        ),
                      ),
                      alignment: pw.Alignment.center,
                      height: 40,
                      child: pw.Text(
                        localization.companyName,
                        style: pw.TextStyle(
                          fontSize: 12,
                          font: customFont,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#eeeeee'),
                        border: pw.Border.all(
                          width: 0.5,
                          color: PdfColor.fromHex('#e2e2e2'),
                        ),
                      ),
                      alignment: pw.Alignment.center,
                      height: 40,
                      child: pw.Text(
                        localization.address,
                        style: pw.TextStyle(
                          fontSize: 12,
                          font: customFont,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#eeeeee'),
                        border: pw.Border.all(
                          width: 0.5,
                          color: PdfColor.fromHex('#e2e2e2'),
                        ),
                      ),
                      alignment: pw.Alignment.center,
                      height: 40,
                      child: pw.Text(
                        localization.contactInfo,
                        style: pw.TextStyle(
                          fontSize: 12,
                          font: customFont,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#eeeeee'),
                        border: pw.Border.all(
                          width: 0.5,
                          color: PdfColor.fromHex('#e2e2e2'),
                        ),
                      ),
                      alignment: pw.Alignment.center,
                      height: 40,
                      child: pw.Text(
                        localization.activityResult,
                        style: pw.TextStyle(
                          fontSize: 12,
                          font: customFont,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  for (var jobPost in selectedData)
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                width: 0.5,
                                color: PdfColor.fromHex('#e2e2e2'),
                              ),
                            ),
                            alignment: pw.Alignment.center,
                            height: 40,
                            child: pw.Text(
                              DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(jobPost.createdAt)),
                              style: pw.TextStyle(
                                fontSize: 12,
                                font: customFont,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                width: 0.5,
                                color: PdfColor.fromHex('#e2e2e2'),
                              ),
                            ),
                            alignment: pw.Alignment.center,
                            height: 40,
                            child: pw.Text(
                              jobPost.companyName,
                              style: pw.TextStyle(
                                fontSize: 12,
                                font: customFont,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                width: 0.5,
                                color: PdfColor.fromHex('#e2e2e2'),
                              ),
                            ),
                            alignment: pw.Alignment.center,
                            height: 40,
                            child: pw.Text(
                              '${jobPost.address} ${jobPost.addressDetail}',
                              style: pw.TextStyle(
                                fontSize: 12,
                                font: customFont,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                width: 0.5,
                                color: PdfColor.fromHex('#e2e2e2'),
                              ),
                            ),
                            alignment: pw.Alignment.center,
                            height: 40,
                            child: pw.Text(
                              jobPost.managerHp,
                              style: pw.TextStyle(
                                fontSize: 12,
                                font: customFont,
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                width: 0.5,
                                color: PdfColor.fromHex('#e2e2e2'),
                              ),
                            ),
                            alignment: pw.Alignment.center,
                            height: 40,
                            child: pw.Text(
                              localization.application,
                              style: pw.TextStyle(
                                fontSize: 12,
                                font: customFont,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(
                  5,
                  10,
                  5,
                  20,
                ),
                child: pw.Text(
                  '${userInfo!.name} 님은 ${userInfo!.createdAt} 부터 ${DateFormat('yyyy-MM-dd').format(DateTime.now())} 까지\n'
                  localization.confirmationThroughShortTermJob,
                  style: pw.TextStyle(
                    fontSize: 12,
                    font: customFont,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(
                  5,
                  0,
                  5,
                  0,
                ),
                child: pw.Text(
                  DateFormat(localization.).format(DateTime.now()),
                  textAlign: pw.TextAlign.end,
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: customFont,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return await PdfApi.saveDocumentMap(name: localization.employmentCertificatePdf, pdf: pdf);
  }

  saveFile(dynamic file, int key) async {
    var result = await fileUploadS3ReturnData(file, 'JOB_ACTIVITY', key);
    if (result['type'] == 1) {
      setState(() {
        fileData['file'] = null;
        sendEmail(result['data'][0]);
      });
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertConfirmDialog(
              alertContent: localization.emailSendFailedRetry,
              alertConfirm: localization.confirm,
              confirmFunc: () {
                isRunning = false;
                context.pop();
              },
              alertTitle: localization.notification,
            );
          },
        );
      }
    }
  }

  sendEmail(key) async {
    UserModel? userInfo = ref.read(userProvider);
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Map<String, dynamic> params = {
      'email': email,
      'name': userInfo!.name,
      'documentType': 'JOBHUNTING',
      'date': formattedDate,
      'atIdx': key,
    };
    var result =
        await ref.read(chatControllerProvider.notifier).sendEmail(params);
    isRunning = false;
    if (result.type == 1) {
      setState(() {
        checkedJobPosts = [];
      });
      if (mounted) {
        context.pop();
        showDefaultToast(localization.emailSentSuccessfully);
      }
    } else {
      showDefaultToast(localization.emailSendFailed);
    }
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getAppliedList(page),
    ]);
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
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

  getAppliedList(int page) async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getAppliedList(page, userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          List<JobpostModel> resultData = result.data;
          setState(() {
            if (page == 1) {
              appliedJobPosts = [...resultData];
            } else {
              appliedJobPosts = [...appliedJobPosts, ...resultData];
            }
            total = result.page['total'];
            lastPage = result.page['lastPage'];
            isLazeLoading = false;
          });
        }
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
        getAppliedList(page);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: localization.employmentCertificateIssued,
      ),
      body: !isLoading
          ? appliedJobPosts.isNotEmpty
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: LazyLoadScrollView(
                          onEndOfPage: () => _loadMore(),
                          child: CustomScrollView(
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  childCount: appliedJobPosts.length,
                                  (context, index) {
                                    var jobPostData = appliedJobPosts[index];
                                    return GestureDetector(
                                      onTap: () {
                                        toggleCheckedState(jobPostData);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(
                                            20.w, 20.w, 20.w, 20.w),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                color: CommonColors.gray100,
                                                width: 1.w),
                                          ),
                                          color: checkedJobPosts.contains(index)
                                              ? CommonColors.gray100
                                              : CommonColors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Text(
                                                    DateFormat(
                                                            'yyyy-MM-dd HH:mm')
                                                        .format(DateTime.parse(
                                                            jobPostData
                                                                .createdAt)),
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          CommonColors.grayB2,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.w),
                                                  Text(
                                                    jobPostData.companyName,
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color:
                                                          CommonColors.gray66,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4.w),
                                                  Text(
                                                    jobPostData.title,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: CommonColors
                                                            .black2b,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  SizedBox(height: 4.w),
                                                  Text(
                                                    '지원한 프로필 | ${jobPostData.profileTitle}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          CommonColors.grayB2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Image.asset(
                                              checkedJobPosts
                                                      .contains(jobPostData)
                                                  ? 'assets/images/icon/IconCheckActive.png'
                                                  : 'assets/images/icon/IconCheck.png',
                                              width: 24.w,
                                              height: 24.w,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const BottomPadding(
                                extra: 100,
                              ),
                            ],
                          )),
                    ),
                    if (isLazeLoading)
                      Positioned(
                          bottom: CommonSize.commonBottom,
                          child: const Loader()),
                    Positioned(
                      left: 20.w,
                      right: 20.w,
                      bottom: CommonSize.commonBoard(context),
                      child: CommonButton(
                        confirm: checkedJobPosts.isNotEmpty,
                        onPressed: () {
                          if (checkedJobPosts.isNotEmpty) {
                            showJobProof(checkedJobPosts);
                          }
                        },
                        fontSize: 15,
                        text: localization.issueCertificate,
                      ),
                    ),
                  ],
                )
              : const CommonEmpty(
                  text: localization.noRecentApplications,
                )
          : const Loader(),
    );
  }
}
