import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/models/categories_model.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/category/category_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:provider/provider.dart';

class SectionI extends StatefulWidget {
  const SectionI({Key? key}) : super(key: key);

  @override
  State<SectionI> createState() => _SectionIState();
}

class _SectionIState extends State<SectionI> {
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
      margin: EdgeInsets.all(10),
      // color: Colors.blue,
      child: Row(
        children: [
          home.categoriesSectionI.length > 0
              ? Container(
                  margin: EdgeInsets.all(10),
                  child: Stack(children: [
                    Container(
                      // width: MediaQuery.of(context).size.width / 2,
                      width: 150,
                      height: 400,
                      child: CachedNetworkImage(
                        imageUrl: home.categoriesSectionI[0].image!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Icon(Icons.error);
                        },
                      ),
                    ),
                    Positioned(
                        bottom: 20,
                        right: 14,
                        child: GestureDetector(
                          onTap: () {
                            redirectLink(home.categoriesSectionI[0]);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 1)),
                            child: Center(
                              child: Text(
                                home.categoriesSectionI[0].titleCategories!,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ))
                  ]),
                )
              : Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 400,
                  color: Colors.grey[400],
                  child: Center(child: Icon(Icons.image_aspect_ratio_sharp)),
                ),
          home.categoriesSectionI.length > 1
              ? Container(
                  // color: Colors.yellow,
                  child: Stack(children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      width: 150,
                      height: 400,
                      child: CachedNetworkImage(
                        imageUrl: home.categoriesSectionI[1].image!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Icon(Icons.error);
                        },
                      ),
                    ),
                    Positioned(
                        bottom: 30,
                        left: 25,
                        child: GestureDetector(
                          onTap: () {
                            redirectLink(home.categoriesSectionI[1]);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 1)),
                            child: Center(
                              child: Text(
                                home.categoriesSectionI[1].titleCategories!,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ))
                  ]),
                )
              : Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 400,
                  color: Colors.grey[400],
                  child: Center(child: Icon(Icons.image_aspect_ratio_sharp)),
                )
        ],
      ),
    );
  }
}
