import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:like_button/like_button.dart';
import 'package:nyoba/pages/product/design_detail_screen.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../pages/wishlist/wishlist_screen.dart';
import '../../provider/app_provider.dart';
import '../../provider/wishlist_provider.dart';
import '../../services/session.dart';

class CardItem extends StatefulWidget {
  final ProductModel? product;
  final int? i, itemCount;

  CardItem({this.product, this.i, this.itemCount});

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  bool isWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  void _checkWishlist() {
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    if (wishlistProvider.idProductWishList.isNotEmpty) {
      isWishlist = wishlistProvider.idProductWishList.contains(widget.product!.id.toString());
    }
  }

  Future<bool?> _toggleWishlist(bool? isLiked) async {
    if (Session.data.getBool('isLogin')!) {
      setState(() {
        isWishlist = !isWishlist;
      });

      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      await wishlistProvider.setWishlistProduct(context, productId: widget.product!.id.toString());

      await wishlistProvider.loadWishlistProduct(page: 1);
      await wishlistProvider.fetchWishlistProducts(wishlistProvider.productWishlist!);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => WishList()));
    }
    return isLiked;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<AppNotifier>(context, listen: false).appLocal;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DesignDetailScreen(
              product: widget.product,
              productId: widget.product!.id.toString(),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          left: locale == Locale('ar') ? (widget.i == widget.itemCount! - 1 ? 15 : 0) : (widget.i == 0 ? 15 : 0),
          right: locale == Locale('ar') ? (widget.i == 0 ? 15 : 0) : (widget.i == widget.itemCount! - 1 ? 15 : 0),
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        width: 130.w,
        height: double.infinity,
        child: Card(
          elevation: 5,
          margin: EdgeInsets.only(bottom: 10, left: 2.5, right: 2.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1 / 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                            ),
                            child: widget.product!.images!.isEmpty
                                ? Icon(Icons.image_not_supported, size: 50)
                                : CachedNetworkImage(
                              imageUrl: widget.product!.images![0].src!,
                              placeholder: (context, url) => Shimmer.fromColors(
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.white,
                                ),
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.image_not_supported_rounded, size: 25),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: LikeButton(
                            size: 25,
                            onTap: _toggleWishlist,
                            circleColor: CircleColor(start: primaryColor, end: secondaryColor),
                            bubblesColor: BubblesColor(
                              dotPrimaryColor: primaryColor,
                              dotSecondaryColor: secondaryColor,
                            ),
                            isLiked: isWishlist,
                            likeBuilder: (bool isLiked) {
                              return Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                                size: 25,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                      child: Text(
                        widget.product!.productName!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: responsiveFont(10)),
                        textScaleFactor: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: widget.product!.discProduct != 0 && widget.product!.discProduct != 0.0,
                            child: widget.product!.type == 'simple'
                                ? Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: secondaryColor,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    "${widget.product!.discProduct!.round()}%",
                                    style: TextStyle(color: Colors.white, fontSize: responsiveFont(9)),
                                  ),
                                ),
                                SizedBox(width: 5),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: stringToCurrency(double.parse(widget.product!.productRegPrice), context),
                                        style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          fontSize: responsiveFont(9),
                                          color: HexColor("C4C4C4"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                                : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: secondaryColor,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    "${widget.product!.discProduct!.round()}%",
                                    style: TextStyle(color: Colors.white, fontSize: responsiveFont(9)),
                                  ),
                                ),
                                SizedBox(width: 5),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: widget.product!.variationRegPrices!.first ==
                                            widget.product!.variationRegPrices!.last
                                            ? '${stringToCurrency(widget.product!.variationRegPrices!.first, context)}'
                                            : '${stringToCurrency(widget.product!.variationRegPrices!.first, context)} - ${stringToCurrency(widget.product!.variationRegPrices!.last, context)}',
                                        style: TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          fontSize: responsiveFont(9),
                                          color: HexColor("C4C4C4"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          widget.product!.type == 'simple'
                              ? RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: stringToCurrency(widget.product!.productPrice!, context),
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: responsiveFont(11), color: secondaryColor),
                                ),
                              ],
                            ),
                          )
                              : RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              children: [
                                widget.product!.variationPrices!.isEmpty
                                    ? TextSpan(
                                    text: '',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: responsiveFont(11), color: secondaryColor))
                                    : TextSpan(
                                    text: widget.product!.variationPrices!.isEmpty
                                        ? ''
                                        : widget.product!.variationPrices!.first == widget.product!.variationPrices!.last
                                        ? stringToCurrency(widget.product!.variationPrices!.first, context)
                                        : '${stringToCurrency(widget.product!.variationPrices!.first, context)} - ${stringToCurrency(widget.product!.variationPrices!.last, context)}',

                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: responsiveFont(11), color: secondaryColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
