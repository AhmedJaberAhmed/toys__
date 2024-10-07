import 'package:flutter/foundation.dart';
import 'package:nyoba/models/categories_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'dart:convert';
import 'package:nyoba/services/categories_api.dart';
import 'package:nyoba/services/product_api.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class CategoryProvider with ChangeNotifier {
  CategoriesModel? category;
  bool loading = true;
  bool loadingAll = true;
  bool loadingProductCategories = true;
  bool loadingSub = false;

  List<CategoriesModel> categories = [];
  List<ProductCategoryModel> productCategories = [];

  List<AllCategoriesModel> allCategories = [];
  List<AllCategoriesModel> subCategories = [];
  List<PopularCategoriesModel> popularCategories = [];
  int? currentSelectedCategory;
  int? currentSelectedCountSub;
  int? currentPage;

  List<ProductModel> listProductCategory = [];
  List<ProductModel> listTempProduct = [];

  CategoryProvider() {
    // fetchCategories();
    // fetchProductCategories();
  }

  Future<bool> fetchCategories() async {
    await CategoriesAPI().fetchCategories().then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        for (Map item in responseJson) {
          categories.add(CategoriesModel.fromJson(item));
        }
        categories.add(new CategoriesModel(
            image: 'images/lobby/viewMore.png',
            categories: null,
            id: null,
            titleCategories: 'View More'));
        loading = false;
        notifyListeners();
      } else {
        loading = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchProductCategories() async {
    loadingProductCategories = true;
    //notifyListeners();
    await CategoriesAPI().fetchProductCategories().then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        productCategories.clear();
        for (Map item in responseJson) {
          productCategories.add(ProductCategoryModel.fromJson(item));
        }
        loadingProductCategories = false;
        notifyListeners();
      } else {
        loadingProductCategories = false;
        notifyListeners();
      }
    });
    return true;
  }

  setAllCategoriesFromSession() {
    final result = jsonDecode(Session.data.getString('listAllCategories')!);
    allCategories.clear();
    for (Map item in result) {
      if (item['title'] != "Membership Plan")
        allCategories.add(AllCategoriesModel.fromJson(item));
    }
  }

  Future<bool> fetchAllCategories() async {
    var result;
    // Session.data.remove("listAllCategories");
    allCategories.clear();
    loadingAll = true;
    notifyListeners();
    printLog(loadingAll.toString(), name: "Loading Categories");
    await CategoriesAPI().fetchAllCategories().then((data) {
      result = data;
      printLog(json.encode(result), name: "All Categories");
      Session.data.setString('listAllCategories', jsonEncode(result));
      for (Map item in result) {
        if (item['title'] != "Membership Plan")
          allCategories.add(AllCategoriesModel.fromJson(item));
      }
      allCategories.removeWhere((element) => element.id == 9911);
      printLog(json.encode(allCategories), name: "after remove Categories");
      loadingAll = false;
      notifyListeners();
    });
    return true;
  }

  resetData() {
    allCategories.clear();
    subCategories.clear();
    listProductCategory.clear();
    currentSelectedCategory = 0;
    notifyListeners();
  }

  Future<bool> fetchSubCategories(int? parent, page) async {
    loadingSub = true;
    await CategoriesAPI()
        .fetchSubCategories(parent: parent, page: page)
        .then((data) {
      printLog("Data sub : ${json.encode(data)}");
      if (data.isNotEmpty) {
        final responseJson = data;

        if (page == 1) {
          subCategories.clear();
        }

        for (Map item in responseJson) {
          subCategories.add(AllCategoriesModel.fromJson(item));
        }
        loadingSub = false;
        notifyListeners();
      } else {
        loadingSub = false;
        notifyListeners();
      }
    });
    return true;
  }

  setPopularCategoriesFromSession() {
    final responseJson =
        jsonDecode(Session.data.getString('listPopularCategories')!);
    popularCategories.clear();
    for (Map item in responseJson) {
      popularCategories.add(PopularCategoriesModel.fromJson(item));
    }
  }

  Future<bool> fetchPopularCategories() async {
    // Session.data.remove("listPopularCategories");
    // popularCategories.clear();
    loadingSub = true;
    await CategoriesAPI().fetchPopularCategories().then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);
        Session.data
            .setString('listPopularCategories', jsonEncode(responseJson));
        popularCategories.clear();
        for (Map item in responseJson) {
          popularCategories.add(PopularCategoriesModel.fromJson(item));
        }
        loadingSub = false;
        notifyListeners();
      } else {
        loadingSub = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchProductsCategory(String category, {int page = 1}) async {
    loadingSub = true;
    await ProductAPI()
        .fetchProduct(category: category, page: page, perPage: 5)
        .then((data) {
      if (data != null) {
        final responseJson = data;
        Session.data.setString('listProductCategory', jsonEncode(responseJson));
        if (page == 1) {
          listProductCategory.clear();
        }

        int count = 0;

        for (Map item in responseJson) {
          listProductCategory.add(ProductModel.fromJson(item));
          count++;
        }

        if (count >= 5) {
          listProductCategory.add(ProductModel());
        }

        for (int i = 0; i < listProductCategory.length; i++) {
          if (listProductCategory[i].type == 'variable') {
            for (int j = 0;
                j < listProductCategory[i].availableVariations!.length;
                j++) {
              if (listProductCategory[i]
                          .availableVariations![j]
                          .displayRegularPrice -
                      listProductCategory[i]
                          .availableVariations![j]
                          .displayPrice !=
                  0) {
                double temp = ((listProductCategory[i]
                                .availableVariations![j]
                                .displayRegularPrice -
                            listProductCategory[i]
                                .availableVariations![j]
                                .displayPrice) /
                        listProductCategory[i]
                            .availableVariations![j]
                            .displayRegularPrice) *
                    100;
                if (listProductCategory[i].discProduct! < temp) {
                  listProductCategory[i].discProduct = temp;
                }
              }
            }
          }
        }

        loadingSub = false;
        notifyListeners();
      } else {
        loadingSub = false;
        notifyListeners();
      }
    });
    return true;
  }
}
