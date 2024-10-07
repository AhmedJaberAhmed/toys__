import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BadgeShimmer extends StatelessWidget {
  final int item = 6;
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 7,
        child: ListView.separated(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) {
            return Container(
              margin: EdgeInsets.only(
                  left: i == 0 ? 15 : 0, right: i == item - 1 ? 15 : 0),
              width: MediaQuery.of(context).size.width / 6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Item Category
                  itemCategory(i),
                  SizedBox(height: 5),
                  // Colorful Shimmer Box
                  Container(
                    width: 60,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5), // Rounded corners
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(width: 15);
          },
          itemCount: item,
        ),
      ),
      baseColor: Colors.lightBlueAccent, // Fun base color for shimmer
      highlightColor: Colors.lightGreenAccent, // Bright highlight color
    )
    ;
  }

  Widget itemCategory(int i, {String type = 'url'}) {
    return Container(
      height: 60,
      width: 60,
      padding: EdgeInsets.all(5),
      color: Colors.white,
    );
  }
}
