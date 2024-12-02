import 'package:chodan_flutter_app/features/theme/widget/bannerhalf/theme_banner_half_double_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/bannerhalf/theme_banner_half_double_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/bannerhalf/theme_banner_half_double_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/bannerhalf/theme_banner_half_one_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/bannerhalf/theme_banner_half_one_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/bannerhalf/theme_banner_half_one_row_widget.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeBannerHalfWidget extends ConsumerStatefulWidget {
  const ThemeBannerHalfWidget({
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
  ConsumerState<ThemeBannerHalfWidget> createState() =>
      _ThemeBannerHalfWidgetState();
}

class _ThemeBannerHalfWidgetState extends ConsumerState<ThemeBannerHalfWidget> {
  bool isLoader = false;
  List themeSettingList = [];

  @override
  void initState() {
    super.initState();
    Future(() async {
      themeSettingList = widget.themeSettingList;
    });
  }

  Widget setTypeWidget(theme,arr) {
    switch (widget.type) {
      case 'OneCole':
        return ThemeBannerHalfOneColWidget(
             themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'OneRow':
        return ThemeBannerHalfOneRowWidget(
             themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'OneHalfRow':
        return ThemeBannerHalfOneHalfRowWidget(
             themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'DoubleCole':
        return ThemeBannerHalfDoubleColWidget(
             themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'DoubleRow':
        return ThemeBannerHalfDoubleRowWidget(
             themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'DoubleHalfRow':
        return ThemeBannerHalfDoubleHalfRowWidget(
             themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      default:
        return ThemeBannerHalfOneColWidget(
             themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return setTypeWidget(widget.themeData, widget.themeSettingList);
  }
}
