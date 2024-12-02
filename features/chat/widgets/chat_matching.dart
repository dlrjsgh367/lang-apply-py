import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/start_chat_dialog_widget.dart';
import 'package:chodan_flutter_app/features/user/controller/user_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/job_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/etc/red_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class ChatMatching extends ConsumerStatefulWidget {
  const ChatMatching({super.key});

  @override
  ConsumerState<ChatMatching> createState() => _ChatMatchingState();
}

class _ChatMatchingState extends ConsumerState<ChatMatching> with Alerts {
  @override
  void initState() {
    Future(() {
      getUserMatchingList(1);
    });
    super.initState();
  }

  int total = 0;
  int lastPage = 0;
  int currentPage = 1;
  bool isLazeLoading = false;
  bool isAutoExtend = false;
  String uuid = '';

  getUserMatchingList(int page) async {
    var user = ref.watch(userProvider);

    if (user!.role != 'ROLE_JOBSEEKER') {
      ApiResultModel result = await ref
          .read(userControllerProvider.notifier)
          .getUserMatchingAllList(user.key, page);
      if (result.type == 1) {
        if (mounted) {
          setState(() {
            lastPage = result.page['lastPage'];
            total = result.page['total'];
            if (page == 1) {
              ref.read(userAllListProvider.notifier).update((state) => []);
            }
          });

          List<JobseekerModel> list = ref.watch(userAllListProvider);

          for (var data in result.data) {
            list.add(data);
          }

          ref.read(userAllListProvider.notifier).update((state) => list);
        }
      } else {
        if (!mounted) return null;
        showNetworkErrorAlert(context);
      }
    }

    setState(() {
      isLazeLoading = false;
    });
  }

  loadMore() {
    if (lastPage > 1 && currentPage + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        currentPage = currentPage + 1;
      });
      getUserMatchingList(currentPage);
    }
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
                text: '매칭된 공고'),
            BottomSheetButton(
                onTap: () {
                  context.push('/seeker/${data.mpIdx}');
                },
                text: '인재 프로필'),
            BottomSheetButton(
              onTap: () {
                context.pop();
                showStartChatDialog(data);
              },
              text: '대화 시작하기',
              isRed: true,
              last: true,
            ),
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

  @override
  Widget build(BuildContext context) {
    var userList = ref.watch(userAllListProvider);
    var chatUser = ref.watch(chatUserAuthProvider);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const RedBack(extraHeight: 80),
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: userList.isEmpty
              ? const CommonEmpty(text: '매칭된 인재가 없어요.')
              : LazyLoadScrollView(
                  isLoading: isLazeLoading,
                  onEndOfPage: () => loadMore(),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(12.w, 16.w, 12.w, 0),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            padding:
                                EdgeInsets.fromLTRB(16.w, 24.w, 16.w, 48.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.w),
                              color: CommonColors.white,
                              boxShadow: const [
                                BoxShadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 16,
                                  color: Color.fromRGBO(0, 0, 0, 0.06),
                                ),
                              ],
                            ),
                            child: CustomScrollView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              slivers: [
                                SliverPadding(
                                  padding: EdgeInsets.only(bottom: 32.w),
                                  sliver: SliverToBoxAdapter(
                                    child: Row(
                                      children: [
                                        Text(
                                          '총 인원 : ',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w600,
                                            color: CommonColors.gray4d,
                                          ),
                                        ),
                                        Text(
                                          '${userList.length}명',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w600,
                                            color: CommonColors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3, // 그리드의 열 수
                                          mainAxisSpacing:
                                              44.w, // 그리드 아이템 사이의 수직 간격
                                          crossAxisSpacing:
                                              26.w, // 그리드 아이템 사이의 수평 간격
                                          mainAxisExtent: 115.w),
                                  delegate: SliverChildBuilderDelegate(
                                      childCount: userList.length,
                                      (context, index) {
                                    var data = userList[index];
                                    return TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          uuid = data.uuid;
                                        });
                                        if (chatUser!.uuid != uuid) {
                                          showJobseekerMenuDialog(
                                              data, chatUser);
                                        }
                                      },
                                      style: ButtonStyles.childBtn,
                                      child: Column(
                                        children: [
                                          ClipOval(
                                            child: SizedBox(
                                              width: 84.w,
                                              height: 84.w,
                                              child: data.profileImg.isNotEmpty
                                                  ? ExtendedImgWidget(
                                                      imgUrl: data.profileImg,
                                                      imgFit: BoxFit.cover,
                                                      // imgWidth: 60.w,
                                                      // imgHeight: 60.w,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/default/imgDefault3.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 8.w,
                                          ),
                                          Text(
                                            ConvertService
                                                .returnMaskingName(data.roomUuid.isNotEmpty, data.meName),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                              color: CommonColors.black2b,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const FooterBottomPadding(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
