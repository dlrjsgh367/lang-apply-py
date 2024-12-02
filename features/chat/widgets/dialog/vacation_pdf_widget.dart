import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/models/chat_file_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VacationPdfWidget extends StatefulWidget {
  const VacationPdfWidget({
    super.key,
    required this.detailData,
    required this.created,
    required this.setPdfDisplay,
  });

  final ChatFileModel detailData;
  final String created;
  final Function setPdfDisplay;

  @override
  State<VacationPdfWidget> createState() => _VacationPdfWidgetState();
}

class _VacationPdfWidgetState extends State<VacationPdfWidget> {
  ChatFileModel? detailData;
  final GlobalKey _pdfKey = GlobalKey();
  double _scaleFactor = 1.0;

  @override
  initState() {
    detailData = widget.detailData;
    super.initState();
  }

  returnVacationType(int type) {
    switch (type) {
      case 1:
        return '연차';
      case 2:
        return '경조휴가';
      case 3:
        return '포상휴가';
      case 4:
        return '생리휴가';
      case 5:
        return '기타휴가';
      default:
        return '연차';
    }
  }

  Future<void> _adjustScaleIfScrollable(BoxConstraints constraints) async {
    final screenHeight = constraints.maxHeight;
    final contentHeight = _pdfKey.currentContext?.size?.height ?? 0;
    if (contentHeight > screenHeight) {
      setState(() {
        _scaleFactor = screenHeight / contentHeight;
      });
    } else {
      setState(() {
        _scaleFactor = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return detailData == null
        ? const SizedBox()
        : Scaffold(
            appBar: AppBar(
              primary: true,
              toolbarHeight: 48.w,
              backgroundColor: CommonColors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                '휴가 신청서',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: CommonColors.black,
                ),
              ),
              titleSpacing: 0,
              centerTitle: true,
              leadingWidth: 0,
              leading: const SizedBox(),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  await _adjustScaleIfScrollable(constraints);
                  widget.setPdfDisplay();
                });
                return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
                      child: Transform.scale(
                        scale: _scaleFactor,
                        alignment: Alignment.topCenter,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              key: _pdfKey,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  height: 48.w,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1.w,
                                          color: CommonColors.gray66),
                                    ),
                                  ),
                                  child: Text(
                                    '신청자 정보',
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
                                        detailData!.vacationDto.vaWorkerName,
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
                                      '연락처',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        ConvertService.formatPhoneNumber(
                                            detailData!
                                                .vacationDto.vaWorkerPhone),
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
                                        detailData!.vacationDto.vaDepartment ==
                                                ''
                                            ? '-'
                                            : detailData!
                                                .vacationDto.vaDepartment,
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
                                        detailData!.vacationDto.vaPosition == ''
                                            ? '-'
                                            : detailData!
                                                .vacationDto.vaPosition,
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
                                      bottom: BorderSide(
                                          width: 1.w,
                                          color: CommonColors.gray66),
                                    ),
                                  ),
                                  child: Text(
                                    '내용',
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
                                      '휴가종류',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        returnVacationType(
                                            detailData!.vacationDto.vaType),
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
                                      '휴가기간',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${detailData!.vacationDto.vaStartDate} ~ ${detailData!.vacationDto.vaEndDate}',
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
                                      '휴가사유',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        detailData!.vacationDto.vaReason,
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
                                  height: 64.w,
                                ),
                                Text(
                                  '위의 사유로 휴가 신청서를\n 제출하오니 허락하여 주시기 바랍니다.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: CommonColors.gray66,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.w,
                                ),
                                Text(
                                  widget.created,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: CommonColors.gray80,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: 24.w,
                                ),
                                Text(
                                  '신청자: ${detailData!.vacationDto.vaWorkerName}',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: CommonColors.gray4d,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: 32.w,
                                ),
                              ],
                            ),
                            Positioned(
                              left: 20.w,
                              right: 20.w,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 60.w),
                                child: Image.asset(detailData!.caRepairStatus ==
                                        0
                                    ? 'assets/images/default/imgMisu.png'
                                    : detailData!.caRepairStatus == 1
                                        ? 'assets/images/default/imgSuri.png'
                                        : 'assets/images/default/imgMisu.png'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ));
              },
            ),
          );
  }
}
