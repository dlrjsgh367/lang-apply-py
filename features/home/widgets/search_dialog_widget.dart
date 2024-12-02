import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SearchDialogWidget extends ConsumerStatefulWidget {
  const SearchDialogWidget({
    super.key,
    required this.searchJobPostList,
    required this.setSearchValue,
    required this.searchValue,
    required this.recentSearchKeyword,
    required this.clickRecentSearchKeyword,
    required this.removeSpecificSearchKeywords,
  });

  final Function setSearchValue;
  final Function searchJobPostList;
  final String searchValue;
  final List<String> recentSearchKeyword;

  final Function clickRecentSearchKeyword;
  final Function removeSpecificSearchKeywords;

  @override
  ConsumerState<SearchDialogWidget> createState() => _SearchDialogWidgetState();
}

class _SearchDialogWidgetState extends ConsumerState<SearchDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
        } else {
          if (!didPop) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        /*appBar: SearchAppbar(
          setSearchValue: widget.setSearchValue,
          searchJobPostList: widget.searchJobPostList,
        ),*/
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(bottom: 16.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: CommonColors.grayD9,
                      ),
                    ),
                  ),
                  child: Text(
                    localization.recentSearches,
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: CommonColors.black2b,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
                child: Row(
                  children: [
                    for (var data in widget.recentSearchKeyword)
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                          height: 28.w,
                          padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              width: 1.w,
                              color: CommonColors.red02,
                            ),
                            borderRadius: BorderRadius.circular(100.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                data,
                                style: TextStyle(
                                  fontSize: 14.w,
                                  color: CommonColors.red,
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Image.asset(
                                'assets/images/icon/iconX.png',
                                width: 12.w,
                                height: 12.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const BottomPadding(),
          ],
        ),
      ),
    );
  }
}
