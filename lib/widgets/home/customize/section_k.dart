import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/categories_model.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/category/category_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

class SectionK extends StatefulWidget {
  const SectionK({Key? key}) : super(key: key);

  @override
  State<SectionK> createState() => _SectionKState();
}

class _SectionKState extends State<SectionK> {
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
    // return GridView.builder(
    //   primary: false,
    //   padding: EdgeInsets.all(15),
    //   physics: ScrollPhysics(),
    //   shrinkWrap: true,
    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
    //   itemCount: home.categories.length,
    //   itemBuilder: (context, index) {
    //     return GestureDetector(
    //       onTap: () {
    //         if (home.categories[index].titleCategories == 'view_more') {
    //           Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                   builder: (context) => CategoryScreen(
    //                         isFromHome: false,
    //                       )));
    //         } else {
    //           Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                   builder: (context) => BrandProducts(
    //                         categoryId: home.categories[index].id.toString(),
    //                         brandName:
    //                             home.categories[index].titleCategories == null
    //                                 ? ""
    //                                 : home.categories[index].titleCategories,
    //                         sortIndex: 1,
    //                       )));
    //         }
    //       },
    //       child: Column(
    //         children: [
    //           Expanded(
    //             child: Container(
    //                 margin: EdgeInsets.only(bottom: 5),
    //                 decoration:
    //                     BoxDecoration(borderRadius: BorderRadius.circular(10)),
    //                 alignment: Alignment.center,
    //                 child: CachedNetworkImage(
    //                   imageUrl: home.categories[index].image!,
    //                   fit: BoxFit.cover,
    //                 )),
    //           ),
    //           Text(
    //               home.categories[index].titleCategories! == "view_more"
    //                   ? AppLocalizations.of(context)!.translate("view_more")!
    //                   : home.categories[index].titleCategories!,
    //               style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    //         ],
    //       ),
    //     );
    //   },
    // );
    return Container( color: Colors.white,
      margin: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              home.categories4.length > 0 &&
                      home.categories4[0].titleCategories != "view_more"
                  //Kiri atas
                  ? GestureDetector(
                      onTap: () {
                        redirectLink(home.categories4[0]);
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            width: 160.w,
                            height: 160.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor),
                            child: CachedNetworkImage(
                              imageUrl: home.categories4[0].image!,
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
                          ),
                          Text(
                              home.categories4[0].titleCategories! ==
                                      "view_more"
                                  ? AppLocalizations.of(context)!
                                      .translate("view_more")!
                                  : HtmlUnescape().convert(
                                      home.categories4[0].titleCategories!),
                              style: TextStyle(
                                  fontSize: 8, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 160.w,
                          height: 160.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primaryColor),
                        ),
                        Text("",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
              home.categories4.length > 2 &&
                      home.categories4[2].titleCategories != "view_more"
                  //Kiri bawah
                  ? GestureDetector(
                      onTap: () {
                        redirectLink(home.categories4[2]);
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            width: 160.w,
                            height: 160.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor),
                            child: CachedNetworkImage(
                              imageUrl: home.categories4[2].image!,
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
                          ),
                          Text(
                              home.categories4[2].titleCategories! ==
                                      "view_more"
                                  ? AppLocalizations.of(context)!
                                      .translate("view_more")!
                                  : HtmlUnescape().convert(
                                      home.categories4[2].titleCategories!),
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 160.w,
                          height: 160.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primaryColor),
                        ),
                        Text("",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    )
            ],
          ),
          Column(
            children: [
              home.categories4.length > 1 &&
                      home.categories4[1].titleCategories != "view_more"
                  //Kanan atas
                  ? GestureDetector(
                      onTap: () {
                        redirectLink(home.categories4[1]);
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            width: 160.w,
                            height: 160.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor),
                            child: CachedNetworkImage(
                              imageUrl: home.categories4[1].image!,
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
                          ),
                          Text(
                              home.categories4[1].titleCategories! ==
                                      "view_more"
                                  ? AppLocalizations.of(context)!
                                      .translate("view_more")!
                                  : HtmlUnescape().convert(
                                      home.categories4[1].titleCategories!),
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 160.w,
                          height: 160.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primaryColor),
                        ),
                        Text("",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
              home.categories4.length > 3 &&
                      home.categories4[3].titleCategories != "view_more"
                  //Kanan bawah
                  ? GestureDetector(
                      onTap: () {
                        redirectLink(home.categories4[3]);
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            width: 160.w,
                            height: 160.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor),
                            child: CachedNetworkImage(
                              imageUrl: home.categories4[3].image!,
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
                          ),
                          Text(
                              home.categories4[3].titleCategories! ==
                                      "view_more"
                                  ? AppLocalizations.of(context)!
                                      .translate("view_more")!
                                  : HtmlUnescape().convert(
                                      home.categories4[3].titleCategories!),
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 160.w,
                          height: 160.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primaryColor),
                        ),
                        Text("",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    )
            ],
          )
        ],
      ),
    );
  }
}
