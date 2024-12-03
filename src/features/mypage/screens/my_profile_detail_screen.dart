import 'dart:math';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/features/map/service/map_service.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/features/worker/widgets/seeker_viewer_widget.dart';
import 'package:chodan_flutter_app/features/worker/widgets/worker_pofile_bottom_widget.dart';
import 'package:chodan_flutter_app/features/worker/widgets/worker_profile_widget.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/attachment_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/appbar_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/etc/dot_line.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MyProfileDetailScreen extends ConsumerStatefulWidget {
  const MyProfileDetailScreen({
    super.key,
    required this.idx,
  });

  final String idx;

  @override
  ConsumerState<MyProfileDetailScreen> createState() =>
      _MyProfileDetailScreenState();
}

class _MyProfileDetailScreenState extends ConsumerState<MyProfileDetailScreen>
    with Files {
  Map<String, dynamic> currentPosition = MapService.currentPosition;
  late ProfileModel profileData;
  bool isLoading = true;
  final GlobalKey _widgetKey = GlobalKey();
  void showAttachment(List files) {
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
      // isScrollControlled: true,
      // isDismissible:false,
      useSafeArea: true,
      // enableDrag: false,
      builder: (BuildContext context) {
        return AttachmentBottomSheet(
          title: localization.172,
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

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getProfileDetailData()]);
  }

  @override
  void initState() {
    super.initState();
    _getAllAsyncTasks().then((_) {
      isLoading = false;
    });
  }

  getProfileDetailData() async {
    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .getProfileDetailData(int.parse(widget.idx));
    if (result.status == 200 && result.type == 1) {
      setState(() {
        profileData = result.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(
        title: localization.310,
        actions: [
          AppbarButton(
              onPressed: () {
                context
                    .push('/my/profile/update/${widget.idx}')
                    .then((_) async {
                  await getProfileDetailData();
                });
              },
              imgUrl: 'iconProfileFix.png'),
        ],
      ),
      body: !isLoading
          ? CustomScrollView(
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
                                showBottomEvaluate: (){},
                                evaluateData: null,
                                currentPosition: currentPosition),
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
            )
          : const Loader(),
    );
  }
}
