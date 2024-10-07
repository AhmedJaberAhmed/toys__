import 'package:flutter/cupertino.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/banner/banner_mini.dart';
import 'package:provider/provider.dart';

class SectionQ extends StatefulWidget {
  const SectionQ({Key? key}) : super(key: key);

  @override
  State<SectionQ> createState() => _SectionQState();
}

class _SectionQState extends State<SectionQ> {
  bool showBannerSpecial = true;

  @override
  void initState() {
    super.initState();
    final home = Provider.of<HomeProvider>(context, listen: false);
    for (int i = 0; i < home.bannerSpecial.length; i++) {
      if (home.bannerSpecial.first.name == "") {
        setState(() {
          showBannerSpecial = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: showBannerSpecial,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              AppLocalizations.of(context)!.translate('banner_1')!,
              style: TextStyle(
                  fontSize: responsiveFont(14), fontWeight: FontWeight.w600),
            ),
          ),
        ),
        //Mini Banner Item start Here
        // buildMiniBanner,
        Visibility(
          visible: showBannerSpecial,
          child: Consumer<HomeProvider>(
            builder: (context, value, child) {
              return BannerMini(
                typeBanner: 'special',
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
