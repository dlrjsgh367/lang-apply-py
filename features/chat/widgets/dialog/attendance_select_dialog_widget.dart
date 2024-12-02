import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/location_service.dart';
import 'package:chodan_flutter_app/features/commute/controller/commute_controller.dart';
import 'package:chodan_flutter_app/features/commute/service/commute_service.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/chat/date_return.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AttendanceSelectDialogWidget extends ConsumerStatefulWidget {
  AttendanceSelectDialogWidget({
    super.key,
    required this.sendDocument,
    required this.uuid,
  });

  Function sendDocument;
  String uuid;

  @override
  ConsumerState<AttendanceSelectDialogWidget> createState() =>
      _AttendanceSelectDialogWidgetState();
}

class _AttendanceSelectDialogWidgetState
    extends ConsumerState<AttendanceSelectDialogWidget> {
  DateTime currentDateTime = DateTime.now();
  Position? currentPosition;
  bool isLoading = false;

  createAttendance(int type) async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    String address = await CommuteService.coord2Address(
        currentPosition!.latitude, currentPosition!.longitude);

    Map<String, dynamic> params = {
      "chRoomUuid": widget.uuid,
      "caType": type,
      "caDate": DateFormat('yyyy-MM-dd').format(currentDateTime),
      "caTime": DateFormat('HH:mm').format(currentDateTime),
      "jobSeekerLat": currentPosition!.latitude,
      "jobSeekerLong": currentPosition!.longitude,
    };

    ApiResultModel result = await ref
        .read(commuteControllerProvider.notifier)
        .createAttendance(params);
    if (result.status == 200) {
      if (result.type == 1) {
        switch (type) {
          case 1:
            widget.sendDocument('attendance', null, null);
            showDefaultToast('출근 처리 되었습니다.');
            context.pop();
          case 2:
            widget.sendDocument('leave', null, null);
            showDefaultToast('퇴근 처리 되었습니다.');
            context.pop();
          case 3:
            widget.sendDocument('outside', null, null);
            showDefaultToast('외근 처리되었습니다.');
          case 4:
            widget.sendDocument('comeback', null, null);
            showDefaultToast('복귀 처리되었습니다.');
          default:
            return null;
        }

        await chatUserService.updateAttendanceStatus(type, widget.uuid);

        await getUserData();
      }
    } else if (result.status == 409) {
      showErrorAlert('출근체크 실패', '이미 종료된 근무입니다.');
    } else if (result.status == 425) {
      if (type == 1) {
        context.pop();
        showAttendanceErrorAlert('외근 처리',
            '현재 위치는 근무지와의 거리가 초과했어요.\n해당 주소로 외근하고 계신지 확인하세요.\n$address');
      } else if (type == 4) {
        context.pop();
        showErrorAlert(
            '복귀 처리 실패', '현재 위치는 근무지와의 거리가 초과했어요.\n현재 위치 확인 후 다시 시도해보세요.');
      }
    } else {
      showErrorAlert('근태체크 실패', '근태 체크에 실패했어요.');
    }
  }

  getUserData() async {
    ApiResultModel result =
        await ref.read(authControllerProvider.notifier).getUserData();
    if (result.type == 1) {
      if (result.status == 200) {
        ref.read(userProvider.notifier).update((state) => result.data);
        await chatUserService.setUserStream(result.data);

        context.pop();
      }
    }
  }

  showErrorAlert(String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: title,
            alertContent: content,
            alertConfirm: '확인',
            confirmFunc: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  showAttendanceErrorAlert(String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: title,
            alertContent: content,
            alertConfirm: '외근 설정',
            alertCancel: '취소',
            onConfirm: () {
              createAttendance(3);
            },
            onCancel: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  confirmAttendanceAlert(String title, String content, int type) async {
    String address = await CommuteService.coord2Address(
        currentPosition!.latitude, currentPosition!.longitude);
    if (address == '') {
      getCurrentLocation();
      showDefaultToast('위치정보를 가져오는데 실패하였습니다. 잠시후 다시 시도해주세요.');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertTwoButtonDialog(
              alertTitle: title,
              alertContent: '$content\n$address',
              alertConfirm: '확인',
              alertCancel: '취소',
              onConfirm: () {
                createAttendance(type);
              },
              onCancel: () {
                context.pop(context);
              },
            );
          });
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
        currentPosition = location;
      });
    } else {
      showDefaultToast('위치정보를 가져오는데 실패하였습니다.');
    }
  }

  @override
  void initState() {
    Future(() async {
      await getCurrentLocation();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var roomInfo = ref.watch(chatUserRoomInfoProvider);
    return Wrap(
      children: [
        SizedBox(
          width: CommonSize.vw,
          child: Column(
            children: [
              const TitleBottomSheet(title: '근태체크'),
              SizedBox(
                height: 14.w,
              ),
              const DateReturn(type: 'date'),
              SizedBox(
                height: 25.w,
              ),
              const DateReturn(type: 'noDate'),
              SizedBox(
                height: 40.w,
              ),
              Padding(
                padding:
                    EdgeInsets.fromLTRB(20.w, 0, 20.w, CommonSize.commonBottom),
                child: Row(
                  children: [
                    Expanded(
                      child: currentPosition == null
                          ? const Loader()
                          : GestureDetector(
                              onTap: roomInfo!.attendanceStatus == 0 ||
                                      roomInfo.attendanceStatus == 2
                                  ? () async {
                                      confirmAttendanceAlert(
                                          '출근 처리', '아래 주소로 출근 처리돼요.', 1);
                                    }
                                  : null,
                              child: Container(
                                height: 56.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.w),
                                  color: CommonColors.grayF2,
                                ),
                                child: Text(
                                  '출근',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: roomInfo.attendanceStatus == 0 ||
                                            roomInfo.attendanceStatus == 2
                                        ? CommonColors.gray66
                                        : CommonColors.grayD9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: currentPosition == null
                          ? const Loader()
                          : GestureDetector(
                              onTap: roomInfo!.attendanceStatus == 1 ||
                                      roomInfo.attendanceStatus == 0 ||
                                      roomInfo.attendanceStatus == 2
                                  ? () async {
                                      createAttendance(3);
                                    }
                                  : null,
                              child: Container(
                                height: 56.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.w),
                                  color: CommonColors.grayF2,
                                ),
                                child: Text(
                                  '외근',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: roomInfo.attendanceStatus == 1 ||
                                            roomInfo.attendanceStatus == 0 ||
                                            roomInfo.attendanceStatus == 2
                                        ? CommonColors.gray66
                                        : CommonColors.grayD9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: currentPosition == null
                          ? const Loader()
                          : GestureDetector(
                              onTap: roomInfo!.attendanceStatus == 3
                                  ? () {
                                      createAttendance(4);
                                    }
                                  : null,
                              child: Container(
                                height: 56.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.w),
                                  color: CommonColors.grayF2,
                                ),
                                child: Text(
                                  '복귀',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: roomInfo!.attendanceStatus == 3
                                        ? CommonColors.gray66
                                        : CommonColors.grayD9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: currentPosition == null
                          ? const Loader()
                          : GestureDetector(
                              onTap: roomInfo!.attendanceStatus == 3 ||
                                      roomInfo.attendanceStatus == 1 ||
                                      roomInfo.attendanceStatus == 4
                                  ? () {
                                      confirmAttendanceAlert(
                                          '퇴근 처리', '아래 주소로 퇴근 처리돼요.', 2);
                                    }
                                  : null,
                              child: Container(
                                height: 56.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.w),
                                  color: CommonColors.grayF2,
                                ),
                                child: Text(
                                  '퇴근',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: roomInfo!.attendanceStatus == 3 ||
                                            roomInfo.attendanceStatus == 1 ||
                                            roomInfo.attendanceStatus == 4
                                        ? CommonColors.gray66
                                        : CommonColors.grayD9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
