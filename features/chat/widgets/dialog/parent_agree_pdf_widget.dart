import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/models/chat_file_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ParentAgreePdfWidget extends StatefulWidget {
  const ParentAgreePdfWidget({
    super.key,
    required this.detailData,
    required this.signImg,
    required this.created,
    required this.setPdfDisplay,
  });

  final ChatFileModel detailData;
  final String signImg;
  final String created;
  final Function setPdfDisplay;

  @override
  State<ParentAgreePdfWidget> createState() => _ParentAgreePdfWidgetState();
}

class _ParentAgreePdfWidgetState extends State<ParentAgreePdfWidget> {
  ChatFileModel? detailData;
  final GlobalKey _pdfKey = GlobalKey();
  double _scaleFactor = 1.0;

  @override
  initState() {
    detailData = widget.detailData;
    super.initState();
  }

  returnParentType(int value) {
    switch (value) {
      case 1:
        return '부';
      case 2:
        return '모';
      case 3:
        return '법정대리인';
      default:
        return '부';
    }
  }

  Future<void> _adjustScaleIfScrollable(BoxConstraints constraints) async {
    // 화면의 크기와 콘텐츠의 크기 비교
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
                '친권자 동의서',
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
            body: LayoutBuilder(builder: (context, constraints) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await _adjustScaleIfScrollable(constraints);
                widget.setPdfDisplay();
              });
              return Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                          20.w, 0.w, 20.w, CommonSize.commonBottom + 100.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Transform.scale(
                            scale: _scaleFactor,
                            alignment: Alignment.topCenter,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Column(
                                  key: _pdfKey,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                        '친권자 정보',
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
                                            detailData!
                                                .parentAgreeDto.paParentName,
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
                                            AuthService.convertBirthday(
                                                detailData!.parentAgreeDto
                                                    .paParentBirth),
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
                                                detailData!.parentAgreeDto
                                                    .paParentPhone),
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
                                          '근로자와의 관계',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            returnParentType(detailData!
                                                .parentAgreeDto.paType),
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
                                          '주소',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${detailData!.parentAgreeDto.paParentAddress} ${detailData!.parentAgreeDto.paParentAddressDetail}',
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
                                            detailData!
                                                .parentAgreeDto.paWorkerName,
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
                                            AuthService.convertBirthday(
                                                detailData!.parentAgreeDto
                                                    .paWorkerBirth),
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
                                                detailData!.parentAgreeDto
                                                    .paWorkerPhone),
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
                                          '주소',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${detailData!.parentAgreeDto.paWorkerAddress} ${detailData!.parentAgreeDto.paWorkerAddressDetail}',
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
                                        '사업장 정보',
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
                                          '회사명',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            detailData!
                                                .parentAgreeDto.paCompanyName,
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
                                          '전화번호',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            ConvertService.formatPhoneNumber(
                                                detailData!.parentAgreeDto
                                                    .paCompanyPhone),
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
                                          '주소',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            detailData!.parentAgreeDto
                                                .paCompanyAddress,
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
                                      height: 40.w,
                                    ),
                                    Text(
                                      '본인은 위 근로자  ${detailData!.parentAgreeDto.paWorkerName} (이)가 위 사업장에서\n근로를 하는 것에 대하여 동의합니다.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: CommonColors.gray66,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.w,
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
                                      height: 12.w,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '친권자: ${detailData!.parentAgreeDto.paParentName}',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: CommonColors.gray4d,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30.w,
                                          height: 30.w,
                                          child: ExtendedImgWidget(
                                            imgFit: BoxFit.contain,
                                            imgUrl: widget.signImg,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned(
                                  left: 20.w,
                                  right: 20.w,
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 60.w),
                                    child: Image.asset(detailData!
                                                .caRepairStatus ==
                                            0
                                        ? 'assets/images/default/imgMisu.png'
                                        : detailData!.caRepairStatus == 1
                                            ? 'assets/images/default/imgSuri.png'
                                            : 'assets/images/default/imgMisu.png'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }));
  }
}
