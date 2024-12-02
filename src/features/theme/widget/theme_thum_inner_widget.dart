import 'package:chodan_flutter_app/features/theme/controller/theme_controller.dart';
import 'package:chodan_flutter_app/features/theme/widget/thuminner/theme_thum_inner_double_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thuminner/theme_thum_inner_double_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thuminner/theme_thum_inner_double_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thuminner/theme_thum_inner_one_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thuminner/theme_thum_inner_one_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/thuminner/theme_thum_inner_one_row_widget.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ThemeThumInnerWidget extends ConsumerStatefulWidget {
  const ThemeThumInnerWidget({
    super.key,
    required this.themeData,
    required this.type,
    required this.themeSettingList,
  });

  final ThemeModel themeData;
  final List themeSettingList;
  final String type;

  @override
  ConsumerState<ThemeThumInnerWidget> createState() =>
      _ThemeThumInnerWidgetState();
}

class _ThemeThumInnerWidgetState extends ConsumerState<ThemeThumInnerWidget> {
  bool isLoader = false;
  List themeSettingList = [];

  Widget setTypeWidget(theme,arr) {
    switch (widget.type) {
      case 'OneCole':
        return ThemeThumInnerOneColWidget(
            themeData: theme, themeSettingList: arr);
      case 'OneRow':
        return ThemeThumInnerOneRowWidget(
            themeData: theme, themeSettingList: arr);
      case 'OneHalfRow':
        return ThemeThumInnerOneHalfRowWidget(
            themeData: theme, themeSettingList: arr);
      case 'DoubleCole':
        return ThemeThumInnerDoubleColWidget(
            themeData: theme, themeSettingList: arr);
      case 'DoubleRow':
        return ThemeThumInnerDoubleRowWidget(
            themeData: theme, themeSettingList: arr);
      case 'DoubleHalfRow':
        return ThemeThumInnerDoubleHalfRowWidget(
            themeData: theme, themeSettingList: arr);
      default:
        return ThemeThumInnerOneColWidget(
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
