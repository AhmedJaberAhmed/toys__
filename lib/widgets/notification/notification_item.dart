import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/utils/notification_text.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

import '../../provider/notification_provider.dart';

class NotificationItem extends StatelessWidget {
  final int index;
  const NotificationItem({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, value, child) {
        if (value.notification[index].type == 'push_notif') {
          final DateTime now =
              DateTime.parse(value.notification[index].createdAt!);
          final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
          final String formatted = formatter.format(now);
          final isDarkMode = Provider.of<AppNotifier>(context).isDarkMode;
          return Container(
            padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
            color: value.notification[index].isRead != 0
                ? null
                : isDarkMode
                    ? Colors.grey[700]
                    : Color(0xfffff8e8),
            child: Column(
              children: [
                CachedNetworkImage(
                    imageUrl: value.notification[index].description!['image'],
                    width: double.infinity,
                    placeholder: (context, url) => Container(),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.image_not_supported_outlined)),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(3)),
                                    child: Text(
                                      "${AppLocalizations.of(context)!.translate('promo')}",
                                      style: TextStyle(
                                          fontSize: responsiveFont(8),
                                          color: Colors.white),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.query_builder),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        formatted,
                                        style: TextStyle(
                                            fontSize: responsiveFont(8),
                                            fontWeight: FontWeight.w300),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                value.notification[index].description!['title'],
                                style: TextStyle(
                                    fontSize: responsiveFont(10),
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text:
                                            '${value.notification[index].description!['description']} ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: responsiveFont(9))),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        }
        final isDarkMode = Provider.of<AppNotifier>(context).isDarkMode;
        return Container(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
          color: value.notification[index].isRead != 0
              ? null
              : isDarkMode
                  ? Colors.grey[700]
                  : Color(0xfffff8e8),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: 80.h,
                    height: 80.h,
                    child: value.notification[index].description!['image'] ==
                            null
                        ? Icon(
                            Icons.broken_image_outlined,
                            size: 80,
                          )
                        : CachedNetworkImage(
                            imageUrl:
                                value.notification[index].description!['image'],
                            memCacheHeight: 200,
                            memCacheWidth: 200,
                            placeholder: (context, url) => Container(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.image_not_supported_outlined)),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(3)),
                              child: Text(
                                "${AppLocalizations.of(context)!.translate('shopping')}",
                                style: TextStyle(
                                    fontSize: responsiveFont(8),
                                    color: Colors.white),
                              ),
                            ),
                            Text(
                              buildNotificationTitle(
                                  value.notification[index]
                                      .description!['description'],
                                  context),
                              style: TextStyle(
                                  fontSize: responsiveFont(10),
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          '${AppLocalizations.of(context)!.translate('order_with_number')} ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: responsiveFont(9))),
                                  TextSpan(
                                      text: value.notification[index]
                                          .description!['link_to']
                                          .toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: responsiveFont(9),
                                          color: primaryColor)),
                                  TextSpan(
                                      text: buildNotificationSubtitle(
                                          value.notification[index]
                                              .description!['description'],
                                          context),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: responsiveFont(9))),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.query_builder),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              value.notification[index].createdAt!,
                              style: TextStyle(
                                  fontSize: responsiveFont(8),
                                  fontWeight: FontWeight.w300),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
