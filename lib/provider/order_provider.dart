import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nyoba/models/cart_model.dart';
import 'package:nyoba/models/order_model.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/auth/sign_in_otp_screen.dart';
import 'package:nyoba/pages/order/checkout_native_screen.dart';
import 'package:nyoba/pages/order/order_success_animation_screen.dart';
import 'package:nyoba/provider/checkout_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/services/order_api.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/webview/checkout_webview.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import 'coupon_provider.dart';

class OrderProvider with ChangeNotifier {
  ProductModel? productDetail;
  String? status;
  String? search;

  bool isLoading = false;
  bool loadDataOrder = false;

  List<OrderModel> listOrder = [];
  List<OrderModel> tempOrder = [];
  int orderPage = 1;

  List<ProductModel?> listProductOrder = [];
  List<ProductModel?> tempProductOrder = [];

  String? variationName = '';

  OrderModel? detailOrder;
  int cartCount = 0;

  Future checkout(order) async {
    var result;
    await OrderAPI()
        .checkoutOrder(order, Session.data.getString('currency_code')!)
        .then((data) {
      printLog(data, name: 'Link Order From API');
      result = data;
    });
    return result;
  }

  bool cekInsert = true;
  Future<List?> fetchOrders({status, search, orderId}) async {
    isLoading = true;
    var result;
    await OrderAPI()
        .listMyOrder(status, search, orderId, orderPage)
        .then((data) {
      result = data;
      List _order = result;

      tempOrder = [];
      if (cekInsert) {
        tempOrder
            .addAll(_order.map((order) => OrderModel.fromJson(order)).toList());
      }

      List<OrderModel> list = List.from(listOrder);
      list.addAll(tempOrder);
      listOrder = list;
      if (listOrder.length < 10) {
        cekInsert = false;
      }
      if (tempOrder.length % 10 == 0) {
        orderPage++;
      }

      listOrder.forEach((element) {
        element.productItems!.sort((a, b) => b.image!.compareTo(a.image!));
      });

      isLoading = false;
      notifyListeners();
      printLog(result.toString());
    });
    return result;
  }

  String statusOrder = "";
  Future<List?> fetchDetailOrder(orderId) async {
    isLoading = true;
    var result;
    await OrderAPI().detailOrder(orderId).then((data) {
      result = data;
      printLog(json.encode(result));

      for (Map item in result) {
        detailOrder = OrderModel.fromJson(item);
      }
      switch (detailOrder!.status) {
        case "pending":
          {
            statusOrder = "Pending Payment";
          }
          break;
        case "processing":
          {
            statusOrder = "Processing";
          }
          break;
        case "ready-to-pick-up":
          {
            statusOrder = "Ready to Pick Up";
          }
          break;
        case "on-delivery":
          {
            statusOrder = "On Delivery";
          }
          break;
        case "completed":
          {
            statusOrder = "Completed";
          }
          break;
        case "cancelled":
          {
            statusOrder = "Cancelled";
          }
          break;
        case "refunded":
          {
            statusOrder = "Refunded";
          }
          break;
        case "failed":
          {
            statusOrder = "Failed";
          }
          break;
        default:
          {
            statusOrder = "On Hold";
          }
          break;
      }
      isLoading = false;
      notifyListeners();
      printLog(result.toString());
    });
    return result;
  }

  Future<dynamic> loadCartCount() async {
    print('Load Count');
    List<ProductModel> productCart = [];
    int _count = 0;

    if (Session.data.containsKey('cart')) {
      List listCart = await json.decode(Session.data.getString('cart')!);

      productCart = listCart
          .map((product) => new ProductModel.fromJson(product))
          .toList();

      productCart.forEach((element) {
        _count += element.cartQuantity!;
      });
    }

    cartCount = _count;
    notifyListeners();
    return _count;
  }

  Future checkOutOrder(context,
      {int? totalSelected,
      List<ProductModel>? productCart,
      Future<dynamic> Function()? removeOrderedItems}) async {
    final coupons = Provider.of<CouponProvider>(context, listen: false);
    final guestCheckoutActive =
        Provider.of<HomeProvider>(context, listen: false).guestCheckoutActive;

    if (totalSelected == 0) {
      return snackBar(context,
          message: AppLocalizations.of(context)!
              .translate('snackbar_product_select')!);
    } else {
      if (!Session.data.getBool('isLogin')! && !guestCheckoutActive) {
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SignInOTPScreen(
                      isFromNavBar: false,
                    )));
      }
      CartModel cart = new CartModel();
      cart.listItem = [];
      productCart!.forEach((element) {
        if (element.isSelected!) {
          var variation = {};
          if (element.selectedVariation!.isNotEmpty) {
            element.selectedVariation!.forEach((elementVar) {
              String columnName = elementVar.columnName!.toLowerCase();
              String? value = elementVar.value;

              variation['attribute_$columnName'] = "$value";
            });
          }
          cart.listItem!.add(new CartProductItem(
            productId: element.id,
            quantity: element.cartQuantity,
            variationId: element.variantId,
            variation: [variation],
            addons: element.selectedAddOn,
            videoId: element.videoId ?? "",
            dateProductCart: element.dateProductCart ?? '',
          ));
        }
      });

      //init list coupon
      cart.listCoupon = [];
      //check coupon
      if (coupons.couponUsed != null) {
        cart.listCoupon!.add(new CartCoupon(code: coupons.couponUsed!.code));
      }

      //add to cart model
      cart.paymentMethod = "xendit_bniva";
      cart.paymentMethodTitle = "Bank Transfer - BNI";
      cart.setPaid = true;
      cart.customerId = Session.data.getInt('id');
      cart.status = 'completed';
      cart.lang = Session.data.getString("language_code");
      cart.token = guestCheckoutActive && Session.data.getBool('isLogin')!
          ? Session.data.getString('cookie')
          : !guestCheckoutActive && Session.data.getBool('isLogin')!
              ? Session.data.getString('cookie')
              : "";
      if (Session.data.containsKey('ref_path'))
        cart.referral = Session.data.getString('ref_path');
      if (guestCheckoutActive && Session.data.getBool('isLogin')!) {
        printLog('Set Cookie', name: "COOKIEP");
      } else {
        printLog('No Set Cookie', name: "COOKIEP");
      }

      //Encode Json
      final jsonOrder = json.encode(cart);
      printLog(jsonOrder, name: 'Json Order');

      //Convert Json to bytes
      var bytes = utf8.encode(jsonOrder);

      //Convert bytes to base64
      var order = base64.encode(bytes);

      //Generate link WebView checkout
      if (Provider.of<HomeProvider>(context, listen: false).checkoutFrom) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CheckOutNative(
                      fromBuyNow: false,
                      line: cart.listItem,
                    )));
      } else {
        await Provider.of<OrderProvider>(context, listen: false)
            .checkout(order)
            .then((value) async {
          printLog(value, name: 'Link Order');
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CheckoutWebView(
                        url: value,
                        onFinish: removeOrderedItems,
                        fromCart: true,
                      )));
        });
      }
    }
  }

  Future onFinishBuyNow(context) async {
    //if (mounted) {
    print("masuk sini");
    await Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => OrderSuccessAnimationScreen()));
    //}
  }

  Future buyNow(context,
      {ProductModel? product,
      Future<dynamic> Function()? onFinishBuyNow,
      String? videoId}) async {
    final guestCheckoutActive =
        Provider.of<HomeProvider>(context, listen: false).guestCheckoutActive;
    if (!Session.data.getBool('isLogin')! && !guestCheckoutActive) {
      return Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SignInOTPScreen(
                    isFromNavBar: false,
                  )));
    }
    CartModel cart = new CartModel();
    cart.listItem = [];

    var variation = {};
    if (product!.selectedVariation!.isNotEmpty) {
      product.selectedVariation!.forEach((elementVar) {
        String columnName = elementVar.columnName!.toLowerCase();
        String? value = elementVar.value;

        variation['attribute_$columnName'] = "$value";
      });
    }
    cart.listItem!.add(new CartProductItem(
      productId: product.id,
      quantity: product.cartQuantity,
      variationId: product.variantId,
      variation: [variation],
      videoId: product.videoId ?? '',
      dateProductCart: product.dateProductCart ?? '',
    ));

    printLog(jsonEncode(cart.listItem!), name: "ISI Cart");
    printLog(jsonEncode(cart), name: "ISI Cart2");

    //init list coupon
    cart.listCoupon = [];

    //add to cart model
    cart.paymentMethod = "xendit_bniva";
    cart.paymentMethodTitle = "Bank Transfer - BNI";
    cart.setPaid = true;
    cart.customerId = Session.data.getInt('id');
    cart.lang = Session.data.getString("language_code");
    cart.status = 'completed';
    cart.token = guestCheckoutActive && Session.data.getBool('isLogin')!
        ? Session.data.getString('cookie')
        : !guestCheckoutActive && Session.data.getBool('isLogin')!
            ? Session.data.getString('cookie')
            : "";
    cart.videoId = videoId ?? "";
    if (Session.data.containsKey('ref_path'))
      cart.referral = Session.data.getString('ref_path');
    //Encode Json
    final jsonOrder = json.encode(cart);
    printLog(jsonOrder, name: 'Json Order');

    //Convert Json to bytes
    var bytes = utf8.encode(jsonOrder);

    //Convert bytes to base64
    var order = base64.encode(bytes);

    //Generate link WebView checkout
    if (Provider.of<HomeProvider>(context, listen: false).checkoutFrom) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CheckOutNative(
                    fromBuyNow: false,
                    line: cart.listItem,
                  )));
    } else {
      await Provider.of<OrderProvider>(context, listen: false)
          .checkout(order)
          .then((value) async {
        printLog(value, name: 'Link Order');
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CheckoutWebView(
                      url: value,
                      onFinish: null,
                      fromCart: false,
                    )));
      });
    }
  }

  Future<void> loadItemOrder(context) async {
    loadDataOrder = true;
    notifyListeners();
    if (detailOrder != null) {
      listProductOrder.clear();
      detailOrder!.productItems!.forEach((element) async {
        await Provider.of<ProductProvider>(context, listen: false)
            .fetchProductDetail(element.productId.toString())
            .then((value) {
          listProductOrder.add(value);
          if (listProductOrder.length == detailOrder!.productItems!.length) {
            loadDataOrder = false;
            notifyListeners();
          }
        });
      });
    }
  }

  List<ProductVariation> variation = [];
  Map<String, dynamic>? variationResult;
  MinMaxQuantity? minMax;
  num? variationPrice = 0;
  bool isAvailable = false;
  bool isOutStock = false;
  int? variationStock = 0;
  bool loadingCheckVariant = false;
  checkProductVariant(context, ProductModel productModel) async {
    loadingCheckVariant = true;
    notifyListeners();
    var tempVar = [];
    variation = [];
    productModel.customVariation!.forEach((element) {
      tempVar.add(element.selectedName);
      variation.add(ProductVariation(
          id: element.id,
          value: element.selectedValue,
          columnName: element.slug));
    });

    printLog(json.encode(productModel));
    // variationName = tempVar.join(", ");
    // productModel.variationName = variationName;
    final product = Provider.of<ProductProvider>(context, listen: false);
    final Future<Map<String, dynamic>?> productResponse =
        product.checkVariation(productId: productModel.id, list: variation);
    productResponse.then((value) {
      if (value!['variation_id'] != 0) {
        productModel.variantId = value['variation_id'];
        productModel.minMaxQuantity =
            MinMaxQuantity.fromJson(value['data']['minmax_quantity']);
        productModel.cartQuantity = productModel.minMaxQuantity!.minQty;
        variationResult = value;
        minMax = MinMaxQuantity.fromJson(value['data']['minmax_quantity']);
        productModel.availableVariations!.forEach((element) {
          if (element.variationId == productModel.variantId) {
            variationPrice = element.displayPrice!;
          }
        });
        if (value['data']['wholesales'] != null &&
            value['data']['wholesales'].isNotEmpty) {
          if (value['data']['wholesales'][0]['price'].isNotEmpty &&
              Session.data.getString('role') == 'wholesale_customer') {
            variationPrice =
                double.parse(value['data']['wholesales'][0]['price']);
          }
        }
        if (value['data']['stock_status'] == 'instock' &&
                value['data']['stock_quantity'] == null ||
            value['data']['stock_quantity'] == 0 &&
                value['data']['stock_status'] == 'instock') {
          variationStock = 999;
          isAvailable = true;
          isOutStock = false;
        } else if (value['data']['stock_status'] == 'outofstock') {
          print('outofstock');
          isAvailable = true;
          isOutStock = true;
          variationStock = 0;
        } else if (value['data']['price'] == 0) {
          print('price not set');
          isAvailable = false;
          isOutStock = false;
          variationStock = 0;
        } else {
          print('else');
          variationStock = value['data']['stock_quantity'];
          isAvailable = true;
          isOutStock = false;
        }
        loadingCheckVariant = false;
        notifyListeners();
      } else {
        variationPrice = 0;
        isAvailable = false;
        loadingCheckVariant = false;
        notifyListeners();
      }
      printLog(isAvailable.toString(), name: 'Is Available');
      printLog(isOutStock.toString(), name: 'Is Out Stock');
    });
  }

  Future<void> actionBuyAgain(context) async {
    printLog("MASUK BUY NOW");
    List<ProductModel> _OutOfStockProducts = [];
    for (int i = 0; i < detailOrder!.productItems!.length; i++) {
      for (int j = 0; j < listProductOrder.length; j++) {
        if (listProductOrder[j]!.type != "simple") {
          if (listProductOrder[j]!.availableVariations != null &&
              listProductOrder[j]!.availableVariations!.isNotEmpty) {
            for (int k = 0;
                k < listProductOrder[j]!.availableVariations!.length;
                k++) {
              if (listProductOrder[j]!.id ==
                      detailOrder!.productItems![i].productId &&
                  listProductOrder[j]!.availableVariations![k].variationId ==
                      detailOrder!.productItems![i].variationId &&
                  i == j) {
                // listProductOrder[j]!.variationName = variationName;
                listProductOrder[j]!.productName =
                    detailOrder!.productItems![i].productName;
                listProductOrder[j]!.cartQuantity =
                    detailOrder!.productItems![i].quantity;
                listProductOrder[j]!.variantId =
                    detailOrder!.productItems![i].variationId;
                listProductOrder[j]!.showImage =
                    detailOrder!.productItems![i].image;

                listProductOrder[j]!.priceTotal =
                    listProductOrder[j]!.availableVariations![k].displayPrice *
                        listProductOrder[j]!.cartQuantity!;
                listProductOrder[j]!.attributes!.forEach((elementAttr) {
                  detailOrder!.productItems![i].metaData!
                      .forEach((elementMeta) {
                    if (elementAttr.name!.toLowerCase().replaceAll(" ", "-") ==
                        elementMeta.key) {
                      elementAttr.selectedVariant = elementMeta.value;
                    }
                  });
                });
                checkProductVariant(context, listProductOrder[j]!).then((data) {
                  listProductOrder[j]!.productStock = variationStock;
                  if (listProductOrder[j]!.cartQuantity! > variationStock!) {
                    _OutOfStockProducts.add(listProductOrder[j]!);
                  }
                });
              }
            }
          }
        } else if (listProductOrder[j]!.id ==
                detailOrder!.productItems![i].productId &&
            listProductOrder[j]!.type == "simple") {
          listProductOrder[j]!.variationName = variationName;
          listProductOrder[j]!.productName =
              detailOrder!.productItems![i].productName;
          listProductOrder[j]!.cartQuantity =
              detailOrder!.productItems![i].quantity;
          listProductOrder[j]!.variantId =
              detailOrder!.productItems![i].variationId;
          listProductOrder[j]!.showImage = detailOrder!.productItems![i].image;
          listProductOrder[j]!.priceTotal = listProductOrder[j]!.productPrice! *
              listProductOrder[j]!.cartQuantity!;
          listProductOrder[j]!.attributes!.forEach((elementAttr) {
            listProductOrder[j]!.metaData!.forEach((elementMeta) {
              if (elementAttr.name!.toLowerCase().replaceAll(" ", "-") ==
                  elementMeta.key) {
                elementAttr.selectedVariant = elementMeta.value;
              }
            });
          });
          if (listProductOrder[j]!.productStock! <
              detailOrder!.productItems![i].quantity!) {
            _OutOfStockProducts.add(listProductOrder[j]!);
          }
        }
      }
    }
    // detailOrder!.productItems!.forEach((elementOrder) {
    //   listProductOrder.forEach((element) {
    //     if (element!.type != "simple") {
    //       if (element.availableVariations != null &&
    //           element.availableVariations!.isNotEmpty) {
    //         element.availableVariations?.forEach((availableVariation) {
    //           if (element.id == elementOrder.productId &&
    //               availableVariation.variationId == elementOrder.variationId) {
    //             element.variationName = variationName;
    //             element.productName = elementOrder.productName;
    //             element.cartQuantity = elementOrder.quantity;
    //             element.variantId = elementOrder.variationId;
    //             element.showImage = elementOrder.image;
    //             element.priceTotal =
    //                 element.productPrice! * element.cartQuantity!;
    //             element.attributes!.forEach((elementAttr) {
    //               elementOrder.metaData!.forEach((elementMeta) {
    //                 if (elementAttr.name!.toLowerCase().replaceAll(" ", "-") ==
    //                     elementMeta.key) {
    //                   elementAttr.selectedVariant = elementMeta.value;
    //                 }
    //               });
    //             });
    //             checkProductVariant(context, element).then((data) {
    //               element.productStock = variationStock;
    //               if (element.cartQuantity! > variationStock!) {
    //                 _OutOfStockProducts.add(element);
    //               }
    //             });
    //           }
    //         });
    //       }
    //     } else if (element.id == elementOrder.productId &&
    //         element.type == "simple") {
    //       print('${element.id} == ${elementOrder.productId}');
    //       element.variationName = variationName;
    //       element.productName = elementOrder.productName;
    //       element.cartQuantity = elementOrder.quantity;
    //       element.variantId = elementOrder.variationId;
    //       element.showImage = elementOrder.image;
    //       element.priceTotal = element.productPrice! * element.cartQuantity!;
    //       element.attributes!.forEach((elementAttr) {
    //         elementOrder.metaData!.forEach((elementMeta) {
    //           if (elementAttr.name!.toLowerCase().replaceAll(" ", "-") ==
    //               elementMeta.key) {
    //             elementAttr.selectedVariant = elementMeta.value;
    //           }
    //         });
    //       });
    //       if (element.productStock! < elementOrder.quantity!) {
    //         _OutOfStockProducts.add(element);
    //       }
    //     }
    //   });
    // });

    List<ProductModel?> tempListProductOrder = [];
    tempListProductOrder = listProductOrder;
    if (_OutOfStockProducts.isNotEmpty) {
      for (int i = 0; i < _OutOfStockProducts.length; i++) {
        tempListProductOrder
            .removeWhere((element) => element == _OutOfStockProducts[i]);
      }
    }
    printLog(json.encode(_OutOfStockProducts), name: "List Product");
    printLog(json.encode(tempListProductOrder), name: "Temp List Product");
    List<CartProductItem> line = [];
    for (int i = 0; i < tempListProductOrder.length; i++) {
      await addCart(tempListProductOrder[i], context);
      line.add(CartProductItem(
          productId: tempListProductOrder[i]!.id,
          quantity: tempListProductOrder[i]!.cartQuantity,
          variationId: tempListProductOrder[i]!.variantId,
          variation: tempListProductOrder[i]!.selectedVariation));
    }
    if (Provider.of<HomeProvider>(context, listen: false).syncCart) {
      Provider.of<CheckoutProvider>(context, listen: false)
          .createCart(line: line)
          .then((value) {
        if (value.toString().contains("error")) {
          return snackBar(context,
              message: AppLocalizations.of(context)!
                  .translate('snackbar_cart_add_failed')!);
        }
      });
    }
    snackBar(context,
        message: AppLocalizations.of(context)!.translate('add_cart_message')!);
  }

  /*add to cart*/
  Future addCart(ProductModel? product, context) async {
    printLog("MASUK ADD CART");
    if (!Session.data.containsKey('cart')) {
      List<ProductModel> listCart = [];
      // product!.priceTotal = (product.cartQuantity! * product.productPrice!);
      //PENGECEKAN MAX QTY
      if (product!.minMaxQuantity!.maxQty >= product.cartQuantity!) {
        listCart.add(product);
      } else if (product.minMaxQuantity!.maxQty < product.cartQuantity!) {
        Navigator.pop(context, false);
        return snackBar(context,
            message:
                "Maximum purchase is ${product.minMaxQuantity!.maxQty} pcs");
      }
      await Session.data.setString('cart', json.encode(listCart));
    } else {
      List products = await json.decode(Session.data.getString('cart')!);

      List<ProductModel> listCart = products
          .map((product) => new ProductModel.fromJson(product))
          .toList();

      int index = products.indexWhere((prod) =>
          prod["id"] == product!.id &&
          prod["variant_id"] == product.variantId &&
          prod['variation_name'] == product.variationName);

      if (index != -1) {
        if (listCart[index].productStock! <
            (product!.cartQuantity! + listCart[index].cartQuantity!)) {
          Navigator.pop(context);
          return snackBar(context,
              message:
                  "${AppLocalizations.of(context)!.translate("exceeded_stock")}");
        }
        product.cartQuantity =
            listCart[index].cartQuantity! + product.cartQuantity!;

        // product.priceTotal = (product.cartQuantity! * product.productPrice!);
        //PENGECEKAN MAX QTY
        if (product.minMaxQuantity!.maxQty >= product.cartQuantity!) {
          listCart[index] = product;
        } else if (product.minMaxQuantity!.maxQty < product.cartQuantity!) {
          Navigator.pop(context, false);
          return snackBar(context,
              message:
                  "Maximum purchase is ${product.minMaxQuantity!.maxQty} pcs");
        }
        await Session.data.setString('cart', json.encode(listCart));
      } else {
        // product!.priceTotal = (product.cartQuantity! * product.productPrice!);
        //PENGECEKAN MAX QTY
        if (product!.minMaxQuantity!.maxQty >= product.cartQuantity!) {
          listCart.insert(0, product);
        } else if (product.minMaxQuantity!.maxQty < product.cartQuantity!) {
          Navigator.pop(context, false);
          return snackBar(context,
              message:
                  "Maximum purchase is ${product.minMaxQuantity!.maxQty} pcs");
        }
        await Session.data.setString('cart', json.encode(listCart));
      }
    }
  }

  Future<List<ProductModel>> fetchProductCart(
      List<ProductModel> cartProduct) async {
    isLoading = true;
    List<ProductModel>? _temp = cartProduct;
    try {
      var result;
      List<String> _tempInclude = [];
      cartProduct.forEach((element) {
        _tempInclude.add(element.id.toString());
      });
      await OrderAPI().loadProductCart(_tempInclude.join(',')).then((data) {
        result = data;
        tempProductOrder = [];
        for (Map item in result) {
          tempProductOrder.add(ProductModel.fromJson(item));
        }

        printLog(json.encode(cartProduct), name: "temp product order");

        tempProductOrder.forEach((tp) {
          cartProduct.forEach((cp) {
            if (tp?.id == cp.id) {
              cp.productPrice = cp.productPrice;
              cp.productRegPrice = cp.productRegPrice;
              cp.productSalePrice = cp.productSalePrice;
              cp.discProduct = tp?.discProduct;
              cp.stockStatus = tp?.stockStatus;
              cp.showImage = cp.images![0].src;
              printLog(cp.images![0].src.toString(), name: "image variant");
              cp.minMaxQuantity = tp?.minMaxQuantity;
              cp.manageStock = tp?.manageStock;
              cp.productStock = tp?.productStock;
              if (cp.type == 'simple' && cp.cartQuantity! > cp.productStock!) {
                cp.cartQuantity = 1;
              }
              cp.priceTotal = cp.cartQuantity! * tp!.productPrice!;

              if (cp.type == 'variable') {
                tp.availableVariations?.forEach((elvar) {
                  if (elvar.variationId == cp.variantId) {
                    cp.productPrice = elvar.displayPrice;
                    cp.productRegPrice = elvar.displayRegularPrice.toString();
                    cp.stockStatus =
                        elvar.isInStock! ? 'instock' : 'outofstock';
                    cp.productStock = elvar.maxQty;
                    if (cp.cartQuantity! > cp.productStock!) {
                      cp.cartQuantity = 1;
                    }
                    cp.priceTotal = cp.cartQuantity! * elvar.displayPrice;

                    printLog(
                        "Variable ${cp.variantId} ${cp.productName} ${cp.stockStatus} ${cp.productStock}");
                  }
                });
              }
              if (cp.stockStatus == 'outofstock' || cp.productStock == 0) {
                cp.isProductAvailable = false;
                cp.isSelected = false;
              } else {
                cp.isProductAvailable = true;
                cp.isSelected = true;
              }
            }
          });
        });

        _temp = cartProduct;

        isLoading = false;
        notifyListeners();
        printLog(result.toString());
      });
      return _temp!;
    } catch (e) {
      printLog(e.toString(), name: 'Load Cart Error');
      isLoading = false;
      notifyListeners();
      return _temp!;
    }
  }

  resetPage() {
    orderPage = 1;
    cekInsert = true;
    listOrder = [];
    tempOrder = [];
    isLoading = true;
    notifyListeners();
  }
}
