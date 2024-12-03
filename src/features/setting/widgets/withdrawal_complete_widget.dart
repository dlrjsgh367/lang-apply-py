import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WithdrawalCompleteWidget extends ConsumerStatefulWidget {
  const WithdrawalCompleteWidget({
    super.key,
    required this.onPress,
  });

  final Function onPress;

  @override
  ConsumerState<WithdrawalCompleteWidget> createState() => _WithdrawalCompleteWidgetState();
}

class _WithdrawalCompleteWidgetState extends ConsumerState<WithdrawalCompleteWidget> {

  @override
  void initState() {
    super.initState();
    Future(() {
      savePageLog();
    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  @override
  Widget build(BuildContext context) {
    return
      CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 32.w, 20.w, 0.w),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localization.721,
                    style: TextStyles.withdrawalTitle,
                  ),
                  SizedBox(
                    height: 16.w,
                  ),
                  Text(
                    '그동안 초단알바를 이용해주셔서 감사합니다.\n아쉽고 또 아쉽지만 더 나은 모습으로 다시 만나길 소망합니다.',
                    style: TextStyle(fontSize: 14.sp, color: CommonColors.gray66),
                  ),
                  SizedBox(
                    height: 16.w,
                  ),
                  BorderButton(
                      onPressed: () {
                        widget.onPress();
                      },
                      text: localization.723)
                ],
              ),
            ),
          ),
          const BottomPadding(),
        ],
      );

  }
}
