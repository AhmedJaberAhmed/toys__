import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/product_container.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SectionF extends StatefulWidget {
  SectionF({Key? key}) : super(key: key);

  @override
  State<SectionF> createState() => _SectionFState();
}

class _SectionFState extends State<SectionF> {
  String? clickIndex = "";
  String? selectedCategory;

  loadNewProduct(bool loading) async {
    this.setState(() {});
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchNewProducts(clickIndex == "" ? '' : clickIndex.toString());
  }

  @override
  Widget build(BuildContext context) {
    final home = Provider.of<HomeProvider>(context, listen: false);
    Widget buildNewProductsClicked = Container(
      child: Consumer<ProductProvider>(builder: (context, value, child) {
        if (value.loadingNew) {
          return Container(
              height: MediaQuery.of(context).size.height / 3.0,
              child: shimmerProductItemSmall());
        }
        return ProductContainer(
          products: value.listNewProduct,
        );
      }),
    );

    Widget buildNewProducts = Container(
      child: ListenableProvider.value(
        value: home,
        child: Consumer<HomeProvider>(builder: (context, value, child) {
          if (value.loading) {
            return Container(
                height: MediaQuery.of(context).size.height / 3.0,
                child: shimmerProductItemSmall());
          }
          return ProductContainer(
            products: value.listNewProduct,
          );
        }),
      ),
    );
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.translate('new_product')!,
                style: TextStyle(
                    fontSize: responsiveFont(14), fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BrandProducts(
                                categoryId: clickIndex == ""
                                    ? ''
                                    : clickIndex.toString(),
                                brandName: selectedCategory ??
                                    AppLocalizations.of(context)!
                                        .translate('new_product'),
                                sortIndex: 1,
                              )));
                },
                child: Text(
                  AppLocalizations.of(context)!.translate('more')!,
                  style: TextStyle(
                      fontSize: responsiveFont(12),
                      fontWeight: FontWeight.w600,
                      color: secondaryColor),
                ),
              ),
            ],
          ),
        ),
        Consumer<HomeProvider>(builder: (context, value, child) {
          if (value.loading) {
            return Container(
              margin: EdgeInsets.only(left: 15),
              height: MediaQuery.of(context).size.height / 21,
              child: ListView.separated(
                itemCount: 6,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  return Shimmer.fromColors(
                    child: Container(
                      color: Colors.white,
                      height: 25,
                      width: 100,
                    ),
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: 5,
                  );
                },
              ),
            );
          } else {
            return Container(
              height: MediaQuery.of(context).size.height / 21,
              child: ListView.separated(
                  itemCount: value.collection.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    return GestureDetector(
                        onTap: () {
                          if (value.collection[i].id.toString() ==
                              clickIndex.toString()) {
                            setState(() {
                              clickIndex = "";
                              selectedCategory = AppLocalizations.of(context)!
                                  .translate('new_product');
                            });
                            context
                                .read<ProductProvider>()
                                .fetchNewProducts(selectedCategory!);
                            print("masuk if");
                          } else {
                            setState(() {
                              clickIndex = value.collection[i].id!.toString();
                              selectedCategory = value.collection[i].name;
                            });
                            print("masuk else");
                            loadNewProduct(true);
                          }
                          setState(() {});
                        },
                        child: tabCategory(
                            value.collection[i], i, value.collection.length));
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      width: 8,
                    );
                  }),
            );
          }
        }),
        Container(
          height: 10,
        ),
        clickIndex == "" ? buildNewProducts : buildNewProductsClicked,
      ],
    );
  }

  Widget tabCategory(ProductCategoryModel model, int i, int count) {
    final locale = Provider.of<AppNotifier>(context, listen: false).appLocal;
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;
    return Container(
      margin: EdgeInsets.only(
          left: locale == Locale('ar')
              ? i == count - 1
                  ? 15
                  : 0
              : i == 0
                  ? 15
                  : 0,
          right: locale == Locale('ar')
              ? i == 0
                  ? 15
                  : 0
              : i == count - 1
                  ? 15
                  : 0),
      child: Tab(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: clickIndex.toString() == model.id.toString()
                  ? primaryColor.withOpacity(0.3)
                  : isDarkMode
                      ? Colors.grey
                      : Colors.white,
              border: Border.all(
                  color: clickIndex.toString() == model.id.toString()
                      ? secondaryColor
                      : HexColor("B0b0b0")),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              convertHtmlUnescape(model.name!),
              style: TextStyle(
                  fontSize: 13,
                  color: clickIndex.toString() == model.id.toString()
                      ? isDarkMode
                          ? Colors.white
                          : secondaryColor
                      : null),
            )),
      ),
    );
  }
}
