import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/search/search_screen.dart';
import 'package:nyoba/provider/category_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/widgets/home/categories/grid_item_category.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_localizations.dart';
import '../../provider/app_provider.dart';
import '../../utils/utility.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryScreen extends StatefulWidget {
  final bool? isFromHome;
  CategoryScreen({Key? key, this.isFromHome}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  String _getHintText(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);

    // Check the locale and return the corresponding hint text
    if (currentLocale.languageCode == 'ar') {
      return 'ما الذي تبحث عنه؟'; // Arabic text
    } else {
      return 'What are you looking for?'; // English text or any other default
    }
  }
  int? chosenindex;
  int? chosenCountSub = 0;

  String? categoryName;

  List<int> indexTab = [0, 1, 2, 3, 4, 5, 6, 7];

  ScrollController _scrollController = new ScrollController();

  int? page = 1;

  @override
  void initState() {
    super.initState();
    final categories = Provider.of<CategoryProvider>(context, listen: false);
    if (Session.data.getString("language_code") == "en") {
      chosenindex = 352;
    } else {
      chosenindex = 3435;
    }
    // categories.resetData();
    // categories.fetchAllCategories();
    // loadSubCategories();
    // loadProducts();
    chosenCountSub = 0;
    categoryName = '';
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (categories.subCategories.length % 30 == 0) {
          setState(() {
            if (page != null) page = page! - 1;
            categories.currentPage = page;
          });
          loadSubCategories();
        }
      }
    });
    //if (categories.allCategories.isEmpty) {
    // loadAllCategories();
    //}
    if (categories.currentSelectedCategory != null) {
      setState(() {
        chosenindex = categories.currentSelectedCategory;
        chosenCountSub = categories.currentSelectedCountSub;
        page = categories.currentPage;
      });
      print(chosenCountSub);
    }
  }

  loadAllCategories() async {
    final categories = Provider.of<CategoryProvider>(context, listen: false);
    setState(() {
      // chosenindex = categories.allCategories[0].id;
      chosenCountSub = categories.allCategories[0].count;
      categoryName = categories.allCategories[0].title;
      categories.currentSelectedCategory = chosenindex;
      categories.currentSelectedCountSub = chosenCountSub;
    });
    // if (chosenCountSub != 0) {
    //   loadSubCategories();
    // } else {
    //   loadProducts();
    // }
  }

  loadPopularCategories() async {
    await Provider.of<CategoryProvider>(context, listen: false)
        .fetchPopularCategories();
  }

  loadSubCategories() async {
    await Provider.of<CategoryProvider>(context, listen: false)
        .fetchSubCategories(chosenindex, page);
  }

  loadProducts() async {
    await Provider.of<CategoryProvider>(context, listen: false)
        .fetchProductsCategory(chosenindex.toString());
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context, listen: false);
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;

    Widget popularView = Container(
      child: ListenableProvider.value(
        value: categories,
        child: Consumer<CategoryProvider>(
          builder: (context, value, child) {
            if (value.loadingSub) {
              return subShimmer();
            }
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: ListView(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: value.popularCategories.length,
                      itemBuilder: (context, i) {
                        return ListView(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          children: [
                            Text(
                              value.popularCategories[i].title!,
                              style: TextStyle(
                                  fontSize: responsiveFont(8),
                                  fontWeight: FontWeight.w600),
                            ),
                            Container(
                              // color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: GridView.builder(
                                primary: false,
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                itemCount: value
                                    .popularCategories[i].categories!.length,
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 10,
                                    crossAxisCount: 3,
                                    childAspectRatio: 1 / 2),
                                itemBuilder: (context, j) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BrandProducts(
                                                    categoryId: value
                                                        .popularCategories[i]
                                                        .categories![j]
                                                        .id,
                                                    brandName: value
                                                        .popularCategories[i]
                                                        .categories![j]
                                                        .titleCategories,
                                                  )));
                                    },
                                    child: Column(
                                      children: [
                                        value.popularCategories[i]
                                            .categories![j].image !=
                                            null
                                            ? AspectRatio(
                                          aspectRatio: 1 / 1,
                                          child: CachedNetworkImage(
                                            imageUrl: value.popularCategories[i].categories![j].image!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Icon(
                                              Icons.image_not_supported_rounded,
                                              size: 60,
                                            ),
                                            fadeInDuration: Duration(milliseconds: 300), // Fast fade-in
                                            cacheManager: CacheManager(
                                              Config(
                                                'customCacheKey', // Customize the cache key if needed
                                                stalePeriod: const Duration(days: 7), // Cache for 7 days
                                                maxNrOfCacheObjects: 200, // Max number of cache objects
                                              ),
                                            ),
                                          ),

                                        )
                                            : Icon(
                                          Icons
                                              .image_not_supported_rounded,
                                          size: 60,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          convertHtmlUnescape(value
                                              .popularCategories[i]
                                              .categories![j]
                                              .titleCategories!),
                                          style: TextStyle(
                                            fontSize: responsiveFont(8),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: 15,
                            ),
                          ],
                        );
                      })
                ],
              ),
            );
          },
        ),
      ),
    );

    Widget subView = Container(
      child: ListenableProvider.value(
        value: categories,
        child: Consumer<CategoryProvider>(
          builder: (context, value, child) {
            if (value.loadingSub && page == 1) {
              return subShimmer();
            }
            if (value.subCategories.isEmpty) {
              return emptyCategories();
            }
            return ListView(
              controller: _scrollController,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    // color: Colors.white,
                  ),
                  child: GridView.builder(
                    primary: false,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: value.subCategories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 5,
                        crossAxisCount: 3,
                        childAspectRatio: 1 / 2),
                    itemBuilder: (context, i) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BrandProducts(
                                    categoryId: value.subCategories[i].id
                                        .toString(),
                                    brandName: value.subCategories[i].title,
                                  )));
                        },
                        child: Column(
                          children: [
                            value.subCategories[i].image != null
                                ? AspectRatio(
                              aspectRatio: 1 / 1,
                              child:CachedNetworkImage(
                                imageUrl: value.subCategories[i].image!,
                                fit: BoxFit.cover, // Makes sure the image fits the container
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300], // Shows a grey shimmer while loading
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.image_not_supported_rounded,
                                  size: 60,
                                ),
                                fadeInDuration: Duration(milliseconds: 300), // Fast image load animation
                                cacheManager: CacheManager(
                                  Config(
                                    'customCacheKey', // Custom cache key
                                    stalePeriod: const Duration(days: 7), // Cache for a week
                                    maxNrOfCacheObjects: 200, // Set cache size limit
                                  ),
                                ),
                              ),

                            )
                                : Icon(
                              Icons.image_not_supported_rounded,
                              size: 60,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              convertHtmlUnescape(
                                  value.subCategories[i].title!),
                              style: TextStyle(
                                fontSize: responsiveFont(8),
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (categories.loadingSub && page != 1) customLoading()
              ],
            );
          },
        ),
      ),
    );

    Widget subViewProducts = Container(
      child: ListenableProvider.value(
        value: categories,
        child: Consumer<CategoryProvider>(
          builder: (context, value, child) {
            if (value.loadingSub) {
              return subShimmer();
            }
            if (value.listProductCategory.length < 1) {
              return  Center(
                  child: Stack(
                    children: [ Container(

                    width: 620, // Set your desired width
                    height: 680, // Set your desired height
                    decoration: BoxDecoration(  color: Colors.white,
                      borderRadius: BorderRadius.circular(10), // Optional: rounded corners
                    ),),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10), // Optional: rounded corners for the image
                          child: Image.asset(
                            'images/order/ggg.gif',
                            fit: BoxFit.cover, // This will make the image cover the entire container
                          ),
                        ),
                      ),

              ] ));
            }
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: GridView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: value.listProductCategory.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    childAspectRatio: 80 / 140),
                itemBuilder: (context, i) {
                  return GridItemCategory(
                    i: i,
                    itemCount: value.listProductCategory.length,
                    product: value.listProductCategory[i],
                    categoryId: chosenindex,
                    categoryName: categoryName,
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    Widget buildMainCategories = Container(
      child: ListenableProvider.value(
        value: categories,
        child: Consumer<CategoryProvider>(builder: (context, value, child) {
          if (value.loadingAll) {
            return shimmerCategories();
          }
          return Column(
            children: [
              appBar(),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: ListView(
                        children: <Widget>[
                          ListView.builder(
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: value.allCategories.length,
                              itemBuilder: (context, i) {
                                if (value.allCategories[i].title! ==
                                    "Popular Categories")
                                  value.allCategories[i].title =
                                  AppLocalizations.of(context)!
                                      .translate('popular_categories')!;
                                return ListView(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    tabBar(
                                      value.allCategories[i].title!,
                                      value.allCategories[i].image!,
                                      value.allCategories[i].id,
                                      value.allCategories[i].count,
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                  ],
                                );
                              })
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        // color: Colors.grey[100],
                          alignment: Alignment.topLeft,
                          child: chosenindex == 9911
                              ? popularView
                              : chosenCountSub == 0
                              ? subViewProducts
                              : subView),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );

    return ColorfulSafeArea(
      color: isDarkMode ? Colors.black : Colors.white,
      child: Scaffold(
        appBar: widget.isFromHome!
            ? null
            : AppBar(
          // backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              // color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            AppLocalizations.of(context)!.translate('categories')!,
            style: TextStyle(
              fontSize: responsiveFont(16),
              fontWeight: FontWeight.w500,
              // color: Colors.black,
            ),
          ),
        ),
        body: buildMainCategories,
      ),
    );
  }

  Widget tabBar(String title, String image, int? indexTab, int? countSub) {
    final categories = Provider.of<CategoryProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        setState(() {
          chosenindex = indexTab;
          chosenCountSub = countSub;
          categoryName = title;
          categories.currentSelectedCategory = chosenindex;
          categories.currentSelectedCountSub = chosenCountSub;
          page = 1;
        });
        if (chosenindex == 9911) {
          loadPopularCategories();
        } else {
          if (chosenCountSub != 0) {
            loadSubCategories();
          } else {
            loadProducts().then((data) {
              int idx = Provider.of<CategoryProvider>(context, listen: false)
                  .listProductCategory[0]
                  .categories!
                  .indexWhere((element) => element.id == chosenindex);
              if (idx == -1) {
                loadProducts();
              }
            });
          }
        }
      },
      child: Container(
        width: 107.w,
        height: 100.h,
        // color: Colors.white,
        child: Stack(
          children: [
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 45.h,
                      width: 45.w,
                      child: image.isEmpty
                          ? Icon(
                        Icons.broken_image_outlined,
                      )
                          :CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: Colors.grey[300], // Placeholder color until image loads
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.image_not_supported_rounded),
                        fadeInDuration: Duration(milliseconds: 300), // Quick fade-in for faster perception
                        cacheManager: CacheManager(
                          Config(
                            'customCacheKey',
                            stalePeriod: const Duration(days: 7), // Cache images for 7 days
                            maxNrOfCacheObjects: 200, // Limit the number of cached images
                          ),
                        ),
                      ),

                    ),
                    Container(
                      height: 5,
                    ),
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: responsiveFont(10),
                            fontWeight: FontWeight.w600,
                            height: 1,
                            color:
                            indexTab == chosenindex ? primaryColor : null),
                      ),
                    )
                  ],
                )),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 5,
              height: indexTab == chosenindex ? 100.w : 0,
              color: secondaryColor,
            )
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return Material(
        elevation: 5,
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(),
          child: Container(
              height: 70,
              padding:
              EdgeInsets.only(left: 15, right: 10, top: 15, bottom: 15),
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchScreen()));
                  },
                  child: TextField(
                    style: TextStyle(fontSize: 14),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      isCollapsed: true,
                      filled: true,
                      enabled: false,
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(25),
                        ),
                      ),
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: Icon(Icons.toys),
                      hintText:
                      _getHintText(context),
                      hintStyle: TextStyle(fontSize: responsiveFont(10)),
                    ),
                  ))),
        ));
  }

  Widget shimmerCategories() {
    final isDarkMode = Provider.of<AppNotifier>(context, listen: false).isDarkMode;

    return Column(
      children: [
        appBar(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    primary: true,
                    shrinkWrap: true,
                    children: [
                      tabBarShimmer(),
                      SizedBox(height: 3),
                      tabBarShimmer(),
                      SizedBox(height: 3),
                      tabBarShimmer(),
                      SizedBox(height: 3),
                      tabBarShimmer(),
                      SizedBox(height: 3),
                      tabBarShimmer(),
                      SizedBox(height: 3),
                      tabBarShimmer(),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Shimmer.fromColors(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 1.25,
                      color: Colors.white,
                      alignment: Alignment.topLeft,
                    ),
                    baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                    highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget tabBarShimmer() {
    final isDarkMode = Provider.of<AppNotifier>(context, listen: false).isDarkMode;

    return Container(
      width: 90.w,
      height: 73.h,
      child: Stack(
        children: [
          Container(
            color: isDarkMode ? Colors.grey[700] : Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Shimmer.fromColors(
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: 60,
                    height: 8,
                    color: Colors.white,
                  ),
                ],
              ),
              baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget appBarShimmer() {
    return Material(
      elevation: 5,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(),
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Shimmer.fromColors(
            child: Container(
              height: 10,
              color: Colors.white,
            ),
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
          ),
        ),
      ),
    );
  }

  Widget subShimmer() {
    final isDarkMode = Provider.of<AppNotifier>(context, listen: false).isDarkMode;

    return  FadeIn(
      duration: Duration(milliseconds: 800), // Duration for fade-in animation
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.2),
              blurRadius: 10.0,
              offset: Offset(0, 6), // Offset for the shadow
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.8, // Increased height
        width: MediaQuery.of(context).size.width * 0.95, // Increased width for better spacing
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.all(24.0), // Increased padding for better content arrangement
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simulated title bar with playful colors
            SlideInUp(
              duration: Duration(milliseconds: 500),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7, // Increased width
                height: 30.0, // Increased height
                decoration: BoxDecoration(
                  color: Colors.blueAccent, // Playful color
                  borderRadius: BorderRadius.circular(12.0), // More rounded corners
                  gradient: LinearGradient(
                    colors: [Colors.yellow, Colors.orange], // Gradient effect
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            SizedBox(height: 21.0), // Increased space
            // Simulated subtitle with SlideInUp animation
            SlideInUp(
              duration: Duration(milliseconds: 500),
              delay: Duration(milliseconds: 200), // Delay for subtitle
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5, // Increased width
                height: 22.0, // Increased height
                decoration: BoxDecoration(
                  color: Colors.pinkAccent, // Playful color
                  borderRadius: BorderRadius.circular(12.0), // More rounded corners
                ),
              ),
            ),
            SizedBox(height: 40.0), // Increased space
            // Simulated image/box with SlideInUp animation
            SlideInUp(
              duration: Duration(milliseconds: 500),
              delay: Duration(milliseconds: 400), // Delay for image box
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4, // Increased height for image box
                decoration: BoxDecoration(
                  color: Colors.greenAccent, // Playful color
                  borderRadius: BorderRadius.circular(12.0), // More rounded corners
                  border: Border.all(color: Colors.blue, width: 2), // Border to make it pop
                ),
                child: Center(
                  child: Text(
                    'حان وقت اللعب ', // Text to engage kids
                    style: TextStyle(
                      fontSize: 24, // Larger font size
                      color: Colors.white, // Contrast color for text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline,
          size: 48,
          color: primaryColor,
        ),
        Text(
          AppLocalizations.of(context)!.translate('categories_empty')!,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

}
