import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:flutter/material.dart';


class DefineListTileWidget extends StatelessWidget {
  const DefineListTileWidget({
    required this.itemName,
    required this.itemKey,
    required this.selectItem,
    required this.selectedKeyList,
    this.isAll = false,
    super.key});

  final String itemName;

  final int itemKey;
  final Function selectItem;
  final List<int> selectedKeyList;

  final bool isAll;

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      contentPadding: const EdgeInsets.all(0),
      child: ListTile(
        onTap: (){
          selectItem();
        },
        title: Container(
            alignment: Alignment.center,
            child: Text(
              ConvertService.removeParentheses(
              isAll
                  ?
              '$itemName ${localization.all}'
                  :
              itemName
              ),
              style: TextStyle(color:
              selectedKeyList.contains(itemKey)
                  ?
              CommonColors.red
                  : CommonColors.black
            ),
            )),
      ),
    );
  }
}
