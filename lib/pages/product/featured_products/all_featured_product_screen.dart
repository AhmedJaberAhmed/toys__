import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/order/cart_screen.dart';
import 'package:nyoba/pages/product/design_detail_screen.dart';
import 'package:nyoba/pages/search/search_screen.dart';
import 'package:nyoba/provider/order_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/widgets/contact/contact_fab.dart';
import 'package:nyoba/widgets/product/grid_item_shimmer.dart';
import 'package:nyoba/widgets/product/product_detail_modal.dart';
import 'package:provider/provider.dart';
import 'package:nyoba/utils/utility.dart';

class AllFeaturedProducts extends StatefulWidget {
  AllFeaturedProducts({Key? key}) : super(key: key);

  @override
  _AllFeaturedProductsState createState() => _AllFeaturedProductsState();
}

class _AllFeaturedProductsState extends State<AllFeaturedProducts> {
  int cartCount = 0;
  int page = 1;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    final product = Provider.of<ProductProvider>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (product.listMoreFeaturedProduct.length % 8 == 0) {
          setState(() {
            page++;
          });
          fetchNewProduct();
        }
      }
    });
    fetchNewProduct();
  }

  Future loadCartCount() async {
    await Provider.of<OrderProvider>(context, listen: false)
        .loadCartCount()
        .then((value) => setState(() {
              cartCount = value;
            }));
  }

  fetchNewProduct() async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchFeaturedProducts(page: page);
    loadCartCount();
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductProvider>(context, listen: false);

    Widget buildItems = ListenableProvider.value(
      value: product,
      child: Consumer<ProductProvider>(builder: (context, value, child) {
        if (value.loadingFeatured && page == 1) {
          return Expanded(
            child: GridView.builder(
                shrinkWrap: true,
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1 / 2,
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15),
                itemBuilder: (context, i) {
                  return GridItemShimmer();
                }),
          );
        }
        if (value.listMoreFeaturedProduct.isEmpty) {
          return buildSearchEmpty(context, "Can't find the products");
        }
        return Expanded(
          child: GridView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: value.listMoreFeaturedProduct.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1 / 2,
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15),
              itemBuilder: (context, i) {
                return itemGridList(
                    value.listMoreFeaturedProduct[i].productName!,
                    value.listMoreFeaturedProduct[i].discProduct!
                        .toInt()
                        .toString(),
                    value.listMoreFeaturedProduct[i].productPrice,
                    value.listMoreFeaturedProduct[i].productRegPrice,
                    i,
                    value.listMoreFeaturedProduct[i].productStock,
                    value.listMoreFeaturedProduct[i].images![0].src!,
                    value.listMoreFeaturedProduct[i]);
              }),
        );
      }),
    );

    return Scaffold(
      floatingActionButton: ContactFAB(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Container(
          height: 38,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchScreen()));
                  },
                  child: TextField(
                    style: TextStyle(fontSize: 14),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      isCollapsed: true,
                      enabled: false,
                      filled: true,
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(5),
                        ),
                      ),
                      prefixIcon: Icon(Icons.search),
                      hintText:
                          AppLocalizations.of(context)!.translate("search"),
                      hintStyle: TextStyle(fontSize: responsiveFont(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CartScreen(
                            isFromHome: false,
                          )));
            },
            child: Container(
              width: 65,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.black,
                  ),
                  Positioned(
                    right: 0,
                    top: 7,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: primaryColor),
                      alignment: Alignment.center,
                      child: Consumer<OrderProvider>(
                        builder: (context, value, child) => Text(
                          value.cartCount.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: responsiveFont(9),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              buildItems,
              if (product.loadingNew && page != 1) customLoading()
            ],
          )),
    );
  }

  Widget itemGridList(
      String title,
      String discount,
      num? price,
      String? crossedPrice,
      int i,
      int? stock,
      String image,
      ProductModel productDetail) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DesignDetailScreen(
                          productId: productDetail.id.toString(),
                        )));
          },
          child: Card(
            elevation: 5,
            margin: EdgeInsets.only(bottom: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Image.network(image),
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: responsiveFont(10)),
                            ),
                          ),
                          Container(
                            height: 5,
                          ),
                          Visibility(
                            visible: discount != "0",
                            child: Flexible(
                              flex: 1,
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: secondaryColor,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 3, horizontal: 7),
                                    child: Text(
                                      '$discount%',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: responsiveFont(9)),
                                    ),
                                  ),
                                  Container(
                                    width: 5,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(color: Colors.black),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: stringToCurrency(
                                                double.parse(productDetail
                                                    .productRegPrice),
                                                context),
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontSize: responsiveFont(9),
                                                color: HexColor("C4C4C4"))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          productDetail.type == 'simple'
                              ? RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: stringToCurrency(
                                              productDetail.productPrice!,
                                              context),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: responsiveFont(11),
                                              color: secondaryColor)),
                                    ],
                                  ),
                                )
                              : RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.black),
                                    children: <TextSpan>[
                                      productDetail.variationPrices!.isEmpty
                                          ? TextSpan(
                                              text: '',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: responsiveFont(11),
                                                  color: secondaryColor))
                                          : TextSpan(
                                              text: productDetail
                                                          .variationPrices!
                                                          .first ==
                                                      productDetail
                                                          .variationPrices!.last
                                                  ? '${stringToCurrency(productDetail.variationPrices!.first, context)}'
                                                  : '${stringToCurrency(productDetail.variationPrices!.first, context)} - ${stringToCurrency(productDetail.variationPrices!.last, context)}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: responsiveFont(11),
                                                  color: secondaryColor)),
                                    ],
                                  ),
                                ),
                          Container(
                            height: 5,
                          ),
                          stock != null && stock != 0
                              ? Text(
                                  "${AppLocalizations.of(context)!.translate('available')} : $stock ${AppLocalizations.of(context)!.translate('in_stock')}",
                                  style: TextStyle(fontSize: responsiveFont(8)),
                                )
                              : Text(
                                  "${AppLocalizations.of(context)!.translate('out_stock')}",
                                  style: TextStyle(
                                      fontSize: responsiveFont(8),
                                      color: Colors.red),
                                )
                        ],
                      ),
                    )),
                Container(
                  margin: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                  decoration: BoxDecoration(
                      border: Border.all(color: secondaryColor),
                      borderRadius: BorderRadius.circular(5)),
                  child: InkWell(
                      onTap: () {
                        if (productDetail.productStock! >= 1) {
                          showMaterialModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            builder: (context) => ProductDetailModal(
                                productModel: productDetail,
                                type: "add",
                                loadCount: loadCartCount),
                          );
                        } else {
                          snackBar(context,
                              message: AppLocalizations.of(context)!
                                  .translate('product_out_stock')!);
                        }
                      },
                      // OutlinedButton(
                      //     style: OutlinedButton.styleFrom(
                      //         side: BorderSide(
                      //           color: secondaryColor, //Color of the border
                      //           //Style of the border
                      //         ),
                      //         alignment: Alignment.center,
                      //         shape: new RoundedRectangleBorder(
                      //             borderRadius: new BorderRadius.circular(5))),
                      //     onPressed: () {
                      //       if (productDetail.productStock! >= 1) {
                      //         showMaterialModalBottomSheet(
                      //           context: context,
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.vertical(
                      //               top: Radius.circular(12),
                      //             ),
                      //           ),
                      //           clipBehavior: Clip.antiAliasWithSaveLayer,
                      //           builder: (context) => ProductDetailModal(
                      //               productModel: productDetail,
                      //               type: "add",
                      //               loadCount: loadCartCount),
                      //         );
                      //       } else {
                      //         snackBar(context,
                      //             message: AppLocalizations.of(context)!
                      //                 .translate('product_out_stock')!);
                      //       }
                      //     },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: responsiveFont(9),
                            color: secondaryColor,
                          ),
                          Text(
                            "${AppLocalizations.of(context)!.translate('add_to_cart')}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: responsiveFont(9),
                                color: secondaryColor),
                          )
                        ],
                      )),
                )
              ],
            ),
          ),
        ));
  }
}
