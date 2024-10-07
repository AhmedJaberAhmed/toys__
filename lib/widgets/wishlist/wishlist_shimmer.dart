import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_localizations.dart';

class ShimmerWishlist extends StatelessWidget {
  final int? i, itemCount;

  ShimmerWishlist({this.i, this.itemCount});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: null,
      child: Container(
        decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(5)),
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          children: [
        Shimmer.fromColors(
        baseColor: Colors.green,
          highlightColor: Colors.purpleAccent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: HexColor("FFCC80"), // Light orange for kids
                ),
                width: 80.h,
                height: 80.h,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      height: 12,
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        // Discount Badge
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: HexColor("FF5722"), // Bright red for discount
                          ),
                          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                          child: Text(
                            "50%",
                            style: TextStyle(color: Colors.white, fontSize: responsiveFont(9)),
                          ),
                        ),
                        SizedBox(width: 5),
                        // Additional info
                        Container(
                          width: 60,
                          color: Colors.white,
                          height: 8,
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    // Product Name
                    Container(
                      width: 80,
                      color: Colors.white,
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Delete Icon
                        Container(
                          width: 25.h,
                          height: 25.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: HexColor("FF9800")), // Bright orange border
                          ),
                          child: Icon(Icons.delete, color: Colors.redAccent),
                        ),
                        // Add to Cart Button
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: HexColor("FF9800")), // Bright orange border
                          ),
                          onPressed: () {},
                          child: Text(
                            AppLocalizations.of(context)!.translate('add_to_cart')!,
                            style: TextStyle(color: HexColor("FF9800"), fontSize: responsiveFont(9)), // Bright orange text
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )

        ],
        ),
      ),
    );
  }
}
