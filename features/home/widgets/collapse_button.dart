import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CollapseButton extends StatefulWidget {
  CollapseButton({
    super.key,
    required this.setChecked,
    required this.checkedArr,
  });

  Function setChecked;
  List checkedArr;

  @override
  State<CollapseButton> createState() => _CollapseButtonState();
}

class _CollapseButtonState extends State<CollapseButton> {
  bool topOpen = false;
  List expandChildArr = [];
  final ScrollController _topScrollCon = ScrollController();
  double maxHeight = 56.w;

  void setChildOpen(data, childLength) {
    setState(() {
      if (expandChildArr.contains(data)) {
        expandChildArr.remove(data);
        maxHeight = maxHeight - 56.w * childLength;
      } else {
        expandChildArr.add(data);
        maxHeight = maxHeight + 56.w * childLength;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        maxHeight = _topScrollCon.position.maxScrollExtent;
      });
    });
  }

  void setOpen() {
    setState(() {
      topOpen = !topOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: topOpen ? maxHeight + 56.w : 56.w,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: _topScrollCon,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                setOpen();
              },
              child: Container(
                height: 56.w,
                padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
                decoration: BoxDecoration(
                  color: CommonColors.white,
                  border: Border(
                    bottom: BorderSide(
                      width: 1.w,
                      color: CommonColors.grayF2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localization.cookingAndServing,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: CommonColors.gray66,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/icon/iconArrowDown.png',
                      width: 20.w,
                      height: 20.w,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                widget.setChecked('cook', 'all');
              },
              child: Container(
                height: 56.w,
                padding: EdgeInsets.fromLTRB(40.w, 0.w, 20.w, 0.w),
                decoration: BoxDecoration(
                  color: CommonColors.grayF7,
                  border: Border(
                    bottom: BorderSide(
                      width: 1.w,
                      color: CommonColors.grayF2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localization.cookingAndServingAll,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.gray66,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20.w,
                      height: 20.w,
                      child: Image.asset(
                        true
                            ? 'assets/images/icon/IconCheckActive.png'
                            : 'assets/images/icon/IconCheck.png',
                        width: 20.w,
                        height: 20.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (var i = 0; i < 6; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: expandChildArr.contains(i) ? 56.w * 3 : 56.w,
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setChildOpen(i, 2);
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(40.w, 0.w, 20.w, 0.w),
                          decoration: BoxDecoration(
                            color: CommonColors.grayF7,
                            border: Border(
                              bottom: BorderSide(
                                width: 1.w,
                                color: CommonColors.grayF2,
                              ),
                            ),
                          ),
                          height: 56.w,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  localization.cooking,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray66,
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/images/icon/iconArrowDown.png',
                                width: 20.w,
                                height: 20.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.setChecked('type', 'data');
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(60.w, 0.w, 20.w, 0.w),
                          color: CommonColors.grayF2,
                          height: 56.w,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '111', // TODO > 111 .. 정체 불명의 텍스트 뭔지 알아내기 (이건호)
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray66,
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20.w,
                                height: 20.w,
                                child: Image.asset(
                                  true
                                      ? 'assets/images/icon/IconCheckActive.png'
                                      : 'assets/images/icon/IconCheck.png',
                                  width: 20.w,
                                  height: 20.w,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.setChecked('type', 'data');
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(60.w, 0.w, 20.w, 0.w),
                          color: CommonColors.grayF2,
                          height: 56.w,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '222', // TODO > 222 .. 정체 불명의 텍스트 뭔지 알아내기 (이건호)
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray66,
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20.w,
                                height: 20.w,
                                child: Image.asset(
                                  true
                                      ? 'assets/images/icon/IconCheckActive.png'
                                      : 'assets/images/icon/IconCheck.png',
                                  width: 20.w,
                                  height: 20.w,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
