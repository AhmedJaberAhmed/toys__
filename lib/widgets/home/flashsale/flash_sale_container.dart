import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/product/design_detail_screen.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class FlashSaleContainer extends StatelessWidget {
  final AnimationController? colorAnimationController;
  final AnimationController? textAnimationController;

  final Animation? colorTween, titleColorTween, iconColorTween, moveTween;
  final List<ProductModel>? dataProducts;
  final String? customImage;

  final bool? loading;

  FlashSaleContainer({
    this.colorAnimationController,
    this.textAnimationController,
    this.colorTween,
    this.titleColorTween,
    this.iconColorTween,
    this.moveTween,
    this.dataProducts,
    this.loading,
    this.customImage,
  });

  bool scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axis == Axis.horizontal) {
      colorAnimationController!.animateTo(scrollInfo.metrics.pixels / 150);
      textAnimationController!.animateTo((scrollInfo.metrics.pixels - 350) / 50);
      return true;
    } else {
      return false;
    }
  }

  double responsiveFont(double size, BuildContext context) {
    // Calculate font size based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    return size * (screenWidth / 375); // 375 is a common base width for mobile screens
  }

  @override
  Widget build(BuildContext context) {
    List<ProductModel> _list = [];
    _list.add(new ProductModel());
    _list.addAll(dataProducts!);

    return NotificationListener<ScrollNotification>(
      onNotification: scrollListener,
      child: Container(
        height: MediaQuery.of(context).size.height / 3,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 0.0),
            colors: [primaryColor, secondaryColor],
            tileMode: TileMode.repeated,
          ),
        ),
        width: double.infinity,
        child: AnimatedBuilder(
          animation: colorAnimationController!,
          builder: (context, child) {
            final screenWidth = MediaQuery.of(context).size.width;
            final cardWidth = screenWidth * 0.3; // 30% of screen width for each card

            return Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: loading!
                      ? customLoading(color: primaryColor)
                      : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_list.length, (index) {
                        if (index == 0) {
                          return SizedBox(
                            width: 0, // Adjust width for the first item if necessary
                          );
                        }

                        final product = _list[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DesignDetailScreen(
                                  productId: product.id.toString(),
                                  product: dataProducts![index - 1],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: cardWidth, // Adjust cardWidth as needed
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1 / 1,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(5),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: product.images![0].src!,
                                        placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.image_not_supported_rounded,
                                                size: 20),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3, horizontal: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.productName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize:
                                                responsiveFont(10, context)),
                                          ),
                                          if (product.discProduct != 0)
                                            IntrinsicWidth(
                                              child: Row(
                                                children: [
                                                  if (product.discProduct != null && product.discProduct! > 0) ...[
                                                    // Only show the discount container if there is a discount
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: secondaryColor,
                                                      ),
                                                      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                                      child: Text(
                                                        "${product.discProduct!.round()}%",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: responsiveFont(9, context),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 1),
                                                    Text(
                                                      stringToCurrency(double.parse(product.productRegPrice), context),
                                                      style: TextStyle(
                                                        fontSize: responsiveFont(8, context),
                                                        color: HexColor("C4C4C4"),
                                                        decoration: TextDecoration.lineThrough,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),

                                          SizedBox(height: 5),
                                          RichText(
                                            text: TextSpan(
                                              style: TextStyle(color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: product.type == 'simple'
                                                      ? '${AppLocalizations.of(context)?.translate('currency_symbol') ?? ''} ${stringToCurrency(product.productPrice!, context)}'
                                                      : (product.variationPrices!.isEmpty
                                                      ? ''
                                                      : product.variationPrices!.first == product.variationPrices!.last
                                                      ? '${AppLocalizations.of(context)?.translate('currency_symbol') ?? ''} ${stringToCurrency(product.variationPrices!.first, context)}'
                                                      : '${AppLocalizations.of(context)?.translate('currency_symbol') ?? ''} ${stringToCurrency(product.variationPrices!.first, context)} - ${stringToCurrency(product.variationPrices!.last, context)}'),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: responsiveFont(11, context),
                                                    color: secondaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          LinearPercentIndicator(
                                            padding: EdgeInsets.zero,
                                            lineHeight: 5.0,
                                            percent: product.productStock != null &&
                                                product.productStock != 0
                                                ? 1
                                                : 0,
                                            backgroundColor: Colors.grey,
                                            progressColor: HexColor("00963C"),
                                          ),
                                          Text(
                                            product.productStock != null &&
                                                product.productStock != 0
                                                ? AppLocalizations.of(context)!
                                                .translate('stock_available')!
                                                : AppLocalizations.of(context)!
                                                .translate('stock_empty')!,
                                            style: TextStyle(
                                                fontSize:
                                                responsiveFont(6, context)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            );

          },
        ),
      ),
    );
  }
}
