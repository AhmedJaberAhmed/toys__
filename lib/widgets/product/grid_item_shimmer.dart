import 'package:flutter/material.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_localizations.dart';

class GridItemShimmer extends StatelessWidget {
  final int? i, itemCount;

  GridItemShimmer({this.i, this.itemCount});

  @override
  Widget build(BuildContext context) {
    // Define some vibrant colors
    Color baseColor = Colors.pinkAccent.withOpacity(0.2); // Base shimmer color
    Color highlightColor = Colors.yellowAccent.withOpacity(0.3); // Highlight shimmer color
    Color secondaryColor = Colors.blueAccent; // Button border color

    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)), // Rounded corners
      child: Card(
        elevation: 5,
        margin: EdgeInsets.only(bottom: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners for card
        child: Shimmer.fromColors(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightGreenAccent, // Fun background color
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title area
                      Container(
                        width: 120,
                        height: 15,
                        color: Colors.orangeAccent, // Title color
                      ),
                      SizedBox(height: 5),
                      Flexible(
                        flex: 1,
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: secondaryColor,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                              child: Container(
                                width: 5,
                                height: 12,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: 60,
                              height: 10,
                              color: Colors.redAccent, // Subtitle color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      // Description area
                      Container(
                        width: 80,
                        height: 10,
                        color: Colors.purpleAccent, // Description color
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: secondaryColor,
                    ),
                    alignment: Alignment.center,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: responsiveFont(9),
                        color: secondaryColor,
                      ),
                      Text(
                        AppLocalizations.of(context)!.translate('add_to_cart')!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: responsiveFont(9),
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          baseColor: baseColor,
          highlightColor: highlightColor,
        ),
      ),
    );
  }
}
