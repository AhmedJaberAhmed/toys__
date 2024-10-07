import 'package:flutter/material.dart';
import 'package:nyoba/pages/product/product_more_screen.dart';
import 'package:nyoba/widgets/webview/inapp_webview.dart';

class ItemDrawerMain extends StatelessWidget {
  final Map<String, dynamic>? item;
  const ItemDrawerMain({super.key, this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item!['link']! == "shop") {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductMoreScreen(
                  include: "",
                  name: "All Products",
                ),
              ));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    InAppWebview(url: item!['link'], title: item!['title']!),
              ));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Text(
              item!['title']!,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey[300],
          )
        ],
      ),
    );
  }
}
