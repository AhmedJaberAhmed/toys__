import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ProductPhotoView extends StatelessWidget {
  final image;
  final bool? isFile;
  final String? caption;
  const ProductPhotoView(
      {Key? key, this.image, this.isFile = false, this.caption = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isFile!
              ? Container(
                  child: PhotoView(
                  imageProvider: FileImage(image),
                ))
              : Container(
                  child: PhotoView(
                  imageProvider: NetworkImage(image),
                )),
          Visibility(
            visible: caption != "",
            child: Positioned(
                bottom: Platform.isIOS ? 30 : 0,
                left: 0,
                right: 0,
                child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: Text(
                      caption!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ))),
          ),
          Positioned(
            top: 40,
            left: 15,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
