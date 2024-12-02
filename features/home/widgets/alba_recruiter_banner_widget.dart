import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/banner/service/banner_service.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/service/jobposting_service.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/app_menu_model.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/worker_default_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AlbaRecruiterBannerWidget extends ConsumerStatefulWidget {
  const AlbaRecruiterBannerWidget({
    super.key,
    required this.bannerItem,
  });

  final BannerModel bannerItem;

  @override
  ConsumerState<AlbaRecruiterBannerWidget> createState() =>
      _AlbaRecruiterBannerWidgetState();
}

class _AlbaRecruiterBannerWidgetState
    extends ConsumerState<AlbaRecruiterBannerWidget> with Alerts {
  @override
  void initState() {
    super.initState();
  }

  moveUrl(BannerModel data) async {
    UserModel? userInfo = ref.watch(userProvider);
    BannerService bannerService = BannerService(user: userInfo);
    bannerService.moveUrl(context, ref, data);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        moveUrl(widget.bannerItem);
      },
      child: Padding(
        padding: EdgeInsets.only(top: 10.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.w),
          child: AspectRatio(
            aspectRatio: 320 / 88,
            child: ExtendedImgWidget(
              imgUrl: widget.bannerItem.files[0].url,
              imgFit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
