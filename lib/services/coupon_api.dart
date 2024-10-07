import 'dart:convert';

import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/models/coupon_model.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class CouponAPI {
  final Map<String, dynamic> _cache = {}; // Cache for storing responses

  Future<dynamic> fetchListCoupon(int page) async {
    String cacheKey = 'coupon_page_$page';

    // Return cached data if available
    if (_cache.containsKey(cacheKey)) {
      printLog("Returning cached data for $cacheKey");
      return _cache[cacheKey];
    }

    try {
      var response = await baseAPI.getAsync('$coupon?page=$page&per_page=50').timeout(const Duration(seconds: 10));
      _cache[cacheKey] = response; // Cache the response
      return response;
    } catch (e) {
      printLog("Error fetching coupon list: $e");
      return null; // Handle as appropriate
    }
  }

  Future<dynamic> newFetchListCoupon() async {
    Map<String, dynamic> data = {'cookie': Session.data.getString('cookie')};
    try {
      var response = await baseAPI.postAsync('$listCoupon', data, isCustom: true).timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      printLog("Error fetching new coupon list: $e");
      return null; // Handle as appropriate
    }
  }

  Future<dynamic> searchCoupon(String code) async {
    String cacheKey = 'coupon_code_$code';

    // Return cached data if available
    if (_cache.containsKey(cacheKey)) {
      printLog("Returning cached data for $cacheKey");
      return _cache[cacheKey];
    }

    try {
      var response = await baseAPI.getAsync('$coupon?code=$code&page=1&per_page=1').timeout(const Duration(seconds: 10));
      _cache[cacheKey] = response; // Cache the response
      return response;
    } catch (e) {
      printLog("Error searching coupon: $e");
      return null; // Handle as appropriate
    }
  }

  Future<dynamic> newSearchCoupon({List<SearchCouponModel>? products, String? code}) async {
    Map<String, dynamic> data = {
      'cookie': Session.data.getString('cookie'),
      'coupon_code': code,
      'products': products
    };
    printLog("Data request to use coupon: ${json.encode(data)}");
    try {
      var response = await baseAPI.postAsync('$applyCoupon', data, isCustom: true).timeout(const Duration(seconds: 10));
      printLog("Response using coupon: ${json.encode(response)}");
      return response;
    } catch (e) {
      printLog("Error using coupon: $e");
      return null; // Handle as appropriate
    }
  }
}
