import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/video_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen>
    with TickerProviderStateMixin {
  TextEditingController searchController = new TextEditingController();
  XFile? videoFile;
  AnimationController? controller;

  Future getVideo() async {
    await ImagePicker()
        .pickVideo(source: ImageSource.gallery)
        .then((file) async {
      await file!.length().then((data) {
        if (data >
            ((context.read<HomeProvider>().videoFileSize * 1024) * 1024)) {
          return snackBar(context, message: "Video size is too large");
        } else {
          setState(() {
            videoFile = file;
          });
        }
      });
    });
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller!.forward();
    context.read<VideoProvider>().uploadedByte = 0;
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      context.read<VideoProvider>().setSelectedProduct({});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Upload Video",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: HexColor("#e9f1fe"),
      body: SingleChildScrollView(
        child: Consumer<VideoProvider>(
          builder: (context, value, child) => Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                child: Column(children: [
                  // Container(
                  //   margin: EdgeInsets.only(bottom: 10),
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(10),
                  //       border: Border.all(color: HexColor("#8bb9e7"), style: )),
                  // ),
                  GestureDetector(
                    onTap: () {
                      getVideo();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 150.h,
                      margin: EdgeInsets.only(bottom: 10),
                      child: DottedBorder(
                          color: HexColor("#8bb9e7"),
                          dashPattern: [4, 6],
                          strokeWidth: 2,
                          child: Center(
                            child: videoFile != null
                                ? Icon(
                                    Icons.check_box,
                                    size: 36,
                                    color: Colors.green,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.upload),
                                      Text("Browse Files to upload")
                                    ],
                                  ),
                          )),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: HexColor("e9f1fe")),
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file_outlined,
                                size: 20,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: Text(
                                  videoFile != null
                                      ? " ${videoFile!.name}"
                                      : " No selected File",
                                  style: TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              if (videoFile != null) {
                                setState(() {
                                  videoFile = null;
                                });
                              }
                            },
                            child: Icon(
                              Icons.delete,
                              size: 20,
                            ),
                          )
                        ]),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Maximum size : ${context.read<HomeProvider>().videoFileSize} MB",
                          style: TextStyle(fontSize: 10, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    value: value.uploadedByte,
                    backgroundColor: Colors.grey.shade400,
                    color: primaryColor,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Consumer<VideoProvider>(
                      builder: (context, value, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select the product you want to link to the video :",
                            style: TextStyle(fontSize: 12),
                          ),
                          Container(
                            height: 48,
                            child: Row(
                              children: [
                                Expanded(
                                  child: EasyAutocomplete(
                                    asyncSuggestions: (searchValue) {
                                      if (searchValue == '' ||
                                          searchValue.length < 3) {
                                        return Future(() => []);
                                      } else {
                                        return context
                                            .read<VideoProvider>()
                                            .getProductVideo(
                                                search: searchValue);
                                      }
                                    },
                                    onChanged: (p0) {
                                      return printLog(p0);
                                    },
                                    progressIndicatorBuilder: customLoading(),
                                    autofocus: false,
                                    focusNode: FocusNode(),
                                    controller: searchController,
                                    onSubmitted: (p0) {
                                      context
                                          .read<VideoProvider>()
                                          .setSelectedProduct(p0);
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      isCollapsed: true,
                                      labelStyle: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: responsiveFont(10),
                                      ),
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      prefixIcon: Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        child: Icon(
                                          Icons.search,
                                          color: primaryColor,
                                          size: 24,
                                        ),
                                      ),
                                      // prefix: Padding(
                                      //   padding: EdgeInsets.zero,
                                      //   child: Icon(
                                      //     Icons.search,
                                      //     color: primaryColor,
                                      //     size: 24,
                                      //   ),
                                      // ),
                                      prefixIconConstraints: BoxConstraints(
                                          maxHeight: 24, maxWidth: 40),
                                      suffixIconConstraints: BoxConstraints(
                                          maxHeight: 24, maxWidth: 40),
                                      suffixIcon: searchController
                                              .text.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  searchController.text = '';
                                                });
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8),
                                                child:
                                                    Icon(Icons.clear, size: 18),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: value.selectedProduct.isNotEmpty,
                                  child: Icon(
                                    Icons.check_box,
                                    color: Colors.green,
                                    size: 28,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
              GestureDetector(
                onTap: () {
                  if (videoFile != null &&
                      context
                          .read<VideoProvider>()
                          .selectedProduct
                          .isNotEmpty &&
                      !value.loadingUploadVideo) {
                    context
                        .read<VideoProvider>()
                        .uploadVideo(
                            productId: context
                                .read<VideoProvider>()
                                .selectedProduct['id'],
                            video: File(videoFile!.path))
                        .then((value) {
                      if (value) {
                        uploadPopDialog("The upload process was successful.")
                            .then((data) {
                          Navigator.pop(context);
                        });
                      } else {
                        uploadPopDialog(
                            "The upload process failed, please try again.");
                      }
                    });
                  } else if (videoFile == null) {
                    snackBar(context, message: "Please select video to upload");
                  } else if (value.selectedProduct.isEmpty) {
                    snackBar(context,
                        message: "Please select product to upload");
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: value.loadingUploadVideo
                          ? Colors.grey
                          : secondaryColor),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: value.loadingUploadVideo
                        ? customLoading()
                        : Text(
                            "Upload",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  uploadPopDialog(String title) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          insetPadding: EdgeInsets.all(0),
          content: Builder(
            builder: (context) {
              return Container(
                height: 150.h,
                width: 330.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: responsiveFont(14),
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Container(
                        child: Column(
                      children: [
                        Container(
                          color: Colors.black12,
                          height: 2,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15)),
                                      color: primaryColor),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('ok')!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ))
                  ],
                ),
              );
            },
          )),
    );
  }
}
