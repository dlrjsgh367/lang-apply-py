import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/models/app_menu_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerService {
  final UserModel? _user;

  BannerService({UserModel? user}) : _user = user;

  Future<void> moveUrl(
      BuildContext context, WidgetRef ref, dynamic data) async {
    switch (data.bannerLinkType) {
      case 1:
        if (_user == null) return;
        _navigateToAppMenu(context, ref, data);
        break;
      case 2:
        await _launchUrl(data.url);
        break;
      case 3:
        if (_user == null) return;
        _navigateToSpecificUrl(context, data);
        break;
      default:
        break;
    }
  }

  void _navigateToAppMenu(BuildContext context, WidgetRef ref, dynamic data) {
    List<AppMenuModel> menuList = ref.watch(appMenuListProvider);
    int key = _user!.memberType == MemberTypeEnum.jobSeeker
        ? data.jobseekerKey
        : data.recruiterKey;
    int index = menuList.indexWhere((element) => element.key == key);
    if (index > -1) {
      context.push(menuList[index].route);
    }
  }

  Future<void> _launchUrl(String url) async {
    final parsedUri = Uri.parse(url);
    if (await canLaunchUrl(parsedUri)) {
      await launchUrl(parsedUri);
    } else {}
  }

  void _navigateToSpecificUrl(BuildContext context, dynamic data) {
    String url = _user!.memberType == MemberTypeEnum.jobSeeker
        ? data.jobseekerUrl
        : data.recruiterUrl;
    if (url.isNotEmpty) {
      context.push(url);
    }
  }
}
