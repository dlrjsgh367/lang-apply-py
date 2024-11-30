import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/features/jobposting/service/jobposting_service.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/etc/worker_default_img.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class WorkerHidesWidget extends ConsumerStatefulWidget {
  const WorkerHidesWidget({
    required this.toggleHidesWorker,
    required this.workerItem,
    required this. index,
    super.key});

  final ProfileModel workerItem;
  final Function toggleHidesWorker;
  final int index;

  @override
  ConsumerState<WorkerHidesWidget> createState() => _WorkerHidesWidgetState();
}

class _WorkerHidesWidgetState extends ConsumerState<WorkerHidesWidget> {

  bool isRunning = false;

  @override
  Widget build(BuildContext context) {
    List<int> workerHidesKeyList = ref.watch(workerHidesKeyListProvider);
    List<int> matchedProfileKeyList = ref.watch(matchingKeyListProvider);
    return GestureDetector(
      onTap: (){
        context.push('/seeker/${widget.workerItem.key}');
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
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
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(200.w),
                  child:
                  widget.workerItem.profileImg!.key != 0
                      ?
                  SizedBox(
                    width: 64.w,
                    height: 64.w,
                    child: ExtendedImgWidget(
                      imgUrl: widget.workerItem.profileImg!.url,
                      imgWidth: 64.w,
                      // imgHeight: 64.w,
                      imgFit: BoxFit.cover,
                    ),
                  )
                      :
                  WorkerDefaultImgWidget(
                    colorCode: widget.workerItem.color, name:
                  ConvertService.isNotEmptyValidate(widget.workerItem.name)
                      ? widget.workerItem.name[0]
                      :
                  '',
                    width: 64.w,
                    height: 64.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${ConvertService.returnMaskingName(matchedProfileKeyList.contains(widget.workerItem.key), widget.workerItem.name)}  (${ConvertService.calculateAge(widget.workerItem.birth)}세, ${widget.workerItem.gender.label})',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: CommonColors.black2b,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async{
                              widget.toggleHidesWorker(workerHidesKeyList,widget.workerItem.key);
                            },
                            child: Row(
                              children: [
                                workerHidesKeyList.contains(widget.workerItem.key)
                                ?
                                Container(
                                  padding: EdgeInsets.fromLTRB(12.w, 3.w, 12.w, 3.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200.w),
                                    color: CommonColors.red,
                                  ),
                                  child: Text(
                                    localization.blocked,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.white,
                                    ),
                                  ),
                                ) : Container(
                                  padding: EdgeInsets.fromLTRB(12.w, 3.w, 12.w, 3.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200.w),
                                    color: CommonColors.grayF2,
                                  ),
                                  child: Text(
                                    localization.unblock,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.grayB2,
                                    ),
                                  ),
                                ),
                                // Image.asset(
                                //   workerHidesKeyList.contains(widget.workerItem.key)
                                //       ?
                                //   'assets/images/icon/iconHeartActive.png'
                                //       :
                                //   'assets/images/icon/iconHeart.png',
                                //   width: 24.w,
                                //   height: 24.w,
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.w),
                      Row(
                        children: [
                          Text(
                            localization.desiredWorkRegion,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CommonColors.gray80,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          for(int i = 0; i<widget.workerItem.profileAreas.length; i++)
                            Padding(
                              padding: EdgeInsets.only(right: i != widget.workerItem.profileAreas.length -1 ? 2.w : 0),
                              child: Text(
                                widget.workerItem.profileAreas[i].areaInfo.dongName,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.gray80,
                                ),
                              ),
                            ),
                        ],
                      ),

                      if(widget.workerItem.profileJobs.isNotEmpty)
                        Text(
                          '${JobpostingService.mergeJobString(widget.workerItem.profileJobs)}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: CommonColors.gray80,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.w),
            DecoratedBox(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: CommonColors.grayF2,
                      ))),
            ),
            SizedBox(height: 12.w),
            Row(
              children: [
                Container(
                  padding:
                  EdgeInsets.fromLTRB(8.w, 2.w, 8.w, 2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.w),
                    color: CommonColors.grayF7,
                  ),
                  child: Text(
                    localization.profile,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CommonColors.gray80,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.push('/seeker/${widget.workerItem.key}');
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.workerItem.profileTitle,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/icon/iconArrowRight.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
