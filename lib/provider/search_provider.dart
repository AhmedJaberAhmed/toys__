import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/product/design_detail_screen.dart';
import 'package:nyoba/services/product_api.dart';
import 'package:nyoba/utils/utility.dart';

import '../app_localizations.dart';

class SearchProvider with ChangeNotifier {
  bool loadingSearch = false;
  bool loadingQr = false;

  String? message;

  List<ProductModel> listSearchProducts = [];
  List<ProductModel> listSuggestionProducts = [];

  String? productWishlist;

  Future<void> newSearchProduct(String product, int page) async {
    loadingSearch = true;
    notifyListeners();
    await ProductAPI().newSearchProduct(product).then((data) {
      if (data != null) {
        final responseJson = json.decode(data.body);

        if (page == 1) {
          listSearchProducts.clear();
          listSuggestionProducts.clear();
        }
        if (product.isNotEmpty &&
            responseJson['message']['product'].isNotEmpty) {
          for (var item in responseJson['message']['product']) {
            listSearchProducts.add(ProductModel.fromJson(item));
          }
        } else if (responseJson['message']['product'].isEmpty &&
            responseJson['message']['suggestion'].isNotEmpty) {
          for (var item in responseJson['message']['suggestion']) {
            listSuggestionProducts.add(ProductModel.fromJson(item));
          }
        }

        loadingSearch = false;
        notifyListeners();
      } else {
        print("Load Failed");
        loadingSearch = false;
        notifyListeners();
      }
    });
  }

  Future<bool> searchProducts(String search, int page) async {
    loadingSearch = true;
    await ProductAPI().searchProduct(search: search, page: page).then((data) {
      if (data != null) {
        final responseJson = data;

        printLog(responseJson.toString(), name: 'Wishlist');
        if (page == 1) listSearchProducts.clear();
        if (search.isNotEmpty) {
          for (Map item in responseJson) {
            listSearchProducts.add(ProductModel.fromJson(item));
          }
        }

        loadingSearch = false;
        notifyListeners();
      } else {
        print("Load Failed");
        loadingSearch = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> scanProduct(String? code, context) async {
    loadingQr = true;
    await ProductAPI().scanProductAPI(code).then((data) {
      if (data['id'] != null) {
        loadingQr = false;
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DesignDetailScreen(
                      productId: data['id'].toString(),
                    )));
      } else if (data['status'] == 'error') {
        loadingQr = false;
        Navigator.pop(context);
        snackBar(context,
            message: AppLocalizations.of(context)!
                .translate('snackbar_product_notfound')!,
            color: Colors.red);
      }
      loadingQr = false;
      notifyListeners();
    });
    return true;
  }
}
