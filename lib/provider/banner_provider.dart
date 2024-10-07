import 'package:flutter/foundation.dart';
import 'package:nyoba/models/banner_mini_model.dart';
import 'package:nyoba/models/banner_model.dart';
import 'dart:convert';
import 'package:nyoba/services/banner_api.dart';

class BannerProvider with ChangeNotifier {
  // Provider state variables
  BannerModel? bannerModel;
  String? errorMessage;

  bool loading = true;
  bool loadingBlog = true;

  List<BannerModel> banners = [];
  List<BannerMiniModel> bannerSpecial = [];
  List<BannerMiniModel> bannerLove = [];

  BannerMiniModel bannerBlog = BannerMiniModel(); // Removed unnecessary constructor call

  BannerProvider() {
    fetchBannerBlog('true');
  }

  // General fetch method to reduce redundancy
  Future<void> fetchData(Future<dynamic> Function() apiCall, Function(List<dynamic>) parseData, {bool isBlog = false}) async {
    try {
      final response = await apiCall();
      if (response.statusCode == 200) {
        final List<dynamic> responseJson = json.decode(response.body);
        parseData(responseJson);
      } else {
        loading = false; // Consider adding error handling to set errorMessage
      }
    } catch (error) {
      errorMessage = error.toString(); // Capture and log error
      loading = false;
    } finally {
      notifyListeners(); // Notify listeners only once after loading is complete
    }
  }

  // Fetch main banners
  Future<void> fetchBanner() async {
    await fetchData(
      BannerAPI().fetchBanner,
          (responseJson) {
        banners = responseJson.map((item) => BannerModel.fromJson(item)).toList(); // Efficiently map and assign
        loading = false;
      },
    );
  }

  // Fetch mini banners
  Future<void> fetchBannerMini() async {
    await fetchData(
      BannerAPI().fetchMiniBanner,
          (responseJson) {
        bannerSpecial.clear();
        bannerLove.clear();

        for (Map item in responseJson) {
          // Use a switch case for better readability
          switch (item['type']) {
            case 'Special Promo':
              bannerSpecial.add(BannerMiniModel.fromJson(item));
              break;
            case 'Love These Items':
              bannerLove.add(BannerMiniModel.fromJson(item));
              break;
          }
        }
        loading = false;
      },
    );
  }

  // Fetch banner for blog
  Future<void> fetchBannerBlog(String blog) async {
    await fetchData(
          () => BannerAPI().fetchMiniBanner(isBlog: blog), // Pass API call with parameter
          (responseJson) {
        if (blog == 'true') {
          bannerBlog = BannerMiniModel.fromJson(responseJson.first); // Assign the first item directly if needed
        }
        loadingBlog = false;
      },
    );
  }
}
