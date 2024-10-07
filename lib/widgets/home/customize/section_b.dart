import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/banner/banner_container.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../pages/search/search_screen.dart';

class SectionB extends StatefulWidget {
  const SectionB({Key? key}) : super(key: key);

  @override
  State<SectionB> createState() => _SectionBState();
}

class _SectionBState extends State<SectionB> {
  final String phoneNumber = "+97450208668"; // Enter your WhatsApp phone number with country code
  final String message = "مرحبًا، أود الاستفسار عن اللعبة المتوفرة لديكم. هل يمكنني الحصول على المزيد من المعلومات حول المواصفات والسعر؟ وهل هي متوفرة حاليًا في المتجر؟ شكرًا لكم."; // Pre-filled message

  // Function to open WhatsApp
  void openWhatsApp(BuildContext context) async {
    final whatsappUrl = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

    // Check if WhatsApp can be launched
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      // If WhatsApp is not installed or can't be launched, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("WhatsApp is not installed or can't be launched")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    String _getHintText(BuildContext context) {
      Locale currentLocale = Localizations.localeOf(context);

      // Check the locale and return the corresponding hint text
      if (currentLocale.languageCode == 'ar') {
        return 'ما الذي تبحث عنه؟'; // Arabic text
      } else {
        return 'What are you looking for?'; // English text or any other default
      }
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        children: [
          // Material with Search TextField
        Material(
        elevation: 5,
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          height: 70,
          padding: EdgeInsets.only(left: 15, right: 10, top: 15, bottom: 15),
          child: Row(
            children: [
              Expanded(
                flex: 9, // Takes most of the available space
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchScreen()),
                    );
                  },
                  child: TextField(
                    style: TextStyle(fontSize: 14),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      isDense: true,
                      isCollapsed: true,
                      filled: true,
                      enabled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: Icon(Icons.content_paste_search_rounded),
                      hintText: _getHintText(context),
                      hintStyle: TextStyle(fontSize: responsiveFont(10)),
                    ),
                  ),



          ),
              ),
              SizedBox(width: 10), // Add space between TextField and Icon
              InkWell(
                onTap: () { openWhatsApp(context);},

                child: Image.asset("images/waw.png"), // Phone icon
              ),
            ],
          ),
        ),
      ),
          SizedBox(height: 20), // Add some space between the search bar and the banner
          Consumer<HomeProvider>(builder: (context, value, child) {
            return Visibility(
              visible: value.banners2.isNotEmpty,
              child: BannerContainer(
                contentHeight: MediaQuery.of(context).size.height,
                dataSliderLength: value.banners2.length,
                dataSlider: value.banners2,
                loading: customLoading(),
              ),
            );
          }),
        ],
      ),
    );

  }
}
