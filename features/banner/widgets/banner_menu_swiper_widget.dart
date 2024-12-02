import 'package:card_swiper/card_swiper.dart';
import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/banner/service/banner_service.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/models/app_menu_model.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerMenuSwiperWidget extends ConsumerWidget {
  const BannerMenuSwiperWidget({required this.bannerList, super.key});

  final List<BannerModel> bannerList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    moveUrl(BannerModel data) async {
      UserModel? userInfo = ref.watch(userProvider);
      BannerService bannerService = BannerService(user: userInfo);
      bannerService.moveUrl(context, ref, data);
    }

    return SizedBox(
      height: (CommonSize.vw - 40.w) / 320 * 88,
      child: Swiper(
        scrollDirection: Axis.horizontal,
        axisDirection: AxisDirection.left,
        itemCount: bannerList.length,
        viewportFraction: 1,
        scale: 1,
        loop: false,
        itemBuilder: (context, index) {
          // BannerModel carouselItem = bannerList[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
            child: GestureDetector(
              onTap: () {
                moveUrl(bannerList[index]);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.w),
                child: ExtendedImgWidget(
                  imgUrl: bannerList[index].files[0].url,
                  imgFit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
        pagination: SwiperPagination(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(bottom: 4.w),
          builder: DotSwiperPaginationBuilder(
            activeColor: CommonColors.gray66,
            color: const Color.fromRGBO(255, 255, 255, 0.7),
            activeSize: 5.w,
            size: 5.w,
            space: 4.w,
          ),
        ),
      ),
    );
  }
}
