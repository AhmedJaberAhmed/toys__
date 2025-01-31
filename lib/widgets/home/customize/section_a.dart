import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/pages/auth/sign_in_otp_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/user_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/banner/banner_container.dart';
import 'package:provider/provider.dart';

class SectionA extends StatelessWidget {
  SectionA({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final home = Provider.of<HomeProvider>(context, listen: false);
    String fullName = "${Session.data.getString('firstname')}";
    return Stack(
      children: [
        Positioned(
          top: 0.h,
          left: 0,
          width: MediaQuery.of(context).size.width,
          height: 180.h,
          child: ClipPath(
            clipper: OvalBottomBorderClipper(),
            child: Container(
              height: 180.h,
              color: primaryColor,
            ),
          ),
        ),
        Column(
          children: [
            // SizedBox(
            //   height: 70.h,
            // ),
            Container(
              height: MediaQuery.of(context).size.height / 12,
              margin: EdgeInsets.all(15),
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: home.logo.image!,
                    placeholder: (context, url) => Container(),
                    errorWidget: (context, url, error) => Icon(
                      Icons.image_not_supported_rounded,
                      size: 15,
                    ),
                  ),
                  Container(
                    width: 12,
                  ),
                  Visibility(
                      visible: Session.data.getBool('isLogin') == null ||
                          !Session.data.getBool('isLogin')!,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              home.logo.title!,
                              style: TextStyle(
                                  fontSize: responsiveFont(14),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          Flexible(
                            child: Row(
                              children: [
                                Text(
                                  "${AppLocalizations.of(context)!.translate('please_login')} ",
                                  style: TextStyle(
                                      fontSize: responsiveFont(10),
                                      color: Colors.white),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SignInOTPScreen(
                                                  isFromNavBar: false,
                                                )));
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('here')!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: responsiveFont(10),
                                        color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      )),
                  Visibility(
                      visible: Session.data.getBool('isLogin')!,
                      child: Consumer<UserProvider>(
                        builder: (context, value, child) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: value.loading
                                  ? Container()
                                  : Text(
                                      "${AppLocalizations.of(context)!.translate('hello')!}, ${fullName.length > 10 ? fullName.substring(0, 10) + '... ' : fullName}",
                                      style: TextStyle(
                                          fontSize: responsiveFont(14),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                            ),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate('welcome')!,
                                style: TextStyle(
                                    fontSize: responsiveFont(10),
                                    color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ))
                ],
              ),
            ),

            //Banner Item start Here
            Consumer<HomeProvider>(builder: (context, value, child) {
              return Visibility(
                visible: value.banners.isNotEmpty,
                child: BannerContainer(
                  contentHeight: MediaQuery.of(context).size.height,
                  dataSliderLength: value.banners.length,
                  dataSlider: value.banners,
                  loading: customLoading(),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
