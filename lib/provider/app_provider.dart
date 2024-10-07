import 'package:flutter/material.dart';
import 'package:nyoba/app_theme/storage_manager.dart';
import 'package:nyoba/provider/flash_sale_provider.dart';
import 'package:nyoba/provider/general_settings_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotifier extends ChangeNotifier {
  Locale _appLocale = Locale('ar');
  bool isDarkMode = false;
  bool isLoading = false;

  int? selectedLocaleIndex = 0;

  Locale get appLocal => _appLocale;

  ThemeData? _themeData;
  ThemeData? getTheme() => _themeData;

  AppNotifier() {
    StorageManager.readData('themeMode').then((value) {
      print('value read from storage: ' + value.toString());
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
        isDarkMode = false;
      } else {
        print('setting dark theme');
        _themeData = darkTheme;
        isDarkMode = true;
      }
      notifyListeners();
    });
  }

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('ar');
      prefs.setString('language_code', 'ar');
      return Null;
    }
    if (prefs.getInt('localeIndex') == null) {
      selectedLocaleIndex = 0;
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code')!);
    selectedLocaleIndex = prefs.getInt('localeIndex');
    print(_appLocale);
    return Null;
  }

  void changeLanguage(Locale type, BuildContext context) async {
    isLoading = true;
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == Locale("ar")) {
      _appLocale = Locale("ar");
      selectedLocaleIndex = 0;
      await prefs.setString('language_code', 'ar');
      await prefs.setString('countryCode', '');
    } else {
      _appLocale = Locale("en");
      selectedLocaleIndex = 1;
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
    }
    await prefs.setInt('localeIndex', selectedLocaleIndex!);
    print(type);
    await Provider.of<HomeProvider>(context, listen: false)
        .fetchHome(context)
        .then((value) async {
      if (Provider.of<HomeProvider>(context, listen: false).activateCurrency) {
        printLog("=== masuk if ===");
        await Provider.of<GeneralSettingsProvider>(context, listen: false)
            .loadAllCurrency(context);
      }
      context.read<FlashSaleProvider>().flashSaleProducts.clear();
      context.read<FlashSaleProvider>().flashSales.clear();
      await context.read<FlashSaleProvider>().fetchFlashSale();
    });
    isLoading = false;
    notifyListeners();
  }

  final lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.white).copyWith(
        surface: Colors.white,
        primary: primaryColor,
        secondary: secondaryColor,
        surfaceTint: Colors.white),
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.black),
      iconTheme: IconThemeData(color: Colors.black),
      // actionsIconTheme:
    ),
    primaryColor: primaryColor,
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'ReadexPro',
        ),
    primaryTextTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'ReadexPro',
        ),
  );

  final darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(surface: Colors.black54),
    primaryColor: primaryColor,
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'ReadexPro',
        ),
    primaryTextTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'ReadexPro',
        ),
  );

  void setDarkMode() async {
    _themeData = darkTheme;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }
}
