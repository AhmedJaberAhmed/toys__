import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:nyoba/models/aftership_check_model.dart';
import 'package:nyoba/models/banner_mini_model.dart';
import 'package:nyoba/models/banner_model.dart';
import 'package:nyoba/models/billing_address_model.dart';
import 'package:nyoba/models/categories_model.dart';
import 'package:nyoba/models/contact_model.dart';
import 'package:nyoba/models/general_settings_model.dart';
import 'package:nyoba/models/home_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/models/variation_model.dart';
import 'package:nyoba/provider/category_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/services/home_api.dart';
import 'package:nyoba/services/product_api.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/customize/section_recently_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../widgets/home/customize/section_a.dart';
import '../widgets/home/customize/section_b.dart';
import '../widgets/home/customize/section_bestdeal.dart';
import '../widgets/home/customize/section_c.dart';
import '../widgets/home/customize/section_d.dart';
import '../widgets/home/customize/section_e.dart';
import '../widgets/home/customize/section_f.dart';
import '../widgets/home/customize/section_g.dart';
import '../widgets/home/customize/section_h.dart';
import '../widgets/home/customize/section_i.dart';
import '../widgets/home/customize/section_j.dart';
import '../widgets/home/customize/section_k.dart';
import '../widgets/home/customize/section_l.dart';
import '../widgets/home/customize/section_m.dart';
import '../widgets/home/customize/section_n.dart';
import '../widgets/home/customize/section_o.dart';
import '../widgets/home/customize/section_p.dart';
import '../widgets/home/customize/section_q.dart';

class HomeProvider with ChangeNotifier {
  bool isReload = false;
  bool loading = false;
  bool guestCheckoutActive = false;
  bool isBannerPopChanged = false;
  bool isPhotoReviewActive = false;
  bool isChatActive = false;
  bool isGiftActive = false;
  bool isWalletActive = false;
  bool isSolid = false;
  bool toolTip = false;
  bool finishToolTip = false;
  bool syncCart = false;
  bool checkoutFrom = false;
  bool showSoldItem = false;
  bool showAverageRating = false;
  bool showRatingSection = false;
  bool showVariationWithImage = false;
  String imageGuide = "";
  bool sectionI = false;
  bool popupBiometric = false;
  bool biteship = false;
  String gmapAPIKey = "";
  bool isLocalPickupPlusActive = false;
  bool isPointPluginActive = false;
  bool activateCurrency = false;

  //Video
  bool videoSetting = false;
  int videoFileSize = 0;

  //For desain product detail screen
  String desainDetailProduct = "design_1";

  // Login Page
  String textHeading = "";
  String text = "";
  String bgColor = "#118eea";
  String textColor = "#FFFFFF";
  String btnColor = "#940000";
  String bgImage = "";
  String design = "classic";

  /*Photoreview*/
  bool? isPremium = false;
  String? textReviewTitle = "";
  String? textReviewHint = "";
  String? textUploadRequirement = "";
  bool? gdprStatus = false;
  String? textGdpr = "";
  bool? helpfulStatus = false;
  String? textHelpful = "";
  String? colorVerified = "";
  String? valueVerified = "";

  /*For multiple address*/
  bool statusMultipleAddress = false;
  int limitMultipleAddress = 0;

  /*List Widget Lobby*/
  List<Widget> customize = [];

  /*List Main Slider Banner Model*/
  List<BannerModel> banners = [];
  List<BannerModel> banners2 = [];
  List<BannerModel> banners3 = [];

  /*List Banner Mini Product Model*/
  List<BannerMiniModel> bannerSpecial = [];
  List<BannerMiniModel> bannerLove = [];
  List<BannerMiniModel> bannerBlog = [];
  List<BannerMiniModel> bannerSingle = [];

  /*Banner PopUp*/
  List<BannerMiniModel> bannerPopUp = [];

  /*List Home Mini Categories Model*/
  List<CategoriesModel> categories = [];
  List<CategoriesModel> categoriesSectionI = [];
  List<CategoriesModel> categories3 = [];
  List<CategoriesModel> categories4 = [];
  List<CategoriesModel> categories6 = [];

/*List Home Collection Model For New Product*/
  List<ProductCategoryModel> collection = [];

  /*List Intro Page Model*/
  List<GeneralSettingsModel> intro = [];

  //List product category home
  List<ProductCategoryModel> productCategories = [];

  //List new product
  List<ProductModel> listNewProduct = [];

  /*General Settings Model*/
  GeneralSettingsModel splashscreen = new GeneralSettingsModel();
  GeneralSettingsModel logo = new GeneralSettingsModel();
  GeneralSettingsModel wa = new GeneralSettingsModel();
  GeneralSettingsModel sms = new GeneralSettingsModel();
  GeneralSettingsModel phone = new GeneralSettingsModel();
  GeneralSettingsModel about = new GeneralSettingsModel();
  GeneralSettingsModel currency = new GeneralSettingsModel();
  GeneralSettingsModel formatCurrency = new GeneralSettingsModel();
  GeneralSettingsModel privacy = new GeneralSettingsModel();
  GeneralSettingsModel terms = new GeneralSettingsModel();
  GeneralSettingsModel image404 = new GeneralSettingsModel();
  GeneralSettingsModel imageThanksOrder = new GeneralSettingsModel();
  GeneralSettingsModel imageNoTransaction = new GeneralSettingsModel();
  GeneralSettingsModel imageSearchEmpty = new GeneralSettingsModel();
  GeneralSettingsModel imageNoLogin = new GeneralSettingsModel();
  GeneralSettingsModel searchBarText = new GeneralSettingsModel();
  GeneralSettingsModel sosmedLink = new GeneralSettingsModel();

  bool? isBarcodeActive = false;

  /*List billing address*/
  List<BillingAddress> billingAddress = [];

  /*Flash Sales Model*/
  List<FlashSaleHomeModel> flashSales = [];

  /*Extend Product Model*/
  List<ProductExtendHomeModel> specialProducts = [];
  List<ProductExtendHomeModel> bestProducts = [];
  List<ProductExtendHomeModel> recommendationProducts = [];
  List<ProductModel> tempProducts = [];
  List<ProductExtendHomeModel> productSectionM = [];

  /*Intro Page Status*/
  String? introStatus;

  /*App Color*/
  List<GeneralSettingsModel> appColors = [];

  bool loadingMore = false;

  bool? isLoadHomeSuccess = true;

  PackageInfo? packageInfo;

  List<ContactModel>? contacts = [];

  AfterShipCheck? afterShipCheck;

  int? photoMaxSize = 1000;
  int? photoMaxFiles = 2;

  bool blogCommentFeature = false;

  bool loadBanner = false;

  bool updateVersion = false;

  bool isNeedLoadingExternalLink = false;
  setUpdateVersion(val) {
    updateVersion = val;
    notifyListeners();
  }

  toggleNeedLoadingExternalLink(bool value) {
    isNeedLoadingExternalLink = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> listMenu = [];
  String typeHeader = "";
  String logoHeader = "";

  Future<void> fetchHomeData(context) async {
    await fetchProductCategories(context);
  }

  Future<void> fetchProductCategories(context) async {
    final categories = Provider.of<CategoryProvider>(context, listen: false);
    //if (categories.productCategories.isEmpty) {
    Future.wait([
      categories.fetchProductCategories(),
      // fetchNewProducts(context)
    ]);
    //}
  }

  Future<void> fetchNewProducts(context) async {
    final product = Provider.of<ProductProvider>(context, listen: false);
    await product.fetchNewProducts('', page: 1);
  }

  Future<bool> fetchBlogComment() async {
    // loading = true;
    await HomeAPI().homeDataApi().then((data) {
      if (data.statusCode == 200) {
        final response = json.decode(data.body);
        if (response['general_settings']['blog_comment_feature'] != null) {
          blogCommentFeature =
              response['general_settings']['blog_comment_feature'];
          printLog(blogCommentFeature.toString(), name: 'blogComment');
        } else {
          blogCommentFeature = false;
        }
      }
    });
    // loading = false;
    notifyListeners();
    return blogCommentFeature;
  }

  setFinishToolTip() {
    finishToolTip = true;
    notifyListeners();
  }

  Future<void> fetchLobby() async {
    loading = true;
    await HomeAPI().customizeLobby().then((data) {
      final responseJson = json.decode(data.body);
      printLog(json.encode(responseJson), name: "Customize Lobby");
      customize.clear();
      for (int i = 0; i < responseJson['homepage'].length; i++) {
        if (responseJson['homepage'][i] == "section_a") {
          customize.add(SectionA());
        }
        if (responseJson['homepage'][i] == "section_b") {
          customize.add(SectionB());
        }
        if (responseJson['homepage'][i] == "section_c") {
          customize.add(SectionC());
        }
        if (responseJson['homepage'][i] == "section_d") {
          customize.add(SectionD());
        }
        if (responseJson['homepage'][i] == "section_e") {
          customize.add(SectionE());
        }
        if (responseJson['homepage'][i] == "section_f") {
          customize.add(SectionF());
        }
        if (responseJson['homepage'][i] == "section_g") {
          customize.add(SectionG());
        }
        if (responseJson['homepage'][i] == "section_h") {
          customize.add(SectionH());
        }
        if (responseJson['homepage'][i] == "section_bestdeal") {
          customize.add(SectionBestDeal());
        }
        if (responseJson['homepage'][i] == "section_i") {
          customize.add(SectionI());
          sectionI = true;
          notifyListeners();
        }
        if (responseJson['homepage'][i] == "section_j") {
          customize.add(SectionJ());
        }
        if (responseJson['homepage'][i] == "section_k") {
          customize.add(SectionK());
        }
        if (responseJson['homepage'][i] == "section_l") {
          customize.add(SectionL());
        }
        if (responseJson['homepage'][i] == "section_m") {
          customize.add(SectionM());
        }
        if (responseJson['homepage'][i] == "section_n") {
          customize.add(SectionN());
        }
        if (responseJson['homepage'][i] == "section_o") {
          customize.add(SectionO());
        }
        if (responseJson['homepage'][i] == "section_p") {
          customize.add(SectionP());
        }
        if (responseJson['homepage'][i] == "section_q") {
          customize.add(SectionQ());
        }
        if (responseJson['homepage'][i] == "section_recently_view") {
          customize.add(SectionRecentlyView());
        }
      }
    });
  }

  customizeHomepage(datas) {
    Map sections = {
      'section_a': SectionA(),
      'section_b': SectionB(),
      'section_c': SectionC(),
      'section_d': SectionD(),
      'section_e': SectionE(),
      'section_f': SectionF(),
      'section_g': SectionG(),
      'section_h': SectionH(),
      'section_i': SectionI(),
      'section_j': SectionJ(),
      'section_k': SectionK(),
      'section_l': SectionL(),
      'section_m': SectionM(),
      'section_n': SectionN(),
      'section_o': SectionO(),
      'section_p': SectionP(),
      'section_q': SectionQ(),
      'section_bestdeal': SectionBestDeal(),
      'section_recently_view': SectionRecentlyView(),
    };

    for (int i = 0; i < datas.length; i++) {
      customize.add(sections[datas[i]]);

      if (datas[i] == 'section_i') {
        sectionI = true;
        notifyListeners();
      }
    }
  }

  Future<bool?> fetchHome(context) async {
    loadBanner = true;
    loading = true;
    // listMenu.add({'title': 'Shop', 'link': 'shop'});
    // listMenu.add({
    //   'title': 'About Us',
    //   'link': 'https://demoonlineshop.revoapps.id/about-us/'
    // });
    // listMenu.add({
    //   'title': 'Privacy Policy',
    //   'link': 'https://demoonlineshop.revoapps.id/privacy-policy-html/'
    // });
    // listMenu.add({
    //   'title': 'Terms & Conditions',
    //   'link': 'https://demoonlineshop.revoapps.id/syarat-dan-ketentuan/'
    // });
    await HomeAPI().homeDataApi().then((data) {
      if (data.statusCode == 304) {
        final responseJson = json.decode(Session.data.getString('homeAPI')!);
        /*Add Data Main Slider*/
        banners.clear();
        banners2.clear();
        banners3.clear();

        //Video
        if (responseJson['general_settings']['video'] != null) {
          videoSetting = responseJson['general_settings']['video']
                      ['video_setting'] ==
                  "active"
              ? true
              : false;
          videoFileSize = responseJson['general_settings']['video']
                          ['video_file_size']
                      .toString() !=
                  ""
              ? int.parse(responseJson['general_settings']['video']
                      ['video_file_size']
                  .toString())
              : 0;
        }

        //header design
        if (responseJson['header_design'] != null) {
          if (responseJson['header_design']['menus'] != null) {
            for (var i in responseJson['header_design']['menus']) {
              listMenu.add(i);
            }
          }
          typeHeader = responseJson['header_design']['type'] ?? "v1";
          logoHeader = responseJson['header_design']['logo'] ?? "";
        }

        //Customize homepage
        customize.clear();
        customizeHomepage(responseJson['customize_homepage']);
        // End customize homepage
        printLog(jsonEncode(responseJson['main_slider']), name: "main slider");
        for (Map item in responseJson['main_slider']) {
          if (item['type'] == "banner-1") {
            banners.add(BannerModel.fromJson(item));
          }
          if (item['type'] == "banner-2") {
            banners2.add(BannerModel.fromJson(item));
          }
          if (item['type'] == "banner-3") {
            printLog(jsonEncode(item), name: "banners-3");
            banners3.add(BannerModel.fromJson(item));
          }
        }
        banners = new List.from(banners.reversed);
        banners2 = new List.from(banners2.reversed);
        banners3 = new List.from(banners3.reversed);

        printLog(jsonEncode(banners), name: "banners");
        printLog(jsonEncode(banners2), name: "banners2");
        printLog(jsonEncode(banners3), name: "banners3");

        /*End*/

        /*Add Data Mini Categories Home*/
        // categories.clear();
        // for (Map item in responseJson['mini_categories']) {
        //   categories.add(CategoriesModel.fromJson(item));
        // }
        // categories = new List.from(categories.reversed);
        categories.clear();
        collection.clear();
        categoriesSectionI.clear();
        categories3.clear();
        categories4.clear();
        categories6.clear();
        for (Map item in responseJson['categories']) {
          collection.add(ProductCategoryModel.fromJson(item));
        }
        for (Map item in responseJson['mini_categories']) {
          if (item['type'] == "mini") {
            categories.add(CategoriesModel.fromJson(item));
          }
          if (item['type'] == "big-category") {
            categoriesSectionI.add(CategoriesModel.fromJson(item));
          }
          if (item['type'] == "category-3") {
            categories3.add(CategoriesModel.fromJson(item));
          }
          if (item['type'] == "category-4") {
            categories4.add(CategoriesModel.fromJson(item));
          }
          if (item['type'] == "category-6") {
            categories6.add(CategoriesModel.fromJson(item));
          }
        }
        // categories.sort(
        //   (a, b) => a.sort!.compareTo(b.sort!),
        // );
        // categoriesSectionI.sort(
        //   (a, b) => a.sort!.compareTo(b.sort!),
        // );
        // categories3.sort(
        //   (a, b) => a.sort!.compareTo(b.sort!),
        // );
        // categories4.sort(
        //   (a, b) => a.sort!.compareTo(b.sort!),
        // );
        // categories6.sort(
        //   (a, b) => a.sort!.compareTo(b.sort!),
        // );
        // categories = new List.from(categories.reversed);
        printLog(jsonEncode(categoriesSectionI), name: "section i");
        // categories.add(new CategoriesModel(
        //     image: 'images/lobby/viewMore.png',
        //     categories: null,
        //     id: null,
        //     titleCategories:
        //         AppLocalizations.of(context)!.translate('view_more')));
        /*End*/

        /*Add Data Flash Sales Home*/
        for (Map item in responseJson['products_flash_sale']) {
          flashSales.add(FlashSaleHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data Mini Banner Home*/
        bannerSpecial.clear();
        bannerLove.clear();
        bannerSingle.clear();
        for (Map item in responseJson['mini_banner']) {
          if (item['type'] == 'Special Promo') {
            bannerSpecial.add(BannerMiniModel.fromJson(item));
          } else if (item['type'] == 'Love These Items') {
            bannerLove.add(BannerMiniModel.fromJson(item));
          } else if (item['type'] == 'Single Banner') {
            bannerSingle.add(BannerMiniModel.fromJson(item));
          }
        }
        /*End*/

        /*Add Data Banner PopUp*/
        bannerPopUp.clear();
        isBannerPopChanged = false;
        for (Map item in responseJson['popup_promo']) {
          bannerPopUp.add(BannerMiniModel.fromJson(item));
        }
        final DateTime now = DateTime.now();
        final DateFormat formatter = DateFormat('dd-MM-yyyy');
        final String formatted = formatter.format(now);
        if (Session.data.containsKey('image_popup_date')) {
          if (formatted != Session.data.getString('image_popup_date')) {
            isBannerPopChanged = true;
          }
        } else {
          isBannerPopChanged = true;
        }
        Session.data.setString('image_popup_date', formatted);
        /*End*/

        /*Add Data Special Products*/
        specialProducts.clear();
        for (Map item in responseJson['products_special']) {
          specialProducts.add(ProductExtendHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data Best Products*/
        bestProducts.clear();
        for (Map item in responseJson['products_our_best_seller']) {
          bestProducts.add(ProductExtendHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data Recommendation Products*/
        recommendationProducts.clear();
        for (Map item in responseJson['products_recomendation']) {
          recommendationProducts.add(ProductExtendHomeModel.fromJson(item));
        }

        /*Add Data Section M Products*/
        productSectionM.clear();
        for (Map item in responseJson['other_products']) {
          productSectionM.add(ProductExtendHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data General Settings*/
        for (Map item in responseJson['general_settings']['empty_image']) {
          if (item['title'] == '404_images') {
            image404 = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'thanks_order') {
            imageThanksOrder = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'no_transaksi' ||
              item['title'] == 'empty_transaksi') {
            imageNoTransaction = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'search_empty') {
            imageSearchEmpty = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'login_required') {
            imageNoLogin = GeneralSettingsModel.fromJson(item);
          }
        }

        printLog(imageNoTransaction.toString());

        logo = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['logo']);
        wa = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['wa']);
        sms = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['sms']);
        phone = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['phone']);
        about = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['about']);
        currency = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['currency']);
        formatCurrency = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['format_currency']);
        privacy = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['privacy_policy']);
        terms = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['term_condition']);
        if (responseJson['general_settings']['biteship'] != null) {
          biteship = responseJson['general_settings']['biteship']['status'];
          gmapAPIKey =
              responseJson['general_settings']['biteship']['gmap_api_key'];
        }
        if (responseJson['general_settings']['point_plugin'] != null) {
          isPointPluginActive =
              responseJson['general_settings']['point_plugin'];
        }
        if (responseJson['general_settings']['livechat_to_revopos'] != null) {
          isChatActive =
              responseJson['general_settings']['livechat_to_revopos'];
        }
        if (responseJson['general_settings']['design_product_page'] != null) {
          desainDetailProduct =
              responseJson['general_settings']['design_product_page'];
        }
        if (responseJson['general_settings']['popup_biometric'] != null) {
          popupBiometric = responseJson['general_settings']['popup_biometric'];
        }
        if (responseJson['general_settings']['terawallet'] != null) {
          isWalletActive = responseJson['general_settings']['terawallet'];
        }
        if (responseJson['general_settings']['gift_box'] != null) {
          String temp = responseJson['general_settings']['gift_box'];
          if (temp != "hide") {
            isGiftActive = true;
          }
        }
        if (responseJson['general_settings']['searchbar_text'] != null) {
          searchBarText = GeneralSettingsModel.fromJson(
              responseJson['general_settings']['searchbar_text']);
        }
        if (responseJson['general_settings']['sosmed_link'] != null) {
          sosmedLink = GeneralSettingsModel.fromJson(
              responseJson['general_settings']['sosmed_link']);
        }
        if (responseJson['general_settings']['product_settings'] != null) {
          showSoldItem = responseJson['general_settings']['product_settings']
              ['show_sold_item_data'];
          showAverageRating = responseJson['general_settings']
              ['product_settings']['show_average_rating_data'];
          showRatingSection = responseJson['general_settings']
              ['product_settings']['show_rating_section'];
          showVariationWithImage = responseJson['general_settings']
              ['product_settings']['show_variation_with_image'];
        }
        if (responseJson['general_settings']['barcode_active'] != null) {
          isBarcodeActive = responseJson['general_settings']['barcode_active'];
        }

        if (responseJson['general_settings']['guest_checkout'] != null) {
          guestCheckoutActive =
              responseJson['general_settings']['guest_checkout'] == 'disable'
                  ? false
                  : true;
        }

        if (responseJson['general_settings']['guide_feature'] != null) {
          toolTip = responseJson['general_settings']['guide_feature']['status'];

          imageGuide =
              responseJson['general_settings']['guide_feature']['image'];
        }

        if (responseJson['general_settings']['sync_cart'] != null) {
          syncCart = responseJson['general_settings']['sync_cart'];
        }

        if (responseJson['general_settings']['themehigh_multiple_addresses'] !=
            null) {
          statusMultipleAddress = responseJson['general_settings']
              ['themehigh_multiple_addresses']['status'];
          limitMultipleAddress = responseJson['general_settings']
              ['themehigh_multiple_addresses']['limit'];
        }

        if (responseJson['general_settings']['checkout_native'] != null) {
          checkoutFrom = responseJson['general_settings']['checkout_native'];
        }

        if (responseJson['general_settings']['photoreviews'] != null) {
          isPhotoReviewActive =
              responseJson['general_settings']['photoreviews']['status'];
          photoMaxFiles =
              responseJson['general_settings']['photoreviews']['maxfiles'];
          photoMaxSize =
              responseJson['general_settings']['photoreviews']['maxsize'];
          isPremium =
              responseJson['general_settings']['photoreviews']['is_premium'];
          textReviewTitle = responseJson['general_settings']['photoreviews']
              ['text_review_title'];
          textReviewHint = responseJson['general_settings']['photoreviews']
              ['text_review_title_hint'];
          textUploadRequirement = responseJson['general_settings']
              ['photoreviews']['text_upload_files_requirement'];
          gdprStatus = responseJson['general_settings']['photoreviews']['gdpr']
              ['status'];
          textGdpr = responseJson['general_settings']['photoreviews']['gdpr']
              ['text_gdpr'];
          helpfulStatus = responseJson['general_settings']['photoreviews']
              ['helpful_button']['status'];
          textHelpful = responseJson['general_settings']['photoreviews']
              ['helpful_button']['text_helpful'];
          colorVerified = responseJson['general_settings']['photoreviews']
              ['verified_owner']['color'];
          valueVerified = responseJson['general_settings']['photoreviews']
              ['verified_owner']['value'];
        }

        billingAddress.clear();
        if (responseJson['general_settings']['additional_billing_address'] !=
            null) {
          printLog(
              "MASUK 1: ${json.encode(responseJson['general_settings']['additional_billing_address'])}");
          for (Map item in responseJson['general_settings']
              ['additional_billing_address']) {
            billingAddress.add(BillingAddress.fromJson(item));
          }
          printLog("MASUK : ${json.encode(billingAddress)}");
        }

        /*End*/

        /*Add Data Intro Page & Splash Screen*/
        splashscreen =
            GeneralSettingsModel.fromJson(responseJson['splashscreen']);
        intro.clear();
        for (Map item in responseJson['intro']) {
          intro.add(GeneralSettingsModel.fromJson(item));
        }
        intro = new List.from(intro.reversed);

        introStatus = responseJson['intro_page_status'];
        /*End*/

        //Add Data home categories
        productCategories.clear();
        if (responseJson['categories'] != null) {
          for (Map item in responseJson['categories']) {
            productCategories.add(ProductCategoryModel.fromJson(item));
          }
        }

        listNewProduct.clear();
        if (responseJson['new_product'] != null) {
          for (Map item in responseJson['new_product']) {
            listNewProduct.add(ProductModel.fromJson(item));
            printLog(jsonEncode(listNewProduct[0].categories),
                name: "INI CATEGORY DARI HOME API");
          }
          for (int i = 0; i < listNewProduct.length; i++) {
            if (listNewProduct[i].type == 'variable') {
              for (int j = 0;
                  j < listNewProduct[i].availableVariations!.length;
                  j++) {
                if (listNewProduct[i]
                            .availableVariations![j]
                            .displayRegularPrice -
                        listNewProduct[i]
                            .availableVariations![j]
                            .displayPrice !=
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
        }

        /*Set Data App Color*/
        if (responseJson['app_color'] != null) {
          appColors.clear();
          for (Map item in responseJson['app_color']) {
            appColors.add(GeneralSettingsModel.fromJson(item));
          }
        }

        if (responseJson['general_settings']['buynow_button_style'] ==
            'solid') {
          isSolid = true;
        }
        printLog(isSolid.toString(), name: "is solid button");

        /*End*/

        contacts!.clear();
        if (wa.description != null && wa.description != '') {
          contacts!.add(new ContactModel(
              id: wa.title, title: 'WhatsApp', url: wa.description));
        }
        if (phone.description != null && phone.description != '') {
          contacts!.add(new ContactModel(
              id: phone.title, title: 'Call', url: "+${phone.description}"));
        }
        if (sms.description != null && sms.description != '') {
          contacts!.add(new ContactModel(
              id: sms.title, title: 'SMS', url: "+${sms.description}"));
        }
        if (isChatActive) {
          contacts!
              .add(new ContactModel(id: "chat", title: "Live Chat", url: ""));
        }

        if (responseJson['general_settings']['aftership'] != null) {
          afterShipCheck = AfterShipCheck.fromJson(
              responseJson['general_settings']['aftership']);
        }

        if (responseJson['general_settings']['login_page'] != null) {
          textHeading =
              responseJson['general_settings']['login_page']['text_heading'];
          text = responseJson['general_settings']['login_page']['text'];
          bgColor = responseJson['general_settings']['login_page']['bg_color'];
          textColor =
              responseJson['general_settings']['login_page']['text_color'];
          btnColor =
              responseJson['general_settings']['login_page']['btn_color'];
          bgImage = responseJson['general_settings']['login_page']['bg_image'];
          design = responseJson['general_settings']['login_page']['design'];
        }

        activateCurrency = responseJson['general_settings']['fox_woocs'];

        printLog(afterShipCheck!.pluginActive.toString(), name: 'AfterShip');

        print("Completed");
        loading = false;
        loadBanner = false;
        notifyListeners();
      } else if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);
        Session.data.setString('homeAPI', json.encode(responseJson));
        final headerJson = data.headers;
        Session.data.setString("home-revo-etag", headerJson['revo-etag']!);
        printLog(json.encode(data.headers), name: "HEADERS");
        /*Add Data Main Slider*/
        banners.clear();
        banners2.clear();
        banners3.clear();

        //Video
        if (responseJson['general_settings']['video'] != null) {
          videoSetting = responseJson['general_settings']['video']
                      ['video_setting'] ==
                  "active"
              ? true
              : false;
          videoFileSize = responseJson['general_settings']['video']
                          ['video_file_size']
                      .toString() !=
                  ""
              ? int.parse(responseJson['general_settings']['video']
                      ['video_file_size']
                  .toString())
              : 0;
        }

        //header design
        if (responseJson['header_design'] != null) {
          if (responseJson['header_design']['menus'] != null) {
            for (var i in responseJson['header_design']['menus']) {
              listMenu.add(i);
            }
          }
          typeHeader = responseJson['header_design']['type'] ?? "v1";
          logoHeader = responseJson['header_design']['logo'] ?? "";
        }

        //Customize homepage
        customize.clear();

        customizeHomepage(responseJson['customize_homepage']);
        //End customize homepage

        // for (Map item in responseJson['main_slider']) {
        //   banners.add(BannerModel.fromJson(item));
        // }
        // banners = new List.from(banners.reversed);
        printLog(jsonEncode(responseJson['main_slider']), name: "main slider");
        for (Map item in responseJson['main_slider']) {
          if (item['type'] == "banner-1") {
            banners.add(BannerModel.fromJson(item));
          }
          if (item['type'] == "banner-2") {
            banners2.add(BannerModel.fromJson(item));
          }
          if (item['type'] == "banner-3") {
            printLog(jsonEncode(item), name: "banners-3");
            banners3.add(BannerModel.fromJson(item));
          }
        }
        banners = new List.from(banners.reversed);
        banners2 = new List.from(banners2.reversed);
        banners3 = new List.from(banners3.reversed);

        printLog(jsonEncode(banners), name: "banners");
        printLog(jsonEncode(banners2), name: "banners2");
        printLog(jsonEncode(banners3), name: "banners3");

        /*End*/

        /*Add Data Mini Categories Home*/
        // categories.clear();
        // for (Map item in responseJson['mini_categories']) {
        //   categories.add(CategoriesModel.fromJson(item));
        // }
        // categories = new List.from(categories.reversed);
        categories.clear();
        collection.clear();
        categoriesSectionI.clear();
        categories3.clear();
        categories4.clear();
        categories6.clear();
        for (Map item in responseJson['categories']) {
          collection.add(ProductCategoryModel.fromJson(item));
        }
        for (Map item in responseJson['mini_categories']) {
          if (item['type'] == "mini") {
            categories.add(CategoriesModel.fromJson(item));
          }
          if (item['type'] == "big-category") {
            categoriesSectionI.add(CategoriesModel.fromJson(item));
          }
          if (item['type'] == "category-3") {
            categories3.add(CategoriesModel.fromJson(item));
          }
          if (item['type'] == "category-4") {
            categories4.add(CategoriesModel.fromJson(item));
          }
          if (item['type'] == "category-6") {
            categories6.add(CategoriesModel.fromJson(item));
          }
        }
        // categories.sort(
        //   (a, b) => a.sort!.compareTo(b.sort!),
        // );
        // categoriesSectionI.sort(
        //   (a, b) => a.sort!.compareTo(b.sort!),
        // );
        // categories3.sort(
        //   (a, b) => a.sort!.compareTo(b.sort!),
        // );
        // categories4.sort(
        //   (a, b) => a.sort!.compareTo(b.sort!),
        // );
        // categories6.sort(
        //   (a, b) => a.sort!.compareTo(b.sort!),
        // );
        // categories = new List.from(categories.reversed);
        printLog(jsonEncode(categoriesSectionI), name: "section i");
        // categories.add(new CategoriesModel(
        //     image: 'images/lobby/viewMore.png',
        //     categories: null,
        //     id: null,
        //     titleCategories:
        //         AppLocalizations.of(context)!.translate('view_more')));
        /*End*/

        /*Add Data Flash Sales Home*/
        for (Map item in responseJson['products_flash_sale']) {
          flashSales.add(FlashSaleHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data Mini Banner Home*/
        bannerSpecial.clear();
        bannerLove.clear();
        bannerSingle.clear();
        for (Map item in responseJson['mini_banner']) {
          if (item['type'] == 'Special Promo') {
            bannerSpecial.add(BannerMiniModel.fromJson(item));
          } else if (item['type'] == 'Love These Items') {
            bannerLove.add(BannerMiniModel.fromJson(item));
          } else if (item['type'] == 'Single Banner') {
            bannerSingle.add(BannerMiniModel.fromJson(item));
          }
        }
        /*End*/

        /*Add Data Banner PopUp*/
        bannerPopUp.clear();
        isBannerPopChanged = false;
        for (Map item in responseJson['popup_promo']) {
          bannerPopUp.add(BannerMiniModel.fromJson(item));
        }
        final DateTime now = DateTime.now();
        final DateFormat formatter = DateFormat('dd-MM-yyyy');
        final String formatted = formatter.format(now);
        if (Session.data.containsKey('image_popup_date')) {
          if (formatted != Session.data.getString('image_popup_date')) {
            isBannerPopChanged = true;
          }
        } else {
          isBannerPopChanged = true;
        }
        Session.data.setString('image_popup_date', formatted);
        /*End*/

        /*Add Data Special Products*/
        specialProducts.clear();
        for (Map item in responseJson['products_special']) {
          specialProducts.add(ProductExtendHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data Best Products*/
        bestProducts.clear();
        for (Map item in responseJson['products_our_best_seller']) {
          bestProducts.add(ProductExtendHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data Recommendation Products*/
        recommendationProducts.clear();
        for (Map item in responseJson['products_recomendation']) {
          recommendationProducts.add(ProductExtendHomeModel.fromJson(item));
        }

        /*Add Data Section M Products*/
        productSectionM.clear();
        for (Map item in responseJson['other_products']) {
          productSectionM.add(ProductExtendHomeModel.fromJson(item));
        }
        /*End*/

        /*Add Data General Settings*/
        for (Map item in responseJson['general_settings']['empty_image']) {
          if (item['title'] == '404_images') {
            image404 = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'thanks_order') {
            imageThanksOrder = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'no_transaksi' ||
              item['title'] == 'empty_transaksi') {
            imageNoTransaction = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'search_empty') {
            imageSearchEmpty = GeneralSettingsModel.fromJson(item);
          } else if (item['title'] == 'login_required') {
            imageNoLogin = GeneralSettingsModel.fromJson(item);
          }
        }

        printLog(imageNoTransaction.toString());

        logo = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['logo']);
        wa = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['wa']);
        sms = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['sms']);
        phone = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['phone']);
        about = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['about']);
        currency = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['currency']);
        formatCurrency = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['format_currency']);
        privacy = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['privacy_policy']);
        terms = GeneralSettingsModel.fromJson(
            responseJson['general_settings']['term_condition']);
        if (responseJson['general_settings']['biteship'] != null) {
          biteship = responseJson['general_settings']['biteship']['status'];
          gmapAPIKey =
              responseJson['general_settings']['biteship']['gmap_api_key'];
        }
        if (responseJson['general_settings']['point_plugin'] != null) {
          isPointPluginActive =
              responseJson['general_settings']['point_plugin'];
        }
        if (responseJson['general_settings']['livechat_to_revopos'] != null) {
          isChatActive =
              responseJson['general_settings']['livechat_to_revopos'];
        }
        if (responseJson['general_settings']['local_pickup_plus'] != null) {
          isLocalPickupPlusActive =
              responseJson['general_settings']['local_pickup_plus'];
        }
        if (responseJson['general_settings']['design_product_page'] != null) {
          desainDetailProduct =
              responseJson['general_settings']['design_product_page'];
        }
        if (responseJson['general_settings']['popup_biometric'] != null) {
          popupBiometric = responseJson['general_settings']['popup_biometric'];
        }
        if (responseJson['general_settings']['terawallet'] != null) {
          isWalletActive = responseJson['general_settings']['terawallet'];
        }
        if (responseJson['general_settings']['gift_box'] != null) {
          String temp = responseJson['general_settings']['gift_box'];
          if (temp != "hide") {
            isGiftActive = true;
          }
        }
        if (responseJson['general_settings']['searchbar_text'] != null) {
          searchBarText = GeneralSettingsModel.fromJson(
              responseJson['general_settings']['searchbar_text']);
        }
        if (responseJson['general_settings']['sosmed_link'] != null) {
          sosmedLink = GeneralSettingsModel.fromJson(
              responseJson['general_settings']['sosmed_link']);
        }
        if (responseJson['general_settings']['product_settings'] != null) {
          showSoldItem = responseJson['general_settings']['product_settings']
              ['show_sold_item_data'];
          showAverageRating = responseJson['general_settings']
              ['product_settings']['show_average_rating_data'];
          showRatingSection = responseJson['general_settings']
              ['product_settings']['show_rating_section'];
          showVariationWithImage = responseJson['general_settings']
              ['product_settings']['show_variation_with_image'];
        }
        if (responseJson['general_settings']['barcode_active'] != null) {
          isBarcodeActive = responseJson['general_settings']['barcode_active'];
        }

        if (responseJson['general_settings']['guest_checkout'] != null) {
          guestCheckoutActive =
              responseJson['general_settings']['guest_checkout'] == 'disable'
                  ? false
                  : true;
        }

        if (responseJson['general_settings']['guide_feature'] != null) {
          toolTip = responseJson['general_settings']['guide_feature']['status'];

          imageGuide =
              responseJson['general_settings']['guide_feature']['image'];
        }

        if (responseJson['general_settings']['sync_cart'] != null) {
          syncCart = responseJson['general_settings']['sync_cart'];
        }

        if (responseJson['general_settings']['themehigh_multiple_addresses'] !=
            null) {
          statusMultipleAddress = responseJson['general_settings']
              ['themehigh_multiple_addresses']['status'];
          limitMultipleAddress = responseJson['general_settings']
              ['themehigh_multiple_addresses']['limit'];
        }

        if (responseJson['general_settings']['checkout'] != null) {
          checkoutFrom = responseJson['general_settings']['checkout'];
        }

        if (responseJson['general_settings']['photoreviews'] != null) {
          isPhotoReviewActive =
              responseJson['general_settings']['photoreviews']['status'];
          photoMaxFiles =
              responseJson['general_settings']['photoreviews']['maxfiles'];
          photoMaxSize =
              responseJson['general_settings']['photoreviews']['maxsize'];
          isPremium =
              responseJson['general_settings']['photoreviews']['is_premium'];
          textReviewTitle = responseJson['general_settings']['photoreviews']
              ['text_review_title'];
          textReviewHint = responseJson['general_settings']['photoreviews']
              ['text_review_title_hint'];
          textUploadRequirement = responseJson['general_settings']
              ['photoreviews']['text_upload_files_requirement'];
          gdprStatus = responseJson['general_settings']['photoreviews']['gdpr']
              ['status'];
          textGdpr = responseJson['general_settings']['photoreviews']['gdpr']
              ['text_gdpr'];
          helpfulStatus = responseJson['general_settings']['photoreviews']
              ['helpful_button']['status'];
          textHelpful = responseJson['general_settings']['photoreviews']
              ['helpful_button']['text_helpful'];
          colorVerified = responseJson['general_settings']['photoreviews']
              ['verified_owner']['color'];
          valueVerified = responseJson['general_settings']['photoreviews']
              ['verified_owner']['value'];
        }

        billingAddress.clear();
        if (responseJson['general_settings']['additional_billing_address'] !=
            null) {
          printLog(
              "MASUK 1: ${json.encode(responseJson['general_settings']['additional_billing_address'])}");
          for (Map item in responseJson['general_settings']
              ['additional_billing_address']) {
            billingAddress.add(BillingAddress.fromJson(item));
          }
          printLog("MASUK : ${json.encode(billingAddress)}");
        }

        /*End*/

        /*Add Data Intro Page & Splash Screen*/
        splashscreen =
            GeneralSettingsModel.fromJson(responseJson['splashscreen']);
        intro.clear();
        for (Map item in responseJson['intro']) {
          intro.add(GeneralSettingsModel.fromJson(item));
        }
        intro = new List.from(intro.reversed);

        introStatus = responseJson['intro_page_status'];
        /*End*/

        //Add Data home categories
        productCategories.clear();
        if (responseJson['categories'] != null) {
          for (Map item in responseJson['categories']) {
            productCategories.add(ProductCategoryModel.fromJson(item));
          }
        }

        listNewProduct.clear();
        if (responseJson['new_product'] != null) {
          for (Map item in responseJson['new_product']) {
            listNewProduct.add(ProductModel.fromJson(item));
            printLog(jsonEncode(listNewProduct[0].categories),
                name: "INI CATEGORY DARI HOME API");
          }
          for (int i = 0; i < listNewProduct.length; i++) {
            if (listNewProduct[i].type == 'variable') {
              for (int j = 0;
                  j < listNewProduct[i].availableVariations!.length;
                  j++) {
                if (listNewProduct[i]
                            .availableVariations![j]
                            .displayRegularPrice -
                        listNewProduct[i]
                            .availableVariations![j]
                            .displayPrice !=
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
        }

        /*Set Data App Color*/
        if (responseJson['app_color'] != null) {
          appColors.clear();
          for (Map item in responseJson['app_color']) {
            appColors.add(GeneralSettingsModel.fromJson(item));
          }
        }

        if (responseJson['general_settings']['buynow_button_style'] ==
            'solid') {
          isSolid = true;
        }
        printLog(isSolid.toString(), name: "is solid button");

        /*End*/

        contacts!.clear();
        if (wa.description != null && wa.description != '') {
          contacts!.add(new ContactModel(
              id: wa.title, title: 'WhatsApp', url: wa.description));
        }
        if (phone.description != null && phone.description != '') {
          contacts!.add(new ContactModel(
              id: phone.title, title: 'Call', url: "+${phone.description}"));
        }
        if (sms.description != null && sms.description != '') {
          contacts!.add(new ContactModel(
              id: sms.title, title: 'SMS', url: "+${sms.description}"));
        }
        if (isChatActive) {
          contacts!
              .add(new ContactModel(id: "chat", title: "Live Chat", url: ""));
        }

        if (responseJson['general_settings']['aftership'] != null) {
          afterShipCheck = AfterShipCheck.fromJson(
              responseJson['general_settings']['aftership']);
        }

        if (responseJson['general_settings']['login_page'] != null) {
          textHeading =
              responseJson['general_settings']['login_page']['text_heading'];
          text = responseJson['general_settings']['login_page']['text'];
          bgColor = responseJson['general_settings']['login_page']['bg_color'];
          textColor =
              responseJson['general_settings']['login_page']['text_color'];
          btnColor =
              responseJson['general_settings']['login_page']['btn_color'];
          bgImage = responseJson['general_settings']['login_page']['bg_image'];
          design = responseJson['general_settings']['login_page']['design'];
        }

        activateCurrency = responseJson['general_settings']['fox_woocs'];

        printLog(afterShipCheck!.pluginActive.toString(), name: 'AfterShip');

        print("Completed");
        loading = false;
        loadBanner = false;
        notifyListeners();
      } else {
        loading = false;
        loadBanner = false;
        isLoadHomeSuccess = false;
        notifyListeners();
        print("Load Failed");
      }
    });
    return isLoadHomeSuccess;
    try {} catch (e) {
      loading = false;
      loadBanner = false;
      isLoadHomeSuccess = false;
      notifyListeners();
      printLog('Error, $e', name: "Home Load Failed");
      return isLoadHomeSuccess;
    }
  }

  Future<bool> fetchMoreRecommendation(String? productId, {int? page}) async {
    loadingMore = true;
    await ProductAPI()
        .fetchMoreProduct(
            include: productId, page: page, perPage: 10, order: '', orderBy: '')
        .then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        tempProducts.clear();
        for (Map item in responseJson) {
          tempProducts.add(ProductModel.fromJson(item));
        }

        loadVariationData(listProduct: tempProducts, load: loadingMore)
            .then((value) {
          tempProducts.forEach((element) {
            recommendationProducts[0].products!.add(element);
          });
          loadingMore = false;
          notifyListeners();
        });
      } else {
        print("Load Failed");
        loadingMore = false;
        notifyListeners();
      }
    });
    return true;
  }

  Future<bool?> loadVariationData(
      {required List<ProductModel> listProduct, bool? load}) async {
    listProduct.forEach((element) async {
      if (element.type == 'variable') {
        List<VariationModel> variations = [];
        notifyListeners();
        load = true;
        await ProductAPI()
            .productVariations(productId: element.id.toString())
            .then((value) {
          if (value.statusCode == 200) {
            final variation = json.decode(value.body);

            for (Map item in variation) {
              if (item['price'].isNotEmpty) {
                variations.add(VariationModel.fromJson(item));
              }
            }

            variations.forEach((v) {
              /*printLog('${element.productName} ${v.id} ${v.price}',
                  name: 'Price Variation 2');*/
              element.variationPrices!.add(double.parse(v.price!));
            });

            element.variationPrices!.sort((a, b) => a.compareTo(b));
          }
          load = false;
          notifyListeners();
        });
      } else {
        load = false;
        notifyListeners();
      }
    });
    return load;
  }

  changeIsReload() {
    isReload = false;
    notifyListeners();
  }

  setPackageInfo(value) {
    packageInfo = value;
    notifyListeners();
  }

  changePopBannerStatus(value) {
    isBannerPopChanged = value;
    notifyListeners();
  }
}
