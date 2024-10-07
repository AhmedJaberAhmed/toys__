
import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';

import '../utils/utility.dart';

class FlashSaleAPI {
  final Map<String, dynamic> _cache = {}; // Cache for storing responses

  Future<dynamic> fetchHomeFlashSale() async {
    // Cache key for home flash sale
    String cacheKey = 'homeFlashSale';

    // Return cached data if available
    if (_cache.containsKey(cacheKey)) {
      printLog("Returning cached data for $cacheKey");
      return _cache[cacheKey];
    }

    try {
      var response = await baseAPI.getAsync('$homeFlashSale', isCustom: true).timeout(const Duration(seconds: 10));
      _cache[cacheKey] = response; // Cache the response
      return response;
    } catch (e) {
      printLog("Error fetching home flash sale: $e");
      return null; // Handle as appropriate
    }
  }

  Future<dynamic> fetchFlashSaleProducts(String productId) async {
    // Create a cache key for the product ID
    String cacheKey = 'flashSaleProducts_$productId';

    // Return cached data if available
    if (_cache.containsKey(cacheKey)) {
      printLog("Returning cached data for $cacheKey");
      return _cache[cacheKey];
    }

    try {
      var response = await baseAPI.getAsync('$product?include=$productId').timeout(const Duration(seconds: 10));
      _cache[cacheKey] = response; // Cache the response
      return response;
    } catch (e) {
      printLog("Error fetching flash sale products: $e");
      return null; // Handle as appropriate
    }
  }
}
