import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:nyoba/pages/account/account_screen.dart';
import 'package:nyoba/pages/auth/sign_in_otp_screen.dart';
import 'package:nyoba/pages/home/video_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_localizations.dart';
import '../blog/blog_screen.dart';
import '../category/category_screen.dart';
import '../order/cart_screen.dart';
import 'lobby_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool? isLogin = false;
  Animation<double>? animation;
  late AnimationController controller;
  List<bool> isAnimate = [false, false, false, false, false, false];
  Timer? _timer;
  late StreamSubscription subscription;
  var isDeviceConnected = false;
  bool isAlertSet = false;

  GlobalKey globalKeyOne = GlobalKey();
  GlobalKey globalKeyTwo = GlobalKey();
  GlobalKey globalKeyThree = GlobalKey();
  GlobalKey globalKeyFour = GlobalKey();

  static List<Widget> _widgetOptions = [];

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    getConectivity();
    getVersion();
    super.initState();
    _widgetOptions = <Widget>[
      LobbyScreen(
        globalKeyTwo: globalKeyTwo,
        globalKeyThree: globalKeyThree,
      ),
      BlogScreen(),
      CategoryScreen(
        isFromHome: true,
      ),
      CartScreen(
        isFromHome: true,
      ),
      AccountScreen()
    ];
    if (context.read<HomeProvider>().videoSetting) {
      _widgetOptions.insert(1, VideoScreen());
    }
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = Tween<double>(begin: 24, end: 24).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0,
          0.150,
          curve: Curves.ease,
        ),
      ),
    );
    if (!Session.data.getBool('big_update')!) {
      Session.data.remove('cart');
      Session.data.setBool('big_update', true);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print(Session.data.getBool('tool_tip')!);
      if (Session.data.containsKey('tool_tip')) {
        if (Session.data.getBool('tool_tip')!) {
          ShowCaseWidget.of(context)
              .startShowCase([globalKeyOne, globalKeyTwo, globalKeyThree]);
        }
      }

      context.read<OrderProvider>().loadCartCount();
    });
  }

  getConectivity() {
    subscription = Connectivity().onConnectivityChanged.listen((event) async {
      isDeviceConnected = await InternetConnectionChecker().hasConnection;
      if (!isDeviceConnected && isAlertSet == false) {
        showDialogBox();
        setState(() {
          isAlertSet = true;
        });
      }
    });
  }

  showDialogBox() {
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => WillPopScope(
        child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            insetPadding: EdgeInsets.all(0),
            content: Builder(
              builder: (context) {
                return Container(
                  height: 220.h,
                  width: 330.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                color: primaryColor),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('warning_internet_connection')!,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 24.h,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .translate('no_internet_connection')!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: responsiveFont(14),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 24.h,
                          ),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context, "Cancel");
                              setState(() {
                                isAlertSet = false;
                              });
                              isDeviceConnected =
                                  await InternetConnectionChecker()
                                      .hasConnection;
                              if (!isDeviceConnected) {
                                showDialogBox();
                                setState(() {
                                  isAlertSet = true;
                                });
                              }
                            },
                            child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.refresh),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("Click to Refresh")
                                    ])),
                          )
                        ],
                      )),
                    ],
                  ),
                );
              },
            )),
        onWillPop: () async => false,
      ),
    );
  }

  Future<bool> _onWillPop() {
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
                              .translate('body_exit_alert')!,
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
                                onTap: () => Navigator.of(context).pop(true),
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
    ).then((value) => value as bool);
  }

  VersionStatus? status;
  getVersion() async {
    try {
      final newVersion = NewVersionPlus();
      final status = await newVersion.getVersionStatus();

      // Check if status is null
      if (status == null) {
        printLog("Version status is null", name: "Version App");
        return; // Early return if status is null
      }

      printLog("${status.localVersion} == ${status.storeVersion}",
          name: "Version App");

      // Split and convert version strings to integers for comparison
      List<int> localVersionParts = status.localVersion.split(".").map((e) => int.tryParse(e) ?? 0).toList();
      List<int> storeVersionParts = status.storeVersion.split(".").map((e) => int.tryParse(e) ?? 0).toList();

      // Ensure that version parts are of expected length
      if (localVersionParts.length < 3 || storeVersionParts.length < 3) {
        printLog("Version parts are incomplete", name: "Version App");
        return;
      }

      // Calculate a comparable integer value for local and store versions
      int localVersion =
          (localVersionParts[0] * 100000) + (localVersionParts[1] * 1000) + localVersionParts[2];
      int storeVersion =
          (storeVersionParts[0] * 100000) + (storeVersionParts[1] * 1000) + storeVersionParts[2];

      bool updateNeeded = localVersion < storeVersion;

      // Check if an update is needed and if the user has not been notified before
      if (updateNeeded && !Provider.of<HomeProvider>(context, listen: false).updateVersion) {
        return showDialog(
          context: context,
          builder: (context) {
            final appName = context.read<HomeProvider>().packageInfo?.appName ?? "App";
            return customDialog(
                appName,
                status.localVersion,
                status.storeVersion);
          },
        ).then((value) {
          // Mark that the user has been notified about the update
          Provider.of<HomeProvider>(context, listen: false).setUpdateVersion(true);
        });
      }
    } catch (e) {
      // Log any errors that might occur
      printLog("Error while checking app version: $e", name: "Version App");
    }
  }

  customDialog(
    String appName,
    String localVersion,
    String storeVersion,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(
        context,
        appName: appName,
        localVersion: localVersion,
        storeVersion: storeVersion,
      ),
    );
  }

  _launchUrl() async {
    if (await canLaunchUrl(Uri.parse(status!.appStoreLink))) {
      await launchUrl(
        Uri.parse(status!.appStoreLink),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch ${status!.appStoreLink}';
    }
  }

  contentBox(
    context, {
    required String appName,
    required String localVersion,
    required String storeVersion,
  }) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 10, top: 40, right: 10, bottom: 10),
          margin: EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Text(
                  "${AppLocalizations.of(context)!.translate('update')} $appName ${AppLocalizations.of(context)!.translate('app_now')}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "${AppLocalizations.of(context)!.translate('your_version')} $localVersion\n${AppLocalizations.of(context)!.translate('new_version')} $storeVersion",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 22,
              ),
              Column(children: [
                GestureDetector(
                    onTap: () async {
                      Provider.of<HomeProvider>(context, listen: false)
                          .setUpdateVersion(true);
                      _launchUrl();
                    },
                    child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "${AppLocalizations.of(context)!.translate('update_now')}",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ))),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                    onTap: () {
                      Provider.of<HomeProvider>(context, listen: false)
                          .setUpdateVersion(true);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "${AppLocalizations.of(context)!.translate('maybe_later')}",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ))),
              ]),
            ],
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 40,
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: Image.asset("images/lobby/icon_rocket.png")),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: Consumer<HomeProvider>(
            builder: (context, value, child) {
              return Stack(
                children: [
                  _widgetOptions.elementAt(_selectedIndex),
                  value.isNeedLoadingExternalLink
                      ? Container(
                          color: Colors.black.withOpacity(0.5),
                          child: customLoading(),
                        )
                      : SizedBox(),
                ],
              );
            },
          ),
          bottomNavigationBar: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<HomeProvider>(
                builder: (context, value, child) {
                  return Stack(
                    children: [
                      AnimatedBuilder(
                        animation: controller,
                        builder: bottomNavBar,
                      ),
                      value.isNeedLoadingExternalLink
                          ? Container(
                              color: Colors.black.withOpacity(0.5),
                              width: MediaQuery.of(context).size.width,
                              height: 40.h,
                            )
                          : SizedBox(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        onWillPop: _onWillPop);
  }

  @override
  void dispose() {
    controller.dispose();
    subscription.cancel();
    globalKeyOne.currentState?.dispose();
    globalKeyTwo.currentState?.dispose();
    globalKeyThree.currentState?.dispose();
    super.dispose();
  }
  Widget bottomNavBar(BuildContext context, Widget? child) {
    // Use MediaQuery for responsiveness
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 5)],
      ),
      child: BottomAppBar(
        padding: EdgeInsets.zero,
        height: screenHeight * 0.1, // Set height responsively
        child: Container(
          height: screenHeight * 0.08, // Adjust inner container height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Use spaceAround for even spacing
            children: <Widget>[
              _buildNavItem(context, 0, Icons.home, 'home', "images/home/home.png"),
              if (context.read<HomeProvider>().videoSetting)
                _buildNavItem(context, 1, Icons.smart_display, 'video', "images/home/video.png"),
              _buildNavItem(
                context,
                context.read<HomeProvider>().videoSetting ? 3 : 2, // Dynamic index based on condition
                Icons.widgets,
                'category',
                "images/home/category.png",
              ),
              _buildNavItem(
                context,
                context.read<HomeProvider>().videoSetting ? 4 : 3, // Dynamic index based on condition
                Icons.shopping_cart,
                'cart',
                "images/home/cart.png",
              ),
              _buildAccountNavItem(context),
            ],
          ),
        ),
        shape: CircularNotchedRectangle(),
        elevation: 5,
      ),
    );
  }
  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, String imagePath) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      flex: 2,
      child: InkWell(
        onTap: () async {
          setState(() {
            isAnimate[index] = true;
            _animatedFlutterLogoState(index);
          });
          await _onItemTapped(index);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut, // Smooth animation curve
          decoration: BoxDecoration(
            gradient: isAnimate[index]
                ? LinearGradient( // Gradient background for active state
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null, // No gradient when inactive
            color: isAnimate[index] ? Colors.transparent : Colors.transparent, // Keep transparent when inactive
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (isAnimate[index])
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isAnimate[index] ? 1.1 : 1.0, // Slightly smaller scale for a subtle effect
                duration: Duration(milliseconds: 150),
                curve: Curves.easeInOut, // Smooth scale animation
                child: Icon(
                  icon,
                  size: screenWidth * 0.07, // Slightly larger icon size
                  color: isAnimate[index] ? Colors.white : Colors.grey,
                ),
              ),
              SizedBox(height: 6), // Increased spacing for better visibility
              Text(
                AppLocalizations.of(context)?.translate(label) ?? label,
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // Slightly larger text size
                  fontWeight: FontWeight.w600, // Semi-bold for better visibility
                  color: isAnimate[index] ? Colors.white : Colors.black,
                  letterSpacing: 0.5, // Added letter spacing for readability
                  shadows: isAnimate[index]
                      ? [Shadow(color: Colors.black26, blurRadius: 2.0)] // Add shadow to text when active
                      : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

      ),
    );
  }

  Widget _buildAccountNavItem(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      flex: 2,
      child: InkWell(
        onTap: () {
          bool isLogin = Session.data.getBool('isLogin') ?? false;

          if (!isLogin) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignInOTPScreen(isFromNavBar: false),
              ),
            );
          } else {
            setState(() {
              _widgetOptions[4] = AccountScreen();
              isAnimate[4] = true;
              _animatedFlutterLogoState(4);
              _onItemTapped(4);
            });
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200), // Smooth transition
          decoration: BoxDecoration(
            color: isAnimate[4] ? Colors.blueAccent : Colors.transparent, // Change color on tap
            borderRadius: BorderRadius.circular(12), // Rounded corners
            boxShadow: [
              if (isAnimate[4]) // Active shadow effect
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02), // Responsive padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isAnimate[4] ? 1.2 : 1.0, // Scale effect on tap
                duration: Duration(milliseconds: 150), // Animation duration for the scale
                child: Icon(
                  Icons.person,
                  size: screenWidth * 0.065, // Responsive icon size
                  color: isAnimate[4] ? Colors.white : Colors.grey, // Change icon color based on state
                ),
              ),
              SizedBox(height: 4), // Spacing between icon and text
              Text(
                AppLocalizations.of(context)?.translate('account') ?? 'Account', // Safe translation
                style: TextStyle(
                  fontSize: screenWidth * 0.035, // Responsive text size
                  fontWeight: FontWeight.bold, // Bold text for better visibility
                  color: isAnimate[4] ? Colors.white : Colors.black, // Change text color based on state
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  _animatedFlutterLogoState(int index) {
    _timer = new Timer(const Duration(milliseconds: 200), () {
      setState(() {
        isAnimate[index] = false;
      });
    });
    return _timer;
  }

  Widget navbarItem(
    int index,
    String image,
    // String clickedImage,
    // Icon icon,
    Icon iconClicked,
    String title,
    int width,
    int smallWidth,
  ) {
    var count = Provider.of<OrderProvider>(context).cartCount;

    final gradientColor = List<Color>.from([primaryColor, secondaryColor]);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 5,
          ),
          Stack(
            children: [
              AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: isAnimate[index] == true ? 0 : 1,
                child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    alignment: Alignment.bottomCenter,
                    width: isAnimate[index] == true
                        ? smallWidth.w
                        : (index == 4 &&
                                    context.read<HomeProvider>().videoSetting) ||
                                (!context.read<HomeProvider>().videoSetting &&
                                    index == 3)
                            ? width.w + 8
                            : width.w,
                    height: isAnimate[index] == true ? smallWidth.w : width.w,
                    child: _selectedIndex == index
                        ?
                        // Image.asset(clickedImage)
                        ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (rect) => LinearGradient(
                                    colors: gradientColor,
                                    begin: Alignment.topCenter)
                                .createShader(rect),
                            child: Image.asset(image),
                          )
                        : Image.asset(image)),
              ),
              Visibility(
                child: Positioned(
                  right: 0,
                  child: Container(
                    // padding: EdgeInsets.all(0.2),
                    decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black54, blurRadius: 1)
                        ]),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child:
                        Consumer<OrderProvider>(builder: (context, data, child) {
                      return Center(
                        child: Text(
                          '${data.cartCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                  ),
                ),
                visible: context.read<HomeProvider>().videoSetting
                    ? index == 4 && count != 0
                    : index == 3 && count != 0,
              )
            ],
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: _selectedIndex == index
                      ? FontWeight.w600
                      : FontWeight.normal,
                  fontSize: responsiveFont(8),
                  fontFamily: 'ReadexPro',
                  color: _selectedIndex == index ? primaryColor : null),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomMessages extends UpgraderMessages {
  /// Override the message function to provide custom language localization.
  @override
  String? message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.body:
        return 'App Name : {{appName}}\nYour Version : {{currentInstalledVersion}}\nAvailable : {{currentAppStoreVersion}}';
      case UpgraderMessage.buttonTitleIgnore:
        return 'Ignore';
      case UpgraderMessage.buttonTitleLater:
        return 'Later';
      case UpgraderMessage.buttonTitleUpdate:
        return 'Update Now';
      case UpgraderMessage.prompt:
        return 'Would you like to update it now?';
      case UpgraderMessage.title:
        return 'New Version Available';
      case UpgraderMessage.releaseNotes:
        break;
    }
    return null;
    // Messages that are not provided above can still use the default values.
  }
}
