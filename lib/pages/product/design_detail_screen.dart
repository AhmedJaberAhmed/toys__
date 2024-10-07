import 'package:flutter/material.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/pages/product/fnb_detail_screen.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:provider/provider.dart';

class DesignDetailScreen extends StatelessWidget {
  final String? productId;
  final String? slug;
  final ProductModel? product;
  final String? videoId;
  DesignDetailScreen(
      {Key? key, this.productId, this.slug, this.product, this.videoId = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, value, child) {
        if (value.desainDetailProduct == "design_1") {
          return ProductDetail(
            product: product,
            productId: productId,
            slug: slug,
            videoId: videoId,
          );
        }
        if (value.desainDetailProduct == "design_2") {
          return FNBDetailScreen(
            product: product,
            productId: productId,
          );
        }
        return Container();
      },
    );
  }
}
