
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/pages/blog/blog_detail_screen.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/product/design_detail_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:provider/provider.dart';

class SectionJ extends StatefulWidget {
  const SectionJ({Key? key}) : super(key: key);

  @override
  State<SectionJ> createState() => _SectionJState();
}

class _SectionJState extends State<SectionJ> {
  @override
  Widget build(BuildContext context) {
    final home = Provider.of<HomeProvider>(context, listen: false);
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(15),
          height: 300.h,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Swiper(
            itemCount: home.bannerSingle.length,
            itemBuilder: (context, index) {
              var slide = home.bannerSingle[index];

              var imageSlider = slide.image;
              var product = slide.product;
              return GestureDetector(
                onTap: () {
                  if (product != null) {
                    if (slide.linkTo.toString().toLowerCase() == 'product') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DesignDetailScreen(
                                  productId: slide.product.toString())));
                    }
                    if (slide.linkTo.toString().toLowerCase() == 'url') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(
                            title: slide.titleSlider,
                            url: slide.name,
                          ),
                        ),
                      );
                    }
                    if (slide.linkTo.toString().toLowerCase() == 'category') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrandProducts(
                                    categoryId: slide.product.toString(),
                                    brandName: slide.name!.split("[<>]").first,
                                    sortIndex: 1,
                                  )));
                    }
                    if (slide.linkTo.toString().toLowerCase() == 'articles') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BlogDetail(id: slide.product.toString()),
                        ),
                      );
                    }
                  }
                },
                child: Stack(children: [
                  Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    // width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.9,
                    child: CachedNetworkImage(
                      imageUrl:
                          home.bannerSingle.isNotEmpty ? imageSlider! : "",
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return Icon(Icons.error);
                      },
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover)),
                        );
                      },
                    ),
                  ),
                  // Positioned(
                  //     bottom: 20,
                  //     right: 0,
                  //     left: 0,
                  //     child: Column(
                  //       children: [
                  //         Container(
                  //             child: Text(
                  //           home.bannerSingle[0].name!.split("[<>]").first,
                  //           style: TextStyle(color: Colors.white, fontSize: 24),
                  //           textAlign: TextAlign.center,
                  //         )),
                  //         Container(
                  //           child: Text(
                  //             home.bannerSingle[0].name!.split("[<>]").last,
                  //             style: TextStyle(color: Colors.white),
                  //             textAlign: TextAlign.center,
                  //           ),
                  //         )
                  //       ],
                  //     )),
                ]),
              );
            },
            viewportFraction: 1,
            autoplay: true,
            loop: true,
            scale: 0.8,
            autoplayDelay: 2600,
            pagination: SwiperPagination(
                margin: EdgeInsets.zero,
                builder: SwiperCustomPagination(builder: (context, config) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: home.bannerSingle.asMap().entries.map((entry) {
                      return Container(
                        width: 9.0,
                        height: 3.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: config.activeIndex == entry.key
                                ? primaryColor
                                : Colors.white),
                      );
                    }).toList(),
                  );
                })),
          ),
        ),
      ],
    );
  }
}
