import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlbaMapJob extends ConsumerStatefulWidget {
  const AlbaMapJob(
      {required this.jobData,
      required this.changeMapJob,
      required this.selectedJobList,
      super.key});

  final DefineModel jobData;
  final Function changeMapJob;
  final List selectedJobList;

  @override
  ConsumerState<AlbaMapJob> createState() => _AlbaMapJobState();
}

class _AlbaMapJobState extends ConsumerState<AlbaMapJob> with Alerts {
  returnIcon(data) {
    switch (data) {
      case 1:
        return 'assets/images/default/iconFood.png';
      case 2:
        return 'assets/images/default/iconDrive.png';
      case 3:
        return 'assets/images/default/iconPro.png';
      case 4:
        return 'assets/images/default/iconWork.png';
      case 5:
        return 'assets/images/default/iconSell.png';
      case 6:
        return 'assets/images/default/iconRes.png';
      case 7:
        return 'assets/images/default/iconService.png';
      case 8:
        return 'assets/images/default/iconIt.png';
      case 9:
        return 'assets/images/default/iconConsult.png';
      case 10:
        return 'assets/images/default/iconMedi.png';
      case 11:
        return 'assets/images/default/iconEdu.png';

      default:
        return 'assets/images/default/iconFood.png';
    }
  }

  checkJobList() {
    int index =
        widget.selectedJobList.indexWhere((el) => el.key == widget.jobData.key);
    return index > -1;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.changeMapJob(widget.jobData);
        });
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(2.w, 0, 2.w, 0),
        height: 32.w,
        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
        decoration: BoxDecoration(
          border: Border.all(
              width: 1.w,
              color: widget.selectedJobList.any((el) => el.key == widget.jobData.key)
                  ? CommonColors.red
                  : CommonColors.grayE6),
          borderRadius: BorderRadius.circular(
            8.w,
          ),
          color: widget.selectedJobList.any((el) => el.key == widget.jobData.key)
              ? CommonColors.red
              : CommonColors.white,
        ),
        child: Row(
          children: [
            Image.asset(
              returnIcon(widget.jobData.key),
              width: 20.w,
              height: 20.w,
            ),
            SizedBox(
              width: 6.w,
            ),
            Text(
              widget.jobData.name,
              style: TextStyle(
                fontSize: 12.w,
                color: widget.selectedJobList.any((el) => el.key == widget.jobData.key)
                    ? CommonColors.white
                    : CommonColors.black2b,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
