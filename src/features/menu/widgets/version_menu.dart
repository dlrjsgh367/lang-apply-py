import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VersionMenu extends StatelessWidget {
  const VersionMenu(
      {super.key,
      required this.version,
      required this.tabFunc,
      required this.updateStatus,
      this.noBorder = false});

  final bool noBorder;
  final Function tabFunc;
  final bool updateStatus;

  final String version;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 0),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          onTap: () {
            if (updateStatus) {
              tabFunc();
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '앱버전',
                      style: TextStyles.menuContent,
                    ),
                    Text(
                      updateStatus ? '새로운 버전이 출시 되었어요.' : '최신버전을 사용중이에요',
                      style: TextStyles.commonButton(
                          color: CommonColors.gray4d, fontSize: 10),
                    ),
                  ],
                ),
              ),
              updateStatus
                  ? Container(
                      padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.w),
                        color: CommonColors.red,
                      ),
                      alignment: Alignment.center,
                      height: 20.w,
                      child: const Text(
                        '업데이트',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : Text(
                      version,
                      style: TextStyles.menuContent,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
