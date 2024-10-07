import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nyoba/constant/cache_config.dart';
import 'package:nyoba/provider/video_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:uiblock/uiblock.dart';
import 'package:video_player/video_player.dart';

import '../../app_localizations.dart';
import '../../models/product_model.dart';
import '../../pages/product/design_detail_screen.dart';
import '../../provider/order_provider.dart';
import '../../provider/product_provider.dart';
import '../../services/session.dart';
import '../../utils/share_link.dart';
import '../product/product_detail_modal.dart';

// ignore: must_be_immutable
class VideoPlayerWidget extends StatefulWidget {
  final String? url;
  final String? videoId;
  final int index;
  const VideoPlayerWidget({
    super.key,
    this.url,
    this.videoId,
    required this.index,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool isPlaying = true;
  bool videoInitialized = false;
  bool isViewed = false;

  late VideoPlayerController videoPlayerController;

  late VideoProvider videoProvider;
  late ProductProvider productProvider;
  late OrderProvider orderProvider;

  @override
  void initState() {
    super.initState();
    videoProvider = Provider.of<VideoProvider>(context, listen: false);
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    orderProvider = Provider.of<OrderProvider>(context, listen: false);
    initializeController().then((data) {});
  }

  initializeController() async {
    var fileInfo = await kCacheManager.getFileFromCache(widget.url!);

    if (videoInitialized) {
      videoPlayerController.dispose();
    }
    if (fileInfo == null) {
      await kCacheManager.downloadFile(widget.url!);
      fileInfo = await kCacheManager.getFileFromCache(widget.url!);
    }
    if (mounted) {
      videoPlayerController = VideoPlayerController.file(fileInfo!.file)
        ..initialize().then((_) {
          setState(() {
            videoPlayerController.setLooping(true); // Set video to loop
            videoPlayerController.play();
            videoProvider.setPlayingVideo(true);
            videoInitialized = true;
            videoPlayerController.addListener(() {
              videoPlayerController.position.then((value) {
                if (videoPlayerController.value.duration.inSeconds.toString() ==
                        value!.inSeconds.toString() &&
                    !isViewed) {
                  printLog("abc");
                  setState(() {
                    isViewed = true;
                  });
                  videoProvider.viewVideo(widget.videoId!);
                }
              });
            });
          });
        });
    }
  }

  /*add to cart*/
  void addCart(ProductModel product) async {
    print('Add Cart');
    List<ProductImageModel> images = [];
    if (product.variantId != null) {
      for (int i = 0; i < product.availableVariations!.length; i++) {
        if (product.availableVariations![i].variationId == product.variantId) {
          images.add(ProductImageModel(
              src: product.availableVariations![i].image!.url!,
              name: product.availableVariations![i].image!.title));
        }
      }
      product.showImage = images[0].src;
    }
    if (product.variantId == null) {
      product.showImage = product.images![0].src;
    }
    ProductModel productCart = product;
    printLog(productCart.showImage!, name: "image add");
    if (productCart.minMaxQuantity!.minQty > productCart.productStock!) {
      return snackBar(context,
          message:
              "Minimum purchase is ${productCart.minMaxQuantity!.minQty} pcs");
    }
    checkSPcart(productCart);
  }

  /*check sharedprefs for cart*/
  checkSPcart(ProductModel productCart) async {
    if (!Session.data.containsKey('cart')) {
      List<ProductModel> listCart = [];
      productCart.priceTotal =
          (productCart.cartQuantity! * productCart.productPrice!);
      //PENGECEKAN MAX QTY
      if (productCart.minMaxQuantity!.maxQty >= productCart.cartQuantity!) {
        listCart.add(productCart);
      } else if (productCart.minMaxQuantity!.maxQty <
          productCart.cartQuantity!) {
        return snackBar(context,
            message:
                "Maximum purchase is ${productCart.minMaxQuantity!.maxQty} pcs");
      }
      await Session.data.setString('cart', json.encode(listCart));
    } else {
      List products = await json.decode(Session.data.getString('cart')!);
      printLog(json.encode(productCart), name: "Product to Cart");
      List<ProductModel> listCart = products
          .map((product) => new ProductModel.fromJson(product))
          .toList();

      int index = products.indexWhere((prod) =>
          prod["id"] == productCart.id &&
          prod["variant_id"] == productCart.variantId &&
          prod['variation_name'] == productCart.variationName);

      if (index != -1) {
        if (productCart.productStock! <
            (productCart.cartQuantity! + listCart[index].cartQuantity!)) {
          return snackBar(context,
              message:
                  "${AppLocalizations.of(context)!.translate("exceeded_stock")}");
        }
        productCart.cartQuantity =
            listCart[index].cartQuantity! + productCart.cartQuantity!;

        productCart.priceTotal =
            (productCart.cartQuantity! * productCart.productPrice!);
        //PENGECEKAN MAX QTY
        if (productCart.minMaxQuantity!.maxQty >= productCart.cartQuantity!) {
          listCart[index] = productCart;
        } else if (productCart.minMaxQuantity!.maxQty <
            productCart.cartQuantity!) {
          return snackBar(context,
              message:
                  "Maximum purchase is ${productCart.minMaxQuantity!.maxQty} pcs");
        }
        await Session.data.setString('cart', json.encode(listCart));
      } else {
        productCart.priceTotal =
            (productCart.cartQuantity! * productCart.productPrice!);
        //PENGECEKAN MAX QTY
        if (productCart.minMaxQuantity!.maxQty >= productCart.cartQuantity!) {
          listCart.insert(0, productCart);
        } else if (productCart.minMaxQuantity!.maxQty <
            productCart.cartQuantity!) {
          return snackBar(context,
              message:
                  "Maximum purchase is ${productCart.minMaxQuantity!.maxQty} pcs");
        }
        await Session.data.setString('cart', json.encode(listCart));
      }
    }
    orderProvider.loadCartCount();
    return snackBar(context,
        message:
            AppLocalizations.of(context)!.translate('product_success_atc')!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      _controller?.play();
    } else if (state == AppLifecycleState.inactive) {
      // App is partially obscured
      _controller?.pause();
    } else if (state == AppLifecycleState.paused) {
      // App is in the background
      _controller?.pause();
    } else if (state == AppLifecycleState.detached) {
      // App is terminated
      _controller?.dispose();
    }
  }

  @override
  void dispose() {
    videoPlayerController.dispose(); //dispose the VideoPlayer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, value, child) {
        return Stack(
          children: [
            videoInitialized
                ? GestureDetector(
                    onTap: () {
                      if (value.isPlaying) {
                        videoPlayerController.pause();
                        value.setPlayingVideo(false);
                      } else {
                        videoPlayerController.play();
                        value.setPlayingVideo(true);
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: AspectRatio(
                              aspectRatio:
                                  videoPlayerController.value.aspectRatio,
                              child: VideoPlayer(videoPlayerController)),
                        ),
                        Visibility(
                          visible: !value.isPlaying,
                          child: Center(
                            child: Icon(
                              Icons.play_arrow,
                              size: 80,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black,
                    child: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.white, size: 30)),
                  ),
            Positioned(
                right: 20,
                top: (MediaQuery.of(context).size.height / 2),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (value.listVideos[widget.index].productDataVideo!
                                  .type ==
                              "variable") {
                            UIBlock.block(context);
                            productProvider
                                .fetchProductDetail(
                              value.listVideos[widget.index].productDataVideo!
                                  .productId
                                  .toString(),
                            )
                                .then((val) {
                              UIBlock.unblock(context);
                              ProductModel prod = val!;
                              prod.videoId = value.listVideos[widget.index]
                                  .videoAffiliate!.videoId;
                              prod.dateProductCart = DateTime.now().toString();
                              showMaterialModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                builder: (context) => ProductDetailModal(
                                  productModel: val,
                                  type: 'add',
                                  loadCount: () => printLog("a"),
                                ),
                              );
                            });
                          } else {
                            UIBlock.block(context);
                            productProvider
                                .fetchProductDetail(value
                                    .listVideos[widget.index]
                                    .productDataVideo!
                                    .productId!
                                    .toString())
                                .then((val) {
                              ProductModel prod = val!;
                              prod.cartQuantity = 1;
                              // prod.variantId = 0;
                              // prod.selectedVariation = [];
                              prod.videoId = value.listVideos[widget.index]
                                  .videoAffiliate!.videoId;
                              prod.dateProductCart = DateTime.now().toString();
                              addCart(prod);
                              UIBlock.unblock(context);
                            });
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${AppLocalizations.of(context)!.translate('buy_now')}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          shareLinks(
                              'video',
                              value.listVideos[widget.index].videoAffiliate!
                                  .linkShare!,
                              context,
                              Session.data.getString('language_code'));
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${AppLocalizations.of(context)!.translate('share')}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          value.setPlayingVideo(false);
                          videoPlayerController.pause();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DesignDetailScreen(
                                  productId: value.listVideos[widget.index]
                                      .productDataVideo!.productId
                                      .toString(),
                                  videoId: value.listVideos[widget.index]
                                      .videoAffiliate!.videoId,
                                ),
                              ));
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${AppLocalizations.of(context)!.translate('detail')}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.black, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${value.listVideos[widget.index].productDataVideo!.postTitle}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: Text(
                            // "${value.listVideos[index].productDataVideo!.postContent!.length > 200 ? value.listVideos[index].productDataVideo!.postContent!.substring(0, 180) + "..." : value.listVideos[index].productDataVideo!.postContent!.length > 150 ? value.listVideos[index].productDataVideo!.postContent!.substring(0, 130) + "..." : value.listVideos[index].productDataVideo!.postContent!.length > 100 ? value.listVideos[index].productDataVideo!.postContent!.substring(0, 80) + "..." : value.listVideos[index].productDataVideo!.postContent!.length > 50 ? value.listVideos[index].productDataVideo!.postContent!.substring(0, 30) + "..." : value.listVideos[index].productDataVideo!.postContent!}",
                            "${value.listVideos[widget.index].productDataVideo!.postContent!}",
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )),
            Positioned(
                bottom: 14,
                right:
                    Session.data.getString('language_code') != 'ar' ? 10 : null,
                left:
                    Session.data.getString('language_code') == 'ar' ? 10 : null,
                child: GestureDetector(
                  onTap: () {
                    value.setPlayingVideo(false);
                    videoPlayerController.pause();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DesignDetailScreen(
                            productId: value.listVideos[widget.index]
                                .productDataVideo!.productId
                                .toString(),
                            videoId: value.listVideos[widget.index]
                                .videoAffiliate!.videoId,
                          ),
                        ));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: value.listVideos[widget.index].productDataVideo!
                          .thumbnail!,
                      width: 60,
                      height: 60,
                    ),
                  ),
                )),
            videoInitialized
                ? Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VideoProgressIndicator(
                      videoPlayerController,
                      allowScrubbing: true,
                      colors: VideoProgressColors(playedColor: primaryColor),
                    ),
                  )
                : SizedBox(),
          ],
        );
      },
    );
  }
}
