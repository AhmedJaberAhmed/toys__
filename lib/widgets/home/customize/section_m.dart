import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/card_item_small.dart';
import 'package:provider/provider.dart';

class SectionM extends StatefulWidget {
  const SectionM({Key? key}) : super(key: key);

  @override
  State<SectionM> createState() => _SectionMState();
}

class _SectionMState extends State<SectionM> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, child) {
      return Visibility(
        visible: value.productSectionM.isNotEmpty &&
            value.productSectionM[0].products!.length > 0,
        child: Column(
          children: [
            // Container(
            //     width: double.infinity,
            //     margin: EdgeInsets.only(left: 15, bottom: 10, right: 15),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Expanded(
            //                 child: Text(
            //               value.productSectionM.isNotEmpty &&
            //                       value.productSectionM[0].title! ==
            //                           'Special Promo : App Only'
            //                   ? AppLocalizations.of(context)!
            //                       .translate('title_hap_1')!
            //                   : value.productSectionM[0].title!,
            //               style: TextStyle(
            //                   fontSize: responsiveFont(14),
            //                   fontWeight: FontWeight.w600),
            //             )),
            //             GestureDetector(
            //               onTap: () {
            //                 Navigator.push(
            //                     context,
            //                     MaterialPageRoute(
            //                         builder: (context) => BrandProducts(
            //                               brandName: value.productSectionM[0]
            //                                           .title! ==
            //                                       'Special Promo : App Only'
            //                                   ? AppLocalizations.of(context)!
            //                                       .translate('title_hap_1')!
            //                                   : value.productSectionM[0].title!,
            //                               sortIndex: 3,
            //                             )));
            //               },
            //               child: Text(
            //                 AppLocalizations.of(context)!.translate('more')!,
            //                 style: TextStyle(
            //                     fontSize: responsiveFont(12),
            //                     fontWeight: FontWeight.w600,
            //                     color: secondaryColor),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ],
            //     )),
            AspectRatio(
              aspectRatio: 1.35,
              child: value.loading
                  ? shimmerProductItemSmall()
                  : Container(
                      margin: EdgeInsets.only(top: 15, bottom: 10),
                      child: ListView.separated(
                        itemCount: value.productSectionM[0].products!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          return CardItem(
                            product: value.productSectionM[0].products![i],
                            i: i,
                            itemCount:
                                value.productSectionM[0].products!.length,
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: 5,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}
