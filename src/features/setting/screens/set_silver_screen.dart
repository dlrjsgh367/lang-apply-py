import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/radio/toggle_radio_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetSilverScreen extends ConsumerStatefulWidget {
  const SetSilverScreen({super.key});

  @override
  ConsumerState<SetSilverScreen> createState() => _SetSilverScreenState();
}

class _SetSilverScreenState extends ConsumerState<SetSilverScreen> {
  late SharedPreferences prefs;
  bool loading = true;
  late bool silver;

  @override
  void initState() {
    super.initState();
    Future(() {
      savePageLog();
      initSilver();
    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  initSilver() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString('silver') == 'true') {
        silver = true;
      } else {
        silver = false;
      }
      loading = false;
    });
  }

  void setSilver() async {
    setState(() {
      if (silver) {
        ScreenUtil.init(context,
            designSize: const Size.fromWidth(360)); // 변경된 디자인 사이즈로 적용
      } else {
        ScreenUtil.init(context,
            designSize:
            const Size.fromWidth(360 - 360 * 0.1)); // 변경된 디자인 사이즈로 적용
      }

      silver = !silver;
      prefs.setString('silver', '$silver');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: '실버벨',
      ),
      body: loading
          ? const Loader()
          : CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(0.w, 24.w, 0.w, 0),
            sliver: SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  setSilver();
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  color: CommonColors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '실버벨 서비스',
                          style: TextStyle(
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                      ToggleRadioButton(
                        readOnly: true,
                        onChanged: (value) {},
                        groupValue: true,
                        value: silver,
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 0),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.w),
                  color: CommonColors.grayF7,
                ),
                padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
                child: Text(
                  '실버벨 서비스 이용 시 사용하는 앱의 글자 크기가 커지고, 중장년층 채용공고를 우선하여 추천해드려요.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: CommonColors.gray66,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
