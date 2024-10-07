import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class CategoriesAPI {
  // Caching categories responses to minimize network calls
  Map<String, dynamic> _categoriesCache = {};

  Future<dynamic> fetchCategories({String showPopular = ''}) async {
    String cacheKey = 'fetchCategories_$showPopular';
    if (_categoriesCache.containsKey(cacheKey)) {
      return _categoriesCache[cacheKey]; // Return cached response
    }

    var response = await baseAPI.getAsync('$category?show_popular=$showPopular', isCustom: true);
    _categoriesCache[cacheKey] = response; // Cache the response
    return response;
  }

  Future<dynamic> fetchProductCategories({int? parent, int? page}) async {
    String? code = Session.data.getString("language_code");
    var url = Uri.parse('$productCategories?_embed&lang=$code&page=${page ?? 1}&parent=${parent ?? ''}');

    var response = await baseAPI.getAsync(url.toString(), printedLog: true);
    printLog("Product Categories : ${response.body}");
    return response;
  }

  Future<dynamic> fetchPopularCategories() async {
    var response = await baseAPI.getAsync('$popularCategories', isCustom: true);
    return response;
  }

  Future<dynamic> fetchSubCategories({int? parent, int? page}) async {
    String lang = Session.data.getString("language_code") ?? "";
    Map<String, dynamic> data = {"lang": lang, "parent": parent};

    printLog(data.toString());
    var response = await baseAPI.postAsync(
      '$allCategoriesUrl?lang=$lang',
      data,
      isCustom: true,
    );
    return response;
  }

  Future<dynamic> fetchAllCategories() async {
    String lang = Session.data.getString("language_code") ?? "";
    Map<String, dynamic> data = {"lang": lang};

    printLog(data.toString());
    var response = await baseAPI.postAsync(
      '$allCategoriesUrl?lang=$lang',
      data,
      isCustom: true,
    );
    return response;
  }
}
