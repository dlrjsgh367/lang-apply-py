import 'dart:io';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/service/check_version.dart';
import 'package:chodan_flutter_app/features/banner/controller/banner_controller.dart';
import 'package:chodan_flutter_app/features/banner/widgets/banner_menu_swiper_widget.dart';
import 'package:chodan_flutter_app/features/menu/widgets/btn_menu.dart';
import 'package:chodan_flutter_app/features/menu/widgets/title_menu.dart';
import 'package:chodan_flutter_app/features/menu/widgets/version_menu.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:chodan_flutter_app/models/check_version_model.dart';
import 'package:chodan_flutter_app/widgets/appbar/munu_appbar.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String appleStoreUrl = 'https://itunes.apple.com/app/id6443827196?mt=8';
  String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.ioninc.chodanalba';
  String version = '';
  bool updateStatus = false;

  void openStore() {
    String url = '';
    if (Platform.isIOS) {
      url = appleStoreUrl;
    } else {
      url = playStoreUrl;
    }
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  returnUpdateText() {
    String msg = '';
    return msg;
  }

  @override
  void initState() {
    super.initState();
    Future(() {
      getVersion();
    });
  }

  getVersion() async {
    CheckVersionModel? checkVersionData =
        await CheckVersionService().runCheckVersion();
    if (checkVersionData == null) {
      return;
    }

    setState(() {
      version = checkVersionData.releaseNote;
      updateStatus = checkVersionData.type == 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BannerModel> menuBannerList = ref.watch(menuBannerListProvider);

    return Scaffold(
      appBar: const MenuAppbar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 16.w,
            ),
          ),
          if (menuBannerList.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.only(bottom: 8.w),
              sliver: SliverToBoxAdapter(
                child: BannerMenuSwiperWidget(bannerList: menuBannerList),
              ),
            ),
          TitleMenu(title: localization.143),
          BtnMenu(
            text: localization.144,
            tabFunc: () {
              context.push('/notice');
            },
          ),
          BtnMenu(
            text: localization.event,
            tabFunc: () {
              context.push('/event');
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 24.w,
            ),
          ),
          TitleMenu(title: localization.customerService),
          BtnMenu(
            text: localization.customerService,
            tabFunc: () {
              context.push('/qna');
            },
          ),
          BtnMenu(
            text: 'FAQ',
            tabFunc: () {
              context.push('/faq');
            },
          ),
          BtnMenu(
            text: localization.146,
            tabFunc: () {
              context.push('/terms/26');
            },
          ),
          BtnMenu(
            text: localization.147,
            tabFunc: () {
              context.push('/terms/27');
            },
          ),
          BtnMenu(
            text: localization.148,
            tabFunc: () {
              context.push('/terms/28');
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 24.w,
            ),
          ),
          TitleMenu(title: localization.149),
          VersionMenu(
            version: version,
            tabFunc: () {
              openStore();
            },
            updateStatus: updateStatus,
          ),
          const BottomPadding(),
        ],
      ),
    );
  }
}
