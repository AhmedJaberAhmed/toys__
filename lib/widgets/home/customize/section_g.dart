import 'package:flutter/material.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/card_item_small.dart';
import 'package:provider/provider.dart';

class SectionG extends StatefulWidget {
  const SectionG({Key? key}) : super(key: key);

  @override
  State<SectionG> createState() => _SectionGState();
}

class _SectionGState extends State<SectionG> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, child) {
      return Visibility(
        visible: value.specialProducts.isNotEmpty &&
            value.specialProducts[0].products!.length > 0,
        child: Column(
          children: [
            Container(
                width: double.infinity,
                margin:
                    EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          value.specialProducts.isNotEmpty &&
                                  value.specialProducts[0].title! ==
                                      'Special Promo : App Only'
                              ? AppLocalizations.of(context)!
                                  .translate('title_hap_1')!
                              : value.specialProducts[0].title!,
                          style: TextStyle(
                              fontSize: responsiveFont(14),
                              fontWeight: FontWeight.w600),
                        )),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BrandProducts(
                                          brandName: value.specialProducts[0]
                                                      .title! ==
                                                  'Special Promo : App Only'
                                              ? AppLocalizations.of(context)!
                                                  .translate('title_hap_1')!
                                              : value.specialProducts[0].title!,
                                          sortIndex: 3,
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
                    Text(
                      value.specialProducts[0].description == null
                          ? ''
                          : value.specialProducts[0].description! == 'For You'
                              ? AppLocalizations.of(context)!
                                  .translate('description_hap_1')!
                              : value.specialProducts[0].description!,
                      style: TextStyle(
                        fontSize: responsiveFont(12),
                        // color: Colors.black,
                      ),
                      textAlign: TextAlign.justify,
                    )
                  ],
                )),
            AspectRatio(
              aspectRatio: 3 / 2,
              child: value.loading
                  ? shimmerProductItemSmall()
                  : ListView.separated(
                      itemCount: value.specialProducts[0].products!.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) {
                        return CardItem(
                          product: value.specialProducts[0].products![i],
                          i: i,
                          itemCount: value.specialProducts[0].products!.length,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          width: 5,
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }
}
