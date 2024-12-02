import 'dart:ui';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_input_widget.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_bottom_appbar.dart';
import 'package:chodan_flutter_app/widgets/appbar/logo_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/appbar_button.dart';
import 'package:chodan_flutter_app/widgets/chat/date_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ChatRecruiterTutorial extends StatefulWidget {
  const ChatRecruiterTutorial({super.key, required this.setTutorial});

  final Function setTutorial;

  @override
  State<ChatRecruiterTutorial> createState() => _ChatRecruiterTutorialState();
}

class _ChatRecruiterTutorialState extends State<ChatRecruiterTutorial> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            primary: true,
            toolbarHeight: 48.w,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              '구직자 이름',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: CommonColors.black,
              ),
            ),
            actions: [],
            titleSpacing: 0,
            centerTitle: true,
            leadingWidth: 64.w,
            leading:
            AppbarButton(onPressed: () {}, imgUrl: 'iconArrowLeft.png'),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 12.w),
                                Flexible(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16.w),
                                        topRight: Radius.circular(16.w),
                                        bottomRight: Radius.circular(16.w),
                                        bottomLeft: Radius.zero,
                                      ),
                                      border: Border.all(
                                          width: 1.w,
                                          color: CommonColors.grayF2),
                                      color: CommonColors.white,
                                    ),
                                    padding: EdgeInsets.fromLTRB(
                                        16.w, 10.w, 16.w, 10.w),
                                    child: Text(
                                      '메세지 문구',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                        color: CommonColors.gray66,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '14:00',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: CommonColors.grayB2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 12.w),
                              ],
                            ),
                          ),

                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 12.w),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      false ? '읽음' : '',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: CommonColors.grayB2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      textAlign: TextAlign.right,
                                      '14:00',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: CommonColors.grayB2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child:  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16.w),
                                        topRight: Radius.circular(16.w),
                                        bottomLeft: Radius.circular(16.w),
                                        bottomRight: Radius.zero,
                                      ),
                                      color: CommonColors.red,
                                    ),
                                    padding: EdgeInsets.fromLTRB(16.w, 10.w, 16.w, 10.w),
                                    child: Text(
                                      '메시지 문구',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                        color: CommonColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.w),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 12.w),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      false ? '읽음' : '',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: CommonColors.grayB2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      textAlign: TextAlign.right,
                                      '14:00',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: CommonColors.grayB2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child:  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16.w),
                                        topRight: Radius.circular(16.w),
                                        bottomLeft: Radius.circular(16.w),
                                        bottomRight: Radius.zero,
                                      ),
                                      color: CommonColors.red,
                                    ),
                                    padding: EdgeInsets.fromLTRB(16.w, 10.w, 16.w, 10.w),
                                    child: Text(
                                      '메시지 문구',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                        color: CommonColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.w),
                        ],
                      ),

                      DateChecker(date: '2024.03.31'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 12.w),
                                Flexible(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16.w),
                                        topRight: Radius.circular(16.w),
                                        bottomRight: Radius.circular(16.w),
                                        bottomLeft: Radius.zero,
                                      ),
                                      border: Border.all(
                                          width: 1.w,
                                          color: CommonColors.grayF2),
                                      color: CommonColors.white,
                                    ),
                                    padding: EdgeInsets.fromLTRB(
                                        16.w, 10.w, 16.w, 10.w),
                                    child: Text(
                                      '메세지 문구',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                        color: CommonColors.gray66,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '14:00',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: CommonColors.grayB2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 12.w),
                              ],
                            ),
                          ),

                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 12.w),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      false ? '읽음' : '',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: CommonColors.grayB2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      textAlign: TextAlign.right,
                                      '14:00',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: CommonColors.grayB2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child:  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16.w),
                                        topRight: Radius.circular(16.w),
                                        bottomLeft: Radius.circular(16.w),
                                        bottomRight: Radius.zero,
                                      ),
                                      color: CommonColors.red,
                                    ),
                                    padding: EdgeInsets.fromLTRB(16.w, 10.w, 16.w, 10.w),
                                    child: Text(
                                      '메시지 문구',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                        color: CommonColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.w),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 12.w),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      false ? '읽음' : '',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: CommonColors.grayB2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      textAlign: TextAlign.right,
                                      '14:00',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: CommonColors.grayB2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child:  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16.w),
                                        topRight: Radius.circular(16.w),
                                        bottomLeft: Radius.circular(16.w),
                                        bottomRight: Radius.zero,
                                      ),
                                      color: CommonColors.red,
                                    ),
                                    padding: EdgeInsets.fromLTRB(16.w, 10.w, 16.w, 10.w),
                                    child: Text(
                                      '메시지 문구',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                        color: CommonColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.w),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: CommonColors.white,
                  border: Border(
                    top: BorderSide(
                      width: 1.w,
                      color: CommonColors.grayF2,
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: 12.w,
                  bottom: 12.w,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/icon/IconChatPlus.png',
                          width: 48.w,
                          height: 48.w,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  // 여러 줄 입력 가능하도록 변경
                                  textInputAction: TextInputAction.newline,
                                  // 엔터 키를 새 줄로 처리
                                  cursorColor: CommonColors.black,
                                  expands: true,
                                  maxLines: null,
                                  minLines: null,
                                  onChanged: (value) {},
                                  style: commonInputText(),
                                  maxLength: null,
                                  decoration: commonChatInput(
                                    hintText: '메시지를 입력해주세요',
                                  ),
                                  onFieldSubmitted: (value) {},
                                ),
                              ),
                              Image.asset(
                                'assets/images/icon/IconChatSend.png',
                                width: 48.w,
                                height: 48.w,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: CommonSize.safePaddingBottom,
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Scaffold(
            appBar: AppBar(
              primary: true,
              toolbarHeight: 48.w,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: SizedBox(),
              actions: [
                Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          color: Colors.white),
                      child: Image.asset(
                        'assets/images/appbar/iconKebab.png',
                        width: 24.w,
                        height: 24.w,
                      ),
                    )),
              ],
              titleSpacing: 0,
              centerTitle: true,
              leadingWidth: 64.w,
              leading: TextButton(
                onPressed: () {
                  widget.setTutorial();
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  fixedSize: Size(64.w, 48.w),
                  backgroundColor: Colors.transparent,
                ).copyWith(
                  overlayColor: ButtonStyles.overlayNone,
                ),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  width: 32.w,
                  height: 32.w,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Image.asset(
                      'assets/images/default/iconXTuto.png',
                      width: 32.w,
                      height: 32.w,
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
            body: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 0, 12.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 4.w,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/default/imgBalloonTuto02.png',
                        width: 253.w,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(4.w, 0, 0, 10.w),
                          child: Image.asset(
                            'assets/images/default/imgBalloonTuto03.png',
                            width: 270.w,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              height: 40.w,
                              width: 40.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                color: CommonColors.white,
                              ),
                              child: Image.asset(
                                'assets/images/icon/IconChatPlus.png',
                                width: 48.w,
                                height: 48.w,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 18.w,
                        ),
                        SizedBox(
                          height: CommonSize.safePaddingBottom,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
