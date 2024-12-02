import 'package:chodan_flutter_app/features/theme/controller/theme_controller.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumoutter/theme_thum_outter_double_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumoutter/theme_thum_outter_double_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumoutter/theme_thum_outter_double_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumoutter/theme_thum_outter_one_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumoutter/theme_thum_outter_one_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thumoutter/theme_thum_outter_one_row_widget.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ThemeThumOutterWidget extends ConsumerStatefulWidget {
  const ThemeThumOutterWidget({
    super.key,
    required this.themeData,
    required this.themeSettingList,
    required this.type,
  });

  final ThemeModel themeData;
  final List themeSettingList;
  final String type;

  @override
  ConsumerState<ThemeThumOutterWidget> createState() =>
      _ThemeThumOutterWidgetState();
}

class _ThemeThumOutterWidgetState extends ConsumerState<ThemeThumOutterWidget> {
  bool isLoader = false;

  @override
  void initState() {
    super.initState();
  }

  Widget setTypeWidget(theme,arr) {
    switch (widget.type) {
      case 'OneCole':
        return ThemeThumOutterOneColWidget(
            themeData: theme, themeSettingList: arr);
      case 'OneRow':
        return ThemeThumOutterOneRowWidget(
            themeData: theme, themeSettingList: arr);
      case 'OneHalfRow':
        return ThemeThumOutterOneHalfRowWidget(
            themeData: theme, themeSettingList: arr);
      case 'DoubleCole':
        return ThemeThumOutterDoubleColWidget(
            themeData: theme, themeSettingList: arr);
      case 'DoubleRow':
        return ThemeThumOutterDoubleRowWidget(
            themeData: theme, themeSettingList: arr);
      case 'DoubleHalfRow':
        return ThemeThumOutterDoubleHalfRowWidget(
            themeData: theme, themeSettingList: arr);
      default:
        return ThemeThumOutterOneColWidget(
            themeData: theme, themeSettingList: arr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return setTypeWidget(widget.themeData,widget.themeSettingList);
  }
}
