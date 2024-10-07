import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerListItemProduct extends StatelessWidget {
  const ShimmerListItemProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,

      color: Colors.lightGreenAccent.withOpacity(.7),
      padding: EdgeInsets.all(10),
      child: Shimmer.fromColors(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.5), // Bright background color
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
            ),
            SizedBox(width: 10),
            // Text Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.lightGreenAccent, // Fun color for the first text
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  margin: EdgeInsets.only(bottom: 5),
                ),
                Container(
                  width: 250,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent, // Bright color for the second text
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  margin: EdgeInsets.only(bottom: 5),
                ),
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent, // Color for the third text
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  margin: EdgeInsets.only(bottom: 8),
                ),
                // Price Text
                Text(
                  "\$999",
                  style: TextStyle(
                    color: Colors.purpleAccent, // Color for the price
                    fontSize: 12, // Adjusted font size for better visibility
                  ),
                )
              ],
            ),
          ],
        ),
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
      )
      ,
    );
  }
}
