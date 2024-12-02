import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/contract/widgets/dialog/construction_contract_dialog_widget.dart';
import 'package:chodan_flutter_app/features/contract/widgets/dialog/minor_contract_dialog_widget.dart';
import 'package:chodan_flutter_app/features/contract/widgets/dialog/normal_contract_dialog_widget.dart';
import 'package:chodan_flutter_app/features/contract/widgets/dialog/short_contract_dialog_widget.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EmploymentContractSelectDialogWidget extends ConsumerStatefulWidget {
  EmploymentContractSelectDialogWidget({
    super.key,
    required this.uuid,
    required this.sendDocument,
    required this.chatUsers,
  });

  Function sendDocument;
  String uuid;
  Map<String, dynamic> chatUsers;

  @override
  ConsumerState<EmploymentContractSelectDialogWidget> createState() =>
      _EmploymentContractSelectDialogWidgetState();
}

class _EmploymentContractSelectDialogWidgetState
    extends ConsumerState<EmploymentContractSelectDialogWidget> {
  showContractDialog(String type) {
    showDialog<void>(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context) {
        switch (type) {
          case 'normal':
            return NormalContractDialogWidget(
              uuid: widget.uuid,
              chatUsers: widget.chatUsers,
            );
          case 'short':
            return ShortContractDialogWidget(
              uuid: widget.uuid,
              chatUsers: widget.chatUsers,
            );
          case 'minor':
            return MinorContractDialogWidget(
              uuid: widget.uuid,
              chatUsers: widget.chatUsers,
            );
          case 'construction':
            return ConstructionContractDialogWidget(
              uuid: widget.uuid,
              chatUsers: widget.chatUsers,
            );
          default:
            return NormalContractDialogWidget(
              uuid: widget.uuid,
              chatUsers: widget.chatUsers,
            );
        }
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
            BottomSheetButton(
              onTap: () {
                context.pop();
                showContractDialog('normal');
                // widget.sendDocument('normalContractCreate', 0, 1);
              },
              text: '표준 근로 계약서',
              isRed:true,
            ),
            BottomSheetButton(
              onTap: () {
                context.pop();
                showContractDialog('short');
                // widget.sendDocument('normalContractCreate', 0, 1);
              },
              text: '단기간 근로자 계약서',
            ),
            BottomSheetButton(
              onTap: () {
                context.pop();
                showContractDialog('minor');
                // widget.sendDocument('normalContractCreate', 0, 1);
              },
              text: '연소 근로 계약서',
            ),
            BottomSheetButton(
              onTap: () {
                context.pop();
                showContractDialog('construction');
                // widget.sendDocument('normalContractCreate', 0, 1);
              },
              text: '건설일용 근로 계약서',
            ),
          ],
        ),
      ),
    );
  }
}
