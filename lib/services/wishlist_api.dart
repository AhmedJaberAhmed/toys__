import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';

class WishlistAPI {
  checkWishlist(int productId) async {
    Map data = {'product_id': productId};
    var response = await baseAPI.postAsync(
      '$checkWishlistProduct',
      data,
      isCustom: true,
    );
    return response;
  }

  setWishlist(String? productId, {bool check = false}) async {
    Map data = {
      'product_id': productId,
      if (Session.data.getString('cookie') != null)
        'cookie': Session.data.getString('cookie'),
      'check': check
    };
    var response = await baseAPI.postAsync(
      '$setWishlistProduct',
      data,
      isCustom: true,
    );
    return response;
  }

  fetchProductWishlist({
    required int page,
    required int perPage,
  }) async {
    Map data = {
      'cookie': Session.data.getString('cookie'),
      'page': page,
      'per_page': perPage,
    };
    var response = await baseAPI.postAsync(
      '$listWishlistProduct',
      data,
      isCustom: true,
    );
    return response;
  }
}
