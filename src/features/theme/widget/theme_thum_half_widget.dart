import 'package:chodan_flutter_app/features/theme/controller/theme_controller.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumhalf/theme_thum_half_double_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumhalf/theme_thum_half_double_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumhalf/theme_thum_half_double_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumhalf/theme_thum_half_one_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumhalf/theme_thum_half_one_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumhalf/theme_thum_half_one_row_widget.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ThemeThumHalfWidget extends ConsumerStatefulWidget {
  const ThemeThumHalfWidget({
    super.key,
    required this.themeData,
    required this.themeSettingList,
    required this.type,
  });

  final ThemeModel themeData;
  final List themeSettingList;
  final String type;

  @override
  ConsumerState<ThemeThumHalfWidget> createState() =>
      _ThemeThumHalfWidgetState();
}

class _ThemeThumHalfWidgetState extends ConsumerState<ThemeThumHalfWidget> {
  bool isLoader = false;
  List themeSettingList = [];

  Widget setTypeWidget(theme,arr) {
    switch (widget.type) {
      case 'OneCole':
        return ThemeThumHalfOneColWidget(
            themeData: theme, themeSettingList: arr);
      case 'OneRow':
        return ThemeThumHalfOneRowWidget(
            themeData: theme, themeSettingList: arr);
      case 'OneHalfRow':
        return ThemeThumHalfOneHalfRowWidget(
            themeData: theme, themeSettingList: arr);
      case 'DoubleCole':
        return ThemeThumHalfDoubleColWidget(
            themeData: theme, themeSettingList: arr);
      case 'DoubleRow':
        return ThemeThumHalfDoubleRowWidget(
            themeData: theme, themeSettingList: arr);
      case 'DoubleHalfRow':
        return ThemeThumHalfDoubleHalfRowWidget(
            themeData: theme, themeSettingList: arr);
      default:
        return ThemeThumHalfOneColWidget(
            themeData: theme, themeSettingList: arr);
    }
  }

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return setTypeWidget(widget.themeData,widget.themeSettingList);
  }
}
