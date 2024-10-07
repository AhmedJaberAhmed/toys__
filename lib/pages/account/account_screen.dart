import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:launch_review/launch_review.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/pages/account/account_address_screen.dart';
import 'package:nyoba/pages/account/account_membership_screen.dart';
import 'package:nyoba/pages/account/account_multiple_address_screen.dart';
import 'package:nyoba/pages/account/currency_screen.dart';
import 'package:nyoba/pages/chat/chat_page.dart';
import 'package:nyoba/pages/home/socmed_screen.dart';
import 'package:nyoba/pages/language/language_screen.dart';
import 'package:nyoba/pages/account/account_detail_screen.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/pages/point/my_point_screen.dart';
import 'package:nyoba/pages/review/review_screen.dart';
import 'package:nyoba/provider/affiliate_provider.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/login_provider.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../provider/local_auth_service.dart';
import '../../utils/share_link.dart';
import '../wishlist/wishlist_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../order/my_order_screen.dart';
import '../../utils/utility.dart';
import 'package:nyoba/widgets/home/wallet_card.dart';

class AccountScreen extends StatefulWidget {
  AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? _versionName;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Session.data.containsKey('emailBio') &&
          Session.data.containsKey('passwordBio')) {
        context.read<LoginProvider>().setBiometric(true);
      } else if (!Session.data.containsKey('emailBio') &&
          !Session.data.containsKey('passwordBio')) {
        context.read<LoginProvider>().setBiometric(false);
      }
    });
    // loadDetail();
  }

  newLogoutPopDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          insetPadding: EdgeInsets.all(0),
          content: Builder(
            builder: (context) {
              return Container(
                height: 150.h,
                width: 330.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      AppLocalizations.of(context)!
                          .translate("your_sess_expired")!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: responsiveFont(14),
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                        child: Column(
                      children: [
                        Container(
                          color: Colors.black12,
                          height: 2,
                        ),
                        GestureDetector(
                          onTap: () => logout(),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15)),
                                color: primaryColor),
                            child: Text(
                              "Ok",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ))
                  ],
                ),
              );
            },
          )),
    );
  }

  showQrCode(String qrData) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          insetPadding: EdgeInsets.all(0),
          content: Builder(
            builder: (context) {
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                padding: EdgeInsets.all(0),
                height: 300.h,
                width: 330.w,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          AppLocalizations.of(context)!.translate('my_qrcode')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: responsiveFont(14.h),
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          AppLocalizations.of(context)!.translate('qr_code')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: responsiveFont(14.h),
                              fontWeight: FontWeight.w500),
                        ),
                        QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 160.w,
                          gapless: false,
                        ),
                        Text(
                          qrData,
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                        )),
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15.0),
                                    bottomRight: Radius.circular(15.0),
                                  ),
                                  color: primaryColor),
                              height: 40.h,
                              width: double.infinity,
                              child: Center(
                                  child: Text(
                                AppLocalizations.of(context)!.translate('ok')!,
                                style: TextStyle(color: Colors.white),
                              )),
                            )),
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }

  referalCodePopUp(context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final locale = Provider.of<AppNotifier>(context, listen: false).appLocal;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          insetPadding: EdgeInsets.all(0),
          content: Builder(
            builder: (context) {
              return Container(
                height: 150.h,
                width: 330.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      AppLocalizations.of(context)!.translate('ref_code')!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: responsiveFont(14),
                          fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.h, vertical: 10.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 15.w,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey.shade200),
                        child: Text(
                          userProvider.refModel!.referralLink!
                              .replaceAll("", "\u{200B}"),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                        child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              shareLinks(
                                  'referal',
                                  userProvider.refModel!.referralLink,
                                  context,
                                  locale);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15)),
                                  color: primaryColor),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.share_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .translate('share')!,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                      text:
                                          userProvider.refModel!.referralLink!))
                                  .then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .translate('link_copied')!),
                                  ),
                                );
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(15)),
                                  color: primaryColor),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.content_copy_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .translate('copy')!,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ))
                  ],
                ),
              );
            },
          )),
    );
  }

  loadDetail() async {
    await Provider.of<UserProvider>(context, listen: false)
        .fetchUserDetail()
        .then((value) {
      if (value!['message'] != null) {
        if (value['message'].contains('cookie')) {
          printLog('cookie ditemukan');
          newLogoutPopDialog();
        }
      }

      if (mounted) this.setState(() {});
    });
  }

  Future _init() async {
    final _packageInfo = await PackageInfo.fromPlatform();

    return _packageInfo.version;
  }

  logout() async {
    final home = Provider.of<HomeProvider>(context, listen: false);
    var auth = FirebaseAuth.instance;

    Session.data.remove('unread_notification');
    FlutterAppBadger.removeBadge();

    Session.data.remove('unread_notification');
    FlutterAppBadger.removeBadge();

    Session().removeUser();
    if (auth.currentUser != null) {
      await GoogleSignIn().signOut();
    }
    if (Session.data.getString('login_type') == 'apple') {
      await auth.signOut();
    }
    if (Session.data.getString('login_type') == 'facebook') {
      context.read<LoginProvider>().facebookSignOut();
    }
    setState(() {});
    home.isReload = true;
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
        (Route<dynamic> route) => false);
  }

  //Untuk logout
  showBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          // height: MediaQuery.of(context).size.height * 0.75,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    // logoutPopDialog();
                  },
                  child: Icon(
                    Icons.close,
                    size: 28,
                  ),
                ),
                Center(
                  child: Image.asset(
                    "images/lobby/sheet_biometric.jpg",
                    width: 250,
                    height: 250,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.translate('easier_faster')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('you_can_register')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('using_face_finger')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('later_you_verify')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('your_account_biometric')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () async {
                    await LocalAuth.canAuthenticate().then((value) {
                      printLog(value.toString());
                      if (value) {
                        String emailBio =
                            context.read<LoginProvider>().emailBio;
                        String passwordBio =
                            context.read<LoginProvider>().passwordBio;
                        if (Session.data.containsKey("usernameBio") &&
                            Session.data.containsKey("passwordTemp")) {
                          emailBio = Session.data.getString("usernameBio")!;
                          passwordBio = Session.data.getString("passwordTemp")!;
                        }
                        Session()
                            .saveBiometric(emailBio, passwordBio)
                            .then((value) {
                          Navigator.pop(context);
                          logoutPopDialog2();
                        });
                      } else {
                        Navigator.pop(context);
                        noBiometric(context);
                      }
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: primaryColor),
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('register_face_finger')!,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    logoutPopDialog();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor)),
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('continue_logout')!,
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  registerBioSuccess() {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          insetPadding: EdgeInsets.all(0),
          content: Builder(
            builder: (context) {
              return Container(
                height: 150.h,
                width: 330.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      AppLocalizations.of(context)!
                          .translate('biometric_registration')!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: responsiveFont(14),
                          fontWeight: FontWeight.w500),
                    ),
                    Container(
                        child: Column(
                      children: [
                        Container(
                          color: Colors.black12,
                          height: 2,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                color: primaryColor),
                            child: Text(
                              AppLocalizations.of(context)!.translate('ok')!,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ))
                  ],
                ),
              );
            },
          )),
    );
  }

  //Untuk ON/OFF biometric
  showBottomSheet2() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          // height: MediaQuery.of(context).size.height * 0.75,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    size: 28,
                  ),
                ),
                Center(
                  child: Image.asset(
                    "images/lobby/sheet_biometric.jpg",
                    width: 250,
                    height: 250,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.translate('easier_faster')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('you_can_register')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('using_face_finger')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('later_you_verify')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate('your_account_biometric')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () async {
                    await LocalAuth.canAuthenticate().then((value) {
                      printLog(value.toString());
                      if (value) {
                        Session()
                            .saveBiometric(
                                context.read<LoginProvider>().emailBio,
                                context.read<LoginProvider>().passwordBio)
                            .then((value) {
                          Navigator.pop(context);
                          context.read<LoginProvider>().setBiometric(true);
                          registerBioSuccess();
                        });
                      } else {
                        Navigator.pop(context);
                        noBiometric(context);
                      }
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: primaryColor),
                    child: Text(
                      AppLocalizations.of(context)!
                          .translate('register_face_finger')!,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor)),
                    child: Text(
                      AppLocalizations.of(context)!.translate('later')!,
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final generalSettings = Provider.of<HomeProvider>(context, listen: false);
    final unread =
        Provider.of<ChatProvider>(context, listen: false).unreadMessage;
    final firstname = Session.data.getString('firstname') ?? "";
    final isChatActive = Provider.of<HomeProvider>(context).isChatActive;
    final point = Provider.of<UserProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;
    final membershipPlan = Session.data.getString("membershipPlan");
    _launchPhoneURL(String phoneNumber) async {
      String url = 'tel:' + phoneNumber;
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.translate('title_myAccount')!,
          style: TextStyle(
            fontSize: responsiveFont(16),
            fontWeight: FontWeight.w500,
            // color: Colors.black
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<UserProvider>(
                      builder: (context, value, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          value.loading
                              ? Row(
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.translate('hello')},",
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: responsiveFont(14),
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Shimmer.fromColors(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          height: 20.h,
                                          width: 70.w,
                                        ),
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!),
                                  ],
                                )
                              : Text(
                                  "${AppLocalizations.of(context)!.translate('hello')}, ${firstname.length > 10 ? firstname.substring(0, 10) + '... ' : firstname} !",
                                  style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: responsiveFont(14),
                                      fontWeight: FontWeight.w500),
                                ),
                          Text(
                            AppLocalizations.of(context)!
                                .translate('welcome_back')!,
                            style: TextStyle(fontSize: responsiveFont(9)),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Visibility(
                          visible: isChatActive,
                          child: Container(
                            child: Stack(children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(10),
                                //   color: primaryColor,
                                // ),
                                child: TextButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                primaryColor)),
                                    child: Text("Live Chat",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.white,
                                        )),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(),
                                          ));
                                    }),
                              ),
                              unread > 0
                                  ? Positioned(
                                      top: 5,
                                      right: 0,
                                      child: Container(
                                        constraints: BoxConstraints(
                                            minWidth: 20, minHeight: 20),
                                        child: Center(
                                            child: Text(
                                          unread.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: responsiveFont(10)),
                                        )),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(120)),
                                            color: secondaryColor),
                                      ),
                                    )
                                  : Container()
                            ]),
                          ),
                        ),
                        if (userProvider.refModel != null)
                          Visibility(
                            visible: !userProvider.loading &&
                                (userProvider.user.phoneNumber != "" ||
                                    userProvider.refModel!.referralLink != ""),
                            child: GestureDetector(
                              onTap: () {
                                String qrData = "";
                                if (url.contains('//99')) {
                                  qrData = userProvider.user.phoneNumber!;
                                } else {
                                  qrData = userProvider.refModel!.referralLink!;
                                }
                                printLog(url);
                                showQrCode(qrData);
                              },
                              child: Image.asset(
                                "images/account/qr-code.png",
                                color: isDarkMode ? Colors.white : Colors.black,
                                height: 25.h,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ]),
            ),
            Container(
              width: double.infinity,
              height: 5,
              color: Colors.black12,
            ),
            Visibility(
              visible: Provider.of<HomeProvider>(context, listen: false)
                  .isPointPluginActive,
              child: Consumer<UserProvider>(
                builder: (context, value, child) {
                  return value.loadingFetch
                      ? Shimmer.fromColors(
                          child: Container(
                            margin:
                                EdgeInsets.only(top: 10, left: 10, right: 10),
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!)
                      : Visibility(
                          visible: value.point != null,
                          child: buildPointCard(),
                        );
                },
              ),
            ),
            WalletCard(showBtnMore: true),
            SizedBox(
              height: 15,
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 15, left: 15, bottom: 5),
              child: Text(
                AppLocalizations.of(context)!.translate('account')!,
                style: TextStyle(
                    fontSize: responsiveFont(10),
                    fontWeight: FontWeight.w600,
                    color: secondaryColor),
              ),
            ),
            Consumer<UserProvider>(
              builder: (context, value, child) => Visibility(
                visible: !url.contains('//99') && value.membershipActive!,
                child: accountButton("membership",
                    AppLocalizations.of(context)!.translate('membership_plan')!,
                    func: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountMembershipScreen()))
                      .then((value) => this.setState(() {}));
                }),
              ),
            ),
            accountButton("akun",
                AppLocalizations.of(context)!.translate('title_myAccount')!,
                func: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountDetailScreen()))
                  .then((value) => this.setState(() {}));
            }),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: 25.w,
                              height: 25.h,
                              child: Icon(Icons.fingerprint)),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            AppLocalizations.of(context)!
                                .translate('biometric_login')!,
                            style: TextStyle(fontSize: responsiveFont(11)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                      Consumer<LoginProvider>(
                          builder: (context, value, _) => Switch(
                                value: value.isBiometric!,
                                onChanged: (val) {
                                  if (!value.isBiometric!) {
                                    showBottomSheet2();
                                  } else {
                                    context
                                        .read<LoginProvider>()
                                        .setBiometric(false);
                                    Session().deleteBiometric();
                                  }
                                },
                                activeTrackColor: Colors.lightGreenAccent,
                                activeColor: Colors.green,
                              )),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  height: 2,
                  color: Colors.black12,
                )
              ],
            ),
            accountButton("address",
                "${AppLocalizations.of(context)!.translate('my_address')}",
                func: () {
              if (!Provider.of<HomeProvider>(context, listen: false)
                  .statusMultipleAddress) {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountAddressScreen()))
                    .then((value) => this.setState(() {}));
              } else if (Provider.of<HomeProvider>(context, listen: false)
                  .statusMultipleAddress) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountMultipleAddress(),
                    ));
              }
            }),
            point.loading
                ? Container()
                : Consumer<UserProvider>(builder: (context, value, child) {
                    return Visibility(
                      visible: value.point != null,
                      child: accountButton("coin",
                          AppLocalizations.of(context)!.translate('my_point')!,
                          func: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyPoint()))
                            .then((value) => this.setState(() {}));
                      }),
                    );
                  }),
            SizedBox(
              height: 5,
            ),
            if (userProvider.refModel != null)
              Visibility(
                visible: userProvider.refModel!.referralLink != null &&
                    userProvider.refModel!.referralLink != "" &&
                    !userProvider.loading,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 15, left: 15, bottom: 5),
                      child: Text(
                        AppLocalizations.of(context)!.translate('affiliate')!,
                        style: TextStyle(
                            fontSize: responsiveFont(10),
                            fontWeight: FontWeight.w600,
                            color: secondaryColor),
                      ),
                    ),
                    accountButton("affiliate_detail",
                        AppLocalizations.of(context)!.translate('details')!,
                        func: () async {
                      await Provider.of<AffiliateProvider>(context,
                              listen: false)
                          .affiliateDetails(context);
                    }),
                    accountButton("ref_code",
                        AppLocalizations.of(context)!.translate('ref_code')!,
                        func: () {
                      referalCodePopUp(context);
                    }),
                    // Visibility(
                    //   visible: context.read<UserProvider>().isUserAffiliate &&
                    //       context.read<HomeProvider>().videoSetting,
                    //   child: accountButton("my_video", "My Video", func: () {
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => MyVideoScreen(),
                    //         ));
                    //   }),
                    // ),
                  ],
                ),
              ),
            SizedBox(
              height: 5,
            ),
            Container(color: Colors.white,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 16, left: 16, bottom: 8), // Consistent spacing
              child: Text(
                AppLocalizations.of(context)!.translate('transaction')!,
                style: TextStyle(
                  fontSize: responsiveFont(12), // Slightly larger font for better readability
                  fontWeight: FontWeight.w600,  // Medium weight for a professional look
                  color: secondaryColor,        // Neutral secondary color
                ),
              ),
            ),

            accountButton(
                "myorder", AppLocalizations.of(context)!.translate('my_order')!,
                func: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyOrder()));
            }),
            accountButton("wishlist",
                AppLocalizations.of(context)!.translate('wishlist')!, func: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => WishList()));
            }),
            Visibility(
              visible: Provider.of<HomeProvider>(context, listen: false)
                  .showRatingSection,
              child: accountButton(
                  "review", AppLocalizations.of(context)!.translate('review')!,
                  func: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ReviewScreen()));
              }),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 5, left: 15, bottom: 5),
              child: Text(
                AppLocalizations.of(context)!.translate('general_setting')!,
                style: TextStyle(
                    fontSize: responsiveFont(10),
                    fontWeight: FontWeight.w600,
                    color: secondaryColor),
              ),
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: 25.w,
                              height: 25.h,
                              child:
                                  Image.asset("images/account/darktheme.png")),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            AppLocalizations.of(context)!
                                .translate('dark_theme')!,
                            style: TextStyle(fontSize: responsiveFont(11)),
                          )
                        ],
                      ),
                      Consumer<AppNotifier>(
                          builder: (context, theme, _) => Switch(
                                value: theme.isDarkMode,
                                onChanged: (value) {
                                  setState(() {
                                    theme.isDarkMode = !theme.isDarkMode;
                                  });
                                  if (theme.isDarkMode) {
                                    theme.setDarkMode();
                                  } else {
                                    theme.setLightMode();
                                  }
                                },
                                activeTrackColor: Colors.lightGreenAccent,
                                activeColor: Colors.green,
                              )),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  height: 2,
                  color: Colors.black12,
                )
              ],
            ),
            accountButton("languange",
                AppLocalizations.of(context)!.translate('title_language')!,
                func: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LanguageScreen()));
            }),
            Visibility(
              visible: Provider.of<HomeProvider>(context, listen: false)
                  .activateCurrency,
              child: accountButton("currency",
                  "${AppLocalizations.of(context)!.translate('currency')}",
                  func: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CurrencyScreen()));
              }),
            ),
            accountButton(
                "rateapp", AppLocalizations.of(context)!.translate('rate_app')!,
                func: () {
              if (Platform.isIOS) {
                LaunchReview.launch(writeReview: false, iOSAppId: appId);
              } else {
                LaunchReview.launch(
                    androidAppId: generalSettings.packageInfo!.packageName);
              }
            }),
            accountButton("contact_us",
                AppLocalizations.of(context)!.translate('contact_us')!,
                func: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SocmedScreen()));
            }),
            accountButton(
                "aboutus", AppLocalizations.of(context)!.translate('about_us')!,
                func: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                            url: generalSettings.about.description,
                            title: AppLocalizations.of(context)!
                                .translate('about_us'),
                          )));
            }),
            accountButton(
                "privacy", AppLocalizations.of(context)!.translate('privacy')!,
                func: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                            url: generalSettings.privacy.description,
                            title: AppLocalizations.of(context)!
                                .translate('privacy'),
                          )));
            }),
            accountButton("terms_conditions",
                AppLocalizations.of(context)!.translate('terms_conditions')!,
                func: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                            url: generalSettings.terms.description,
                            title: AppLocalizations.of(context)!
                                .translate('terms_conditions'),
                          )));
            }),
            accountButton(
                "contact", AppLocalizations.of(context)!.translate('contact')!,
                func: () {
              _launchPhoneURL("+" + generalSettings.phone.description!);
            }),
            accountButton(
                "logout", AppLocalizations.of(context)!.translate('logout')!,
                func: () {
              printLog("${Session.data.getString("usernameBio")}",
                  name: "username bio");
              printLog("${Session.data.getString("passwordBio")}",
                  name: "password bio");
              printLog("${Session.data.getString("emailBio")}",
                  name: "email bio");
              printLog("${Session.data.getString("passwordTemp")}",
                  name: "password temp");
              if (!Session.data.containsKey('emailBio') &&
                  !Session.data.containsKey('passwordBio') &&
                  context.read<HomeProvider>().popupBiometric) {
                showBottomSheet();
              } else {
                logoutPopDialog();
              }
            }),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              alignment: Alignment.centerLeft,
              child: FutureBuilder(
                future: _init(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _versionName = snapshot.data as String?;
                    return Text(
                      '${AppLocalizations.of(context)!.translate('version')} ' +
                          _versionName!,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: responsiveFont(10)),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              // Text(
              //   "${AppLocalizations.of(context).translate('version')} $version",
              //   style: TextStyle(
              //       fontWeight: FontWeight.w300, fontSize: responsiveFont(10)),
              // ),
            )
          ],
        ),
      ),
    );
  }

  Widget accountButton(String image, String title, {var func}) {
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;
    return Column(
      children: [
        InkWell(
          onTap: func,
          child:Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // More spacious padding
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white, // Neutral background colors
              borderRadius: BorderRadius.circular(8), // Rounded corners for a modern feel
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ], // Subtle shadow for depth
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (image == "affiliate_detail")
                      Icon(
                        Icons.connect_without_contact_rounded,
                        color: isDarkMode ? Colors.white70 : Colors.grey[700], // Subtle icon color
                        size: 22, // Consistent size for professionalism
                      )
                    else if (image == "membership")
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Icon(
                          FontAwesomeIcons.crown,
                          color: isDarkMode ? Colors.white70 : Colors.grey[700],
                          size: 22, // Larger, consistent icon size
                        ),
                      )
                    else
                      Container(
                        width: 30.w, // Uniform size for all icons/images
                        height: 30.h,
                        child: Image.asset(
                          "images/account/$image.png",
                          color: isDarkMode ? Colors.white70 : null, // Subtle color for dark mode
                        ),
                      ),
                    SizedBox(width: 12), // Slightly increased spacing for better layout
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: responsiveFont(13), // A bit larger font size for clarity
                        fontWeight: FontWeight.w500,  // Medium weight for a more refined look
                        color: isDarkMode ? Colors.white70 : Colors.grey[800], // Modern text color
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: isDarkMode ? Colors.white70 : Colors.grey[500], // Subtle arrow color
                  size: 22, // Consistent arrow size
                ),
              ],
            ),
          ),

        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          width: double.infinity,
          height: 2,
          color: Colors.black12,
        )
      ],
    );
  }

  Widget buildPointCard() {
    final point = Provider.of<UserProvider>(context, listen: false);
    String fullName =
        "${Session.data.getString('firstname')} ${Session.data.getString('lastname')}";

    String _role = "${Session.data.getString('role') ?? ""}";
    String _membershipPlan =
        "${Session.data.getString('membershipPlan') ?? ""}";

    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

    if (point.point == null) {
      return Container();
    }
    return Container(
        margin: EdgeInsets.only(top: 15, left: 10, right: 10),
        child: Stack(
          children: [
            Image.asset("images/account/card_point.png"),
            Positioned(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  _membershipPlan == ""
                      ? capitalize(_role)
                      : capitalize(_membershipPlan),
                  style: TextStyle(
                      fontSize: responsiveFont(14),
                      color: secondaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              top: 15,
              right: 15,
            ),
            Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.translate('full_name')!,
                      style: TextStyle(
                          fontSize: responsiveFont(10),
                          color: primaryColor,
                          fontWeight: FontWeight.w400)),
                  Text(
                    fullName.length > 10
                        ? fullName.substring(0, 10) + '... '
                        : fullName,
                    style: TextStyle(
                        fontSize: responsiveFont(18),
                        color: secondaryColor,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
              bottom: 10,
              left: 15,
            ),
            Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppLocalizations.of(context)!.translate('total_point')!,
                      style: TextStyle(
                          fontSize: responsiveFont(10),
                          color: primaryColor,
                          fontWeight: FontWeight.w400)),
                  point.loading
                      ? Text(
                          '-',
                          style: TextStyle(
                              fontSize: responsiveFont(18),
                              color: secondaryColor,
                              fontWeight: FontWeight.w600),
                        )
                      : Text(
                          '${point.point!.pointsBalance} ${point.point!.pointsLabel}',
                          style: TextStyle(
                              fontSize: responsiveFont(18),
                              color: secondaryColor,
                              fontWeight: FontWeight.w600),
                        )
                ],
              ),
              bottom: 10,
              right: 15,
            )
          ],
        ));
  }

  logoutPopDialog2() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          insetPadding: EdgeInsets.all(0),
          content: Builder(
            builder: (context) {
              return Container(
                height: 150.h,
                width: 330.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .translate('title_exit_alert')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: responsiveFont(14),
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .translate('biometric_registration')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: responsiveFont(12),
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .translate('logout_body_alert')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: responsiveFont(12),
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    Container(
                        child: Column(
                      children: [
                        Container(
                          color: Colors.black12,
                          height: 2,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(false),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15)),
                                      color: primaryColor),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('no')!,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => logout(),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(15)),
                                      color: Colors.white),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('yes')!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primaryColor),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ))
                  ],
                ),
              );
            },
          )),
    );
  }

  logoutPopDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          insetPadding: EdgeInsets.all(0),
          content: Builder(
            builder: (context) {
              return Container(
                height: 150.h,
                width: 330.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .translate('title_exit_alert')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: responsiveFont(14),
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .translate('logout_body_alert')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: responsiveFont(12),
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    Container(
                        child: Column(
                      children: [
                        Container(
                          color: Colors.black12,
                          height: 2,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(false),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15)),
                                      color: primaryColor),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('no')!,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => logout(),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(15)),
                                      color: Colors.white),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('yes')!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primaryColor),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ))
                  ],
                ),
              );
            },
          )),
    );
  }
}
