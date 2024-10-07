import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';

class BannerAPI {
  final Map<String, dynamic> _cache = {}; // Cache for storing responses

  Future<dynamic> fetchBanner() async {
    if (_cache.containsKey('banner')) {
      return _cache['banner']; // Return cached data if available
    }

    var response = await baseAPI.getAsync('$banner', isCustom: true);
    _cache['banner'] = response; // Store in cache
    return response;
  }

  Future<dynamic> fetchMiniBanner({String isBlog = ''}) async {
    String cacheKey = 'miniBanner_$isBlog'; // Create a unique cache key based on the blog parameter

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]; // Return cached data if available
    }

    var response = await baseAPI.getAsync('$homeMiniBanner?blog_banner=$isBlog', isCustom: true);
    _cache[cacheKey] = response; // Store in cache
    return response;
  }
}
