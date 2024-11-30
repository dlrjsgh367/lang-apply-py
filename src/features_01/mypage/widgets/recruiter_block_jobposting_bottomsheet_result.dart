import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/custom_sliver_header_delegate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecruiterBlockJobpostingBottomsheet extends StatelessWidget {
  const RecruiterBlockJobpostingBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: CustomSliverHeaderDelegate(
            minHeight: 50.0, // 최소 높이
            maxHeight: 50.0, // 최대 높이
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  color: Colors.white, // 배경색
                  alignment: Alignment.centerLeft, // 정렬
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(localization.businessCertificationNotCompleted),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ).copyWith(
                    overlayColor: ButtonStyles.overlayNone,
                  ),
                  onPressed: () {
                    context.pop();
                  },
                  child: Image.asset(
                    'assets/images/icon/iconX.png',
                    width: 13,
                    height: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Column(
            children: [
              Text(localization.jobStabilityLawUpdate),
              Text(localization.businessCertificationRequired),
            ],
          ),
        ),

        SliverToBoxAdapter(
            child: Row(
              children: [
                CommonButton(
                  onPressed: (){
                    context.pop();
                  },
                  confirm: true,
                  text: localization.doItLater,
                  width: CommonSize.vw / 2,
                ),
                CommonButton(
                  onPressed: (){
                    //TODO : 인증하러 가기
                    context.pop();
                  },
                  confirm: true,
                  text: localization.goToCertification,
                  width: CommonSize.vw / 2,
                ),
              ],
            )

        )

      ],
    );
  }
}
