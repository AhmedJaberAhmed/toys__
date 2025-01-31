import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../provider/app_provider.dart';

class CardItemShimmer extends StatelessWidget {
  final int? i, itemCount;

  CardItemShimmer({this.i, this.itemCount});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<AppNotifier>(context, listen: false).appLocal;
    return InkWell(
      onTap: null,
      child: Container(
        margin: EdgeInsets.only(
          left: locale == Locale('ar')
              ? i == itemCount! - 1
                  ? 15
                  : 0
              : i == 0
                  ? 15
                  : 0,
          right: locale == Locale('ar')
              ? i == 0
                  ? 15
                  : 0
              : i == itemCount! - 1
                  ? 15
                  : 0,
        ),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        width: MediaQuery.of(context).size.width / 3,
        height: double.infinity,
        child: Card(
            elevation: 5,
            margin: EdgeInsets.only(bottom: 10),
            child:Shimmer.fromColors(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10), // Increased radius for a softer look
                        topLeft: Radius.circular(10),
                      ),
                      color: Colors.pinkAccent.withOpacity(0.5), // Fun background color
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 3,
                            child: Container(
                              width: double.infinity,
                              height: 10,
                              color: Colors.lightGreenAccent, // Fun color for top text
                            ),
                          ),
                          Container(height: 5),
                          Flexible(
                            flex: 2,
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.orangeAccent, // Bright color for icon
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                  width: 20,
                                  height: 10,
                                ),
                                SizedBox(width: 5),
                                Container(
                                  width: 70,
                                  height: 10,
                                  color: Colors.yellowAccent, // Bright color for text
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              child: Container(
                                width: 70,
                                height: 10,
                                color: Colors.lightBlueAccent, // Fun color for lower text
                              ),
                            ),
                          ),
                          Container(height: 5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            )
        ),
      ),
    );
  }
}
