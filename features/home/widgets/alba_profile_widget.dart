import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/features/jobposting/service/jobposting_service.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/worker_default_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AlbaProfileWidget extends ConsumerStatefulWidget {
  const AlbaProfileWidget({
    super.key,
    required this.workerItem,
    required this.toggleLikesWorker,
    required this.showBottomSuggestJobposting,
  });

  final ProfileModel workerItem;
  final Function toggleLikesWorker;
  final Function showBottomSuggestJobposting;

  @override
  ConsumerState<AlbaProfileWidget> createState() => _AlbaProfileWidgetState();
}

class _AlbaProfileWidgetState extends ConsumerState<AlbaProfileWidget>
    with Alerts {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<int> workerLikesKeyList = ref.watch(workerLikesKeyListProvider);
    List<int> matchedProfileKeyList = ref.watch(matchingKeyListProvider);
    return GestureDetector(
      onTap: () {
        context.push('/seeker/${widget.workerItem.key}');
      },
      child: Container(
        margin: EdgeInsets.only(top: 10.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: CommonColors.white,
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: [
            BoxShadow(
                blurRadius: 4.w,
                color: const Color.fromRGBO(150, 150, 150, 0.25))
          ],
          border: Border(
            bottom: BorderSide(
              color: CommonColors.grayF2,
              width: 1.w,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.workerItem.profileTitle,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: CommonColors.black2b,
              ),
            ),
            SizedBox(
              height: 16.w,
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  ClipOval(
                    child: widget.workerItem.profileImg!.key != 0
                        ? SizedBox(
                            width: 106.w,
                            height: 106.w,
                            child: ExtendedImgWidget(
                              imgUrl: widget.workerItem.profileImg!.url,
                              imgFit: BoxFit.cover,
                            ),
                          )
                        : WorkerDefaultImgWidget(
                            width: 106.w,
                            height: 106.w,
                            colorCode: widget.workerItem.color,
                            name: widget.workerItem.userInfo.name[0],
                          ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: 100.w,
                              ),
                              child: Text(
                                '${ConvertService.returnMaskingName(matchedProfileKeyList.contains(widget.workerItem.key), widget.workerItem.userInfo.name)} ',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: CommonColors.black2b,
                                ),
                              ),
                            ),
                            Text(
                              '(${ConvertService.calculateAge(widget.workerItem.userInfo.birth)}세, ${returnConditionGenderNameFromParam(widget.workerItem.userInfo.gender)})',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: CommonColors.black2b,
                              ),
                            ),
                          ],
                        ),
                        if (widget.workerItem.profileAreas.isNotEmpty)
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/icon/iconPinGray.png',
                                width: 14.w,
                                height: 14.w,
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Expanded(
                                child: Text(
                                  '${widget.workerItem.distance.toStringAsFixed(1)}km ${ConvertService.returnMaskingSiGuDong(matchedProfileKeyList.contains(widget.workerItem.key), widget.workerItem.userInfo.si, widget.workerItem.userInfo.gu, widget.workerItem.userInfo.dongName)}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.sp,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (widget.workerItem.profileJobs.isNotEmpty)
                          Text(
                            '${JobpostingService.mergeJobString(widget.workerItem.profileJobs)}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CommonColors.gray80,
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: CommonButton(
                                      height: 32.w,
                                      confirm: true,
                                      onPressed: () {
                                        widget.showBottomSuggestJobposting(
                                            widget.workerItem.key);
                                      },
                                      text: localization.jobProposal,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      widget.toggleLikesWorker(
                                          workerLikesKeyList,
                                          widget.workerItem.key);
                                    },
                                    child: Image.asset(
                                      workerLikesKeyList
                                              .contains(widget.workerItem.key)
                                          ? 'assets/images/icon/iconHeartActive.png'
                                          : 'assets/images/icon/iconHeart.png',
                                      width: 24.w,
                                      height: 24.w,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
