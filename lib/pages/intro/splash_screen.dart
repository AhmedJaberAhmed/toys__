import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/models/checkout_guest_model.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/pages/intro/select_language_screen.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/provider/general_settings_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/provider/wallet_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/custom_page_route.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final Future Function()? onLinkClicked;

  SplashScreen({Key? key, this.onLinkClicked}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool loadHomeSuccess = true;
  bool isHaveInternetConnection = false;
  String? _versionName;

  Future startSplashScreen() async {
    final home = Provider.of<HomeProvider>(context, listen: false);
    FlutterNativeSplash.remove();

    // Set the splash duration as needed
    var duration = const Duration(milliseconds: 9000);
    navigateScreen(duration);
  }

  Future navigateScreen(Duration duration) async {
    final home = Provider.of<HomeProvider>(context, listen: false);

    return Timer(duration, () {
      if (!Session.data.containsKey('big_update')) {
        Session.data.setBool('big_update', false);
      }

      if (home.introStatus == 'show') {
        if (!Session.data.containsKey('tool_tip')) {
          Session.data.setBool('tool_tip', true);
        }
        if (home.toolTip) {
          Session.data.setBool('tool_tip', true);
        }

        if (!Session.data.containsKey('isIntro')) {
          Session.data.setBool('isLogin', false);
          Session.data.setBool('isIntro', true);
          Navigator.push(context, MaterialPageRoute(builder: (context) => SelectLanguageScreen()));
        } else {
          Navigator.of(context).pushReplacement(
            CustomPageRoute(direction: AxisDirection.left, child: HomeScreen()),
          );
        }
      } else {
        if (!Session.data.containsKey('tool_tip')) {
          Session.data.setBool('tool_tip', true);
        }
        if (home.toolTip) {
          Session.data.setBool('tool_tip', true);
        }
        if (!Session.data.containsKey('isIntro')) {
          Session.data.setBool('isLogin', false);
          Session.data.setBool('isIntro', true);
          Navigator.of(context).pushReplacement(
            CustomPageRoute(direction: AxisDirection.left, child: SelectLanguageScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            CustomPageRoute(direction: AxisDirection.left, child: HomeScreen()),
          );
        }
      }

      if (widget.onLinkClicked != null) {
        widget.onLinkClicked!();
      }
    });
  }

  Future _init() async {
    final _packageInfo = await PackageInfo.fromPlatform();
    context.read<HomeProvider>().setPackageInfo(_packageInfo);
    return _packageInfo.version;
  }

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    loadHome();
    loadWallet();
    loadUnreadMessage();
    startSplashScreen(); // Start splash screen on initialization
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  checkInternetConnection() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        isHaveInternetConnection = result != ConnectivityResult.none;
      });
    });
  }

  loadUnreadMessage() async {
    if (Provider.of<HomeProvider>(context, listen: false).isChatActive &&
        (Session.data.getBool('isLogin') ?? false)) {
      await Provider.of<ChatProvider>(context, listen: false).checkUnreadMessage();
    }
  }

  loadWallet() async {
    if (Session.data.getBool('isLogin') ?? false) {
      await Provider.of<WalletProvider>(context, listen: false).fetchBalance();
      await Provider.of<UserProvider>(context, listen: false).fetchUserDetail();
    }
  }

  loadHome() async {
    if (!Session.data.containsKey('currency_code')) {
      Session.data.setString('currency_code', "USD");
    }

    await Provider.of<HomeProvider>(context, listen: false).fetchHome(context).then((value) async {
      if (Provider.of<HomeProvider>(context, listen: false).activateCurrency) {
        await Provider.of<GeneralSettingsProvider>(context, listen: false).loadAllCurrency(context);
      }

      if (!Session.data.containsKey('order_guest')) {
        List<CheckoutGuest> listOrder = [];
        Session.data.setString('order_guest', json.encode(listOrder));
      }

      final appColors = Provider.of<HomeProvider>(context, listen: false).appColors;
      setState(() {
        loadHomeSuccess = value ?? true;
      });

      appColors.forEach((element) {
        setState(() {
          if (element.title == 'primary') {
            primaryColor = HexColor(element.description!);
          } else if (element.title == 'secondary') {
            secondaryColor = HexColor(element.description!);
          } else if (element.title == 'button_color') {
            buttonColor = HexColor(element.description!);
          } else {
            textButtonColor = HexColor(element.description!);
          }
        });
      });

      if (loadHomeSuccess && mounted) await startSplashScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = Provider.of<HomeProvider>(context, listen: false);

    return Scaffold(
      body: isHaveInternetConnection
          ? buildNoConnection(context)
          : home.loading
          ? Container()
          : home.isLoadHomeSuccess!
          ? imageSplashScreen() // Call image splash screen method
          : buildError(context),
    );
  }

  Widget imageSplashScreen() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, // Set the background color to white
      ),
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
        children: [
          Center( // Center the GIF image
            child: Image.asset(
              'images/order/ggg.gif',
              fit: BoxFit.fill,
            ),
          ),
          FutureBuilder(
            future: _init(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _versionName = snapshot.data as String?;
                return Text(
                  'Version $_versionName',
                  style: const TextStyle(color: Colors.grey),
                );
              }
              return Container();
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

  }

  Widget buildError(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(25),
        child: const Text('Error loading home content. Please try again later.'),
      ),
    );
  }

  Widget buildNoConnection(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(25),
        child: const Text('No internet connection.'),
      ),
    );
  }
}