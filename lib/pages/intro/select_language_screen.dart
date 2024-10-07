import 'package:flutter/material.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/pages/home/home_screen.dart';
import 'package:nyoba/pages/intro/intro_screen.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/custom_page_route.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
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
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppNotifier>(context);
    final home = Provider.of<HomeProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 40),
        child: ListView(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.translate('choose_language')!,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: responsiveFont(20),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemBuilder: (context, i) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      appLanguage.selectedLocaleIndex = i;
                    });
                    appLanguage.changeLanguage(
                        Locale(locale(appLanguage.selectedLocaleIndex)),
                        context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    child: itemList(image[i], title[i], i),
                    // child: LanguageOption(
                    //   image: image[i],
                    //   title: title[i],
                    //   // isSelected: appLanguage.selectedLocaleIndex == i,
                    //   index: i,
                    // ),
                  ),
                );
              },
              itemCount: title.length,
              separatorBuilder: (context, index) => SizedBox(height: 0),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  appLanguage.isLoading
                      ? null
                      : home.intro.isEmpty
                          ? Navigator.of(context).pushReplacement(
                              CustomPageRoute(
                                direction: AxisDirection.left,
                                child: ShowCaseWidget(
                                    builder: Builder(
                                  builder: (context) => HomeScreen(),
                                )),
                              ),
                            )
                          : Navigator.of(context).pushReplacement(
                              CustomPageRoute(
                                direction: AxisDirection.left,
                                child: IntroScreen(
                                  intro: home.intro,
                                ),
                              ),
                            );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        appLanguage.isLoading ? Colors.grey : primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 10)),
                child: appLanguage.isLoading
                    ? customLoading()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!
                              .translate('continue')!),
                          Icon(Icons.arrow_forward_ios_rounded)
                        ],
                      ))
          ],
        ),
      ),
    );
  }

  Widget itemList(String image, String title, int index) {
    var appLanguage = Provider.of<AppNotifier>(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: appLanguage.selectedLocaleIndex == index
            ? Colors.blue[50]
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(
            "images/account/$image.png",
            width: 40,
            height: 40,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                appLanguage.selectedLocaleIndex = index;
              });
              appLanguage.changeLanguage(
                  Locale(locale(appLanguage.selectedLocaleIndex)), context);
            },
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: appLanguage.selectedLocaleIndex == index
                    ? primaryColor
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor),
              ),
              height: 20,
              width: 20,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: appLanguage.selectedLocaleIndex == index
                      ? Colors.white
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Radio<String>(
          //   value: title,
          //   groupValue: appLanguage.selectedLocaleIndex == index ? title : null,
          //   onChanged: (value) {
          //     // onTap();
          //   },
          //   activeColor: primaryColor,
          // ),
        ],
      ),
    );
  }
}

// class LanguageOption extends StatelessWidget {
//   final String image;
//   final String title;
//   // final bool isSelected;
//   // final VoidCallback onTap;
//   final int index;

//   const LanguageOption({
//     required this.image,
//     required this.title,
//     // required this.isSelected,
//     // required this.onTap,
//     required this.index,
//   });

//   @override
//   Widget build(BuildContext context) {
//     var appLanguage = Provider.of<AppNotifier>(context);
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       decoration: BoxDecoration(
//         color: appLanguage.selectedLocaleIndex == index
//             ? Colors.blue[50]
//             : Colors.transparent,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Image.asset(
//             "images/account/$image.png",
//             width: 40,
//             height: 40,
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           Radio<String>(
//             value: title,
//             groupValue: appLanguage.selectedLocaleIndex == index ? title : null,
//             onChanged: (value) {
//               // onTap();
//             },
//             activeColor: primaryColor,
//           ),
//         ],
//       ),
//     );
//   }
// }
