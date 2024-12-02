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
                  child: const Text('사업자 인증을 받지 않으셨네요!'),
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
              Text('직업안정법 개정으로 모집공고를 등록하려면'),
              Text('사업자 인증이 꼭 필요해요!'),
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
                  text: '나중에하기',
                  width: CommonSize.vw / 2,
                ),
                CommonButton(
                  onPressed: (){
                    //TODO : 인증하러 가기
                    context.pop();
                  },
                  confirm: true,
                  text: '인증하러 가기',
                  width: CommonSize.vw / 2,
                ),
              ],
            )

        )

      ],
    );
  }
}
