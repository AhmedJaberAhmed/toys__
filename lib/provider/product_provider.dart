import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/attribute_filter_model.dart';
import 'package:nyoba/models/filter_data_model.dart';
import 'package:nyoba/models/product_extend_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/models/review_model.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/services/product_api.dart';
import 'package:nyoba/services/review_api.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

class ProductProvider with ChangeNotifier {
  bool loadingFeatured = false;
  bool loadingBestDeals = false;
  bool loadingNew = false;

  bool loadingExtends = true;
  bool loadingSpecial = true;
  bool loadingBest = true;
  bool loadingRecommendation = true;
  bool loadingDetail = false;
  bool loadingCategory = false;
  bool loadingYouMightAlsoLike = false;
  bool loadingBrand = false;
  bool loadingMore = true;

  bool loadingReview = false;
  bool loadAddReview = false;
  bool loadingRecent = false;

  String? message;

  List<ProductModel> listFeaturedProduct = [];
  List<ProductModel> listMoreFeaturedProduct = [];

  List<ProductModel> listBestDeal = [];

  List<ProductModel> listNewProduct = [];
  List<ProductModel> listMoreNewProduct = [];

  List<ProductModel> listSpecialProduct = [];
  List<ProductModel> listMoreSpecialProduct = [];

  List<ProductModel> listBestProduct = [];
  List<ProductModel> listRecentProduct = [];
  List<ProductModel> listRecommendationProduct = [];
  List<ProductModel> listCategoryProduct = [];
  List<ProductModel> listBrandProduct = [];

  List<ProductModel> listMoreExtendProduct = [];
  List<ProductModel> listTempProduct = [];

  List<ReviewHistoryModel> listReviewLimit = [];

  List<AttributeFilter>? attributeFilter = [];
  String? paramAttrFilter;

  late ProductExtendModel productSpecial;
  late ProductExtendModel productBest;
  late ProductExtendModel productRecommendation;

  String? productRecent;

  ProductModel? productDetail;

  // Image Review Product
  List<XFile>? imageFileList = [];
  List<TextEditingController>? textImageList = [];
  List<XFile>? imageFileInvalidList = [];
  List<XFile>? imageFileVideoList = [];
  List<TextEditingController>? textVideoList = [];
  List<XFile>? imageFileInvalidVideoList = [];
  List<String>? imageBase64 = [];

  dynamic pickImageError;
  String? retrieveDataError;
  final ImagePicker _picker = ImagePicker();

  int pageBestDeals = 1;

  setPageBestDeals(val) {
    pageBestDeals = val;
    notifyListeners();
  }

  ProductProvider() {
    fetchFeaturedProducts();
    fetchExtendProducts('our_best_seller');
    fetchExtendProducts('special');
    fetchExtendProducts('recomendation');
  }

  Future<bool> fetchFeaturedProducts(
      {int page = 1, String? order = '', String? orderBy = ''}) async {
    loadingFeatured = true;
    await ProductAPI()
        .fetchMoreProduct(
            page: page, order: order!, orderBy: orderBy, featured: true)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        if (page == 1) {
          listFeaturedProduct.clear();
          listMoreFeaturedProduct.clear();
        }

        for (Map item in responseJson) {
          if (page == 1) {
            listFeaturedProduct.add(ProductModel.fromJson(item));
          }
          listMoreFeaturedProduct.add(ProductModel.fromJson(item));
        }

        loadingFeatured = false;
        notifyListeners();
      } else {
        loadingFeatured = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchNewProducts(String category, {int page = 1}) async {
    loadingNew = true;
    await ProductAPI()
        .fetchProduct(category: category, page: page)
        .then((data) {
      if (data != null) {
        final responseJson = data;
        printLog(responseJson.toString(), name: "response new produk");

        if (page == 1) {
          listNewProduct.clear();
          listMoreNewProduct.clear();
        }
        for (Map item in responseJson) {
          if (page == 1) {
            listNewProduct.add(ProductModel.fromJson(item));
            listMoreNewProduct.add(ProductModel.fromJson(item));
          } else {
            listMoreNewProduct.add(ProductModel.fromJson(item));
          }
        }
        for (int i = 0; i < listNewProduct.length; i++) {
          if (listNewProduct[i].type == 'variable') {
            for (int j = 0;
                j < listNewProduct[i].availableVariations!.length;
                j++) {
              if (listNewProduct[i]
                          .availableVariations![j]
                          .displayRegularPrice -
                      listNewProduct[i].availableVariations![j].displayPrice !=
                  0) {
                double temp = ((listNewProduct[i]
                                .availableVariations![j]
                                .displayRegularPrice -
                            listNewProduct[i]
                                .availableVariations![j]
                                .displayPrice) /
                        listNewProduct[i]
                            .availableVariations![j]
                            .displayRegularPrice) *
                    100;
                if (listNewProduct[i].discProduct! < temp) {
                  listNewProduct[i].discProduct = temp;
                }
              }
            }
          }
        }

        loadingNew = false;
        notifyListeners();
      } else {
        loadingNew = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchExtendProducts(type) async {
    await ProductAPI().fetchExtendProduct(type).then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        for (Map item in responseJson) {
          if (type == 'our_best_seller') {
            productBest = ProductExtendModel.fromJson(item);
          } else if (type == 'special') {
            productSpecial = ProductExtendModel.fromJson(item);
          } else if (type == 'recomendation') {
            productRecommendation = ProductExtendModel.fromJson(item);
          }
        }
        notifyListeners();
      } else {
        notifyListeners();
        print("Load Extend Failed");
      }
    });
    return true;
  }

  Future<bool> fetchRecentProducts() async {
    await ProductAPI().fetchRecentViewProducts().then((data) {
      if (data["products"].toString().isNotEmpty) {
        productRecent = data["products"];
        this.fetchListRecentProducts(productRecent);
      }
      notifyListeners();
    });
    return true;
  }

  Future<bool> fetchListRecentProducts(productId) async {
    await ProductAPI()
        .fetchMoreProduct(
            include: productId, order: 'desc', orderBy: 'popularity')
        .then((data) {
      if (data != null) {
        final responseJson = data;

        listRecentProduct.clear();
        for (Map item in responseJson) {
          listRecentProduct.add(ProductModel.fromJson(item));
        }

        loadingRecent = false;
        notifyListeners();
      } else {
        print("Load Recent Failed");
        loadingRecent = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> hitViewProducts(productId) async {
    await ProductAPI().hitViewProductsAPI(productId).then((data) {
      notifyListeners();
    });
    return true;
  }

  Future<ProductModel?> fetchProductDetail(String? productId,
      {String? videoId = ""}) async {
    loadingDetail = true;
    await ProductAPI()
        .fetchDetailProduct(productId, videoId: videoId)
        .then((data) {
      if (data != null) {
        final responseJson = data;
        // printLog("detail product : $data");
        productDetail = ProductModel.fromJson(responseJson.first);

        loadingDetail = false;
        notifyListeners();
      } else {
        print("Load Failed");
        loadingDetail = false;
        notifyListeners();
      }
    });
    return productDetail;
  }

  Future<ProductModel?> fetchProductDetailSlug(String? slug) async {
    loadingDetail = true;
    await ProductAPI().fetchDetailProductSlug(slug).then((data) {
      if (data != null) {
        final responseJson = data;

        for (Map item in responseJson) {
          productDetail = ProductModel.fromJson(item);
        }

        notifyListeners();
      } else {
        print("Load Failed");
        notifyListeners();
      }
    });
    return productDetail;
  }

  Future<Map<String, dynamic>?> checkVariation({productId, list}) async {
    var result;
    await ProductAPI().checkVariationProduct(productId, list).then((data) {
      result = data;
      notifyListeners();
      printLog(json.encode(result));
    });
    return result;
  }

  Future<bool> fetchCategoryProduct(
      String category, int page, String order, String orderBy) async {
    loadingCategory = true;
    loadingYouMightAlsoLike = true;
    printLog(jsonEncode(listCategoryProduct), name: "LIST CATEGORY PRODUCT 1");
    await ProductAPI()
        .fetchBrandProduct(
            order: order,
            orderBy: 'rand',
            page: page,
            perPage: 20,
            category: category)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        if (page == 1) {
          listCategoryProduct.clear();
        }
        printLog(jsonEncode(listCategoryProduct),
            name: "LIST CATEGORY PRODUCT 2");

        for (Map item in responseJson) {
          listCategoryProduct.add(ProductModel.fromJson(item));
        }

        printLog(jsonEncode(listCategoryProduct),
            name: "LIST CATEGORY PRODUCT 3");

        loadingCategory = false;
        loadingYouMightAlsoLike = false;
        notifyListeners();
      } else {
        loadingCategory = false;
        loadingYouMightAlsoLike = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchBrandProductBySlug(
      {String? category,
      int? page,
      String? order,
      String? orderBy,
      String? attribute,
      String? slug}) async {
    loadingBrand = true;
    await ProductAPI()
        .fetchBrandProduct(
            page: page, attributeFilter: attributeFilter, slug: slug)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        listTempProduct.clear();
        if (page == 1) {
          listBrandProduct.clear();
        }
        for (Map item in responseJson) {
          listBrandProduct.add(ProductModel.fromJson(item));
        }
        for (int i = 0; i < listBrandProduct.length; i++) {
          if (listBrandProduct[i].type == 'variable') {
            for (int j = 0;
                j < listBrandProduct[i].availableVariations!.length;
                j++) {
              if (listBrandProduct[i]
                          .availableVariations![j]
                          .displayRegularPrice -
                      listBrandProduct[i]
                          .availableVariations![j]
                          .displayPrice !=
                  0) {
                double temp = ((listBrandProduct[i]
                                .availableVariations![j]
                                .displayRegularPrice -
                            listBrandProduct[i]
                                .availableVariations![j]
                                .displayPrice) /
                        listBrandProduct[i]
                            .availableVariations![j]
                            .displayRegularPrice) *
                    100;
                if (listBrandProduct[i].discProduct! < temp) {
                  listBrandProduct[i].discProduct = temp;
                }
              }
            }
          }
        }

        loadingBrand = false;
        notifyListeners();
      } else {
        loadingBrand = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchBrandProduct(
      {String? category,
      int? page,
      String? order,
      String? orderBy,
      String? attribute,
      String? slug}) async {
    loadingBrand = true;
    await ProductAPI()
        .fetchBrandProduct(
            category: category!,
            order: order!,
            orderBy: orderBy!,
            page: page,
            attribute: attribute!,
            attributeFilter: attributeFilter,
            slug: slug)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        listTempProduct.clear();
        if (page == 1) {
          listBrandProduct.clear();
        }
        for (Map item in responseJson) {
          listBrandProduct.add(ProductModel.fromJson(item));
        }
        for (int i = 0; i < listBrandProduct.length; i++) {
          if (listBrandProduct[i].type == 'variable') {
            for (int j = 0;
                j < listBrandProduct[i].availableVariations!.length;
                j++) {
              if (listBrandProduct[i]
                          .availableVariations![j]
                          .displayRegularPrice -
                      listBrandProduct[i]
                          .availableVariations![j]
                          .displayPrice !=
                  0) {
                double temp = ((listBrandProduct[i]
                                .availableVariations![j]
                                .displayRegularPrice -
                            listBrandProduct[i]
                                .availableVariations![j]
                                .displayPrice) /
                        listBrandProduct[i]
                            .availableVariations![j]
                            .displayRegularPrice) *
                    100;
                if (listBrandProduct[i].discProduct! < temp) {
                  listBrandProduct[i].discProduct = temp;
                }
              }
            }
          }
        }

        loadingBrand = false;
        notifyListeners();
      } else {
        loadingBrand = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<List<String>> generateImageBase64() async {
    loadAddReview = true;
    List<String> _temp = [];
    if (imageFileList!.isNotEmpty) {
      imageBase64 = [];

      for (var element in imageFileList!) {
        final file = File(element.path);
        final bytes = file.readAsBytesSync().lengthInBytes;
        final kb = bytes / 1024;
        List<int> imageBytes = await file.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        printLog(kb.toString(), name: 'File Size KB');
        imageBase64!.add(base64Image);
        printLog(imageBase64.toString(), name: 'ListBase64');
      }
      _temp = imageBase64!;
      printLog(_temp.toString(), name: 'Temps');
    }
    notifyListeners();
    return _temp;
  }

  Future<Map<String, dynamic>?> addReview(context,
      {productId, review, rating, reviewTitle, name, email}) async {
    loadAddReview = true;
    var result;
    notifyListeners();
    try {
      printLog(imageBase64.toString(), name: 'Image Base64');
      List<File> listTemp = [];
      String textTemp = "";
      textImageList!.forEach((element) {
        if (textTemp == "") {
          if (element.text.isNotEmpty) textTemp += element.text;
          if (element.text.isEmpty) textTemp += "{empty}";
        } else {
          if (element.text.isNotEmpty) textTemp += "|${element.text}";
          if (element.text.isEmpty) textTemp += "|{empty}";
        }
      });
      textVideoList!.forEach((element) {
        if (textTemp == "") {
          if (element.text.isNotEmpty) textTemp += element.text;
          if (element.text.isEmpty) textTemp += "{empty}";
        } else {
          if (element.text.isNotEmpty) textTemp += "|${element.text}";
          if (element.text.isEmpty) textTemp += "|{empty}";
        }
      });
      imageFileList!.forEach((element) {
        listTemp.add(File(element.path));
      });
      imageFileVideoList!.forEach((element) {
        listTemp.add(File(element.path));
      });
      await ReviewAPI()
          .inputReview(productId, review, rating, reviewTitle, textTemp,
              image: listTemp, name: name, email: email)
          .then((data) {
        result = data;
        printLog(json.encode(result), name: "Result");
        if (result['status'] == 'success') {
          imageBase64 = [];
          Navigator.pop(context);
          snackBar(context,
              message:
                  '${AppLocalizations.of(context)!.translate('success_review')}');
        } else {
          Navigator.pop(context);
          snackBar(context, message: 'Error, ${result['message']}');
        }
        loadAddReview = false;

        notifyListeners();
        printLog(result.toString());
      });
      return result;
    } catch (e) {
      result = {"message": "$e"};
      printLog(e.toString());
      loadAddReview = false;
      notifyListeners();
      return result;
    }
  }

  Future<bool> fetchMoreExtendProduct(String? productId,
      {int? page, required String order, String? orderBy}) async {
    loadingMore = true;
    await ProductAPI()
        .fetchMoreProduct(
            include: productId, page: page, order: order, orderBy: orderBy)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        listTempProduct.clear();
        if (page == 1) {
          listMoreExtendProduct.clear();
        }
        for (Map item in responseJson) {
          listMoreExtendProduct.add(ProductModel.fromJson(item));
        }

        loadingMore = false;
        notifyListeners();
      } else {
        print("Load Failed");
        loadingMore = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool> fetchBestDeals(
      {String? order = 'desc', String? orderBy = 'rand'}) async {
    loadingBestDeals = true;
    notifyListeners();
    await ProductAPI()
        .fetchMoreProduct(
            page: pageBestDeals, order: order!, orderBy: orderBy, perPage: 24)
        .then((data) {
      if (data != null) {
        final responseJson = data;

        if (pageBestDeals == 1) {
          listBestDeal.clear();
        }

        for (Map item in responseJson) {
          listBestDeal.add(ProductModel.fromJson(item));
        }

        loadingBestDeals = false;
        notifyListeners();
      } else {
        loadingBestDeals = false;
        notifyListeners();
      }
    });
    return true;
  }

  setAttributeFilter(FilterDataModel filter) {
    attributeFilter!.clear();
    filter.dataFilter!.forEach((element) {
      List<TermFilter> termFilter = element.termFilter;
      List<String> terms = [];
      termFilter.forEach((e) {
        if (e.isSelected!) {
          terms.add(e.name!);
        }
      });
      if (terms.isNotEmpty) {
        attributeFilter!.add(new AttributeFilter(
            taxonomy: element.taxonomy,
            field: 'slug',
            operator: 'IN',
            terms: terms));
      }
    });
    notifyListeners();
  }

  void _setImageFileListFromFile(XFile? value) {
    imageFileList = value == null ? null : <XFile>[value];
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.files == null) {
        _setImageFileListFromFile(response.file);
      } else {
        imageFileList = response.files;
      }
    } else {
      retrieveDataError = response.exception!.code;
    }
  }

  Future<void> onImageButtonPressed(
      BuildContext context, ImageSource source, bool image) async {
    try {
      if (image) {
        final maxSize =
            Provider.of<HomeProvider>(context, listen: false).photoMaxSize;
        final maxFiles =
            Provider.of<HomeProvider>(context, listen: false).photoMaxFiles;

        imageFileInvalidList = [];

        final List<XFile>? pickedFileList = await _picker.pickMultiImage();

        pickedFileList!.forEach((element) async {
          final file = File(element.path);
          final bytes = file.readAsBytesSync().lengthInBytes;
          final kb = bytes / 1024;

          if (kb < maxSize!) {
            printLog(imageFileList!.length.toString());
            if (imageFileList!.length < maxFiles!) {
              imageFileList!.add(element);
            } else {
              imageFileInvalidList!.add(element);
            }
          } else {
            imageFileInvalidList!.add(element);
          }
          textImageList?.add(new TextEditingController());
        });

        printLog("${imageFileList!.length}", name: 'Image Total');
        notifyListeners();
      } else if (!image) {
        final maxSize =
            Provider.of<HomeProvider>(context, listen: false).photoMaxSize;
        final maxFiles =
            Provider.of<HomeProvider>(context, listen: false).photoMaxFiles;

        imageFileInvalidVideoList = [];

        final XFile? pickedFile = await _picker.pickVideo(source: source);

        final file = File(pickedFile!.path);
        final bytes = file.readAsBytesSync().lengthInBytes;
        final kb = bytes / 1024;

        if (kb < maxSize!) {
          printLog(imageFileVideoList!.length.toString());
          if (imageFileVideoList!.length < maxFiles!) {
            imageFileVideoList!.add(pickedFile);
          } else {
            imageFileInvalidVideoList!.add(pickedFile);
          }
        } else {
          imageFileInvalidVideoList!.add(pickedFile);
        }
        textVideoList?.add(new TextEditingController());

        printLog("${imageFileVideoList!.length}", name: 'Video Total');
        notifyListeners();
      }
    } catch (e) {
      pickImageError = e;
      notifyListeners();
    }
  }

  setRetrieveDataError() {
    retrieveDataError = null;
    notifyListeners();
  }

  reset() {
    loadingBrand = true;
    attributeFilter = [];
    notifyListeners();
  }

  resetReview() {
    imageFileList = [];
    imageFileInvalidList = [];
    imageBase64 = [];
    notifyListeners();
  }

  double totalPriceProduct = 0; //For price total product
  double priceProduct = 0; //For price product
  double priceAddOn = 0; //For price add-on
  List<String> addOn = []; //For chosen add-on

  //Called when setAddOn, check price product
  calculateTotalPrice({int qty = 1}) {
    totalPriceProduct = qty * (priceProduct + priceAddOn);
    notifyListeners();
  }

  //Set add-on, chosen add-on & set price
  setAddON(String label, OptionAddOn option) {
    if (addOn.contains(label)) {
      priceAddOn = priceAddOn - option.price!;
      addOn.removeWhere((element) => element == label);
      notifyListeners();
    } else if (!addOn.contains(label)) {
      addOn.add(label);
      priceAddOn = priceAddOn + option.price!;

      notifyListeners();
    }
    calculateTotalPrice();
  }

  //Checking price product for F&B, checking from availableVariations
  //If available at availableVariations, the priceProduct will change
  Future<int> checkPriceProduct(ProductModel product) async {
    int idx = 0;
    if (product.availableVariations != null &&
        product.availableVariations!.isNotEmpty) {
      List<String> tempAttribute = []; //Temporary variable for selected variant
      List<String> tempAvailable =
          []; //Temporary variable for available variant
      for (int j = 0; j < product.availableVariations!.length; j++) {
        int check = 0;
        for (int i = 0; i < product.attributes!.length; i++) {
          tempAttribute.add(product.attributes![i].selectedVariant!);
          tempAvailable.add(product.availableVariations![j]
              .attributes['attribute_${product.attributes![i].slug}']);
        }
        for (int i = 0; i < tempAttribute.length; i++) {
          if (tempAttribute[i] == tempAvailable[i]) {
            check++;
          }
          if (check >= product.attributes!.length) {
            priceProduct =
                product.availableVariations![j].displayPrice.toDouble();
            idx = j;
          }
        }
        tempAttribute.clear();
        tempAvailable.clear();
      }
      calculateTotalPrice();
    } else {
      priceProduct = product.productPrice!.toDouble();
    }
    return idx;
  }

  resetDetailProduct() {
    totalPriceProduct = 0; //For price total product
    priceProduct = 0; //For price product
    priceAddOn = 0; //For price add-on
    addOn = []; //For chosen add-on
    notifyListeners();
  }
}
