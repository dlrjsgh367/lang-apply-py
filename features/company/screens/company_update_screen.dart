import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/features/company/service/company_service.dart';
import 'package:chodan_flutter_app/features/company/widgets/update_company_info_widget.dart';
import 'package:chodan_flutter_app/features/company/widgets/update_company_manager_widget.dart';
import 'package:chodan_flutter_app/features/company/widgets/update_company_owner_widget.dart';
import 'package:chodan_flutter_app/features/company/widgets/update_company_photo_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/company_img_widget.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/company_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CompanyUpdateScreen extends ConsumerStatefulWidget {
  const CompanyUpdateScreen({super.key});

  @override
  ConsumerState<CompanyUpdateScreen> createState() =>
      _CompanyUpdateScreenState();
}

class _CompanyUpdateScreenState extends ConsumerState<CompanyUpdateScreen> {
  late UserModel userData;
  bool isLoading = true;

  String getCompanyVerifyStatus(UserModel userData) {
    String status = CompanyService.convertIntToString(
        userData.companyInfo!.isCompanyVerify);
    String date = userData.companyInfo!.isCompanyVerify == 0
        ? ''
        : '(${DateFormat('yyyy.MM.dd HH:mm:ss').format(DateTime.parse(userData.companyInfo!.companyVerifyDate))})';
    return '$status $date';
  }

  showPhotoAlert(BuildContext context, CompanyModel companyData) {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return UpdateCompanyPhotoWidget(
          data: companyData,
        );
      },
    ).then((value) => getCompanyInfo());
  }

  showInfoAlert(BuildContext context, CompanyModel companyData) {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return UpdateCompanyInfoWidget(
          data: companyData,
        );
      },
    ).then((value) => getCompanyInfo());
  }

  showManagerAlert(BuildContext context, CompanyModel companyData) {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddCompanyManagerWidget(
          data: companyData,
        );
      },
    ).then((value) => getCompanyInfo());
  }

  showOwnerAlert(BuildContext context, CompanyModel companyData) {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddCompanyOwnerWidget(
          data: companyData,
        );
      },
    ).then((value) => getCompanyInfo());
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getUserData(),
      getCompanyInfo(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _getAllAsyncTasks().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  getUserData() async {
    ApiResultModel result =
        await ref.read(authControllerProvider.notifier).getUserData();
    if (result.status == 200) {
      if (result.type == 1) {
        ref.read(userProvider.notifier).update((state) => result.data);
      }
    }
  }

  getCompanyInfo() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(companyControllerProvider.notifier)
          .getCompanyInfo(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          setState(() {
            userData = result.data;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
        } else {
          if (!didPop) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: CommonAppbar(
          title: localization.editCompanyInformation,
        ),
        body: !isLoading
            ? CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, CommonSize.commonBoard(context) + 30.w),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showPhotoAlert(context, userData.companyInfo!);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.w),
                              child:
                              CompanyImgWidget(
                                imgUrl: userData.companyInfo!.files[0].url,
                                imgWidth: CommonSize.vw,
                                // imgHeight: CommonSize.vh,
                                color: Color(
                                  ConvertService.returnBgColor(
                                      userData.companyInfo!.color),
                                ), text:  userData.companyInfo!.name,
                              ),

                            ),
                          ),
                          SizedBox(
                            height: 24.w,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  localization.basicInformation,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.gray4d,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showInfoAlert(context, userData.companyInfo!);
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  height: 36.w,
                                  width: 36.w,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/images/icon/iconArrowRightThin.png',
                                    width: 24.w,
                                    height: 24.w,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.w),
                          Row(
                            children: [
                              SizedBox(
                                width: 86.w,
                                child: Text(
                                  localization.companyName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  userData.companyInfo!.name,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 16.w),
                          Row(
                            children: [
                              SizedBox(
                                width: 86.w,
                                child: Text(
                                  localization.industryName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  userData.industryName,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 16.w),
                          Row(
                            children: [
                              SizedBox(
                                width: 86.w,
                                child: Text(
                                  localization.numberOfEmployees,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  localization.numOfPeople(userData.companyInfo!.numberOfEmployees),
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 16.w),
                          Row(
                            children: [
                              SizedBox(
                                width: 86.w,
                                child: Text(
                                  localization.address,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${userData.companyInfo!.address} ${userData.companyInfo!.addressDetail}',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 16.w),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 86.w,
                                child: Text(
                                  localization.companyIntroduction,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  userData.companyInfo!.companyIntroduce,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20.w,
                          ),
                          Divider(
                            thickness: 1,
                            height: 1,
                            color: CommonColors.grayF7,
                          ),
                          SizedBox(
                            height: 14.w,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  localization.recruitmentContact,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.gray4d,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showManagerAlert(
                                      context, userData.companyInfo!);
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  height: 36.w,
                                  width: 36.w,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/images/icon/iconArrowRightThin.png',
                                    width: 24.w,
                                    height: 24.w,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 18.w),
                          Row(
                            children: [
                              SizedBox(
                                width: 96.w,
                                child: Text(
                                  localization.contactPersonName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.gray80,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  userData.companyInfo!.managerName.isEmpty ? '-' : userData.companyInfo!.managerName,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.w),
                          Row(
                            children: [
                              SizedBox(
                                width: 96.w,
                                child: Text(
                                  localization.contactNumber,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  userData.companyInfo!.managerPhoneNumber.isEmpty ? '-' : userData.companyInfo!.managerPhoneNumber,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.w),
                          Row(
                            children: [
                              SizedBox(
                                width: 96.w,
                                child: Text(
                                  localization.email,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  userData.companyInfo!.managerEmail.isEmpty ? '-' : userData.companyInfo!.managerEmail,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.w),
                          Divider(
                            thickness: 1,
                            height: 1,
                            color: CommonColors.grayF7,
                          ),
                          SizedBox(
                            height: 14.w,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  localization.businessCertification,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.gray4d,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showOwnerAlert(context, userData.companyInfo!);
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  height: 36.w,
                                  width: 36.w,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/images/icon/iconArrowRightThin.png',
                                    width: 24.w,
                                    height: 24.w,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.w),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0.w),
                              color: CommonColors.grayF7,
                            ),
                            padding: EdgeInsets.all(20.w),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 72.w,
                                  child: Text(
                                    localization.certificationStatus,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.gray80,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    getCompanyVerifyStatus(userData),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              )
            : const Loader(),
      ),
    );
  }
}
