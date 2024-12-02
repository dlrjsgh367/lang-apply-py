import 'dart:convert';

import 'package:chodan_flutter_app/core/back_listener.dart';
import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_list_recruiter.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_list_seeker.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_matching.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/chat_search_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/start_chat_dialog_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/user/controller/user_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_bottom_appbar.dart';
import 'package:chodan_flutter_app/widgets/appbar/red_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({this.tab, super.key});

  final String? tab;

  @override
  ConsumerState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with Alerts, BackButtonEvent, SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animateController;
  late Animation<double> _animation;
  bool _isDragging = false;
  double _previousScrollPosition = 0;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  String uuid = '';

  String enteredText = '';
  String searchValue = '';
  List<String> recentSearchKeyword = [];

  int total = 0;
  int page = 0;

  TextEditingController searchController = TextEditingController();

  loadMore() {
    chatUserService = ChatUserService(ref: ref);
    if (searchValue != '') {
      chatUserService.getSearchUserRoomsList(searchValue);
    } else {
      page = page + 1;
      chatUserService.getUserRoomsList(page);
    }
  }

  void stopScroll() {
    _scrollController.animateTo(
      _scrollController.offset, // 현재 위치로 스크롤
      duration: const Duration(milliseconds: 1),
      curve: Curves.ease,
    );
  }

  getUserMatchingList() async {
    var user = ref.watch(userProvider);

    ApiResultModel result = await ref
        .read(userControllerProvider.notifier)
        .getUserMatchingList(user!.key);
    if (result.type == 1) {
      if (mounted) {
        setState(() {
          total = result.page['total'];
        });
        ref.read(userListProvider.notifier).update((state) => result.data);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  setSearchValue(String value, TextEditingController controller) {
    setState(() {
      searchValue = value;
      searchController.text = searchValue;
      enteredText = controller.text.trim();
    });
  }

  saveRecentSearchKeywordsToLocalStorage(String keyword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keywords = await getRecentSearchKeyword();
    if (keywords.length == 10) {
      keywords.removeLast();
    }
    if (keywords.contains(keyword)) {
      keywords.remove(keyword);
    }
    keywords.insert(0, keyword);
    String jsonString = jsonEncode(keywords);
    await prefs.setString('searchKeywords', jsonString);
  }

  Future<List<String>> getRecentSearchKeyword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('searchKeywords');
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      List<String> keywords = jsonList.map((item) => item.toString()).toList();
      return keywords;
    }
    return [];
  }

  setRecentSearchKeywords() async {
    List<String> keywords = await getRecentSearchKeyword();
    setState(() {
      recentSearchKeyword = keywords;
    });
  }

  searchChatList(String value) async {
    chatUserService = ChatUserService(ref: ref);

    if (value == '') {
      await chatUserService.getUserRoomsList(1);
    } else {
      setState(() {
        searchValue = value;
      });
      saveRecentSearchKeywordsToLocalStorage(value).then((_) async {
        setRecentSearchKeywords();

        await chatUserService.getSearchUserRoomsList(searchValue);
      });

      savePageLog();
    }

    context.pop();
  }

  reset() {
    searchChatList('');
  }

  removeSpecificSearchKeywords(String keyword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keywords = await getRecentSearchKeyword();
    keywords.remove(keyword);
    String jsonString = jsonEncode(keywords);
    await prefs.setString('searchKeywords', jsonString);
    List<String> list = recentSearchKeyword;
    list.remove(keyword);
    setState(() {
      recentSearchKeyword = [...list];
    });
  }

  void clickRecentSearchKeyword(String keyword) async {
    setState(() {
      searchValue = keyword;
      searchController.text = searchValue;
    });
    searchChatList(keyword);
  }

  showSearchDialog() {
    showModalSideSheet(
      width: CommonSize.vw,
      useRootNavigator: false,
      withCloseControll: false,
      ignoreAppBar: true,
      context: context,
      transitionDuration: const Duration(milliseconds: 200),
      body: ChatSearchDialogWidget(
        setSearchValue: setSearchValue,
        searchChatList: searchChatList,
        searchValue: searchValue,
        recentSearchKeyword: recentSearchKeyword,
        clickRecentSearchKeyword: clickRecentSearchKeyword,
        removeSpecificSearchKeywords: removeSpecificSearchKeywords,
        resetJobPost: reset,
      ),
    );
  }

  showJobseekerMenuDialog(dynamic data, dynamic chatUser) {
    showModalBottomSheet<void>(
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
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return ContentBottomSheet(
          contents: [
            BottomSheetButton(
                onTap: () {
                  context.push('/jobpost/${data.jpIdx}');
                },
                text: localization.matchedJobPostings),
            BottomSheetButton(
                onTap: () {
                  context.push('/seeker/${data.mpIdx}');
                },
                text: localization.candidateProfile),
            BottomSheetButton(
                isRed: true,
                last: true,
                onTap: () {
                  context.pop();
                  if (data.roomUuid.isEmpty) {
                    showStartChatDialog(data);
                  } else {
                    context.push('/chat/detail/${data.roomUuid}');
                  }
                },
                text: localization.startConversation),
          ],
        );
      },
    );
  }

  showStartChatDialog(dynamic data) {
    showModalBottomSheet<void>(
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
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return StartChatDialogWidget(
            partnerUuid: uuid,
            data: data,
            isMichinMatching: data.michinMatchingList.isNotEmpty);
      },
    );
  }

  returnLastChatDate(DateTime chatDate) {
    DateTime now = DateTime.now();

    if (DateFormat('yyyy-MM-dd').format(chatDate) ==
        DateFormat('yyyy-MM-dd').format(now)) {
      return DateFormat('HH:mm').format(chatDate);
    } else if (DateTime(now.year, now.month, now.day - 1) ==
        DateFormat('yyyy-MM-dd').format(chatDate)) {
      return localization.yesterday;
    } else {
      return DateFormat('yyyy-MM-dd').format(chatDate);
    }
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });

    Future(() async {
      savePageLog();
      await getUserData();
      var user = ref.watch(userProvider);
      chatUserService = ChatUserService(ref: ref);
      initChatService(user!, chatUserService);
      if (user!.memberType != MemberTypeEnum.jobSeeker) {
        getUserMatchingList();
        if (widget.tab != null && widget.tab == 'matching') {
          setTab(1);
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
      setRecentSearchKeywords();
    });

    _animateController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animateController,
      curve: Curves.linear,
    );
    _animateController.value = 1;
    super.initState();
  }

  getUserData() async {
    ApiResultModel result =
        await ref.read(authControllerProvider.notifier).getUserData();
    if (result.status == 200) {
      if (result.type == 1) {
        ref.read(userProvider.notifier).update((state) => result.data);
      }
    }
  }

  _onUpdateScroll(metrics) {
    if (_isDragging) {
      final double currentScrollPosition = metrics.pixels;
      if (currentScrollPosition > _previousScrollPosition) {
        _animateController.animateBack(0,
            duration: const Duration(milliseconds: 100));
      } else if (currentScrollPosition < _previousScrollPosition) {
        _animateController.forward();
      }
      _previousScrollPosition = currentScrollPosition;
    }
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.chat.type);
  }

  getDday(DateTime date) {
    // D-day 날짜 설정 (년, 월, 일)
    DateTime dDay = date;

    // 현재 날짜 가져오기
    DateTime now = DateTime.now();

    // D-day 계산 (D-day 날짜 - 현재 날짜)
    Duration difference = dDay.difference(now);

    // D-day 출력
    if (difference.isNegative) {
      return localization.terminated;
    } else {
      return 'D-${difference.inDays}';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  int activeTab = 0;

  setTab(data) {
    setState(() {
      savePageLog();
      activeTab = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    var chatUserList = ref.watch(userListProvider);
    var chatUser = ref.watch(chatUserAuthProvider);

    var chatRooms = ref.watch(chatUserRoomProvider);
    var user = ref.watch(userProvider);

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            backPress();
          }
        },
        child: Scaffold(
          appBar: RedAppbar(
            setTab: user?.role != 'ROLE_JOBSEEKER' ? setTab : () {},
            activeTab: activeTab,
            tabTitleArr:
                user?.role != 'ROLE_JOBSEEKER' ? [localization.conversationList, localization.matchingList] : [localization.conversationList],
          ),
          bottomNavigationBar: CommonBottomAppbar(type: 'chat'),
          body: isLoading || user == null
              ? const Loader()
              : activeTab == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizeTransition(
                          sizeFactor: _animation,
                          axis: Axis.vertical,
                          axisAlignment: -1,
                          child: Container(
                            color: CommonColors.red,
                            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 8.w),
                            child: TextFormField(
                              controller: searchController,
                              readOnly: true,
                              decoration: searchInput(
                                hintText: user.role != 'ROLE_JOBSEEKER'
                                    ? localization.searchByCandidateName
                                    : localization.searchByCompanyName,
                                height: 50,
                                clearFunc: () {
                                  setSearchValue('', searchController);
                                  reset();
                                },
                              ),
                              onTap: () {
                                showSearchDialog();
                              },
                            ),
                          ),
                        ),
                        if (user.role != 'ROLE_JOBSEEKER')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(20.w, 20.w, 16.w, 16.w),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${localization.matchedCandidates} : ',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: CommonColors.gray4d,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            localization.numOfCandidates(total),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: CommonColors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              setTab(1);
                                            });
                                          },
                                          style: ButtonStyles.childBtn,
                                          child: Row(
                                            children: [
                                              Text(
                                                localization.viewAll,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: CommonColors.gray60,
                                                ),
                                              ),
                                              Image.asset(
                                                'assets/images/icon/iconArrowRightThin.png',
                                                width: 16.w,
                                                height: 16.w,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.w),
                                    Text(
                                      localization.startConversationWithMatchedCandidate,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: CommonColors.gray60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (total > 0)
                                SingleChildScrollView(
                                  padding:
                                      EdgeInsets.fromLTRB(10.w, 0, 10.w, 8.w),
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (var data in chatUserList)
                                        GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              uuid = data.uuid;
                                            });
                                            if (chatUser!.uuid != uuid) {
                                              showJobseekerMenuDialog(
                                                  data, chatUser);
                                            }
                                          },
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10.w, 0, 10.w, 0),
                                            width: 60.w,
                                            child: Column(
                                              children: [
                                                ClipOval(
                                                  child: SizedBox(
                                                    width: 60.w,
                                                    height: 60.w,
                                                    child: data.profileImg
                                                                .isNotEmpty &&
                                                            data.profileIdx !=
                                                                ''
                                                        ? ExtendedImgWidget(
                                                            imgUrl:
                                                                data.profileImg,
                                                            imgFit:
                                                                BoxFit.cover,
                                                          )
                                                        : Container(
                                                            color: Colors.black,
                                                            child: Image.asset(
                                                              'assets/images/default/imgDefault3.png',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 8.w,
                                                ),
                                                Text(
                                                  ConvertService
                                                      .returnMaskingName(
                                                          data.roomUuid
                                                              .isNotEmpty,
                                                          data.meName),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          CommonColors.black2b),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              Divider(
                                height: 16.w,
                                thickness: 16.w,
                                color: CommonColors.grayF7,
                              ),
                            ],
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 4.w, 0, 4.w),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 1.w, color: CommonColors.grayE6),
                              ),
                            ),
                            child: Text(
                              localization.numOfConversations(chatRooms.length),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: CommonColors.gray60,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: chatRooms.isEmpty
                              ? CommonEmpty(
                                  text: localization.noOngoingConversations,
                                )
                              : LazyLoadScrollView(
                                  isLoading: ChatUserService.isLazyLoad,
                                  onEndOfPage: () => loadMore(),
                                  child:
                                      NotificationListener<ScrollNotification>(
                                    onNotification: (ScrollNotification
                                        scrollNotification) {
                                      if (scrollNotification
                                          is ScrollStartNotification) {
                                        _isDragging = true;
                                      }
                                      if (scrollNotification
                                          is ScrollUpdateNotification) {
                                        _onUpdateScroll(
                                            scrollNotification.metrics);
                                      }
                                      if (scrollNotification
                                          is ScrollEndNotification) {
                                        _isDragging = false;
                                      }
                                      return false;
                                    },
                                    child: CustomScrollView(
                                      controller: _scrollController,
                                      physics: const ClampingScrollPhysics(),
                                      slivers: [
                                        SliverPadding(
                                          padding: EdgeInsets.fromLTRB(
                                              20.w, 0, 20.w, 0),
                                          sliver: SliverList(
                                            delegate:
                                                SliverChildBuilderDelegate(
                                              childCount: chatRooms.length,
                                              (context, index) {
                                                var data = chatRooms[index]!;
                                                if (!data.isOut) {
                                                  return user.role !=
                                                          'ROLE_JOBSEEKER'
                                                      ? ChatListRecruiter(
                                                          data: data)
                                                      : ChatListSeeker(
                                                          data: data);
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    )
                  : const ChatMatching(),
        ));
  }
}
