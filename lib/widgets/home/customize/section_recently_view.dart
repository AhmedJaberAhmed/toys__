import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_localizations.dart';
import '../../../pages/product/product_more_screen.dart';
import '../../../provider/product_provider.dart';
import '../../../utils/utility.dart';
import '../product_container.dart';

class SectionRecentlyView extends StatelessWidget {
  const SectionRecentlyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<ProductProvider>(builder: (context, value, child) {
        return Visibility(
            visible: value.listRecentProduct.isNotEmpty,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.translate('recent_view')!,
                        style: TextStyle(
                            fontSize: responsiveFont(14),
                            fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductMoreScreen(
                                        name: AppLocalizations.of(context)!
                                            .translate('recent_view')!,
                                        include: value.productRecent,
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
                ProductContainer(
                  products: value.listRecentProduct,
                )
              ],
            ));
      }),
    );
  }
}
