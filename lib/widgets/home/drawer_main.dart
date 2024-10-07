import 'package:flutter/material.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/pages/search/search_screen.dart';
import 'package:nyoba/provider/category_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/home/item_drawer_categories.dart';
import 'package:nyoba/widgets/home/item_drawer_main.dart';
import 'package:provider/provider.dart';

class DrawerMain extends StatefulWidget {
  const DrawerMain({super.key});

  @override
  State<DrawerMain> createState() => _DrawerMainState();
}

class _DrawerMainState extends State<DrawerMain> {
  bool choosenMenu = false;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer2<HomeProvider, CategoryProvider>(
        builder: (context, value, value2, child) => SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(),
                        ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!
                            .translate('search_product')!,
                        style: TextStyle(color: Colors.grey),
                      ),
                      Icon(Icons.search)
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Flexible(
                  //   flex: 2,
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       setState(() {
                  //         choosenMenu = true;
                  //       });
                  //     },
                  //     child: Container(
                  //         padding: EdgeInsets.symmetric(vertical: 20),
                  //         decoration: BoxDecoration(
                  //             border: Border(
                  //                 bottom: choosenMenu
                  //                     ? BorderSide(
                  //                         color: primaryColor, width: 2)
                  //                     : BorderSide.none),
                  //             color: choosenMenu
                  //                 ? Colors.grey[300]
                  //                 : Colors.grey[200]),
                  //         child: Center(
                  //             child: Text(
                  //           "MENU",
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.w600,
                  //               color: choosenMenu ? null : Colors.grey),
                  //         ))),
                  //   ),
                  // ),
                  Flexible(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          choosenMenu = false;
                        });
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: !choosenMenu
                                      ? BorderSide(
                                          color: primaryColor, width: 2)
                                      : BorderSide.none),
                              color: !choosenMenu
                                  ? Colors.grey[300]
                                  : Colors.grey[200]),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!
                                .translate('categories')!,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: choosenMenu ? Colors.cyan : null),
                          ))),
                    ),
                  ),
                ],
              ),
              value.loading
                  ? customLoading()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: choosenMenu
                          ? value.listMenu.length
                          : value2.allCategories.length,
                      itemBuilder: (context, index) {
                        if (!choosenMenu) {
                          return ItemDrawerCategories(
                            category: value2.allCategories[index],
                          );
                        }
                        return ItemDrawerMain(item: value.listMenu[index]);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
