import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BtnMenu extends StatelessWidget {
  BtnMenu({super.key, required this.text, required this.tabFunc,this.noBorder = false});


  final bool noBorder;
  final Function tabFunc;

  final String text;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
            onTap: () {
              tabFunc();
            },
            child: Container(
              decoration: BoxDecoration(
                color: CommonColors.white,
                border: noBorder? null: Border(
                  bottom: BorderSide(
                    width:  1.w,
                    color: CommonColors.grayF7,
                  ),
                ),
              ),
              height: 48.w,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: CommonColors.gray66,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/icon/iconArrowMenu.png',
                    width: 24.w,
                    height: 24.w,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
