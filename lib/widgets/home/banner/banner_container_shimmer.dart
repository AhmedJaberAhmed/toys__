import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BannerContainerShimmer extends StatelessWidget {
  final int dataSliderLength;
  final double contentHeight;

  BannerContainerShimmer(
      {required this.dataSliderLength, required this.contentHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: contentHeight / 6.5,
      child: ListView.separated(
          physics: BouncingScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 10,
            );
          },
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: dataSliderLength,
          itemBuilder: (context, i) {
            return Shimmer.fromColors(
              child: Container(
                margin: EdgeInsets.only(
                    left: i == 0 ? 15 : 0,
                    right: i == dataSliderLength - 1 ? 15 : 0),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height / 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient( // Adding a gradient for a fun effect
                    colors: [
                      Colors.lightBlueAccent, // Bright base color
                      Colors.pinkAccent,      // Playful highlight color
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10), // Slightly increased border radius for softness
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: Offset(0, 2), // Soft shadow for depth
                    ),
                  ],
                ),
              ),
              baseColor: Colors.transparent, // Making base color transparent to show gradient
              highlightColor: Colors.transparent, // Making highlight color transparent to show gradient
            )
            ;
          }),
    );
  }
}
