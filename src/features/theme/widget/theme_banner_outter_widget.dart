import 'package:chodan_flutter_app/features/theme/controller/theme_controller.dart';
import 'package:chodan_flutter_app/features/theme/widget/banneroutter/theme_banner_outter_double_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/banneroutter/theme_banner_outter_double_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/banneroutter/theme_banner_outter_double_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/banneroutter/theme_banner_outter_one_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/banneroutter/theme_banner_outter_one_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/banneroutter/theme_banner_outter_one_row_widget.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeBannerOutterWidget extends ConsumerStatefulWidget {
  const ThemeBannerOutterWidget({
    super.key,
    required this.themeData,
    required this.type,
    required this.themeSettingList,
    required this.moveUrl
  });

  final ThemeModel themeData;
  final List themeSettingList;
  final String type;
  final Function moveUrl;

  @override
  ConsumerState<ThemeBannerOutterWidget> createState() =>
      _ThemeBannerOutterWidgetState();
}

class _ThemeBannerOutterWidgetState
    extends ConsumerState<ThemeBannerOutterWidget> {
  bool isLoader = false;
  @override
  void initState() {
    super.initState();
    
  }


  Widget setTypeWidget(theme,arr) {
    switch (widget.type) {
      case 'OneCole':
        return ThemeBannerOutterOneColWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'OneRow':
        return ThemeBannerOutterOneRowWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'OneHalfRow':
        return ThemeBannerOutterOneHalfRowWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'DoubleCole':
        return ThemeBannerOutterDoubleColWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'DoubleRow':
        return ThemeBannerOutterDoubleRowWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'DoubleHalfRow':
        return ThemeBannerOutterDoubleHalfRowWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      default:
        return ThemeBannerOutterOneColWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return setTypeWidget(widget.themeData,widget.themeSettingList);
  }
}
