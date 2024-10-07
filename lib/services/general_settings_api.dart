import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';

import '../utils/utility.dart';

class GeneralSettingsAPI {
  final Map<String, dynamic> _cache = {}; // Cache for storing responses

  Future<dynamic> introPageData() async {
    // Cache key for intro page data
    String cacheKey = 'introPageData';

    // Return cached data if available
    if (_cache.containsKey(cacheKey)) {
      printLog("Returning cached data for $cacheKey");
      return _cache[cacheKey];
    }

    try {
      var response = await baseAPI.getAsync('$introPage', isCustom: true).timeout(const Duration(seconds: 10));
      _cache[cacheKey] = response; // Cache the response
      return response;
    } catch (e) {
      printLog("Error fetching intro page data: $e");
      return null; // Handle as appropriate
    }
  }

  Future<dynamic> generalSettingsData() async {
    // Cache key for general settings data
    String cacheKey = 'generalSettingsData';

    // Return cached data if available
    if (_cache.containsKey(cacheKey)) {
      printLog("Returning cached data for $cacheKey");
      return _cache[cacheKey];
    }

    try {
      var response = await baseAPI.getAsync('$generalSetting', isCustom: true).timeout(const Duration(seconds: 10));
      _cache[cacheKey] = response; // Cache the response
      return response;
    } catch (e) {
      printLog("Error fetching general settings data: $e");
      return null; // Handle as appropriate
    }
  }

  Future<dynamic> getCurrency() async {
    // Cache key for currency data
    String cacheKey = 'currencyData';

    // Return cached data if available
    if (_cache.containsKey(cacheKey)) {
      printLog("Returning cached data for $cacheKey");
      return _cache[cacheKey];
    }

    try {
      var response = await baseAPI.getAsync('woocs/currencies', isCustom: true, printedLog: true).timeout(const Duration(seconds: 10));
      _cache[cacheKey] = response; // Cache the response
      return response;
    } catch (e) {
      printLog("Error fetching currency data: $e");
      return null; // Handle as appropriate
    }
  }
}
