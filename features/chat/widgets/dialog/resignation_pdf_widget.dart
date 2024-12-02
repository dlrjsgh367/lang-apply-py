import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/models/chat_file_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResignationPdfWidget extends StatefulWidget {
  const ResignationPdfWidget({
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
  State<ResignationPdfWidget> createState() => _ResignationPdfWidgetState();
}

class _ResignationPdfWidgetState extends State<ResignationPdfWidget> {
  ChatFileModel? detailData;
  final GlobalKey _pdfKey = GlobalKey();
  double _scaleFactor = 1.0;

  @override
  initState() {
    detailData = widget.detailData;
    super.initState();
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
                '사직서',
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
                          20.w, 16.w, 20.w, CommonSize.commonBottom),
                      child: Transform.scale(
                        scale: _scaleFactor,
                        alignment: Alignment.topCenter,
                        child:  Stack(
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
                                        width: 1.w, color: CommonColors.gray66),
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
                                      detailData!.resignationDto.reName,
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
                                      AuthService.convertBirthday(detailData!
                                          .resignationDto.reStartDate),
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
                                      detailData!.resignationDto.rePosition ==
                                              ''
                                          ? '-'
                                          : detailData!
                                              .resignationDto.rePosition,
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
                                        width: 1.w, color: CommonColors.gray66),
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
                                    '퇴사일자',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.gray80,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      AuthService.convertBirthday(detailData!
                                          .resignationDto.reResignationDate),
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
                                    '퇴사사유',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.gray80,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      detailData!.resignationDto.reReason,
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
                                '위의 사유로 사직서를\n 제출하오니 허락하여 주시기 바랍니다.',
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '신청자: ${detailData!.resignationDto.reName}',
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
                                      imgWidth: 30.w,
                                      imgHeight: 30.w,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.w,
                              ),
                            ],
                          ),
                          Positioned(
                            left: 20.w,
                            right: 20.w,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 60.w),
                              child: Image.asset(
                                  'assets/images/default/imgDong.png'),
                            ),
                          ),
                        ],
                      )),
                    ),
                  ),
                ],
              );
            }));
  }
}
