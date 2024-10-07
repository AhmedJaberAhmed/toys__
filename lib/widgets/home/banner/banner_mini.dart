import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/models/banner_mini_model.dart';
import 'package:nyoba/pages/blog/blog_detail_screen.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/product/design_detail_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:provider/provider.dart';

class BannerMini extends StatelessWidget {
  final String? typeBanner;
  final List<BannerMiniModel> bannerLove;
  final List<BannerMiniModel> bannerSpecial;
  const BannerMini(
      {Key? key,
      this.typeBanner,
      required this.bannerLove,
      required this.bannerSpecial})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, child) {
      List<BannerMiniModel> _miniBanner = [];
      if (typeBanner == 'love') {
        _miniBanner = bannerLove;
      } else if (typeBanner == 'special') {
        _miniBanner = bannerSpecial;
      }
      return Container(
        color: Colors.white,
        margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 15),
        child: GridView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: _miniBanner.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              childAspectRatio: 2 / 1),
          itemBuilder: (context, i) {
            if (value.loadBanner) {
              shimmerMiniBanner();
            }
            return _miniBanner[i].name == ""
                ? Container()
                : Container(
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(5)),
                    child: InkWell(
                        onTap: () {
                          if (_miniBanner[i].linkTo.toString().toLowerCase() ==
                              'url') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewScreen(
                                  title: _miniBanner[i].titleSlider,
                                  url: _miniBanner[i].name,
                                ),
                              ),
                            );
                          }
                          if (_miniBanner[i].linkTo.toString().toLowerCase() ==
                              'category') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BrandProducts(
                                          categoryId:
                                              _miniBanner[i].product.toString(),
                                          brandName: _miniBanner[i].name,
                                        )));
                          }
                          if (_miniBanner[i].linkTo.toString().toLowerCase() ==
                              'blog') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlogDetail(
                                  id: _miniBanner[i].product.toString(),
                                ),
                              ),
                            );
                          }
                          if (_miniBanner[i].linkTo.toString().toLowerCase() ==
                              'product') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DesignDetailScreen(
                                          productId:
                                              _miniBanner[i].product.toString(),
                                        )));
                          }
                          if (_miniBanner[i].linkTo.toString().toLowerCase() ==
                              'attribute') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BrandProducts(
                                          attribute:
                                              _miniBanner[i].product.toString(),
                                          brandName: _miniBanner[i].name,
                                        )));
                          }
                        },
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: _miniBanner[i].image!,
                          errorWidget: (context, url, error) {
                            return shimmerMiniBanner();
                          },
                        )),
                  );
          },
        ),
      );
    });
  }
}
