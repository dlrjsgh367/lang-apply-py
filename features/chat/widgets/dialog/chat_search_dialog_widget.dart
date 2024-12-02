import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/banner/controller/banner_controller.dart';
import 'package:chodan_flutter_app/features/banner/widgets/banner_menu_swiper_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/search_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ChatSearchDialogWidget extends ConsumerStatefulWidget {
  ChatSearchDialogWidget({
    super.key,
    required this.searchChatList,
    required this.setSearchValue,
    required this.searchValue,
    required this.recentSearchKeyword,
    required this.clickRecentSearchKeyword,
    required this.removeSpecificSearchKeywords,
    required this.resetJobPost,
  });

  Function setSearchValue;
  Function searchChatList;
  String searchValue;
  List<String> recentSearchKeyword;

  Function clickRecentSearchKeyword;
  Function removeSpecificSearchKeywords;
  Function resetJobPost;

  @override
  ConsumerState<ChatSearchDialogWidget> createState() =>
      _ChatSearchDialogWidgetState();
}

class _ChatSearchDialogWidgetState
    extends ConsumerState<ChatSearchDialogWidget> {
  final TextEditingController _searchController = TextEditingController();
  List recentSearchKeyword = [];

  @override
  void initState() {
    if (widget.searchValue != '') {
      _searchController.text = widget.searchValue;
    }
    setState(() {
      recentSearchKeyword = widget.recentSearchKeyword;
    });

    Future(() {
      savePageLog();
    });

    super.initState();
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.chat.type);
  }

  @override
  Widget build(BuildContext context) {
    var user = ref.watch(userProvider);
    List<BannerModel> bannerList = ref.watch(
        user!.memberType == MemberTypeEnum.recruiter
            ? jobSeekerBannerListProvider
            : jobPostingBannerListProvider);

    return GestureDetector(
      onHorizontalDragUpdate: (details) async {
        int sensitivity = 15;
        if (details.globalPosition.dx - details.delta.dx < 60 &&
            details.delta.dx > sensitivity) {
          context.pop();
        }
      },
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: PopScope(
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
          appBar: SearchAppbar(
            resetJobPost: (){
              widget.resetJobPost();
              widget.setSearchValue('', _searchController);
            },
            onChange: (String value) {
              widget.setSearchValue(value, _searchController);

              if (value == '') {
                chatUserService = ChatUserService(ref: ref);
                chatUserService.getUserRoomsList(1);
              }
            },
            afterFunc: (String keyword) {
              widget.searchChatList(keyword);
            },
            searchValue: widget.searchValue,
            searchPlaceHolder: user.memberType == MemberTypeEnum.recruiter
                ? '구직자명으로 검색'
                : '업체명으로 검색',
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
                      '최근검색어',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: CommonColors.black2b,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              if (recentSearchKeyword.isNotEmpty)
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
                    child: Row(
                      children: [
                        for (var data in recentSearchKeyword)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.text = data;
                              });

                              widget.clickRecentSearchKeyword(data);
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
                                    data,
                                    style: TextStyle(
                                      fontSize: 14.w,
                                      color: CommonColors.red,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        recentSearchKeyword.remove(data);
                                      });
                                      widget.removeSpecificSearchKeywords(data);
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
              if (bannerList.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.only(bottom: 8.w, top: 48.w),
                  sliver: SliverToBoxAdapter(
                    child: BannerMenuSwiperWidget(bannerList: bannerList),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
