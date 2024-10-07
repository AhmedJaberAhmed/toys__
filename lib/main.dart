import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
// import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/deeplink/deeplink_config.dart';
import 'package:nyoba/pages/chat/chat_page.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/pages/notification/notification_screen.dart';
import 'package:nyoba/provider/affiliate_provider.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/blog_provider.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/provider/checkout_provider.dart';
import 'package:nyoba/provider/coupon_provider.dart';
import 'package:nyoba/provider/flash_sale_provider.dart';
import 'package:nyoba/provider/general_settings_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/login_provider.dart';
import 'package:nyoba/provider/membership_provider.dart';
import 'package:nyoba/provider/notification_provider.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/provider/register_provider.dart';
import 'package:nyoba/provider/review_provider.dart';
import 'package:nyoba/provider/search_provider.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/provider/video_provider.dart';
import 'package:nyoba/provider/wallet_provider.dart';
import 'package:nyoba/provider/wishlist_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/global_variable.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nyoba/provider/banner_provider.dart';
import 'package:nyoba/provider/category_provider.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';


Future<void> _messageHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  await Firebase.initializeApp();
  await Session.initLocalStorage();

  if (Session.data.getInt('unread_notification') != null) {
    printLog("masuk if notif session");
    FlutterAppBadger.updateBadgeCount(
        Session.data.getInt('unread_notification')!);
  } else {
    printLog("masuk if notif session null");
    FlutterAppBadger.updateBadgeCount(1);
  }

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String initialRoute = "Initial Route";
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse!.payload;
    initialRoute = "Initial Route : $selectedNotificationPayload";
    print(initialRoute);
  }
  printLog('Background Message Exists');
  debugPrint("Notif Body ${message.notification!.body}");
  debugPrint("Notif Title ${message.notification!.title}");
  debugPrint("Notif Data ${message.data}");
  RemoteNotification? notification = message.notification;
  AppleNotification? apple = message.notification?.apple;
  AndroidNotification? android = message.notification?.android;

  var _imageUrl = '';

  print(android);

  if (Platform.isAndroid && android != null) {
    if (android.imageUrl != null) {
      _imageUrl = android.imageUrl!;
    }
  } else if (Platform.isIOS && apple != null) {
    if (apple.imageUrl != null) {
      _imageUrl = apple.imageUrl!;
    }
  }
  // if (notification != null) {
  //   await Session.savePushNotificationData(
  //       image: _imageUrl,
  //       description: notification.body,
  //       title: notification.title,
  //       payload: json.encode(message.data));
  // }
}

RemoteMessage? initialMessage;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  // Initialize Firebase and session
  await Firebase.initializeApp();
  await Session.initLocalStorage();
  await Session.init();

  // Set display mode for Android
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
    final activeMode = await FlutterDisplayMode.active;
    printLog(activeMode.refreshRate.toString());
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  // Subscribe to Firebase topic
  FirebaseMessaging.instance.subscribeToTopic('news');

  // Initialize app language settings
  final AppNotifier appLanguage = AppNotifier();
  await appLanguage.fetchLocale();

  // Handle notification app launch details
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb && Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  String initialRoute = "Initial Route";
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.notificationResponse!.payload;
    initialRoute = "Initial Route : $selectedNotificationPayload";
    print(initialRoute);
  }

  // Set up Firebase messaging handlers
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      final notification = message.notification;
      final imageUrl = Platform.isAndroid ? message.notification?.android?.imageUrl : message.notification?.apple?.imageUrl;

      print("Notif Data Initial Message ${message.data}");
      Session.data.setString("dataNotif", jsonEncode(message.data));
      print("${Session.data.getString("dataNotif")}, ini data notif di init message");
    }
  });

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Run the app
  runApp(
    Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => BannerProvider()),
          ChangeNotifierProvider(create: (context) => CategoryProvider()),
          ChangeNotifierProvider(create: (context) => FlashSaleProvider()),
          ChangeNotifierProvider(create: (context) => BlogProvider()),
          ChangeNotifierProvider(create: (context) => LoginProvider()),
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => ProductProvider()),
          ChangeNotifierProvider(create: (context) => GeneralSettingsProvider()),
          ChangeNotifierProvider(create: (context) => RegisterProvider()),
          ChangeNotifierProvider(create: (context) => WishlistProvider()),
          ChangeNotifierProvider(create: (context) => SearchProvider()),
          ChangeNotifierProvider(create: (context) => OrderProvider()),
          ChangeNotifierProvider(create: (context) => CouponProvider()),
          ChangeNotifierProvider(create: (context) => ReviewProvider()),
          ChangeNotifierProvider(create: (context) => NotificationProvider()),
          ChangeNotifierProvider(create: (context) => appLanguage),
          ChangeNotifierProvider(create: (context) => HomeProvider()),
          ChangeNotifierProvider(create: (context) => WalletProvider()),
          ChangeNotifierProvider(create: (context) => ChatProvider()),
          ChangeNotifierProvider(create: (context) => CheckoutProvider()),
          ChangeNotifierProvider(create: (context) => AffiliateProvider()),
          ChangeNotifierProvider(create: (context) => MembershipProvider()),
          ChangeNotifierProvider(create: (context) => VideoProvider()),
        ],
        child: MyApp(
          appLanguage: appLanguage,
          notificationAppLaunchDetails: notificationAppLaunchDetails,
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  final AppNotifier? appLanguage;

  MyApp({Key? key, this.appLanguage, this.notificationAppLaunchDetails})
      : super(key: key);
  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  bool isHaveInternetConnection = true;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    // checkBadger();
    requestNotificationPermissions();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    _handleIncomingLinks();
  }

  Future<void> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      // Android-specific code
      final PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        // Notification permissions granted
      } else if (status.isDenied) {
        // Notification permissions denied
      } else if (status.isPermanentlyDenied) {
        // Notification permissions permanently denied, open app settings
        await openAppSettings();
      }
    }
  }

  checkBadger() async {
    var appBadgeSupported;
    try {
      bool res = await FlutterAppBadger.isAppBadgeSupported();
      if (res) {
        appBadgeSupported = 'Supported';
      } else {
        appBadgeSupported = 'Not supported';
      }
    } on PlatformException {
      appBadgeSupported = 'Failed to get badge support.';
    }
    printLog(appBadgeSupported.toString(), name: "IS SUPPORTED");
  }

  checkInternetConnection() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!
      setState(() {
        if (result == ConnectivityResult.none)
          isHaveInternetConnection = false;
        else
          isHaveInternetConnection = true;
      });
    });
    // InternetConnectionChecker().onStatusChange.listen(
    //   (event) {
    //     final hasInternet = event == InternetConnectionStatus.connected;

    //     setState(() {
    //       this.isHaveInternetConnection = hasInternet;
    //     });
    //     if (!isHaveInternetConnection) {
    //       FlutterNativeSplash.remove();
    //     }
    //   },
    // );
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                /*await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        SecondPage(receivedNotification.payload),
                  ),
                );*/
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      debugPrint("Payload : $payload");
      var _payload = json.decode(payload!);
      if (_payload['type'] == 'order') {
        await Navigator.of(GlobalVariable.navState.currentContext!).push(
            MaterialPageRoute(builder: (context) => NotificationScreen()));
      } else if (_payload['type'] == 'chat') {
        await Navigator.of(GlobalVariable.navState.currentContext!)
            .push(MaterialPageRoute(builder: (context) => ChatPage()));
      } else {
        print("Else");
        Uri uri = Uri.parse(_payload['click_action']);
        DeeplinkConfig().pathUrl(uri, context, false,
            id: int.parse(_payload['id'].toString()),
            type: _payload['type'].toString(),
            fromNotif: true);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print('Reload onMessageOpenedApp!');
      debugPrint('Message Open Click ' + message.data.toString());
      debugPrint('All Message ' + message.toString());

      printLog(message.data['type'], name: "Notif type");

      if (message.data['type'] == 'order') {
        Navigator.of(GlobalVariable.navState.currentContext!).push(
            MaterialPageRoute(builder: (context) => NotificationScreen()));
      } else if (message.data['type'] == 'chat') {
        Navigator.of(GlobalVariable.navState.currentContext!)
            .push(MaterialPageRoute(builder: (context) => ChatPage()));
      } else {
        print("Else");
        var dataId = int.parse(message.data['id'].toString());
        var dataType = message.data['type'];
        Uri uri = Uri.parse(message.data['click_action']);
        DeeplinkConfig().pathUrl(uri, context, false,
            id: dataId, type: dataType, fromNotif: true);
      }
    });
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      _sub = AppLinks().allUriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('Uri: $uri');
        DeeplinkConfig().pathUrl(uri!, context, false);
      }, onError: (Object err) {
        if (!mounted) return;
        print('Error: $err');
      });
    }
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return ChangeNotifierProvider<AppNotifier?>(
            create: (_) => widget.appLanguage, child: child);
      },
      child: Consumer<AppNotifier>(
        builder: (context, value, _) => MaterialApp(
          navigatorKey: GlobalVariable.navState,
          debugShowCheckedModeBanner: false,
          locale: value.appLocal,
          title: 'Baby Best Toys',
          routes: <String, WidgetBuilder>{
            'HomeScreen': (BuildContext context) => HomeScreen(),
          },
          theme: value.getTheme(),
          supportedLocales: [
            Locale('en', 'US'),
            Locale('id', ''),
            Locale('es', ''),
            Locale('fr', ''),
            Locale('zh', ''),
            Locale('ja', ''),
            Locale('ko', ''),
            Locale('ar', ''),
            Locale('te', ''),
            Locale("af"),
            Locale("am"),
            Locale("ar"),
            Locale("az"),
            Locale("be"),
            Locale("bg"),
            Locale("bn"),
            Locale("bs"),
            Locale("ca"),
            Locale("cs"),
            Locale("da"),
            Locale("de"),
            Locale("el"),
            Locale("en"),
            Locale("es"),
            Locale("et"),
            Locale("fa"),
            Locale("fi"),
            Locale("fr"),
            Locale("gl"),
            Locale("ha"),
            Locale("he"),
            Locale("hi"),
            Locale("hr"),
            Locale("hu"),
            Locale("hy"),
            // Locale("id"),
            Locale("is"),
            Locale("it"),
            Locale("ja"),
            Locale("ka"),
            Locale("kk"),
            Locale("km"),
            Locale("ko"),
            Locale("ku"),
            Locale("ky"),
            Locale("lt"),
            Locale("lv"),
            Locale("mk"),
            Locale("ml"),
            Locale("mn"),
            Locale("ms"),
            Locale("nb"),
            Locale("nl"),
            Locale("nn"),
            Locale("no"),
            Locale("pl"),
            Locale("ps"),
            Locale("pt"),
            Locale("ro"),
            Locale("ru"),
            Locale("sd"),
            Locale("sk"),
            Locale("sl"),
            Locale("so"),
            Locale("sq"),
            Locale("sr"),
            Locale("sv"),
            Locale("ta"),
            Locale("te"),
            Locale("tg"),
            Locale("th"),
            Locale("tk"),
            Locale("tr"),
            Locale("tt"),
            Locale("uk"),
            Locale("ug"),
            Locale("ur"),
            Locale("uz"),
            Locale("vi"),
            Locale("zh")
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            CountryLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              return FutureBuilder(
                  future: DeeplinkConfig().initUniLinks(context),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    if (!isHaveInternetConnection) {
                      return Scaffold(
                        body: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .translate('no_internet_connection')!,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return snapshot.data as Widget;
                  });
            },
          ),
        ),
      ),
    );
  }
}
