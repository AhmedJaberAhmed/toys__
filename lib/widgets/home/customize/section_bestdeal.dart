import 'package:flutter/cupertino.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/grid_item.dart';
import 'package:nyoba/widgets/product/grid_item_shimmer.dart';
import 'package:provider/provider.dart';

class SectionBestDeal extends StatefulWidget {
  const SectionBestDeal({Key? key}) : super(key: key);

  @override
  State<SectionBestDeal> createState() => _SectionBestDealState();
}

class _SectionBestDealState extends State<SectionBestDeal> {
  int page = 1;
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(builder: (context, value, child) {
      if (value.loadingBestDeals && value.pageBestDeals == 1) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GridView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  childAspectRatio: 78 / 125),
              itemBuilder: (context, i) {
                return GridItemShimmer();
              }),
        );
      }
      return Visibility(
          visible: value.listBestDeal.isNotEmpty,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin:
                    EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                child: Text(
                  AppLocalizations.of(context)!.translate('best_deals')!,
                  style: TextStyle(
                      fontSize: responsiveFont(14),
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: GridView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: value.listBestDeal.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 2,
                        childAspectRatio: 78 / 125),
                    itemBuilder: (context, i) {
                      return GridItem(
                        i: i,
                        itemCount: value.listBestDeal.length,
                        product: value.listBestDeal[i],
                      );
                    }),
              ),
              if (value.loadingBestDeals) customLoading()
            ],
          ));
    });
  }
}
