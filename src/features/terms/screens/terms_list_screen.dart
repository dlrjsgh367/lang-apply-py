import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/terms/controller/terms_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/term_category_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:intl/intl.dart';

class TermsListScreen extends ConsumerStatefulWidget {
  const TermsListScreen({super.key, required this.type});

  final String type;

  @override
  ConsumerState<TermsListScreen> createState() => _TermsListScreenState();
}

class _TermsListScreenState extends ConsumerState<TermsListScreen> {
  bool isLoading = true;
  late BoardModel termsData;
  List<BoardModel> termsList = [];
  int termsIdx = 0;

  @override
  void initState() {
    super.initState();
    Future(() {
      getTerms();
    });
  }

  getTerms() async {
    int bcIdx = int.parse(widget.type);
    var user = ref.watch(userProvider);
    int memberType = user?.memberType == MemberTypeEnum.jobSeeker ? 1 : 2;

    ApiResultModel result = await ref
        .read(termsControllerProvider.notifier)
        .getTermsList(bcIdx, memberType);
    if (result.type == 1) {
      setState(() {
        List<BoardModel> data = result.data;
        termsList = [...data];
        termsData = termsList[0];
        termsIdx = termsData.key;
        isLoading = false;
      });
    }
  }

  showCategory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CommonColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      barrierColor: CommonColors.barrier,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TermCategoryBottomSheet(dataArr: termsList, initItem: termsIdx);
      },
    ).then((value) => setState(() {
          termsList.map((e) {
            if (e.key == value) {
              termsData = e;
              termsIdx = termsData.key;
            }
          }).toList();
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoading
          ? const ModalAppbar(title: '')
          : ModalAppbar(title: termsData.title),
      body: !isLoading
          ? CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(0, 12.w, 0, 12.w),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showCategory();
                            },
                            child: Container(
                              height: 28.w,
                              padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(500.w),
                                color: CommonColors.grayF7,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('yyyy-MM-dd').format(
                                        DateTime.parse(termsData.createdAt
                                            .replaceAll("T", " "))),
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.grayB2),
                                  ),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  Image.asset(
                                    'assets/images/icon/iconArrowDownGray.png',
                                    width: 20.w,
                                    height: 20.w,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: Html(data: termsData.content),
                  ),
                ),
                const BottomPadding(),
              ],
            )
          : const Loader(),
    );
  }
}
