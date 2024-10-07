import 'package:flutter/cupertino.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/widgets/home/categories/badge_category.dart';
import 'package:provider/provider.dart';

class SectionC extends StatefulWidget {
  const SectionC({Key? key}) : super(key: key);

  @override
  State<SectionC> createState() => _SectionCState();
}

class _SectionCState extends State<SectionC> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, child) {
      return Container(
        margin: EdgeInsets.only(top: 15),
        child: BadgeCategory(
          value.categories,
        ),
      );
    });
  }
}
