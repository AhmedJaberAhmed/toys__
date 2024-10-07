import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:like_button/like_button.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/product/design_detail_screen.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../pages/wishlist/wishlist_screen.dart';
import '../../provider/wishlist_provider.dart';
import '../../services/session.dart';

class GridItem extends StatefulWidget {
  final int? i;
  final int? itemCount;
  final ProductModel? product;

  GridItem({this.i, this.itemCount, this.product});

  @override
  State<GridItem> createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool? isWishlist = false;

  checkWishlist() {
    if (Provider.of<WishlistProvider>(context, listen: false)
            .idProductWishList !=
        []) {
      if (Provider.of<WishlistProvider>(context, listen: false)
          .idProductWishList
          .contains(widget.product!.id.toString())) {
        setState(() {
          isWishlist = true;
        });
      }
    }
    // Provider.of<WishlistProvider>(context, listen: false)
    //     .checkWishlistProduct(productId: widget.product!.id.toString())
    //     .then((value) {
    //   printLog(jsonEncode(value), name: "Wishlist2");
    //   if (value!['message'] == true) {
    //     setState(() {
    //       isWishlist = true;
    //     });
    //   }
    // });
  }

  Future<bool?> setWishlist(bool? isLiked) async {
    if (Session.data.getBool('isLogin')!) {
      setState(() {
        isWishlist = !isWishlist!;
        isLiked = isWishlist;
      });
      final wishlist = Provider.of<WishlistProvider>(context, listen: false);

      final Future<Map<String, dynamic>?> setWishlist =
          wishlist.setWishlistProduct(context,
              productId: widget.product!.id.toString());

      setWishlist.then((value) async {
        await Provider.of<WishlistProvider>(context, listen: false)
            .loadWishlistProduct(
          page: 1,
        )
            .then((value) async {
          await Provider.of<WishlistProvider>(context, listen: false)
              .fetchWishlistProducts(wishlist.productWishlist!);
        });
        print("200");
      });
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => WishList()));
    }
    return isLiked;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.product != null) {
      checkWishlist();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(5)),
      child: Card(
          elevation: 5,
          margin: EdgeInsets.only(bottom: 1),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DesignDetailScreen(
                            product: widget.product,
                            productId: widget.product!.id.toString(),
                          )));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 1 / 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: widget.product!.images![0].src!,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                        child: Container(
                                          width: double.infinity,
                                          height: 400, // Set a specific height to make it more prominent
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15), // Rounded corners for a softer look
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.2),
                                                spreadRadius: 5,
                                                blurRadius: 15,
                                                offset: Offset(0, 3), // Shadow effect
                                              ),
                                            ],
                                          ),
                                        ),
                                        baseColor: Colors.lightBlueAccent.withOpacity(0.5), // Fun base color
                                        highlightColor: Colors.yellow.withOpacity(0.5), // Bright highlight color
                                      )
,
                                    errorWidget: (context, url, error) => Icon(
                                    Icons.image_not_supported_rounded,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: LikeButton(
                                size: 25,
                                onTap: setWishlist,
                                circleColor: CircleColor(
                                    start: primaryColor, end: secondaryColor),
                                bubblesColor: BubblesColor(
                                  dotPrimaryColor: primaryColor,
                                  dotSecondaryColor: secondaryColor,
                                ),
                                isLiked: isWishlist,
                                likeBuilder: (bool isLiked) {
                                  if (!isLiked) {
                                    return Icon(
                                      Icons.favorite_border,
                                      color: Colors.grey,
                                      size: 25,
                                    );
                                  }
                                  return Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 25,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                        child: Text(
                          widget.product!.productName!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: responsiveFont(10)),
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: widget.product!.discProduct != 0,
                                  child: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: secondaryColor,
                                        ),
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: Text(
                                          "${widget.product!.discProduct!.round()}%",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: responsiveFont(9)),
                                        ),
                                      ),
                                      Container(
                                        width: 5,
                                      ),
                                      widget.product!.type == "simple"
                                          ? RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                    color: Colors.black),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: stringToCurrency(
                                                          double.parse(widget
                                                              .product!
                                                              .productRegPrice),
                                                          context),
                                                      style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          fontSize:
                                                              responsiveFont(9),
                                                          color: HexColor(
                                                              "C4C4C4"))),
                                                ],
                                              ),
                                            )
                                          : RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                    color: Colors.black),
                                                children: <TextSpan>[
                                                  widget
                                                          .product!
                                                          .variationRegPrices!
                                                          .isEmpty
                                                      ? TextSpan(
                                                          text: '',
                                                          style: TextStyle(
                                                              decoration: TextDecoration
                                                                  .lineThrough,
                                                              fontSize:
                                                                  responsiveFont(
                                                                      9),
                                                              color: HexColor(
                                                                  "C4C4C4")))
                                                      : TextSpan(
                                                          text: widget
                                                                      .product!
                                                                      .variationRegPrices!
                                                                      .first ==
                                                                  widget
                                                                      .product!
                                                                      .variationRegPrices!
                                                                      .last
                                                              ? '${stringToCurrency(widget.product!.variationRegPrices!.first, context)}'
                                                              : '${stringToCurrency(widget.product!.variationRegPrices!.first, context)} - ${stringToCurrency(widget.product!.variationRegPrices!.last, context)}',
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              fontSize:
                                                                  responsiveFont(9),
                                                              color: HexColor("C4C4C4"))),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                widget.product!.type == 'simple'
                                    ?RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: stringToCurrency(widget.product!.productPrice!, context),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: responsiveFont(11),
                                          color: secondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )

                                    : RichText(
                                        text: TextSpan(
                                          style: TextStyle(color: Colors.black),
                                          children: <TextSpan>[
                                            widget.product!.variationPrices!
                                                    .isEmpty
                                                ? TextSpan(
                                                    text: '',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize:
                                                            responsiveFont(11),
                                                        color: secondaryColor))
                                                : TextSpan(
                                                    text: widget
                                                                .product!
                                                                .variationPrices!
                                                                .first ==
                                                            widget
                                                                .product!
                                                                .variationPrices!
                                                                .last
                                                        ? '${stringToCurrency(widget.product!.variationPrices!.first, context)}'
                                                        : '${stringToCurrency(widget.product!.variationPrices!.first, context)} - ${stringToCurrency(widget.product!.variationPrices!.last, context)}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize:
                                                            responsiveFont(11),
                                                        color: secondaryColor)),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          buildButtonCart(context, widget.product)
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  height: 5,
                ),
              ],
            ),
          )),
    );
  }
}
