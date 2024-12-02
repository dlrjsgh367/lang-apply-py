
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:chodan_flutter_app/models/search_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/search_appbar.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/features/banner/controller/banner_controller.dart';
import 'package:chodan_flutter_app/features/banner/widgets/banner_menu_swiper_widget.dart';
import 'package:chodan_flutter_app/features/apply/controller/apply_controller.dart';

class SearchDialogWidget extends ConsumerStatefulWidget {
  const SearchDialogWidget({
    super.key,
    required this.afterFunc,
    required this.searchValue,
    required this.searchPlaceHolder,
    required this.resetJobPost,
  });

  final Function afterFunc;
  final String? searchValue;
  final String? searchPlaceHolder;
  final Function resetJobPost;
  @override
  ConsumerState<SearchDialogWidget> createState() => _SearchDialogWidgetState();
}

class _SearchDialogWidgetState extends ConsumerState<SearchDialogWidget> {

  @override
  void initState() {
    super.initState();
    Future(() {
      getSearchHistory();
    });
  }

  List<SearchModel> searchList = [];
  bool isActive = false;
  getSearchHistory() async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .getSearchHistory(null);
    if (result.type == 1) {
      setState(() {
        List<SearchModel> data = result.data;
        searchList = [...data];
        isActive = false;
      });
    }
  }
  deleteSearchHistory(idx) async{
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .deleteSearchHistory(idx);
    if (result.type == 1) {
      getSearchHistory();
    }
  }

  Future<ApiResultModel> addSearchHistory(text) async {
    return await ref.read(applyControllerProvider.notifier).addSearchHistory(text, null);
  }

  searchFunc(text) async{
    if(text != ''){
      await addSearchHistory(text);
    }
    widget.afterFunc(text);
    isActive = false;
    context.pop(context);
  }



  @override
  Widget build(BuildContext context) {
    List<BannerModel> menuBannerList = ref.watch(menuBannerListProvider);

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
      child: GestureDetector(
        onHorizontalDragUpdate: (details) async {
          int sensitivity = 5;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            context.pop();

          }
        },
        child: Scaffold(
          appBar: SearchAppbar(
            afterFunc:searchFunc,
            searchValue: widget.searchValue,
            searchPlaceHolder:widget.searchPlaceHolder,
            resetJobPost: widget.resetJobPost,
          ),
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
                      for (int i =0; i < searchList.length; i++)
                        GestureDetector(
                          onTap: () {
                            if(!isActive){
                              isActive = true;
                              searchFunc(searchList[i].word);
                            }
                          },
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
                                  searchList[i].word,
                                  style: TextStyle(
                                    fontSize: 14.w,
                                    color: CommonColors.red,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                GestureDetector(
                                  onTap: (){
                                    if(!isActive){
                                      isActive = true;
                                      deleteSearchHistory(searchList[i].key);
                                    }
                                  },
                                  child: Image.asset(
                                    'assets/images/icon/iconX.png',
                                    width: 12.w,
                                    height: 12.w,
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
              if (menuBannerList.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.only(bottom: 8.w,top: 48.w),
                  sliver: SliverToBoxAdapter(
                    child: BannerMenuSwiperWidget(bannerList: menuBannerList),
                  ),
                ),
              const BottomPadding(),
            ],
          ),
        ),
      ),

    );
  }
}
