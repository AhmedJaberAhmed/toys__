import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/services/session.dart';

class CartModel {
  // Model
  int? customerId;
  String? paymentMethod;
  String? paymentMethodTitle;
  bool? setPaid;
  String? status;
  String? token;
  List<CartProductItem>? listItem = [];
  List<CartCoupon>? listCoupon = [];
  String? lang = Session.data.getString("language_code");
  String? referral;
  String? videoId;

  CartModel({
    this.customerId,
    this.paymentMethod,
    this.paymentMethodTitle,
    this.setPaid,
    this.status,
    this.token,
    this.listItem,
    this.listCoupon,
    this.lang,
    this.referral,
    this.videoId,
  });

  Map toJson() => {
        'payment_method': paymentMethod,
        'payment_method_title': paymentMethodTitle,
        'set_paid': setPaid,
        'customer_id': customerId,
        'status': status,
        'token': token,
        'line_items': listItem,
        'coupon_lines': listCoupon,
        'lang': lang,
        'referral': referral,
        'video_id': videoId
      };
}

class CartProductItem {
  final int? productId;
  final int? quantity;
  final int? variationId;
  List<dynamic>? variation = [];
  List<SelectedAddOnProduct>? addons = [];
  String? videoId = '';
  String? dateProductCart = '';

  CartProductItem({
    this.productId,
    this.quantity,
    this.variationId,
    this.variation,
    this.addons,
    this.videoId,
    this.dateProductCart,
  });

  Map toJson() => {
        'product_id': productId,
        'quantity': quantity,
        'variation_id': variationId,
        'variation': variation,
        'addons': addons,
        'video_id': videoId,
        'date_product_cart': dateProductCart,
      };
}

class CartCoupon {
  final String? code;

  CartCoupon({this.code});

  Map toJson() => {
        'code': code,
      };
}
