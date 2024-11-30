
import 'package:chodan_flutter_app/features/theme/widget/bannerinner/theme_banner_inner_double_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/bannerinner/theme_banner_inner_double_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/bannerinner/theme_banner_inner_double_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/bannerinner/theme_banner_inner_one_col_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/bannerinner/theme_banner_inner_one_half_row_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/bannerinner/theme_banner_inner_one_row_widget.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeBannerInnerWidget extends ConsumerStatefulWidget {
  const ThemeBannerInnerWidget({
    super.key,
    required this.type,
    required this.themeData,
    required this.themeSettingList,
    required this.moveUrl
  });

  final ThemeModel themeData;
  final List themeSettingList;
  final String type;
  final Function moveUrl;

  @override
  ConsumerState<ThemeBannerInnerWidget> createState() =>
      _ThemeBannerInnerWidgetState();
}

class _ThemeBannerInnerWidgetState
    extends ConsumerState<ThemeBannerInnerWidget> {
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
        return ThemeBannerInnerOneColWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'OneRow':
        return ThemeBannerInnerOneRowWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'OneHalfRow':
        return ThemeBannerInnerOneHalfRowWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'DoubleCole':
        return ThemeBannerInnerDoubleColWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'DoubleRow':
        return ThemeBannerInnerDoubleRowWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      case 'DoubleHalfRow':
        return ThemeBannerInnerDoubleHalfRowWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
      default:
        return ThemeBannerInnerOneColWidget(
            themeData: theme, themeSettingList: arr,moveUrl:widget.moveUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return setTypeWidget(widget.themeData,widget.themeSettingList);
  }
}
