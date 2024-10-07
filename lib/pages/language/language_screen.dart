import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:provider/provider.dart';

import '../../utils/utility.dart';

class LanguageScreen extends StatefulWidget {
  LanguageScreen({Key? key}) : super(key: key);

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  List<String> image = [
    "qatar",
    "united_states",
  ];
  List<String> title = [
    "Arabic",
    "English",
  ];

  String locale(int? index) {
    String locale = 'ar';
    if (index == 0) {
      locale = 'ar';
    } else if (index == 1) {
      locale = 'en';
    }
    return locale;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.translate('title_language')!,
          style: TextStyle(
              // color: Colors.black,
              fontSize: responsiveFont(16),
              fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          color: appLanguage.isLoading ? Colors.grey : Colors.black,
          onPressed: () {
            if (!appLanguage.isLoading) {
              Navigator.pop(context);
            }
          },
          icon: Icon(
            Icons.arrow_back,
            // color: Colors.black,
          ),
        ),
      ),
      body: Container(
          margin: EdgeInsets.all(15),
          child: ListView(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemBuilder: (context, i) {
                  return InkWell(
                    onTap: () async {
                      setState(() {
                        appLanguage.selectedLocaleIndex = i;
                      });
                      appLanguage.changeLanguage(
                          Locale(locale(appLanguage.selectedLocaleIndex)),
                          context);

                      // printLog(
                      //     "==== " + Session.data.getString('language_code')!);

                      // await context
                      //     .read<HomeProvider>()
                      //     .fetchHome(context)
                      //     .then((value) async {
                      //   printLog("=== masuk then ===");
                      //   if (Provider.of<HomeProvider>(context, listen: false)
                      //       .activateCurrency) {
                      //     printLog("=== masuk if ===");
                      //     await Provider.of<GeneralSettingsProvider>(context,
                      //             listen: false)
                      //         .loadAllCurrency(context);
                      //   }
                      // });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      width: double.infinity,
                      child: itemList(image[i], title[i], i),
                    ),
                  );
                },
                itemCount: title.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    width: double.infinity,
                    height: 1,
                    color: HexColor("c4c4c4"),
                  );
                },
              ),
            ],
          )),
    );
  }

  Widget itemList(String image, String title, int i) {
    var appLanguage = Provider.of<AppNotifier>(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                    width: 36.h,
                    height: 36.w,
                    child: Image.asset("images/account/$image.png")),
                SizedBox(
                  width: 15,
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: responsiveFont(12)),
                )
              ],
            ),
            appLanguage.selectedLocaleIndex == i
                ? appLanguage.isLoading
                    ? customLoading()
                    : Text(
                        AppLocalizations.of(context)!.translate('active')!,
                        style: TextStyle(
                            fontSize: responsiveFont(12),
                            fontWeight: FontWeight.w600,
                            color: secondaryColor),
                      )
                : Container()
          ],
        )
      ],
    );
  }
}
