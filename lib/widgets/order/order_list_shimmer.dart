import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:shimmer/shimmer.dart';

class OrderListShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (context, i) {
          return Container(
            margin: EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            child: Shimmer.fromColors(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container for Image/Avatar
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            color: Colors.orangeAccent[100], // Bright color for kids
                          ),
                          height: 50.h,
                          width: 50.h,
                        ),
                        Container(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 10,
                                color: Colors.white,
                              ),
                              Container(
                                height: 5,
                              ),
                              Container(
                                width: 30,
                                height: 10,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 5,
                  ),
                  // Total Cost Section
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total cost",
                              style: TextStyle(fontSize: responsiveFont(8)),
                            ),
                            Container(
                              width: 60,
                              height: 10,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        // More Details Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.pinkAccent, // Brighter primary color
                                Colors.yellowAccent, // Brighter secondary color
                              ],
                            ),
                          ),
                          height: 30.h,
                          child: TextButton(
                            onPressed: null,
                            child: Text(
                              "More details",
                              style: TextStyle(color: Colors.white, fontSize: responsiveFont(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 10,
                              color: Colors.white,
                            ),
                            Container(
                              height: 5,
                            ),
                            Container(
                              width: 60,
                              height: 10,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        // Status or Tag Section
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.greenAccent[100], // Bright background color
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          child: Container(
                            width: 60,
                            height: 10,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            )

          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            color: HexColor("c4c4c4"),
            height: 1,
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 10),
          );
        },
        itemCount: 3);
  }
}
