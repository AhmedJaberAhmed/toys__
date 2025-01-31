import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/models/review_product_model.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/review_provider.dart';
import 'package:nyoba/widgets/product/product_photoview.dart';
import 'package:nyoba/widgets/product/product_videoview.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_localizations.dart';
import '../../utils/utility.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductReview extends StatefulWidget {
  final String? productId;
  ProductReview({Key? key, this.productId}) : super(key: key);

  @override
  _ProductReviewState createState() => _ProductReviewState();
}

class _ProductReviewState extends State<ProductReview> {
  int currentIndex = 0;

  int countAll = 0;
  int countOneStar = 0;
  int countTwoStar = 0;
  int countThreeStar = 0;
  int countFourStar = 0;
  int countFiveStar = 0;
  int countImage = 0;
  int countVerified = 0;

  List<ReviewProduct> listReview = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    final review = Provider.of<ReviewProvider>(context, listen: false);
    await Provider.of<ReviewProvider>(context, listen: false)
        .fetchReviewProduct(widget.productId)
        .then((value) {
      setState(() {
        listReview = review.listReviewAllStar;

        countAll = review.listReviewAllStar.length;
        countOneStar = review.listReviewOneStar.length;
        countTwoStar = review.listReviewTwoStar.length;
        countThreeStar = review.listReviewThreeStar.length;
        countFourStar = review.listReviewFourStar.length;
        countFiveStar = review.listReviewFiveStar.length;
        countImage = review.listReviewImage.length;
        countVerified = review.listReviewVerified.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final review = Provider.of<ReviewProvider>(context, listen: false);
    final isDarkMode = Provider.of<AppNotifier>(context).isDarkMode;
    Widget buildReview = Container(
      child: ListenableProvider.value(
        value: review,
        child: Consumer<ReviewProvider>(builder: (context, value, child) {
          if (value.isLoadingReview) {
            return ListView.builder(
                primary: false,
                shrinkWrap: true,
                itemCount: 4,
                itemBuilder: (context, i) {
                  return Column(
                    children: [
                      commentShimmer(),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        color: HexColor("EEEEEE"),
                        width: double.infinity,
                        height: 2,
                      ),
                    ],
                  );
                });
          }
          if (listReview.isEmpty) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: primaryColor,
                  ),
                  Text(
                    AppLocalizations.of(context)!
                        .translate('empty_review_product')!,
                  )
                ],
              ),
            );
          }
          return ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: listReview.length,
              itemBuilder: (context, i) {
                return Column(
                  children: [
                    comment(
                        listReview[i].reviewer!,
                        listReview[i].review!,
                        listReview[i].rating!,
                        listReview[i].dateCreated!,
                        listReview[i].image!,
                        listReview[i].mediaCaption!,
                        listReview[i].verified!,
                        listReview[i].reviewTitle!,
                        listReview[i].userVote ?? "",
                        listReview[i].totalUp ?? 0,
                        listReview[i].totalDown ?? 0,
                        listReview[i].id!),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15),
                      color: isDarkMode ? Colors.black12 : HexColor("EEEEEE"),
                      width: double.infinity,
                      height: 2,
                    ),
                  ],
                );
              });
        }),
      ),
    );

    return DefaultTabController(
      length: 8,
      child: Scaffold(
        // backgroundColor: Colors.white,
        appBar: AppBar(
          // backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              // color: Colors.black,
            ),
          ),
          title: Text(
            "${AppLocalizations.of(context)!.translate('all_reviews')}",
            style: TextStyle(
              fontSize: responsiveFont(14),
              fontWeight: FontWeight.w500,
              // color: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              firstPart(),
              Container(
                color: isDarkMode ? Colors.black12 : HexColor("EEEEEE"),
                width: double.infinity,
                height: 5,
              ),
              buildReview
            ],
          ),
        ),
      ),
    );
  }

  VideoPlayerController? _controllerVideo;
  Widget comment(
      String name,
      String comment,
      int starGoldItem,
      String date,
      List<String> image,
      List<String> caption,
      bool verified,
      String title,
      String userVote,
      int totalUp,
      int totalDown,
      int id) {
    final isPhotoActive =
        Provider.of<HomeProvider>(context, listen: false).isPhotoReviewActive;
    bool _isNumeric(String? str) {
      if (str == null) {
        return false;
      }
      return double.tryParse(str) != null;
    }

    List _phoneNumberName = name.split("");

    return Container(
      margin: EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.person,
                  size: 40,
                ),
              )),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      starGold(starGoldItem),
                      Container(
                        child: Text(
                          convertDateFormatShortMonth(DateTime.parse(date)),
                          style: TextStyle(fontSize: responsiveFont(8)),
                        ),
                      ),
                    ]),
                Row(
                  children: [
                    Text(
                      _isNumeric(name)
                          ? '${_phoneNumberName[0]}${_phoneNumberName[1]}${_phoneNumberName[2]}*****${_phoneNumberName[_phoneNumberName.length - 3]}${_phoneNumberName[_phoneNumberName.length - 2]}${_phoneNumberName[_phoneNumberName.length - 1]}'
                          : name,
                      style: TextStyle(
                          fontSize: responsiveFont(10),
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Visibility(
                        visible: verified &&
                            Provider.of<HomeProvider>(context, listen: false)
                                .isPremium!,
                        child: Provider.of<HomeProvider>(context, listen: false)
                                    .valueVerified ==
                                "{badge}"
                            ? Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: HexColor(Provider.of<HomeProvider>(
                                        context,
                                        listen: false)
                                    .colorVerified!),
                              )
                            : Text(
                                Provider.of<HomeProvider>(context,
                                        listen: false)
                                    .valueVerified!,
                                style: TextStyle(fontSize: responsiveFont(9)),
                              ))
                  ],
                ),
                Visibility(
                  visible: Provider.of<HomeProvider>(context, listen: false)
                      .isPremium!,
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                comment.isEmpty
                    ? Container()
                    : HtmlWidget(
                        comment,
                        textStyle: TextStyle(color: HexColor("929292")),
                      ),
                /*item == 0
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 50.h,
                        child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, i) {
                              return Container(
                                height: 50.h,
                                width: 60.w,
                                decoration: BoxDecoration(
                                    color: HexColor("c4c4c4"),
                                    borderRadius: BorderRadius.circular(5)),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(
                                width: 5,
                              );
                            },
                            itemCount: item),
                      ),*/
                image.isEmpty || !isPhotoActive
                    ? Container()
                    : GridView.builder(
                        shrinkWrap: true,
                        itemCount: image.length,
                        physics: ScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1 / 1,
                            crossAxisCount: 4,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5),
                        itemBuilder: (context, i) {
                          final _imageReview = image[i];
                          final _captionReview = caption[i];
                          if (!_imageReview.contains('.png') ||
                              !_imageReview.contains('.jpg') ||
                              !_imageReview.contains('.jpeg')) {
                            _controllerVideo =
                                VideoPlayerController.network(_imageReview)
                                  ..initialize().then((_) {
                                    setState(
                                        () {}); //when your thumbnail will show.
                                  });
                          }
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              print("View Image");
                              if (_imageReview.contains('.png') ||
                                  _imageReview.contains('.jpg') ||
                                  _imageReview.contains('.jpeg')) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProductPhotoView(
                                              image: _imageReview,
                                              caption: _captionReview,
                                            )));
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProductVideoView(
                                              isFile: true,
                                              video: _imageReview,
                                              caption: _captionReview,
                                            )));
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5)),
                              height: 70.h,
                              width: 70.w,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: _imageReview.contains('.png') ||
                                          _imageReview.contains('.jpg') ||
                                          _imageReview.contains('.jpeg')
                                      ? CachedNetworkImage(
                                          imageUrl: _imageReview,
                                          fit: BoxFit.fitHeight,
                                          memCacheHeight: 100,
                                          memCacheWidth: 100,
                                          placeholder: (context, url) =>
                                              customLoading(),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.image_not_supported_rounded,
                                            size: 25,
                                          ),
                                        )
                                      : VideoPlayer(_controllerVideo!)),
                            ),
                          );
                        }),
                Visibility(
                  visible: Provider.of<HomeProvider>(context, listen: false)
                      .isPremium!,
                  child: Column(
                    children: [
                      Divider(),
                      Row(
                        children: [
                          Text(
                            Provider.of<HomeProvider>(context, listen: false)
                                .textHelpful!,
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            totalUp.toString(),
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<ReviewProvider>()
                                  .voteReview(
                                      currentIndex == 0
                                          ? "all"
                                          : currentIndex == 1
                                              ? "image"
                                              : currentIndex == 2
                                                  ? "verified"
                                                  : currentIndex == 3
                                                      ? "five"
                                                      : currentIndex == 4
                                                          ? "four"
                                                          : currentIndex == 5
                                                              ? "three"
                                                              : currentIndex ==
                                                                      6
                                                                  ? "two"
                                                                  : "one",
                                      id.toString(),
                                      "up")
                                  .then((data) {
                                if (data) {
                                  setState(() {
                                    userVote = "up";
                                  });
                                }
                              });
                            },
                            child: Icon(
                              Icons.thumb_up_alt_outlined,
                              color: userVote == "up"
                                  ? Colors.black
                                  : Colors.black38,
                              size: 18,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<ReviewProvider>()
                                  .voteReview(
                                      currentIndex == 0
                                          ? "all"
                                          : currentIndex == 1
                                              ? "image"
                                              : currentIndex == 2
                                                  ? "verified"
                                                  : currentIndex == 3
                                                      ? "five"
                                                      : currentIndex == 4
                                                          ? "four"
                                                          : currentIndex == 5
                                                              ? "three"
                                                              : currentIndex ==
                                                                      6
                                                                  ? "two"
                                                                  : "one",
                                      id.toString(),
                                      "down")
                                  .then((data) {
                                if (data) {
                                  setState(() {
                                    userVote = "down";
                                  });
                                }
                              });
                            },
                            child: Icon(
                              Icons.thumb_down_alt_outlined,
                              color: userVote == "down"
                                  ? Colors.black
                                  : Colors.black38,
                              size: 18,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            totalDown.toString(),
                            style: TextStyle(fontSize: 12),
                          )
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
    );
  }

  Widget firstPart() {
    final review = Provider.of<ReviewProvider>(context, listen: false);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: TabBar(
        labelPadding: EdgeInsets.symmetric(horizontal: 5),
        onTap: (i) {
          setState(() {
            currentIndex = i;
          });
          if (currentIndex == 0) {
            setState(() {
              listReview = review.listReviewAllStar;
            });
          } else if (currentIndex == 1) {
            setState(() {
              listReview = review.listReviewImage;
            });
          } else if (currentIndex == 2) {
            setState(() {
              listReview = review.listReviewVerified;
            });
          } else if (currentIndex == 3) {
            setState(() {
              listReview = review.listReviewFiveStar;
            });
          } else if (currentIndex == 4) {
            setState(() {
              listReview = review.listReviewFourStar;
            });
          } else if (currentIndex == 5) {
            setState(() {
              listReview = review.listReviewThreeStar;
            });
          } else if (currentIndex == 6) {
            setState(() {
              listReview = review.listReviewTwoStar;
            });
          } else if (currentIndex == 7) {
            setState(() {
              listReview = review.listReviewOneStar;
            });
          }
        },
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
          border: Border.all(color: secondaryColor),
          borderRadius: BorderRadius.circular(5),
          // color: Colors.white,
        ),
        tabs: [
          tabStyle(
              0,
              Text(
                "${AppLocalizations.of(context)!.translate('all')}",
                style: TextStyle(
                  fontSize: responsiveFont(12),
                  // color: Colors.black,
                ),
              ),
              countAll),
          tabStyle(
              1,
              Text(
                "${AppLocalizations.of(context)!.translate('with_images')}",
                style: TextStyle(
                  fontSize: responsiveFont(12),
                  // color: Colors.black,
                ),
              ),
              countImage),
          tabStyle(
              2,
              Text(
                "${AppLocalizations.of(context)!.translate('verified')}",
                style: TextStyle(
                  fontSize: responsiveFont(12),
                  // color: Colors.black,
                ),
              ),
              countVerified),
          tabStyle(3, starGold(5), countFiveStar),
          tabStyle(4, starGold(4), countFourStar),
          tabStyle(5, starGold(3), countThreeStar),
          tabStyle(6, starGold(2), countTwoStar),
          tabStyle(7, starGold(1), countOneStar),
        ],
      ),
    );
  }

  Widget starGold(int starCount) {
    return Container(
      height: 20.h,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: starCount,
          itemBuilder: (context, i) {
            return Container(
                width: 15.w,
                height: 15.h,
                child: Image.asset("images/product_detail/starGold.png"));
          }),
    );
  }

  Widget tabStyle(int index, Widget title, int total) {
    final isDarkMode = Provider.of<AppNotifier>(context).isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: currentIndex == index
            ? Colors.transparent
            : isDarkMode
                ? Colors.transparent
                : HexColor("eeeeee"),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
            color: currentIndex == index ? Colors.transparent : Colors.grey),
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          title,
          Text("($total)",
              style: TextStyle(
                fontSize: responsiveFont(10),
                color: currentIndex == index ? primaryColor : null,
              ))
        ],
      ),
    );
  }

  Widget commentShimmer() {
    return Shimmer.fromColors(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                      width: 80,
                      color: Colors.white,
                    ),
                    starGold(5),
                    Container(
                      height: 10,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 10,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 10,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      height: 10,
                      width: 120,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!);
  }
}
