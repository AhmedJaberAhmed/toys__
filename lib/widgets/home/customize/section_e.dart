import 'package:flutter/material.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/widgets/home/banner/banner_mini.dart';
import 'package:provider/provider.dart';

class SectionE extends StatefulWidget {
  const SectionE({Key? key}) : super(key: key);

  @override
  State<SectionE> createState() => _SectionEState();
}

class _SectionEState extends State<SectionE> {
  bool showBannerLove = true;

  @override
  void initState() {
    super.initState();
    final home = Provider.of<HomeProvider>(context, listen: false);
    for (int i = 0; i < home.bannerLove.length; i++) {
      if (home.bannerLove.first.name == "") {
        setState(() {
          showBannerLove = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: showBannerLove,
          child: Container(color: Colors.white,
            margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text(
                //   AppLocalizations.of(context)!.translate('banner_2')!,
                //   style: TextStyle(
                //       fontSize: responsiveFont(14),
                //       fontWeight: FontWeight.w600),
                // ),
                /*GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AllProducts()));
                              },
                              child: Text(
                                "More",
                                style: TextStyle(
                                    fontSize: responsiveFont(12),
                                    fontWeight: FontWeight.w600,
                                    color: secondaryColor),
                              ),
                            ),*/
              ],
            ),
          ),
        ),
        //Mini Banner Item start Here
        Visibility(
          visible: showBannerLove,
          child: Consumer<HomeProvider>(
            builder: (context, value, child) {
              return BannerMini(
                typeBanner: 'love',
                bannerLove: value.bannerLove,
                bannerSpecial: value.bannerSpecial,
              );
            },
          ),
        ),
      ],
    );
  }
}
