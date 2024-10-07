import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/product/design_detail_screen.dart';
import '../../../pages/blog/blog_detail_screen.dart';
import '../../webview/webview.dart';

class BannerContainer extends StatefulWidget {
  final List<dynamic> dataSlider;
  final int dataSliderLength;
  final double contentHeight;
  final Widget loading;

  BannerContainer({
    required this.dataSliderLength,
    required this.contentHeight,
    required this.dataSlider,
    required this.loading,
  });

  @override
  State<BannerContainer> createState() => _BannerContainerState();
}

class _BannerContainerState extends State<BannerContainer> {
  int _currentIndex = 0; // To track the current slide index

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/_photo__.png'), // Use your local background image
          fit: BoxFit.fill, // Ensures the image covers the entire container
        ),
      ),
      child: Column(
        children: [
          CarouselSlider.builder(
            itemCount: widget.dataSlider.length,
            itemBuilder: (BuildContext context, int index, int realIndex) {
              var slide = widget.dataSlider[index];
              var imageSlider = slide.image;
              var product = slide.product;

              return InkWell(
                onTap: () {
                  if (product != null) {
                    if (slide.linkTo.toString().toLowerCase() == 'product') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DesignDetailScreen(
                            productId: slide.product.toString(),
                          ),
                        ),
                      );
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
                            brandName: slide.name,
                          ),
                        ),
                      );
                    }
                    if (slide.linkTo.toString().toLowerCase() == 'blog') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlogDetail(
                            id: slide.product.toString(),
                          ),
                        ),
                      );
                    }
                    if (slide.linkTo.toString().toLowerCase() == 'attribute') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BrandProducts(
                            attribute: slide.product.toString(),
                            brandName: slide.name,
                          ),
                        ),
                      );
                    }
                  }
                },
                child: CachedNetworkImage(
                  imageUrl: imageSlider,
                  placeholder: (context, url) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  imageBuilder: (context, imageProvider) => Container(
                    width: double.infinity, // Full width of the parent container
                    height: MediaQuery.of(context).size.width * 0.5, // Dynamic height to fit aspect ratio
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain, // Ensures the image fits without being cut
                      ),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: MediaQuery.of(context).size.width * 0.5, // Dynamic height for the carousel
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayAnimationDuration: const Duration(seconds: 1),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          // Pagination Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.dataSlider.asMap().entries.map((entry) {
              return Container(
                width: 12.0,
                height: 6.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: _currentIndex == entry.key
                      ? Colors.pinkAccent
                      : Colors.cyan,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
