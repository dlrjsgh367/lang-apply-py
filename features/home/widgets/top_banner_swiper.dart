import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/banner/service/banner_service.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/models/app_menu_model.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class TopBannerSwiper extends ConsumerStatefulWidget {
  const TopBannerSwiper({required this.data, super.key,required this.closeBanner});

  final Function closeBanner;
  final List data;

  @override
  ConsumerState<TopBannerSwiper> createState() => _TopBannerSwiperState();
}

class _TopBannerSwiperState extends ConsumerState<TopBannerSwiper> {
  int activeIndex = 0;

  SwiperController swiperController = SwiperController();

  moveUrl(BannerModel data) async {
    UserModel? userInfo = ref.watch(userProvider);
    BannerService bannerService = BannerService(user: userInfo);
    bannerService.moveUrl(context, ref, data);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: CommonSize.vw * 0.08 ,
          child: Swiper(
            controller: swiperController,
            scrollDirection: Axis.horizontal,
            axisDirection: AxisDirection.left,
            itemCount: widget.data.length,
            viewportFraction: 1,
            autoplay: widget.data.length > 1 ? true : false,
            autoplayDelay: 3000,
            scale: 1,
            loop: widget.data.length > 1 ? true : false,
            itemBuilder: (context, index) {
              dynamic item = widget.data[index];
              return GestureDetector(
                onTap: (){
                  moveUrl(item);
                },
                child: SizedBox(
                  height:  CommonSize.vw * 0.08 ,
                  child: ExtendedImgWidget(
                    loadingWidget: Loader(size: CommonSize.vw * 0.06),
                    failedWidget: Loader(size: CommonSize.vw * 0.06),
                    imgUrl: item.files[0].url,
                    imgFit: BoxFit.cover,
                    imgHeight:  CommonSize.vw * 0.08 ,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          right: 10.w,
          top: 0,
          bottom: 0,
          child: GestureDetector(

            onTap: () {
              widget.closeBanner();
            },
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.fromLTRB(10.w,0,10.w,0),
              child: Image.asset(
                'assets/images/icon/iconX.png',
                width: 16.w,
                height: 16.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
