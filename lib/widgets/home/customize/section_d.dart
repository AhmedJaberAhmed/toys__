import 'package:flutter/material.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/product_container.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SectionD extends StatefulWidget {
  const SectionD({Key? key}) : super(key: key);

  @override
  State<SectionD> createState() => _SectionDState();
}

class _SectionDState extends State<SectionD> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: Provider.of<HomeProvider>(context, listen: false)
              .bestProducts[0]
              .products!
              .length >
          0,
      child: Stack(
        children: [
          Container(
            color: primaryColor,
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 3.5,
          ),
          Consumer<HomeProvider>(builder: (context, value, child) {
            if (value.loading) {
              return Column(
                children: [
                  Shimmer.fromColors(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 15, right: 15, top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 150,
                                  height: 10,
                                  color: Colors.white,
                                )
                              ],
                            ),
                            Container(
                              height: 2,
                            ),
                            Container(
                              width: 100,
                              height: 8,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!),
                  Container(
                    height: 10,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 3.0,
                    child: shimmerProductItemSmall(),
                  )
                ],
              );
            }
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 15, right: 15, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                            value.bestProducts[0].title! == 'Best Seller'
                                ? AppLocalizations.of(context)!
                                    .translate('title_hap_2')!
                                : value.bestProducts[0].title!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: responsiveFont(14),
                                fontWeight: FontWeight.w600),
                          )),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BrandProducts(
                                            brandName: value.bestProducts[0]
                                                        .title! ==
                                                    'Best Seller'
                                                ? AppLocalizations.of(context)!
                                                    .translate('title_hap_2')!
                                                : value.bestProducts[0].title!,
                                            sortIndex: 0,
                                          )));
                            },
                            child: Text(
                              AppLocalizations.of(context)!.translate('more')!,
                              style: TextStyle(
                                  fontSize: responsiveFont(12),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        value.bestProducts[0].description == null
                            ? ''
                            : value.bestProducts[0].description! ==
                                    'Get The Best Products'
                                ? AppLocalizations.of(context)!
                                    .translate('description_hap_2')!
                                : value.bestProducts[0].description!,
                        style: TextStyle(
                          fontSize: responsiveFont(12),
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.justify,
                      )
                    ],
                  ),
                ),
                Container(
                  height: 10,
                ),
                ProductContainer(
                  products: value.bestProducts[0].products!,
                )
              ],
            );
          }),
        ],
      ),
    );
  }
}
