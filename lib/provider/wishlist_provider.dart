import 'package:flutter/material.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/services/product_api.dart';
import 'package:nyoba/services/wishlist_api.dart';
import 'package:nyoba/utils/utility.dart';

import '../app_localizations.dart';

class WishlistProvider with ChangeNotifier {
  bool loadingWishlist = true;

  String? message;

  List<ProductModel> listWishlistProduct = [];

  String? productWishlist;
  List<String> idProductWishList = [];

  Future<bool> fetchWishlistProducts(
    String productId, {
    int? page = 1,
    bool isFromWishList = false,
  }) async {
    if (productId.isNotEmpty) {
      await ProductAPI()
          .fetchProduct(
        include: productId,
        perPage: 8,
      )
          .then((data) {
        if (data != null) {
          final responseJson = data;

          printLog(responseJson.toString(), name: 'Wishlist');
          if (!isFromWishList) {
            listWishlistProduct.clear();
          } else {
            if (page == 1) {
              listWishlistProduct.clear();
            }
          }
          for (Map item in responseJson) {
            listWishlistProduct.add(ProductModel.fromJson(item));
          }
          for (int i = 0; i < listWishlistProduct.length; i++) {
            if (listWishlistProduct[i].type == 'variable') {
              for (int j = 0;
                  j < listWishlistProduct[i].availableVariations!.length;
                  j++) {
                if (listWishlistProduct[i]
                            .availableVariations![j]
                            .displayRegularPrice -
                        listWishlistProduct[i]
                            .availableVariations![j]
                            .displayPrice !=
                    0) {
                  double temp = ((listWishlistProduct[i]
                                  .availableVariations![j]
                                  .displayRegularPrice -
                              listWishlistProduct[i]
                                  .availableVariations![j]
                                  .displayPrice) /
                          listWishlistProduct[i]
                              .availableVariations![j]
                              .displayRegularPrice) *
                      100;
                  if (listWishlistProduct[i].discProduct! < temp) {
                    listWishlistProduct[i].discProduct = temp;
                  }
                }
              }
            }
          }

          loadingWishlist = false;
          notifyListeners();
        } else {
          print("Load Failed");
          loadingWishlist = false;
          notifyListeners();
        }
      });
    } else {
      loadingWishlist = false;
      notifyListeners();
    }
    return true;
  }

  Future<Map<String, dynamic>?> checkWishlistProduct({productId}) async {
    var result;
    await WishlistAPI().setWishlist(productId, check: true).then((data) {
      result = data;
      notifyListeners();
      printLog(result.toString(), name: "cek wishlist");
    });
    return result;
  }

  Future<Map<String, dynamic>?> setWishlistProduct(context, {productId}) async {
    var result;
    await WishlistAPI().setWishlist(productId).then((data) {
      result = data;

      printLog(result['message'], name: "Result message");
      printLog(result['type'], name: "Result message");
      if (result['message'] == 'success') {
        if (result['type'] == 'add') {
          snackBar(context,
              message: AppLocalizations.of(context)!
                  .translate('wishlist_add_message')!);
        } else {
          snackBar(context,
              message: AppLocalizations.of(context)!
                  .translate('wishlist_remove_message')!);
        }
      } else {
        snackBar(context,
            message: AppLocalizations.of(context)!
                .translate('error_submit_message')!,
            color: Colors.red);
      }

      notifyListeners();
      printLog(result.toString(), name: "set wishlist");
    });
    return result;
  }

  Future<Map<String, dynamic>?> loadWishlistProduct({
    productId,
    required int page,
  }) async {
    loadingWishlist = true;
    var result;
    idProductWishList.clear();
    await WishlistAPI()
        .fetchProductWishlist(
      page: page,
      perPage: 8,
    )
        .then((data) {
      result = data;
      productWishlist = result['products'];
      idProductWishList = result['products'].split(",");
      notifyListeners();
      printLog(result.toString(), name: "Wishlist Products");
      printLog(idProductWishList.toString(), name: "ID PRODUCT WISHLIST");
    });
    return result;
  }
}
