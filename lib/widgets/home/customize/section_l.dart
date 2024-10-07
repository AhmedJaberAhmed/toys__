import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/categories_model.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/category/category_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

class SectionL extends StatefulWidget {
  const SectionL({Key? key}) : super(key: key);

  @override
  State<SectionL> createState() => _SectionLState();
}

class _SectionLState extends State<SectionL> {
  redirectLink(CategoriesModel collection) {
    if (collection.titleCategories == 'view_more') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CategoryScreen(
                    isFromHome: false,
                  )));
    } else {
      printLog(json.encode(collection));
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
    //       crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
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
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              home.categories6.length > 0 &&
                      home.categories6[0].titleCategories != "view_more"
                  //Kiri atas
                  ? GestureDetector(
                      onTap: () {
                        redirectLink(home.categories6[0]);
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            width: 105.w,
                            height: 105.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor),
                            child: CachedNetworkImage(
                              imageUrl: home.categories6[0].image!,
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
                              home.categories6[0].titleCategories! ==
                                      "view_more"
                                  ? AppLocalizations.of(context)!
                                      .translate("view_more")!
                                  : convertHtmlUnescape(
                                      home.categories6[0].titleCategories!),
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primaryColor),
                        ),
                        Text("",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
              home.categories6.length > 3 &&
                      home.categories6[3].titleCategories != "view_more"
                  //Kiri bawah
                  ? GestureDetector(
                      onTap: () {
                        redirectLink(home.categories6[3]);
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor),
                            child: CachedNetworkImage(
                              imageUrl: home.categories6[3].image!,
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
                              home.categories6[3].titleCategories! ==
                                      "view_more"
                                  ? AppLocalizations.of(context)!
                                      .translate("view_more")!
                                  : convertHtmlUnescape(
                                      home.categories6[3].titleCategories!),
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 105.w,
                          height: 105.w,
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
              home.categories6.length > 1 &&
                      home.categories6[1].titleCategories != "view_more"
                  //Tengah atas
                  ? GestureDetector(
                      onTap: () {
                        redirectLink(home.categories6[1]);
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor),
                            child: CachedNetworkImage(
                              imageUrl: home.categories6[1].image!,
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
                              home.categories6[1].titleCategories! ==
                                      "view_more"
                                  ? AppLocalizations.of(context)!
                                      .translate("view_more")!
                                  : convertHtmlUnescape(
                                      home.categories6[1].titleCategories!),
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 105.w,
                          height: 105.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primaryColor),
                        ),
                        Text("",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
              home.categories6.length > 4 &&
                      home.categories6[4].titleCategories != "view_more"
                  //Tengah bawah
                  ? GestureDetector(
                      onTap: () {
                        redirectLink(home.categories6[4]);
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor),
                            child: CachedNetworkImage(
                              imageUrl: home.categories6[4].image!,
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
                              home.categories6[4].titleCategories! ==
                                      "view_more"
                                  ? AppLocalizations.of(context)!
                                      .translate("view_more")!
                                  : convertHtmlUnescape(
                                      home.categories6[4].titleCategories!),
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 105.w,
                          height: 105.w,
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
              home.categories6.length > 2 &&
                      home.categories6[2].titleCategories != "view_more"
                  //Kanan atas
                  ? GestureDetector(
                      onTap: () {
                        redirectLink(home.categories6[2]);
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor),
                            child: CachedNetworkImage(
                              imageUrl: home.categories6[2].image!,
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
                              home.categories6[2].titleCategories! ==
                                      "view_more"
                                  ? AppLocalizations.of(context)!
                                      .translate("view_more")!
                                  : convertHtmlUnescape(
                                      home.categories6[2].titleCategories!),
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 105.w,
                          height: 105.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: primaryColor),
                        ),
                        Text("",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
              home.categories6.length > 5 &&
                      home.categories6[5].titleCategories != "view_more"
                  //Kanan bawah
                  ? GestureDetector(
                      onTap: () {
                        redirectLink(home.categories6[5]);
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(5),
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor),
                            child: CachedNetworkImage(
                              imageUrl: home.categories6[5].image!,
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
                          Container(
                            width: 100.w,
                            child: Text(
                                home.categories6[5].titleCategories! ==
                                        "view_more"
                                    ? AppLocalizations.of(context)!
                                        .translate("view_more")!
                                    : convertHtmlUnescape(
                                        home.categories6[5].titleCategories!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 105.w,
                          height: 105.w,
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
