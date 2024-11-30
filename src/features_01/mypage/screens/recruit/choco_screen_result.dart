import 'dart:convert';
import 'dart:io';

import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/menu/widgets/title_menu.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/payment_service.dart';
import 'package:chodan_flutter_app/mixins/in_app_purchase_mixins.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/tabs/common_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/choco_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChocoScreen extends ConsumerStatefulWidget {
  const ChocoScreen({super.key});

  @override
  ConsumerState<ChocoScreen> createState() => _ChocoScreenState();
}

class _ChocoScreenState extends ConsumerState<ChocoScreen>
    with Alerts, InAppPurchaseMixins {
  int activeTab = 1;
  String status = '';
  PayClass payClass = PayClass();
  String orderUUID = '';
  bool isPaymentLoading = false;

  setTab(data) {
    setState(() {
      savePageLog();
      activeTab = data;
    });
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      initInAppPurchase();
      await Future.wait<void>([
        savePageLog(),
        getChocoListData(page),
        getChocoProductListData(productPage),
        getMyChoco(),
      ]);
    }).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  List<ChocoModel> chocoList = [];
  List<ChocoModel> chocoProductList = [];
  ChocoModel? myChocoData;
  bool isLoading = true;
  var isLazeLoading = false;
  var isProductLazeLoading = false;
  var page = 1;
  var lastPage = 1;
  var total = 0;
  var productPage = 1;
  var productLastPage = 1;
  var productTotal = 0;

  _chocoLoadMore() async {
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
      });
      page = page + 1;
      Future(() {
        getChocoListData(page);
      });
    }
  }

  getMyChoco() async {
    ApiResultModel result =
        await ref.read(mypageControllerProvider.notifier).getMyChoco();

    if (result.type == 1) {
      setState(() {
        List<ChocoModel> data = result.data;
        if (data.isNotEmpty) {
          myChocoData = data[0];
        }
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  getChocoListData(int page) async {
    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .getChocoListData(page);
    if (result.type == 1) {
      setState(() {
        List<ChocoModel> data = result.data;
        if (page == 1) {
          chocoList = [...data];
        } else {
          chocoList = [...chocoList, ...data];
        }
        lastPage = result.page['lastPage'];
        total = result.page['total'];
        isLazeLoading = false;
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  isChocoUse(idx) {
    if (idx == 0 || idx == 1 || idx == 2) {
      return true;
    } else {
      return false;
    }
  }

  _productLoadMore() async {
    if (productLastPage > 1 && productPage + 1 <= productLastPage) {
      setState(() {
        isProductLazeLoading = true;
      });
      productPage = productPage + 1;
      Future(() {
        getChocoProductListData(productPage);
      });
    }
  }

  getChocoProductListData(int page) async {
    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .getChocoProductListData(page);
    if (result.type == 1) {
      setState(() {
        List<ChocoModel> data = result.data;
        if (page == 1) {
          chocoProductList = [...data];
        } else {
          chocoProductList = [...chocoProductList, ...data];
        }
        productLastPage = result.page['lastPage'];
        productTotal = result.page['total'];
        isProductLazeLoading = false;
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  returnProductTypeImg(type) {
    if (type == 1) {
      return 'assets/images/icon/imgChocoBon.png';
    } else if (type == 2) {
      return 'assets/images/icon/imgChocoSil.png';
    } else if (type == 3) {
      return 'assets/images/icon/imgChocoPop.png';
    } else if (type == 4) {
      return 'assets/images/icon/imgChocoRec.png';
    } else if (type == 5) {
      return 'assets/images/icon/imgChocoPop.png';
    }
  }

  Color returnProductColor(type) {
    if (type == 1) {
      return CommonColors.yellow;
    } else if (type == 2) {
      return CommonColors.orange;
    } else if (type == 3) {
      return CommonColors.pink;
    } else if (type == 4) {
      return CommonColors.blue03;
    } else if (type == 5) {
      return CommonColors.purple;
    } else {
      return CommonColors.purple;
    }
  }

  paymentItem(ChocoModel item) async {
    if (isPaymentLoading) {
      return;
    }
    setState(() {
      isPaymentLoading = true;
    });

    ApiResultModel cartResult = await payClass.createCart(item);
    if (cartResult.status != 200) {
      paymentErrorAlert();
      return;
    }
    List cartKey = cartResult.data;

    ApiResultModel orderKeyResult = await payClass.getOrderKey();
    if (orderKeyResult.status != 200) {
      paymentErrorAlert();
      return;
    }

    orderUUID = orderKeyResult.data;

    ApiResultModel cartOrderResult =
        await payClass.createCartByOrderKey(cartKey, orderUUID);
    if (cartOrderResult.status != 200) {
      paymentErrorAlert();
      return;
    }

    String buyId = item.playStoreKey;
    if (Platform.isIOS) {
      buyId = item.appStoreKey;
    }
    bool isSuccess = await buyPurchase(buyId);
    if (!isSuccess) {
      paymentErrorAlert();
    }
  }

  paymentErrorAlert() {
    showErrorAlert(context, localization.notification, '결제에 실패했습니다.');
    setState(() {
      isPaymentLoading = false;
    });
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    if (token != null) {
      ApiResultModel result =
          await ref.read(authControllerProvider.notifier).getUserData();
      if (result.type == 1) {
        ref.read(userProvider.notifier).update((state) => result.data);
        ref.read(userAuthProvider.notifier).update((state) => result.data);
      }
    } else {
      if (mounted) {
        showStartDialog(context);
      }
    }
  }

  @override
  void completePurchase(purchaseDetails) {
    if (Platform.isIOS) {
      String receiptData =
          purchaseDetails.verificationData.serverVerificationData;
      createOrder(receiptData);
    } else if (Platform.isAndroid) {
      Map<String, dynamic> receiptData = {
        'packageName': '',
        'productId': '',
        'purchaseToken': '',
      };
      Map<String, dynamic> body =
          jsonDecode(purchaseDetails.verificationData.localVerificationData);
      setState(() {
        receiptData['packageName'] = body["packageName"];
        receiptData['productId'] = body["productId"];
        receiptData['purchaseToken'] = body["purchaseToken"];
      });
      createOrder(jsonEncode(receiptData));
    }
  }

  @override
  void cancelPurchase(purchaseDetails) {
    showDefaultToast(localization.paymentCanceled);
    setState(() {
      isPaymentLoading = false;
    });
  }

  void handleError(error) {
    showDefaultToast(localization.paymentCanceled);
    setState(() {
      isPaymentLoading = false;
    });
  }

  createOrder(String receiptData) async {
    ApiResultModel result = await payClass.createOrder(orderUUID, receiptData);
    if (result.status == 200) {
      setState(() {
        isPaymentLoading = false;
      });
      showDefaultToast(localization.paymentCompleted);
      getUserData();
      getChocoListData(page);
      getMyChoco();
    } else {
      paymentErrorAlert();
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = ref.read(userProvider);
    return user == null && myChocoData == null && isLoading
        ? const Loader()
        : Scaffold(
            appBar: const CommonAppbar(
              title: localization.myShortTermCoins,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 12.w),
                  child: CommonTab(
                    setTab: setTab,
                    activeTab: activeTab,
                    tabTitleArr: const ['사용내역', '초단코인샵'],
                  ),
                ),
                Expanded(
                    child: activeTab == 0
                        ? LazyLoadScrollView(
                            onEndOfPage: () => _chocoLoadMore(),
                            child: !isLoading
                                ? Stack(
                                    children: [
                                      CustomScrollView(
                                        slivers: [
                                          SliverPadding(
                                            padding: EdgeInsets.fromLTRB(
                                                20.w, 0.w, 20.w, 0.w),
                                            sliver: SliverToBoxAdapter(
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    0.w, 12.w, 0.w, 12.w),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      width: 1.w,
                                                      color: CommonColors.black,
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      localization.availableShortTermCoins,
                                                      style: TextStyle(
                                                          fontSize: 15.sp,
                                                          color: CommonColors
                                                              .gray4d,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        myChocoData == null
                                                            ? localization.zeroCoins
                                                            : '${ConvertService.returnStringWithCommaFormat(myChocoData!.totalChoco)} 초코',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                          fontSize: 16.sp,
                                                          color:
                                                              CommonColors.red,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SliverPadding(
                                            padding: EdgeInsets.fromLTRB(
                                                20.w, 12.w, 20.w, 12.w),
                                            sliver: SliverToBoxAdapter(
                                                child: Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 12.w),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    width: 1.w,
                                                    color: CommonColors.grayF7,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        localization.purchasedCoins,
                                                        style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          myChocoData == null
                                                              ? localization.zeroCoins
                                                              : '${ConvertService.returnStringWithCommaFormat(myChocoData!.totalPaidChoco)} 초코',
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 4.w,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        localization.earnedCoins,
                                                        style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          myChocoData == null
                                                              ? localization.zeroCoins
                                                              : '${ConvertService.returnStringWithCommaFormat(myChocoData!.totalFreeChoco)} 초코',
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )),
                                          ),
                                          SliverPadding(
                                            padding: EdgeInsets.fromLTRB(
                                                20.w, 0.w, 20.w, 24.w),
                                            sliver: SliverToBoxAdapter(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        localization.coinsExpireIn30Days,
                                                        style: TextStyle(
                                                            fontSize: 14.sp,
                                                            color: CommonColors
                                                                .gray4d,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          myChocoData == null
                                                              ? localization.zeroCoins
                                                              : '${ConvertService.returnStringWithCommaFormat(myChocoData!.toExpireChoco)} 초코',
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                            color: CommonColors
                                                                .gray66,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 12.w,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        localization.purchasedCoins,
                                                        style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          myChocoData == null
                                                              ? localization.zeroCoins
                                                              : '${ConvertService.returnStringWithCommaFormat(myChocoData!.toExpirePaidChoco)} 초코',
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 4.w,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        localization.earnedCoins,
                                                        style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          myChocoData == null
                                                              ? localization.zeroCoins
                                                              : '${ConvertService.returnStringWithCommaFormat(myChocoData!.toExpireFreeChoco)} 초코',
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SliverPadding(
                                            padding: EdgeInsets.fromLTRB(
                                                20.w, 0, 20.w, 0),
                                            sliver: SliverToBoxAdapter(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      width: 1.w,
                                                      color:
                                                          CommonColors.gray66,
                                                    ),
                                                  ),
                                                ),
                                                height: 48.w,
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/default/imgChoco.png',
                                                      width: 20.w,
                                                      height: 20.w,
                                                    ),
                                                    SizedBox(
                                                      width: 8.w,
                                                    ),
                                                    Text(localization.coinUsageHistory,
                                                        style: TextStyle(
                                                          fontSize: 15.sp,
                                                          color: CommonColors
                                                              .gray4d,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SliverPadding(
                                            padding: EdgeInsets.fromLTRB(
                                                20.w,
                                                chocoList.isEmpty ? 100.w : 0,
                                                20.w,
                                                0),
                                            sliver: chocoList.isEmpty
                                                ? const SliverToBoxAdapter(
                                                    child: CommonEmpty(
                                                        text:
                                                            localization.noCoinUsageHistory),
                                                  )
                                                : SliverList(
                                                    delegate:
                                                        SliverChildBuilderDelegate(
                                                      childCount:
                                                          chocoList.length,
                                                      (context, index) {
                                                        return Container(
                                                          padding: EdgeInsets
                                                              .fromLTRB(0, 20.w,
                                                                  0, 20.w),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border(
                                                              bottom:
                                                                  BorderSide(
                                                                width: 1.w,
                                                                color:
                                                                    CommonColors
                                                                        .grayF7,
                                                              ),
                                                            ),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              Text(
                                                                DateFormat(
                                                                        'yyyy.MM.dd HH:mm:ss')
                                                                    .format(
                                                                  DateTime.parse(chocoList[
                                                                          index]
                                                                      .createdAt
                                                                      .replaceAll(
                                                                          "T",
                                                                          " ")),
                                                                ),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      13.sp,
                                                                  color:
                                                                      CommonColors
                                                                          .grayB2,
                                                                ),
                                                              ),
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      chocoList[
                                                                              index]
                                                                          .reason,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14.sp,
                                                                        color: CommonColors
                                                                            .gray4d,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    isChocoUse(chocoList[index]
                                                                            .chocoUseType)
                                                                        ? '+${ConvertService.returnStringWithCommaFormat(chocoList[index].chocoCnt)} 초코'
                                                                        : '${ConvertService.returnStringWithCommaFormat(chocoList[index].chocoCnt)} 초코',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: isChocoUse(chocoList[index]
                                                                              .chocoUseType)
                                                                          ? CommonColors
                                                                              .red
                                                                          : CommonColors
                                                                              .gray4d,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                          ),
                                          const BottomPadding(),
                                        ],
                                      ),
                                    ],
                                  )
                                : const Loader(),
                          )
                        : LazyLoadScrollView(
                            onEndOfPage: () => _productLoadMore(),
                            child: !isLoading
                                ? Stack(
                                    children: [
                                      CustomScrollView(
                                        slivers: [
                                          SliverPadding(
                                            padding: EdgeInsets.fromLTRB(
                                                16.w, 0.w, 16.w, 0.w),
                                            sliver: SliverToBoxAdapter(
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    16.w, 20.w, 16.w, 20.w),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    12.w,
                                                  ),
                                                  color: CommonColors.grayF7,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      localization.availableShortTermCoins,
                                                      style: TextStyle(
                                                          fontSize: 15.sp,
                                                          color: CommonColors
                                                              .gray4d,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        myChocoData == null
                                                            ? localization.zeroCoins
                                                            : '${ConvertService.returnStringWithCommaFormat(myChocoData!.totalChoco)} 초코',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                          fontSize: 16.sp,
                                                          color:
                                                              CommonColors.red,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SliverPadding(
                                              padding: EdgeInsets.fromLTRB(
                                                  20.w, 5.w, 20.w, 0),
                                              sliver: SliverToBoxAdapter(
                                                child: Text(
                                                  localization.shortTermCoinsDescription,
                                                  style: TextStyle(
                                                    color: CommonColors.gray4d,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              )),
                                          SliverPadding(
                                            padding: EdgeInsets.fromLTRB(
                                                20.w, 20.w, 20.w, 0),
                                            sliver: SliverToBoxAdapter(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      width: 1.w,
                                                      color:
                                                          CommonColors.gray66,
                                                    ),
                                                  ),
                                                ),
                                                height: 48.w,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  localization.howMuchToRecharge,
                                                  style:
                                                      TextStyles.borderButton,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SliverPadding(
                                            padding: EdgeInsets.fromLTRB(
                                                20.w, 0, 20.w, 0),
                                            sliver: SliverList(
                                              delegate:
                                                  SliverChildBuilderDelegate(
                                                childCount:
                                                    chocoProductList.length,
                                                (context, index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      paymentItem(
                                                          chocoProductList[
                                                              index]);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              8.w,
                                                              20.w,
                                                              12.w,
                                                              20.w),
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            width: 1.w,
                                                            color: CommonColors
                                                                .grayF7,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/default/imgChoco.png',
                                                            width: 32.w,
                                                            height: 32.w,
                                                          ),
                                                          SizedBox(
                                                            width: 8.w,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                chocoProductList[index]
                                                                            .status !=
                                                                        0
                                                                    ? Image
                                                                        .asset(
                                                                        returnProductTypeImg(
                                                                            chocoProductList[index].status),
                                                                        width:
                                                                            40.w,
                                                                      )
                                                                    : const SizedBox
                                                                        .shrink(),
                                                                SizedBox(
                                                                  height: 4.w,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(
                                                                          bottom:
                                                                              4.w),
                                                                      child:
                                                                          Text(
                                                                        '${ConvertService.returnStringWithCommaFormat(chocoProductList[index].chocoCnt)} 초코',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14.sp,
                                                                          color:
                                                                              CommonColors.brown,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          4.w,
                                                                    ),
                                                                    Expanded(
                                                                      child: chocoProductList[index].chocoExtraCnt >
                                                                              0
                                                                          ? Text(
                                                                              '+${ConvertService.returnStringWithCommaFormat(chocoProductList[index].chocoExtraCnt)} 보너스',
                                                                              style: TextStyle(
                                                                                fontSize: 10.sp,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: returnProductColor(chocoProductList[index].status),
                                                                              ),
                                                                            )
                                                                          : const SizedBox
                                                                              .shrink(),
                                                                    ),
                                                                    Text(
                                                                      '₩ ${ConvertService.returnStringWithCommaFormat(chocoProductList[index].name)}',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14.sp,
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        color: CommonColors
                                                                            .red,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          SliverPadding(
                                              padding: EdgeInsets.fromLTRB(
                                                  20.w, 40.w, 20.w, 0),
                                              sliver: SliverToBoxAdapter(
                                                child: Text(
                                                  localization.additionalRechargeSupportInfo,
                                                  style: TextStyle(
                                                    color: CommonColors.gray96,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              )),
                                          const BottomPadding(),
                                        ],
                                      ),
                                      if (isPaymentLoading) const Loader(),
                                    ],
                                  )
                                : const Loader(),
                          )),
              ],
            ),
          );
  }
}
