import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/pages/blog/blog_detail_screen.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/product/design_detail_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:provider/provider.dart';

class SectionO extends StatefulWidget {
  const SectionO({Key? key}) : super(key: key);

  @override
  State<SectionO> createState() => _SectionOState();
}

class _SectionOState extends State<SectionO> {
  CarouselController _controller = CarouselController();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, child) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Visibility(
            visible: value.banners3.isNotEmpty,
            child: Column(
              children: [
                Container(
                  height: 130.h,
                  margin: EdgeInsets.only(
                    top: 10,
                  ),
                  child: CarouselSlider(
                    carouselController: _controller,
                    items: value.banners3.map((i) {
                      return Builder(
                        builder: (context) {
                          return InkWell(
                            onTap: () {
                              if (i.product != null) {
                                if (i.linkTo.toString().toLowerCase() ==
                                    'product') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DesignDetailScreen(
                                                productId: i.product.toString(),
                                              )));
                                }
                                if (i.linkTo.toString().toLowerCase() ==
                                    'url') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebViewScreen(
                                        title: i.titleSlider,
                                        url: i.name,
                                      ),
                                    ),
                                  );
                                }
                                if (i.linkTo.toString().toLowerCase() ==
                                    'collections') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => BrandProducts(
                                                categoryId:
                                                    i.product.toString(),
                                                brandName: i.name,
                                                sortIndex: 1,
                                              )));
                                }
                                if (i.linkTo.toString().toLowerCase() ==
                                    'articles') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BlogDetail(id: i.product.toString()),
                                    ),
                                  );
                                }

                                // if (slide.linkTo == 'attribute') {
                                //   Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //           builder: (context) => BrandProducts(
                                //                 attribute: slide.product.toString(),
                                //                 brandName: slide.name,
                                //               )));
                                // }
                              }
                            },
                            child: CachedNetworkImage(
                              imageUrl: i.image!,
                              placeholder: (context, url) => Container(
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[300])),
                              errorWidget: (context, url, error) {
                                return Icon(Icons.error);
                              },
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 15),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                    options: CarouselOptions(
                      enableInfiniteScroll: false,
                      autoPlay: true,
                      viewportFraction: 1,
                      height: 130.h,
                      onPageChanged: (index, reason) {
                        setState(
                          () {
                            currentIndex = index;
                          },
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  // margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: value.banners3.asMap().entries.map((e) {
                      return Container(
                        width: 10,
                        height: 10,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentIndex == e.key
                                ? primaryColor
                                : Colors.white,
                            border: currentIndex == e.key
                                ? Border.all(
                                    width: 0, color: Colors.transparent)
                                : Border.all(width: 0.4, color: primaryColor)),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          );
        },
      );
    });
  }
}
