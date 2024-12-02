import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/parent_agree_create_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/resignation_create_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/vacation_create_dialog_widget.dart';
import 'package:chodan_flutter_app/features/evaluate/widgets/evaluation_jobseeker_chat_bottom_sheet.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DocumentSelectDialogWidget extends ConsumerStatefulWidget {
  DocumentSelectDialogWidget({
    super.key,
    required this.uuid,
    required this.sendDocument,
    required this.chatUsers,
    required this.companyName,
  });

  Function sendDocument;
  String uuid;
  Map<String, dynamic> chatUsers;
  final String companyName;

  @override
  ConsumerState<DocumentSelectDialogWidget> createState() =>
      _DocumentSelectDialogWidgetState();
}

class _DocumentSelectDialogWidgetState
    extends ConsumerState<DocumentSelectDialogWidget> {
  showVacationCreateDialog() {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        return VacationCreateDialogWidget(
          uuid: widget.uuid,
          chatUsers: widget.chatUsers,
        );
      },
    );
  }

  showResignationCreateDialog() {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context) {
        return ResignationCreateDialogWidget(
          uuid: widget.uuid,
          chatUsers: widget.chatUsers,
          companyName: widget.companyName,
        );
      },
    );
  }

  showParentAgreeCreateDialog() {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context) {
        return ParentAgreeCreateDialogWidget(
          uuid: widget.uuid,
          chatUsers: widget.chatUsers,
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8.w, 0, CommonSize.commonBottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const TitleBottomSheet(title: '서류작성'),
            SizedBox(
              height: 20.w,
            ),
            BottomSheetButton(
                onTap: () {
                  Navigator.pop(context);
                  showVacationCreateDialog();
                },
                text: '휴가 신청서'),
            BottomSheetButton(
                onTap: () {
                  Navigator.pop(context);
                  showParentAgreeCreateDialog();
                },
                text: '친권자 동의서'),
            BottomSheetButton(
                onTap: () {
                  Navigator.pop(context);
                  showResignationCreateDialog();
                },
                text: '사직서'),
          ],
        ),
      ),
    );
  }
}
