/* Dart Package */
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:nyoba/deeplink/deeplink_config.dart';
import 'package:nyoba/pages/home/socmed_screen.dart';
import 'package:nyoba/pages/notification/notification_screen.dart';
import 'package:nyoba/pages/order/cart_screen.dart';
import 'package:nyoba/pages/order/coupon_screen.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/search/search_screen.dart';
import 'package:nyoba/provider/blog_provider.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/provider/coupon_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/notification_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/provider/wallet_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/widgets/home/drawer_main.dart';
import 'package:nyoba/widgets/home/home_appbar.dart';
import 'package:provider/provider.dart';

/* Widget  */
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../app_localizations.dart';
import '../../provider/app_provider.dart';
import '../../provider/local_auth_service.dart';
import '../../provider/login_provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/home/grid_item.dart';
import 'package:nyoba/widgets/draggable/draggable_widget.dart';
import 'package:nyoba/widgets/draggable/model/anchor_docker.dart';
import 'package:nyoba/widgets/product/grid_item_shimmer.dart';

/* Provider */
import '../../provider/category_provider.dart';

/* Helper */
import '../../utils/utility.dart';
import 'home_screen.dart';

class LobbyScreen extends StatefulWidget {
  LobbyScreen(
      {Key? key, required this.globalKeyTwo, required this.globalKeyThree})
      : super(key: key);
  final GlobalKey globalKeyTwo;
  final GlobalKey globalKeyThree;
  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen>
    with TickerProviderStateMixin {
  AnimationController? _colorAnimationController;
  AnimationController? _textAnimationController;
  Animation? _colorTween, _titleColorTween, _iconColorTween, _moveTween;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  int itemCount = 10;
  int itemCategoryCount = 9;
  int? clickIndex = 0;
  int page = 1;
  String? selectedCategory;
  ScrollController _scrollController = new ScrollController();

  bool isLogin = false;
  bool isHaveInternetConnection = false;
  bool showBannerLove = true;
  bool showBannerSpecial = true;
  @override
  void initState() {
    super.initState();
    printLog(isHaveInternetConnection.toString(), name: "koneksi internet");
    printLog('Init', name: 'Init Home');
    // refreshHome();
    loadBlog();
    loadCategory();
    final products = Provider.of<ProductProvider>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);
    isLogin = Session.data.getBool('isLogin')!;
    loadWishList();
    loadNotif();
    Provider.of<ProductProvider>(context, listen: false).setPageBestDeals(1);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 400) {
        if (products.listBestDeal.length % 24 == 0 &&
            !products.loadingBestDeals &&
            products.listBestDeal.isNotEmpty) {
          printLog("masuk load best deals");
          setState(() {
            page++;
          });
          Provider.of<ProductProvider>(context, listen: false).setPageBestDeals(
              context.read<ProductProvider>().pageBestDeals + 1);
          loadBestDeals();
        }
      }
    });
    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween = ColorTween(
      begin: primaryColor.withOpacity(0.0),
      end: primaryColor.withOpacity(1.0),
    ).animate(_colorAnimationController!);
    _titleColorTween = ColorTween(
      begin: Colors.white,
      end: HexColor("ED625E"),
    ).animate(_colorAnimationController!);
    _iconColorTween = ColorTween(begin: Colors.white, end: HexColor("#4A3F35"))
        .animate(_colorAnimationController!);
    _textAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _moveTween = Tween(
      begin: Offset(0, 0),
      end: Offset(-25, 0),
    ).animate(_colorAnimationController!);

    loadHome();

    if (home.isReload) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        refreshHome();
      });
    }
    for (int i = 0; i < home.bannerSpecial.length; i++) {
      if (home.bannerSpecial.first.name == "") {
        setState(() {
          showBannerSpecial = false;
        });
      }
    }
    for (int i = 0; i < home.bannerLove.length; i++) {
      if (home.bannerLove.first.name == "") {
        setState(() {
          showBannerLove = false;
        });
      }
    }

    if (Session.data.getBool('isLogin')!) {
      loadRecentProduct();
      // loadWallet();
      loadCoupon();
    }
    loadBestDeals();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      deeplinkBackgroundNotif();
    });

    // loadUnreadMessage();

    _getCurrentPosition().then((value) {
      _getAddressFromLatLng(_currentPosition!);
    });
  }

  //LOCATION
  String? _currentAddress;
  Position? _currentPosition;

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      printLog(
          "${place.administrativeArea} - ${place.country} - ${place.isoCountryCode} - ${place.locality} - ${place.name} - ${place.postalCode} - ${place.subThoroughfare} - ${place.thoroughfare}");
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
        Provider.of<LoginProvider>(context, listen: false).countryCode =
            place.isoCountryCode;
      });
    }).catchError((e) {
      debugPrint(e);
    });
    printLog(_currentAddress!);
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      snackBar(context,
          message:
              "Location services are disabled. Please enable the services");
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        snackBar(context, message: 'Location permissions are denied');

        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      snackBar(context,
          message:
              'Location permissions are permanently denied, we cannot request permissions.');

      return false;
    }
    return true;
  }
  //END OF LOCATION

  deeplinkBackgroundNotif() {
    print("${Session.data.getString("local_notif")}, ini data notif di lobby");
    print("${Session.data.getString("dataNotif")}, ini data notif di lobby");
    if (Session.data.containsKey("local_notif")) {
      var data = jsonDecode(Session.data.getString("local_notif")!);
      var payload = jsonDecode(data["payload"]);
      print("$data, ini data decode");
      print("${data["payload"]}, ini data payload");
      print("${payload["click_action"]}, ini data click_action");
      DeeplinkConfig()
          .pathUrl(Uri.parse(payload["click_action"]), context, false);
      Session.data.remove("local_notif");
    }
    if (Session.data.containsKey("dataNotif")) {
      var data = jsonDecode(Session.data.getString("dataNotif")!);
      var clickAction = data["click_action"];
      DeeplinkConfig().pathUrl(Uri.parse(clickAction), context, false);
      Session.data.remove("dataNotif");
    }
  }

  loadWishList() async {
    // final wishlist = Provider.of<WishlistProvider>(context, listen: false);

    // if (Session.data.getBool('isLogin')!) {
    //   await Provider.of<WishlistProvider>(context, listen: false)
    //       .loadWishlistProduct();
    //
    //   // .then((value) async {
    //   // await Provider.of<WishlistProvider>(context, listen: false)
    //   //     .fetchWishlistProducts(wishlist.productWishlist!);
    //   // });
    // }
    // loadCartCount();
  }

  loadNotif() async {
    if (Session.data.containsKey('isLogin')) {
      if (Session.data.getBool('isLogin')!)
        await Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications();
    }
  }

  logout() async {
    final home = Provider.of<HomeProvider>(context, listen: false);
    var auth = FirebaseAuth.instance;

    Session.data.remove('unread_notification');
    FlutterAppBadger.removeBadge();

    Session.data.remove('unread_notification');
    FlutterAppBadger.removeBadge();

    Session().removeUser();
    printLog("Logout gan");
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

  logoutPopDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
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

  loadBlog() async {
    final blogProvider = Provider.of<BlogProvider>(context, listen: false);
    if (Session.data.containsKey('listBlog')) {
      blogProvider.setListBlogFromSession();
    } else {
      printLog("FETCHING BLOG");
      await Provider.of<BlogProvider>(context, listen: false)
          .fetchBlogs(page: page, search: "", loadingList: true);
    }
  }

  loadCategory() async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    if (Session.data.containsKey('listAllCategories')) {
      categoryProvider.allCategories.clear();
      categoryProvider.fetchAllCategories();
    } else {
      printLog("FETCHING CATEGORIES 1");
      categoryProvider.fetchAllCategories();
    }

    if (Session.data.containsKey('listPopularCategories')) {
      categoryProvider.setPopularCategoriesFromSession();
    } else {
      printLog("FETCHING CATEGORIES 2");
      categoryProvider.fetchPopularCategories();
    }
  }

  bool showBottomSheetBiometric = false;

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
                              AppLocalizations.of(context)!.translate("ok")!,
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

  showBottomSheet() {
    showBottomSheetBiometric = true;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
                  onTap: () => Navigator.pop(context),
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
                          // context.read<LoginProvider>().emailBio,
                          // context.read<LoginProvider>().passwordBio,
                          Session.data.getString("usernameBio")!,
                          Session.data.getString("passwordTemp")!,
                        )
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

  loadUserDetail() async {
    await Provider.of<UserProvider>(context, listen: false)
        .fetchUserDetail()
        .then((value) {
      printLog(jsonEncode(value), name: "USER DETAIL");
      if (value!['message'] != null) {
        if (value['message'].contains("cookie")) {
          printLog('cookie ditemukan');
          logoutPopDialog();
        }
      }
      // if (mounted) this.setState(() {});
    });
    if (context.read<HomeProvider>().popupBiometric) {
      if (!Session.data.containsKey('emailBio') &&
          !Session.data.containsKey('passwordBio') &&
          !showBottomSheetBiometric) {
        showBottomSheet();
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  int item = 6;

  loadUnreadMessage() async {
    await Provider.of<ChatProvider>(context, listen: false)
        .checkUnreadMessage();
  }

  loadBestDeals() async {
    await Provider.of<ProductProvider>(context, listen: false).fetchBestDeals();
  }

  loadNewProduct(bool loading) async {
    this.setState(() {});
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchNewProducts(clickIndex == 0 ? '' : clickIndex.toString());
  }

  loadRecentProduct() async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchRecentProducts();
  }

  loadHome() async {
    await Provider.of<HomeProvider>(context, listen: false)
        .fetchHomeData(context);
  }

  loadWallet() async {
    if (Session.data.getBool('isLogin')!)
      await Provider.of<WalletProvider>(context, listen: false).fetchBalance();
  }

  loadBanner() async {
    this.setState(() {});
    await Provider.of<HomeProvider>(context, listen: false).fetchHome(context);
  }

  refreshHome() async {
    setState(() {
      context.read<HomeProvider>().flashSales = [];
    });
    if (mounted) {
      Provider.of<ProductProvider>(context, listen: false).setPageBestDeals(1);
      setState(() {
        page = 1;
      });
      if (isLogin == true) {
        loadUserDetail();
      }
      context.read<WalletProvider>().changeWalletStatus();
      loadWallet();
      await Provider.of<HomeProvider>(context, listen: false)
          .fetchHome(context)
          .then((value) {
        final home = Provider.of<HomeProvider>(context, listen: false);
        for (int i = 0; i < home.bannerSpecial.length; i++) {
          if (home.bannerSpecial.first.name == "") {
            setState(() {
              showBannerSpecial = false;
            });
          }
        }
        for (int i = 0; i < home.bannerLove.length; i++) {
          if (home.bannerLove.first.name == "") {
            setState(() {
              showBannerLove = false;
            });
          }
        }
      });
      loadCategory();
      loadWishList();
      loadBanner();
      loadNewProduct(true);
      loadUnreadMessage();
      loadCoupon();
      loadBestDeals();
      refreshController.refreshCompleted();
      await Provider.of<HomeProvider>(context, listen: false).changeIsReload();
    }
  }

  loadRecommendationProduct(include) async {
    await Provider.of<HomeProvider>(context, listen: false)
        .fetchMoreRecommendation(include, page: page)
        .then((value) {
      this.setState(() {});
      Future.delayed(Duration(milliseconds: 3500), () {
        print('Delayed Done');
        this.setState(() {});
      });
    });
  }

  loadCoupon() async {
    await Provider.of<CouponProvider>(context, listen: false)
        .fetchCoupon(page: 1)
        .then((value) => this.setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  final dragController = DragController();

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductProvider>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);
    final coupons = Provider.of<CouponProvider>(context, listen: false);
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;
    final notification =
        Provider.of<NotificationProvider>(context, listen: false)
            .unreadNotification;

    // Widget buildMiniBanner = ListenableProvider.value(
    //   value: home,
    //   child: Consumer<HomeProvider>(
    //     builder: (context, value, child) {
    //       return BannerMini(
    //         bannerLove: value.bannerLove,
    //         bannerSpecial: value.bannerSpecial,
    //       );
    //     },
    //   ),
    // );
    // Widget buildNewProducts = Container(
    //   child: ListenableProvider.value(
    //     value: home,
    //     child: Consumer<HomeProvider>(builder: (context, value, child) {
    //       if (value.loading) {
    //         return Container(
    //             height: MediaQuery.of(context).size.height / 3.0,
    //             child: shimmerProductItemSmall());
    //       }
    //       return ProductContainer(
    //         products: value.listNewProduct,
    //       );
    //     }),
    //   ),
    // );
    // Widget buildNewProductsClicked = Container(
    //   child: ListenableProvider.value(
    //     value: products,
    //     child: Consumer<ProductProvider>(builder: (context, value, child) {
    //       if (value.loadingNew) {
    //         return Container(
    //             height: MediaQuery.of(context).size.height / 3.0,
    //             child: shimmerProductItemSmall());
    //       }
    //       return ProductContainer(
    //         products: value.listNewProduct,
    //       );
    //     }),
    //   ),
    // );
    // Widget buildRecentProducts = Container(
    //   child: ListenableProvider.value(
    //     value: products,
    //     child: Consumer<ProductProvider>(builder: (context, value, child) {
    //       return Visibility(
    //           visible: value.listRecentProduct.isNotEmpty,
    //           child: Column(
    //             children: [
    //               Container(
    //                 margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     Text(
    //                       AppLocalizations.of(context)!
    //                           .translate('recent_view')!,
    //                       style: TextStyle(
    //                           fontSize: responsiveFont(14),
    //                           fontWeight: FontWeight.w600),
    //                     ),
    //                     GestureDetector(
    //                       onTap: () {
    //                         Navigator.push(
    //                             context,
    //                             MaterialPageRoute(
    //                                 builder: (context) => ProductMoreScreen(
    //                                       name: AppLocalizations.of(context)!
    //                                           .translate('recent_view')!,
    //                                       include: value.productRecent,
    //                                     )));
    //                       },
    //                       child: Text(
    //                         AppLocalizations.of(context)!.translate('more')!,
    //                         style: TextStyle(
    //                             fontSize: responsiveFont(12),
    //                             fontWeight: FontWeight.w600,
    //                             color: secondaryColor),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               ProductContainer(
    //                 products: value.listRecentProduct,
    //               )
    //             ],
    //           ));
    //     }),
    //   ),
    // );
    // Widget buildRecommendation = Visibility(
    //   visible: home.recommendationProducts[0].products!.length > 0,
    //   child: Container(
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Container(
    //           width: double.infinity,
    //           height: 7,
    //           color: isDarkMode ? Colors.black12 : HexColor("EEEEEE"),
    //         ),
    //         Container(
    //           margin: EdgeInsets.only(left: 15, top: 15, right: 15),
    //           child: Text(
    //             home.recommendationProducts[0].title! ==
    //                     'Recommendations For You'
    //                 ? AppLocalizations.of(context)!.translate('title_hap_3')!
    //                 : home.recommendationProducts[0].title!,
    //             style: TextStyle(
    //                 fontSize: responsiveFont(14), fontWeight: FontWeight.w600),
    //           ),
    //         ),
    //         Container(
    //             margin: EdgeInsets.only(left: 15, bottom: 10, right: 15),
    //             child: Text(
    //               home.recommendationProducts[0].description! ==
    //                       'Recommendation Products'
    //                   ? AppLocalizations.of(context)!
    //                       .translate('description_hap_3')!
    //                   : home.recommendationProducts[0].description!,
    //               style: TextStyle(
    //                 fontSize: responsiveFont(12),
    //                 // color: Colors.black,
    //               ),
    //               textAlign: TextAlign.justify,
    //             )),
    //         //recommendation item
    //         Container(
    //           margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    //           child: GridView.builder(
    //             primary: false,
    //             shrinkWrap: true,
    //             itemCount: home.recommendationProducts[0].products!.length,
    //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //                 crossAxisSpacing: 10,
    //                 mainAxisSpacing: 10,
    //                 crossAxisCount: 2,
    //                 childAspectRatio: 78 / 125),
    //             itemBuilder: (context, i) {
    //               return GridItem(
    //                 i: i,
    //                 itemCount: home.recommendationProducts[0].products!.length,
    //                 product: home.recommendationProducts[0].products![i],
    //               );
    //             },
    //           ),
    //         ),
    //         Container(
    //           height: 15,
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    return ColorfulSafeArea(
      color: primaryColor,
      child: Consumer2<HomeProvider, OrderProvider>(
        builder: (context, value, value2, child) => Scaffold(
          resizeToAvoidBottomInset: false,
          drawer: value.typeHeader != "v1" ? DrawerMain() : null,
          appBar: value.typeHeader != "v1"
              ?AppBar(
            toolbarHeight: 85, // Adjust the height here
            elevation: 0,
            titleSpacing: 0,
            leading: Builder(builder: (context) {
              return GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Icon(
                  size: 50,
                  Icons.menu_outlined ,
                  color: primaryColor,
                ),
              );
            }),
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Container(
              padding: EdgeInsets.only(top: 10), // Add top padding
              width: 180,
              height: 150,
              child: CachedNetworkImage(
                imageUrl: value.logoHeader,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => Icon(Icons.image_not_supported),
                placeholder: (context, url) => Container(),
              ),
            ),
            actions: [
              // v2
              Visibility(
                visible: value.typeHeader == "v2",
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(isFromHome: false),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10, top: 12),
                    height: Scaffold.of(context).appBarMaxHeight,
                    child: Stack(
                      children: [
                        Container(
                          width: 40.w, // Increased width for the logo
                          height: 40.w, // Increased height for the logo
                          child: Image.asset('images/lobby/icon-cart-v2.png'),
                        ),
                        Positioned(
                          bottom: 5, // Adjust this to move the text higher
                          left: 10,
                          child: Text(
                            "${value2.cartCount}",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp), // Use responsive font size
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // v4
              Visibility(
                visible: value.typeHeader == "v4",
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(
                          isFromHome: false,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: 10.h,
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: secondaryColor,
                      ),
                      child: Container(
                        width: 40.w, // Increased width for the logo
                        height: 40.w, // Increased height for the logo
                        child: Image.asset('images/lobby/icon-cart-v4.png'),
                      ),
                    ),
                  ),
                ),
              ),

              // v5
              Visibility(
                visible: value.typeHeader == "v5",
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 40.w, // Increased width for the logo
                    height: 40.w, // Increased height for the logo
                    margin: EdgeInsets.only(right: 10),
                    child: Image.asset("images/lobby/icon-search-v5.png"),
                  ),
                ),
              ),

              // User Icon
              Visibility(
                visible: value.typeHeader == "v5",
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SocmedScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 40.w, // Increased width for the logo
                    height: 40.w, // Increased height for the logo
                    margin: EdgeInsets.only(right: 10),
                    child: Image.asset("images/lobby/icon-user-v5.png"),
                  ),
                ),
              ),

              // Cart for v5
              Visibility(
                visible: value.typeHeader == "v5",
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(
                          isFromHome: false,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 5),
                    height: Scaffold.of(context).appBarMaxHeight,
                    child: Stack(
                      children: [
                        Container(
                          height: Scaffold.of(context).appBarMaxHeight,
                          width: 30,
                        ),
                        Positioned(
                          bottom: 15, // Adjust this as needed
                          right: 0,
                          left: 0,
                          child: Container(
                            width: 40.w, // Increased width for the logo
                            height: 40.w, // Increased height for the logo
                            child: Image.asset('images/lobby/icon-cart-v5.png'),
                          ),
                        ),
                        Positioned(
                          top: 10, // Adjust this to move the cart count higher or lower
                          right: 0,
                          child: Container(
                            height: 15.w,
                            width: 15.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: secondaryColor,
                            ),
                            child: Center(
                              child: Text(
                                "${value2.cartCount}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10.sp), // Use responsive font size
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Notification Icon
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationScreen()),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 15, top: 20),
                      width: 26.w,
                      height: Scaffold.of(context).appBarMaxHeight,
                      child: Icon(
                        size: 50,
                        Icons.notifications,
                        color: primaryColor,
                      ),
                    ),
                    Visibility(
                      visible: notification.isNotEmpty &&
                          Session.data.getBool('isLogin')!,
                      child: Positioned(
                        right: 10,
                        top: 15,
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: HexColor("960000"),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              notification.length > 99
                                  ? "99+"
                                  : notification.length.toString(),
                              style: TextStyle(
                                fontSize: notification.length > 99 ? 6.h : 8.h,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],




          )
              : null,
          body: Stack(
            children: [
              SmartRefresher(
                controller: refreshController,
                scrollController: _scrollController,
                onRefresh: refreshHome,
                child: SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Home Header (incl. AppBar, Banner Slider, etc)
                      // HomeHeader(
                      //   globalKeyTwo: widget.globalKeyTwo,
                      //   globalKeyThree: widget.globalKeyThree,
                      // ),
                      Visibility(
                        visible: value.typeHeader == "v1",
                        child: HomeAppBar(
                          globalKeyTwo: widget.globalKeyTwo,
                          globalKeyThree: widget.globalKeyThree,
                        ),
                      ),
                      Consumer<HomeProvider>(
                        builder: (context, value, child) => Column(
                          children: value.customize,
                        ),
                      ),
                      //chat
                      //         ChatCard(),
                      //         // wallet
                      //         WalletCard(showBtnMore: true),
                      //         // ChatCard(),
                      //         Container(
                      //           height: 15,
                      //         ),
                      //         //category section
                      //         Consumer<HomeProvider>(builder: (context, value, child) {
                      //           return BadgeCategory(
                      //             value.categories,
                      //           );
                      //         }),
                      //         //flash sale countdown & card product item
                      //         Consumer<HomeProvider>(builder: (context, value, child) {
                      //           if (value.flashSales.isEmpty) {
                      //             return Container();
                      //           }
                      //           return FlashSaleCountdown(
                      //             dataFlashSaleCountDown: home.flashSales,
                      //             dataFlashSaleProducts: home.flashSales[0].products,
                      //             textAnimationController: _textAnimationController,
                      //             colorAnimationController: _colorAnimationController,
                      //             colorTween: _colorTween,
                      //             iconColorTween: _iconColorTween,
                      //             moveTween: _moveTween,
                      //             titleColorTween: _titleColorTween,
                      //             loading: home.loading,
                      //           );
                      //         }),
                      //         Container(
                      //           width: double.infinity,
                      //           margin: EdgeInsets.only(
                      //               left: 15, bottom: 10, right: 15, top: 15),
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //             children: [
                      //               Text(
                      //                 AppLocalizations.of(context)!
                      //                     .translate('new_product')!,
                      //                 style: TextStyle(
                      //                     fontSize: responsiveFont(14),
                      //                     fontWeight: FontWeight.w600),
                      //               ),
                      //               GestureDetector(
                      //                 onTap: () {
                      //                   Navigator.push(
                      //                       context,
                      //                       MaterialPageRoute(
                      //                           builder: (context) => BrandProducts(
                      //                                 categoryId: clickIndex == 0
                      //                                     ? ''
                      //                                     : clickIndex.toString(),
                      //                                 brandName: selectedCategory ??
                      //                                     AppLocalizations.of(context)!
                      //                                         .translate('new_product'),
                      //                                 sortIndex: 1,
                      //                               )));
                      //                 },
                      //                 child: Text(
                      //                   AppLocalizations.of(context)!.translate('more')!,
                      //                   style: TextStyle(
                      //                       fontSize: responsiveFont(12),
                      //                       fontWeight: FontWeight.w600,
                      //                       color: secondaryColor),
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //         // Consumer<CategoryProvider>(
                      //         //     builder: (context, value, child) {
                      //         //   if (value.loadingProductCategories) {
                      //         //     return Container(
                      //         //       margin: EdgeInsets.only(left: 15),
                      //         //       height: MediaQuery.of(context).size.height / 21,
                      //         //       child: ListView.separated(
                      //         //         itemCount: 6,
                      //         //         scrollDirection: Axis.horizontal,
                      //         //         itemBuilder: (context, i) {
                      //         //           return Shimmer.fromColors(
                      //         //             child: Container(
                      //         //               color: Colors.white,
                      //         //               height: 25,
                      //         //               width: 100,
                      //         //             ),
                      //         //             baseColor: Colors.grey[300]!,
                      //         //             highlightColor: Colors.grey[100]!,
                      //         //           );
                      //         //         },
                      //         //         separatorBuilder:
                      //         //             (BuildContext context, int index) {
                      //         //           return SizedBox(
                      //         //             width: 5,
                      //         //           );
                      //         //         },
                      //         //       ),
                      //         //     );
                      //         //   } else {
                      //         //     return Container(
                      //         //       height: MediaQuery.of(context).size.height / 21,
                      //         //       child: ListView.separated(
                      //         //           itemCount: value.productCategories.length,
                      //         //           scrollDirection: Axis.horizontal,
                      //         //           itemBuilder: (context, i) {
                      //         //             return GestureDetector(
                      //         //                 onTap: () {
                      //         //                   if (value.productCategories[i].id ==
                      //         //                       clickIndex) {
                      //         //                     setState(() {
                      //         //                       clickIndex = 0;
                      //         //                       selectedCategory =
                      //         //                           AppLocalizations.of(context)!
                      //         //                               .translate('new_product');
                      //         //                     });
                      //         //                     print("masuk if");
                      //         //                   } else {
                      //         //                     setState(() {
                      //         //                       clickIndex =
                      //         //                           value.productCategories[i].id;
                      //         //                       selectedCategory =
                      //         //                           value.productCategories[i].name;
                      //         //                     });
                      //         //                     print("masuk else");
                      //         //                   }
                      //         //                   loadNewProduct(true);
                      //         //                   setState(() {});
                      //         //                 },
                      //         //                 child: tabCategory(
                      //         //                     value.productCategories[i],
                      //         //                     i,
                      //         //                     value.productCategories.length));
                      //         //           },
                      //         //           separatorBuilder:
                      //         //               (BuildContext context, int index) {
                      //         //             return SizedBox(
                      //         //               width: 8,
                      //         //             );
                      //         //           }),
                      //         //     );
                      //         //   }
                      //         // }),

                      //         Consumer<HomeProvider>(builder: (context, value, child) {
                      //           if (value.loading) {
                      //             return Container(
                      //               margin: EdgeInsets.only(left: 15),
                      //               height: MediaQuery.of(context).size.height / 21,
                      //               child: ListView.separated(
                      //                 itemCount: 6,
                      //                 scrollDirection: Axis.horizontal,
                      //                 itemBuilder: (context, i) {
                      //                   return Shimmer.fromColors(
                      //                     child: Container(
                      //                       color: Colors.white,
                      //                       height: 25,
                      //                       width: 100,
                      //                     ),
                      //                     baseColor: Colors.grey[300]!,
                      //                     highlightColor: Colors.grey[100]!,
                      //                   );
                      //                 },
                      //                 separatorBuilder:
                      //                     (BuildContext context, int index) {
                      //                   return SizedBox(
                      //                     width: 5,
                      //                   );
                      //                 },
                      //               ),
                      //             );
                      //           } else {
                      //             return Container(
                      //               height: MediaQuery.of(context).size.height / 21,
                      //               child: ListView.separated(
                      //                   itemCount: value.productCategories.length,
                      //                   scrollDirection: Axis.horizontal,
                      //                   itemBuilder: (context, i) {
                      //                     return GestureDetector(
                      //                         onTap: () {
                      //                           if (value.productCategories[i].id ==
                      //                               clickIndex) {
                      //                             setState(() {
                      //                               clickIndex = 0;
                      //                               selectedCategory =
                      //                                   AppLocalizations.of(context)!
                      //                                       .translate('new_product');
                      //                             });
                      //                             print("masuk if");
                      //                           } else {
                      //                             setState(() {
                      //                               clickIndex =
                      //                                   value.productCategories[i].id;
                      //                               selectedCategory =
                      //                                   value.productCategories[i].name;
                      //                             });
                      //                             print("masuk else");
                      //                           }
                      //                           loadNewProduct(true);
                      //                           setState(() {});
                      //                         },
                      //                         child: tabCategory(
                      //                             value.productCategories[i],
                      //                             i,
                      //                             value.productCategories.length));
                      //                   },
                      //                   separatorBuilder:
                      //                       (BuildContext context, int index) {
                      //                     return SizedBox(
                      //                       width: 8,
                      //                     );
                      //                   }),
                      //             );
                      //           }
                      //         }),

                      //         Container(
                      //           height: 10,
                      //         ),
                      //         clickIndex == 0
                      //             ? buildNewProducts
                      //             : buildNewProductsClicked,
                      //         Container(
                      //           height: 15,
                      //         ),
                      //         Visibility(
                      //           visible: showBannerSpecial,
                      //           child: Container(
                      //             margin: EdgeInsets.symmetric(horizontal: 15),
                      //             child: Text(
                      //               AppLocalizations.of(context)!.translate('banner_1')!,
                      //               style: TextStyle(
                      //                   fontSize: responsiveFont(14),
                      //                   fontWeight: FontWeight.w600),
                      //             ),
                      //           ),
                      //         ),
                      //         //Mini Banner Item start Here
                      //         // buildMiniBanner,
                      //         Visibility(
                      //           visible: showBannerSpecial,
                      //           child: ListenableProvider.value(
                      //             value:
                      //                 Provider.of<HomeProvider>(context, listen: false),
                      //             child: Consumer<HomeProvider>(
                      //               builder: (context, value, child) {
                      //                 return BannerMini(
                      //                   typeBanner: 'special',
                      //                   bannerLove: value.bannerLove,
                      //                   bannerSpecial: value.bannerSpecial,
                      //                 );
                      //               },
                      //             ),
                      //           ),
                      //         ),

                      //         //special for you item
                      //         Consumer<HomeProvider>(builder: (context, value, child) {
                      //           return Visibility(
                      //             visible: value.specialProducts[0].products!.length > 0,
                      //             child: Column(
                      //               children: [
                      //                 Container(
                      //                     width: double.infinity,
                      //                     margin: EdgeInsets.only(
                      //                         left: 15, bottom: 10, right: 15),
                      //                     child: Column(
                      //                       crossAxisAlignment: CrossAxisAlignment.start,
                      //                       children: [
                      //                         Row(
                      //                           mainAxisAlignment:
                      //                               MainAxisAlignment.spaceBetween,
                      //                           children: [
                      //                             Expanded(
                      //                                 child: Text(
                      //                               value.specialProducts[0].title! ==
                      //                                       'Special Promo : App Only'
                      //                                   ? AppLocalizations.of(context)!
                      //                                       .translate('title_hap_1')!
                      //                                   : value.specialProducts[0].title!,
                      //                               style: TextStyle(
                      //                                   fontSize: responsiveFont(14),
                      //                                   fontWeight: FontWeight.w600),
                      //                             )),
                      //                             GestureDetector(
                      //                               onTap: () {
                      //                                 Navigator.push(
                      //                                     context,
                      //                                     MaterialPageRoute(
                      //                                         builder:
                      //                                             (context) =>
                      //                                                 ProductMoreScreen(
                      //                                                   include: products
                      //                                                       .productSpecial
                      //                                                       .products,
                      //                                                   name: value
                      //                                                               .specialProducts[
                      //                                                                   0]
                      //                                                               .title! ==
                      //                                                           'Special Promo : App Only'
                      //                                                       ? AppLocalizations.of(
                      //                                                               context)!
                      //                                                           .translate(
                      //                                                               'title_hap_1')!
                      //                                                       : value
                      //                                                           .specialProducts[
                      //                                                               0]
                      //                                                           .title!,
                      //                                                 )));
                      //                               },
                      //                               child: Text(
                      //                                 AppLocalizations.of(context)!
                      //                                     .translate('more')!,
                      //                                 style: TextStyle(
                      //                                     fontSize: responsiveFont(12),
                      //                                     fontWeight: FontWeight.w600,
                      //                                     color: secondaryColor),
                      //                               ),
                      //                             ),
                      //                           ],
                      //                         ),
                      //                         Text(
                      //                           value.specialProducts[0].description ==
                      //                                   null
                      //                               ? ''
                      //                               : value.specialProducts[0]
                      //                                           .description! ==
                      //                                       'For You'
                      //                                   ? AppLocalizations.of(context)!
                      //                                       .translate(
                      //                                           'description_hap_1')!
                      //                                   : value.specialProducts[0]
                      //                                       .description!,
                      //                           style: TextStyle(
                      //                             fontSize: responsiveFont(12),
                      //                             // color: Colors.black,
                      //                           ),
                      //                           textAlign: TextAlign.justify,
                      //                         )
                      //                       ],
                      //                     )),
                      //                 AspectRatio(
                      //                   aspectRatio: 3 / 2,
                      //                   child: value.loading
                      //                       ? shimmerProductItemSmall()
                      //                       : ListView.separated(
                      //                           itemCount: value
                      //                               .specialProducts[0].products!.length,
                      //                           scrollDirection: Axis.horizontal,
                      //                           itemBuilder: (context, i) {
                      //                             return CardItem(
                      //                               product: value
                      //                                   .specialProducts[0].products![i],
                      //                               i: i,
                      //                               itemCount: value.specialProducts[0]
                      //                                   .products!.length,
                      //                             );
                      //                           },
                      //                           separatorBuilder:
                      //                               (BuildContext context, int index) {
                      //                             return SizedBox(
                      //                               width: 5,
                      //                             );
                      //                           },
                      //                         ),
                      //                 ),
                      //               ],
                      //             ),
                      //           );
                      //         }),
                      //         Container(
                      //           height: 10,
                      //         ),
                      //         Visibility(
                      //           visible: Provider.of<HomeProvider>(context, listen: false)
                      //                   .bestProducts[0]
                      //                   .products!
                      //                   .length >
                      //               0,
                      //           child: Stack(
                      //             children: [
                      //               Container(
                      //                 color: primaryColor,
                      //                 width: double.infinity,
                      //                 height: MediaQuery.of(context).size.height / 3.5,
                      //               ),
                      //               Consumer<HomeProvider>(
                      //                   builder: (context, value, child) {
                      //                 if (value.loading) {
                      //                   return Column(
                      //                     children: [
                      //                       Shimmer.fromColors(
                      //                           child: Container(
                      //                             width: double.infinity,
                      //                             margin: EdgeInsets.only(
                      //                                 left: 15, right: 15, top: 10),
                      //                             child: Column(
                      //                               crossAxisAlignment:
                      //                                   CrossAxisAlignment.start,
                      //                               children: [
                      //                                 Row(
                      //                                   mainAxisAlignment:
                      //                                       MainAxisAlignment
                      //                                           .spaceBetween,
                      //                                   children: [
                      //                                     Container(
                      //                                       width: 150,
                      //                                       height: 10,
                      //                                       color: Colors.white,
                      //                                     )
                      //                                   ],
                      //                                 ),
                      //                                 Container(
                      //                                   height: 2,
                      //                                 ),
                      //                                 Container(
                      //                                   width: 100,
                      //                                   height: 8,
                      //                                   color: Colors.white,
                      //                                 )
                      //                               ],
                      //                             ),
                      //                           ),
                      //                           baseColor: Colors.grey[300]!,
                      //                           highlightColor: Colors.grey[100]!),
                      //                       Container(
                      //                         height: 10,
                      //                       ),
                      //                       Container(
                      //                         height: MediaQuery.of(context).size.height /
                      //                             3.0,
                      //                         child: shimmerProductItemSmall(),
                      //                       )
                      //                     ],
                      //                   );
                      //                 }
                      //                 return Column(
                      //                   children: [
                      //                     Container(
                      //                       width: double.infinity,
                      //                       margin: EdgeInsets.only(
                      //                           left: 15, right: 15, top: 10),
                      //                       child: Column(
                      //                         crossAxisAlignment:
                      //                             CrossAxisAlignment.start,
                      //                         children: [
                      //                           Row(
                      //                             mainAxisAlignment:
                      //                                 MainAxisAlignment.spaceBetween,
                      //                             children: [
                      //                               Expanded(
                      //                                   child: Text(
                      //                                 value.bestProducts[0].title! ==
                      //                                         'Best Seller'
                      //                                     ? AppLocalizations.of(context)!
                      //                                         .translate('title_hap_2')!
                      //                                     : value.bestProducts[0].title!,
                      //                                 style: TextStyle(
                      //                                     color: Colors.white,
                      //                                     fontSize: responsiveFont(14),
                      //                                     fontWeight: FontWeight.w600),
                      //                               )),
                      //                               GestureDetector(
                      //                                 onTap: () {
                      //                                   Navigator.push(
                      //                                       context,
                      //                                       MaterialPageRoute(
                      //                                           builder: (context) =>
                      //                                               ProductMoreScreen(
                      //                                                 name: value
                      //                                                             .bestProducts[
                      //                                                                 0]
                      //                                                             .title! ==
                      //                                                         'Best Seller'
                      //                                                     ? AppLocalizations.of(
                      //                                                             context)!
                      //                                                         .translate(
                      //                                                             'title_hap_2')!
                      //                                                     : value
                      //                                                         .bestProducts[
                      //                                                             0]
                      //                                                         .title!,
                      //                                                 include: products
                      //                                                     .productBest
                      //                                                     .products,
                      //                                               )));
                      //                                 },
                      //                                 child: Text(
                      //                                   AppLocalizations.of(context)!
                      //                                       .translate('more')!,
                      //                                   style: TextStyle(
                      //                                       fontSize: responsiveFont(12),
                      //                                       fontWeight: FontWeight.w600,
                      //                                       color: Colors.white),
                      //                                 ),
                      //                               ),
                      //                             ],
                      //                           ),
                      //                           Text(
                      //                             value.bestProducts[0].description ==
                      //                                     null
                      //                                 ? ''
                      //                                 : value.bestProducts[0]
                      //                                             .description! ==
                      //                                         'Get The Best Products'
                      //                                     ? AppLocalizations.of(context)!
                      //                                         .translate(
                      //                                             'description_hap_2')!
                      //                                     : value.bestProducts[0]
                      //                                         .description!,
                      //                             style: TextStyle(
                      //                               fontSize: responsiveFont(12),
                      //                               color: Colors.white,
                      //                             ),
                      //                             textAlign: TextAlign.justify,
                      //                           )
                      //                         ],
                      //                       ),
                      //                     ),
                      //                     Container(
                      //                       height: 10,
                      //                     ),
                      //                     ProductContainer(
                      //                       products: value.bestProducts[0].products!,
                      //                     )
                      //                   ],
                      //                 );
                      //               }),
                      //             ],
                      //           ),
                      //         ),
                      //         Visibility(
                      //           visible: showBannerLove,
                      //           child: Container(
                      //             margin: EdgeInsets.only(
                      //                 left: 15, right: 15, top: 15, bottom: 10),
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 Text(
                      //                   AppLocalizations.of(context)!
                      //                       .translate('banner_2')!,
                      //                   style: TextStyle(
                      //                       fontSize: responsiveFont(14),
                      //                       fontWeight: FontWeight.w600),
                      //                 ),
                      //                 /*GestureDetector(
                      //                   onTap: () {
                      //                     Navigator.push(
                      //                         context,
                      //                         MaterialPageRoute(
                      //                             builder: (context) => AllProducts()));
                      //                   },
                      //                   child: Text(
                      //                     "More",
                      //                     style: TextStyle(
                      //                         fontSize: responsiveFont(12),
                      //                         fontWeight: FontWeight.w600,
                      //                         color: secondaryColor),
                      //                   ),
                      //                 ),*/
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         //Mini Banner Item start Here
                      //         Visibility(
                      //           visible: showBannerLove,
                      //           child: Consumer<HomeProvider>(
                      //             builder: (context, value, child) {
                      //               return BannerMini(
                      //                 typeBanner: 'love',
                      //                 bannerLove: value.bannerLove,
                      //                 bannerSpecial: value.bannerSpecial,
                      //               );
                      //             },
                      //           ),
                      //         ),

                      //         //recently viewed item
                      //         buildRecentProducts,
                      //         Container(
                      //           height: 15,
                      //         ),

                      //         buildRecommendation,

                      //         Container(
                      //           width: double.infinity,
                      //           height: 7,
                      //           color: isDarkMode ? Colors.black12 : HexColor("EEEEEE"),
                      //         ),
                      //         bestDealProduct()
                    ],
                  ),
                ),
              ),
              Visibility(
                  visible: coupons.coupons.isNotEmpty && home.isGiftActive,
                  child: DraggableWidget(
                    bottomMargin: 120,
                    topMargin: 60,
                    intialVisibility: true,
                    horizontalSpace: 3,
                    verticalSpace: 30,
                    normalShadow: BoxShadow(
                      color: Colors.transparent,
                      offset: Offset(0, 10),
                      blurRadius: 0,
                    ),
                    shadowBorderRadius: 50,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CouponScreen()));
                        },
                        child: Container(
                            height: 100,
                            width: 100,
                            child:
                                Image.asset("images/lobby/gift-coupon.gif"))),
                    initialPosition: AnchoringPosition.bottomRight,
                    dragController: dragController,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabCategory(ProductCategoryModel model, int i, int count) {
    final locale = Provider.of<AppNotifier>(context, listen: false).appLocal;
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;
    return Container(
      margin: EdgeInsets.only(
          left: locale == Locale('ar')
              ? i == count - 1
                  ? 15
                  : 0
              : i == 0
                  ? 15
                  : 0,
          right: locale == Locale('ar')
              ? i == 0
                  ? 15
                  : 0
              : i == count - 1
                  ? 15
                  : 0),
      child: Tab(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: clickIndex == model.id
                  ? primaryColor.withOpacity(0.3)
                  : isDarkMode
                      ? Colors.grey
                      : Colors.white,
              border: Border.all(
                  color: clickIndex == model.id
                      ? secondaryColor
                      : HexColor("B0b0b0")),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              convertHtmlUnescape(model.name!),
              style: TextStyle(
                  fontSize: 13,
                  color: clickIndex == model.id
                      ? isDarkMode
                          ? Colors.white
                          : secondaryColor
                      : null),
            )),
      ),
    );
  }

  Widget bestDealProduct() {
    final product = Provider.of<ProductProvider>(context, listen: false);

    return ListenableProvider.value(
        value: product,
        child: Consumer<ProductProvider>(builder: (context, value, child) {
          if (value.loadingBestDeals && page == 1) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                      childAspectRatio: 78 / 125),
                  itemBuilder: (context, i) {
                    return GridItemShimmer();
                  }),
            );
          }
          return Visibility(
              visible: value.listBestDeal.isNotEmpty,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(
                        left: 15, bottom: 10, right: 15, top: 10),
                    child: Text(
                      AppLocalizations.of(context)!.translate('best_deals')!,
                      style: TextStyle(
                          fontSize: responsiveFont(14),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: value.listBestDeal.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 2,
                            childAspectRatio: 78 / 125),
                        itemBuilder: (context, i) {
                          return GridItem(
                            i: i,
                            itemCount: value.listBestDeal.length,
                            product: value.listBestDeal[i],
                          );
                        }),
                  ),
                  if (value.loadingBestDeals && page != 1) customLoading()
                ],
              ));
        }));
  }
}
