import 'package:flutter/cupertino.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/grid_item.dart';
import 'package:provider/provider.dart';

class SectionH extends StatefulWidget {
  const SectionH({Key? key}) : super(key: key);

  @override
  State<SectionH> createState() => _SectionHState();
}

class _SectionHState extends State<SectionH> {
  @override
  Widget build(BuildContext context) {
    final home = Provider.of<HomeProvider>(context, listen: false);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 15, top: 15, right: 15),
            child: Text(
              // home.recommendationProducts[0].title! == 'Recommendations For You'
              AppLocalizations.of(context)!.translate('title_hap_3')!,
              // : home.recommendationProducts[0].title!,
              style: TextStyle(
                  fontSize: responsiveFont(14), fontWeight: FontWeight.w600),
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 15, bottom: 10, right: 15),
              ),
          //recommendation item
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: GridView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: home.recommendationProducts[0].products!.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  crossAxisCount: 2,
                  childAspectRatio: 78 / 125),
              itemBuilder: (context, i) {
                return GridItem(
                  i: i,
                  itemCount: home.recommendationProducts[0].products!.length,
                  product: home.recommendationProducts[0].products![i],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
