import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CouponShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemBuilder: (context, i) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left Card
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 100.h,
                    child: Card(
                      color: Colors.lightBlue[100], // Light blue background for fun
                      elevation: 4, // Slight elevation for depth
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 5, bottom: 15),
                              width: double.infinity,
                              height: 10,
                              color: Colors.white,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5, bottom: 15),
                              width: double.infinity,
                              height: 8,
                              color: Colors.white,
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                alignment: Alignment.centerRight,
                                width: 150,
                                height: 8,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Right Card
                  Container(
                    height: 100.h,
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Card(
                      color: Colors.pink[300], // Light pink background for fun
                      elevation: 4, // Slight elevation for depth
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Rounded corners
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        child: Column(
                          children: [
                            Text(
                              "GET",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5, bottom: 15),
                              width: double.infinity,
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(
            height: 15,
          );
        },
        itemCount: 4);
  }
}
