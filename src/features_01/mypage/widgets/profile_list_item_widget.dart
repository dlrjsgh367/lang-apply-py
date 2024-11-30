import 'package:chodan_flutter_app/features/mypage/widgets/profile_text.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileListItemWidget extends StatelessWidget {
  const ProfileListItemWidget({
    super.key,
    required this.onTap,
    required this.title,
    this.content,
    this.isRequire = false,
    this.isEditable = true,
  });


  final Function onTap;
  final String title;
  final String? content;

  final bool isRequire;

  final bool isEditable;


  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child:  GestureDetector(
        onTap: () {
          onTap();
        },
        child:
        Container(
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
          child:

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.black2b,
                                ),
                              ),
                            ),
                            if (isRequire)
                            Container(
                              margin: EdgeInsets.only(left: 4.w),
                              width: 4.w,
                              height: 4.w,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CommonColors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if(isEditable)
                  Image.asset(
                    'assets/images/icon/iconArrowRightThin.png',
                    width: 24.w,
                    height: 24.w,
                  ),
                ],
              ),
              if (content != null)
                ProfileText(
                  text: content!,
                ),
            ],
          )   ,),
      ),
    );

  }
}
