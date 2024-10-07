import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nyoba/pages/search/qr_scanner_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/search_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/product/list_item_product.dart';
import 'package:nyoba/widgets/product/shimmer_list_item_product.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _getHintText(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);

    // Check the locale and return the corresponding hint text
    if (currentLocale.languageCode == 'ar') {
      return 'ما الذي تبحث عنه؟'; // Arabic text
    } else {
      return 'What are you looking for?'; // English text or any other default
    }
  }
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int page = 1;
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onSearchChanged() {
    if (searchController.text.length >= 3) {
      Future.delayed(Duration(milliseconds: 600), () {
        setState(() {
          page = 1;
        });
        search();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (Provider.of<SearchProvider>(context, listen: false).listSearchProducts.length % 10 == 0) {
        setState(() {
          page++;
        });
        search();
      }
    }

    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (isVisible) {
        setState(() {
          isVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!isVisible) {
        setState(() {
          isVisible = true;
        });
      }
    }
  }

  Future<void> search() async {
    await Provider.of<SearchProvider>(context, listen: false)
        .newSearchProduct(Uri.encodeComponent(searchController.text), page);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);
    final settingProvider = Provider.of<HomeProvider>(context, listen: false);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: settingProvider.isBarcodeActive! && isVisible,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => QRScanner()));
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: primaryColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: Container(
                    height: 30,
                    padding: EdgeInsets.all(5),
                    child: Image.asset("images/search/barcode_icon.png"),
                  ),
                ),
                SizedBox(width: 5),
                Text("SCAN BARCODE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        title: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50, // Set the height of the text field
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(fontSize: 16), // Increase font size if needed
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.search, size: 30), // Increase the icon size
                      hintText:_getHintText(context),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: searchController.text.isNotEmpty,
                child: IconButton(
                  icon: Icon(Icons.cancel, color: primaryColor),
                  onPressed: () {
                    setState(() {
                      searchController.clear();
                      page = 1;
                      searchProvider.listSearchProducts.clear();
                      searchProvider.listSuggestionProducts.clear();
                    });
                    search();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (searchProvider.loadingSearch && page == 1) ...[
              ListView.builder(
                itemCount: 4,
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemBuilder: (context, index) => ShimmerListItemProduct(),
              ),
            ] else if (searchProvider.listSearchProducts.isEmpty && searchProvider.listSuggestionProducts.isEmpty) ...[
              buildSearchEmpty(context, searchController.text.isEmpty
                  ? AppLocalizations.of(context)!.translate('search_here')
                  : AppLocalizations.of(context)!.translate('cant_find_prod')),
            ] else if (searchProvider.listSuggestionProducts.isNotEmpty) ...[
              buildSuggestions(context, searchProvider),
            ] else ...[
              buildSearchResults(context, searchProvider),
            ],
            if (searchProvider.loadingSearch && page != 1) customLoading(),
          ],
        ),
      ),
    );
  }

  Widget buildSuggestions(BuildContext context, SearchProvider searchProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 15),
        Text("${AppLocalizations.of(context)!.translate('cant_find_product')}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 20),
        Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Text("${AppLocalizations.of(context)!.translate('follow_suggestions_search')}", textAlign: TextAlign.center),
        ),
        SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          physics: ScrollPhysics(),
          itemCount: searchProvider.listSuggestionProducts.length,
          itemBuilder: (context, i) {
            return ListItemProduct(
              itemCount: searchProvider.listSuggestionProducts.length,
              product: searchProvider.listSuggestionProducts[i],
              i: i,
            );
          },
        ),
      ],
    );
  }

  Widget buildSearchResults(BuildContext context, SearchProvider searchProvider) {
    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: searchProvider.listSearchProducts.length,
      itemBuilder: (context, i) {
        return ListItemProduct(
          itemCount: searchProvider.listSearchProducts.length,
          product: searchProvider.listSearchProducts[i],
          i: i,
        );
      },
    );
  }
}
