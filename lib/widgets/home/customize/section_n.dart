import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/models/categories_model.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/category/category_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:provider/provider.dart';

class SectionN extends StatefulWidget {
  const SectionN({Key? key}) : super(key: key);

  @override
  State<SectionN> createState() => _SectionNState();
}

class _SectionNState extends State<SectionN> {
  redirectLink(CategoriesModel collection) {
    if (collection.titleCategories == 'view_more') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CategoryScreen(
                    isFromHome: false,
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BrandProducts(
                    categoryId: collection.categories.toString(),
                    brandName: collection.titleCategories == null
                        ? ""
                        : collection.titleCategories,
                    sortIndex: 1,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = Provider.of<HomeProvider>(context, listen: false);
    return Container(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              redirectLink(home.categories3[0]);
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 205,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              margin: EdgeInsets.only(right: 5),
              child: Stack(children: [
                CachedNetworkImage(
                  imageUrl: home.categories3[0].image!,
                  fit: BoxFit.fill,
                  imageBuilder: (context, imageProvider) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.fill)),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black12,
                              Colors.black
                            ])),
                    child: Text(
                      home.categories3[0].titleCategories!,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              ]),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 5),
              child: Column(children: [
                home.categories3.length >= 2
                    ? GestureDetector(
                        onTap: () {
                          redirectLink(home.categories3[1]);
                        },
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.only(bottom: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(children: [
                              CachedNetworkImage(
                                imageUrl: home.categories3[1].image!,
                                fit: BoxFit.fill,
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill)),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.only(left: 15),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black12,
                                            Colors.black
                                          ])),
                                  child: Text(
                                    home.categories3[1].titleCategories!,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              )
                            ]),
                          ),
                        ),
                      )
                    : Container(
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[400]),
                        margin: EdgeInsets.only(bottom: 5),
                        child: Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      ),
                home.categories3.length >= 3
                    ? GestureDetector(
                        onTap: () {
                          redirectLink(home.categories3[2]);
                        },
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(children: [
                            CachedNetworkImage(
                              imageUrl: home.categories3[2].image!,
                              fit: BoxFit.fill,
                              imageBuilder: (context, imageProvider) {
                                return Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill)),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.only(left: 15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black12,
                                          Colors.black
                                        ])),
                                child: Text(
                                  home.categories3[2].titleCategories!,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          ]),
                        ),
                      )
                    : Container(
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[400]),
                        // margin: EdgeInsets.only(bottom: 5),
                        child: Center(child: Icon(Icons.image_not_supported)),
                      ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
