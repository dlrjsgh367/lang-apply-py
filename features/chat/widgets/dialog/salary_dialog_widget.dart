import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/chat_file_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SalaryDialogWidget extends ConsumerStatefulWidget {
  const SalaryDialogWidget({
    super.key,
    required this.roomUuid,
    required this.messageUuid,
    required this.created,
  });

  final String roomUuid;
  final String messageUuid;
  final String created;

  @override
  ConsumerState<SalaryDialogWidget> createState() => _SalaryDialogWidgetState();
}

class _SalaryDialogWidgetState extends ConsumerState<SalaryDialogWidget> {
  bool isLoading = false;
  bool isAgree = false;
  final formatCurrency = NumberFormat('#,###');

  @override
  void initState() {
    Future(() {
      getChatFileDetail();
    });
    super.initState();
  }

  getChatFileDetail() async {
    setState(() {
      isLoading = true;
    });
    ApiResultModel result = await ref
        .read(chatControllerProvider.notifier)
        .getChatFileDetail(widget.messageUuid);

    if (result.type == 1) {
      ref
          .read(contractDetailProvider.notifier)
          .update((state) => ChatFileModel.fromJson(result.data));
    } else if (result.status != 200) {
      if (!mounted) return null;
      showErrorAlert('알림', '데이터 통신에 실패했습니다.');
    } else {
      if (!mounted) return null;
      showErrorAlert('알림', '데이터 통신에 실패했습니다.');
    }

    setState(() {
      isLoading = false;
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
            },
            onCancel: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  updateStatus(int status) async {
    var apiUploadResult = await ref
        .read(chatControllerProvider.notifier)
        .updateDocumentStatus(widget.messageUuid, widget.roomUuid, status);

    if (apiUploadResult.type == 1) {
      if (status == 1) {
        showDefaultToast('동의가 완료되었습니다.');
      } else if (status == 2) {
        showDefaultToast('거절이 완료되었습니다.');
      }
      context.pop();
    } else {
      if (status == 1) {
        showDefaultToast('동의에 실패하였습니다.');
      } else if (status == 2) {
        showDefaultToast('거절에 실패하였습니다.');
      }
      return false;
    }
  }

  returnTotal(String type) {
    var detailData = ref.watch(contractDetailProvider);
    double total = 0;

    if (type == 'payment') {
      for (var data in detailData!.salaryStateDto.salaryPaymentDto) {
        double price = data['spAmount'];
        total += price;
      }
    } else {
      for (var data in detailData!.salaryStateDto.salaryDeductionDtos) {
        double price = data['sdAmount'];
        total += price;
      }
    }

    return total;
  }

  returnPaymentType(int value) {
    switch (value) {
      case 0:
        return '기본급';
      case 1:
        return '식대';
      case 2:
        return '차량유지비';
      case 3:
        return '연장근로수당';
      case 4:
        return '야간근로수당';
      case 5:
        return '휴일근로수당';
      case 6:
        return '직급수당';
      case 7:
        return '보육수당';
      case 8:
        return '근속수당';
      case 9:
        return '가족수당';
      case 10:
        return '당직수당';
      case 11:
        return '상여금';
      case 12:
        return '기타';
    }
  }

  returnDeductionType(int value) {
    switch (value) {
      case 0:
        return '소득세';
      case 1:
        return '지방소득세';
      case 2:
        return '국민연금';
      case 3:
        return '건강보험';
      case 4:
        return '고용보험';
      case 5:
        return '산재보험';
      case 6:
        return '장기요양보험';
      case 7:
        return '주민세';
      case 8:
        return '상조회비';
      case 9:
        return '연말정산';
      case 10:
        return '기타';
    }
  }

  @override
  Widget build(BuildContext context) {
    var detailData = ref.watch(contractDetailProvider);

    return Scaffold(
      appBar: const ModalAppbar(
        title: '급여내역서',
      ),
      body: isLoading || detailData == null
          ? const Loader()
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  20.w, 16.w, 20.w, CommonSize.commonBottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 48.w,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(width: 1.w, color: CommonColors.gray66),
                      ),
                    ),
                    child: Text(
                      '근로자 정보',
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: CommonColors.gray4d),
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  Row(
                    children: [
                      Text(
                        '이름',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CommonColors.gray80,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          detailData.salaryStateDto.ssWorkerName,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: CommonColors.black2b,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 12.w,
                  ),
                  Row(
                    children: [
                      Text(
                        '생년월일',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CommonColors.gray80,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          DateFormat('yyyy.MM.dd').format(DateTime.parse(detailData.salaryStateDto.ssWorkerBirthdate)),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: CommonColors.black2b,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 12.w,
                  ),
                  Row(
                    children: [
                      Text(
                        '입사일자',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CommonColors.gray80,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          DateFormat('yyyy.MM.dd').format(DateTime.parse(detailData.salaryStateDto.ssStartDate)),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: CommonColors.black2b,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 12.w,
                  ),
                  Row(
                    children: [
                      Text(
                        '소속',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CommonColors.gray80,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          detailData.salaryStateDto.ssDepartment,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: CommonColors.black2b,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 12.w,
                  ),
                  Row(
                    children: [
                      Text(
                        '직위',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CommonColors.gray80,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          detailData.salaryStateDto.ssPosition,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: CommonColors.black2b,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 24.w,
                  ),
                  Container(
                    height: 48.w,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(width: 1.w, color: CommonColors.gray66),
                      ),
                    ),
                    child: Text(
                      '지급항목',
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: CommonColors.gray4d),
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  for (var i = 0;
                      i < detailData.salaryStateDto.salaryPaymentDto.length;
                      i++)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 12.w),
                      child: Row(
                        children: [
                          Text(
                            returnPaymentType(detailData
                                .salaryStateDto.salaryPaymentDto[i]['spType']),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.gray80,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              formatCurrency
                                  .format(detailData.salaryStateDto
                                      .salaryPaymentDto[i]['spAmount'])
                                  .toString(),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: CommonColors.black2b,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 24.w,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.w),
                        color: CommonColors.grayF7),
                    padding: EdgeInsets.fromLTRB(16.w, 20.w, 16.w, 20.w),
                    child: Row(
                      children: [
                        Text(
                          '지급합계',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.gray4d),
                        ),
                        Expanded(
                          child: Text(
                            formatCurrency
                                .format(returnTotal('payment'))
                                .toString(),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.gray4d),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24.w,
                  ),
                  Container(
                    height: 48.w,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(width: 1.w, color: CommonColors.gray66),
                      ),
                    ),
                    child: Text(
                      '공제항목',
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: CommonColors.gray4d),
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  for (var i = 0;
                      i < detailData.salaryStateDto.salaryDeductionDtos.length;
                      i++)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : 12.w),
                      child: Row(
                        children: [
                          Text(
                            returnDeductionType(detailData.salaryStateDto
                                .salaryDeductionDtos[i]['sdType']),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.gray80,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              formatCurrency
                                  .format(detailData.salaryStateDto
                                      .salaryDeductionDtos[i]['sdAmount'])
                                  .toString(),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: CommonColors.black2b,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 24.w,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.w),
                        color: CommonColors.grayF7),
                    padding: EdgeInsets.fromLTRB(16.w, 20.w, 16.w, 20.w),
                    child: Row(
                      children: [
                        Text(
                          '공제합계',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.gray4d),
                        ),
                        Expanded(
                          child: Text(
                            formatCurrency
                                .format(returnTotal('deduction'))
                                .toString(),
                            textAlign: TextAlign.end,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.gray4d),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24.w,
                  ),
                  Divider(
                    height: 1.w,
                    thickness: 1.w,
                    color: CommonColors.gray66,
                  ),
                  SizedBox(
                    height: 24.w,
                  ),
                  Row(
                    children: [
                      Text(
                        '실수령액',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CommonColors.gray4d,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          formatCurrency.format(returnTotal('payment') -
                              returnTotal('deduction')),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: CommonColors.gray4d,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 45.w,
                  ),
                  Text(
                    widget.created,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.gray80),
                  ),
                ],
              ),
            ),
    );
  }
}
