import 'package:flutter/material.dart';
import 'package:nyoba/models/video_model.dart';
import 'package:nyoba/provider/video_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class MyVideoWidget extends StatefulWidget {
  final VideoModel? video;
  final String? sort;
  MyVideoWidget({this.video, Key? key, this.sort}) : super(key: key);

  @override
  State<MyVideoWidget> createState() => _MyVideoWidgetState();
}

class _MyVideoWidgetState extends State<MyVideoWidget> {
  VideoPlayerController? controller;
  bool isPlay = false;
  bool loadingDelete = false;
  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(
      widget.video!.videoAffiliate!.videoUrl!,
    );
    controller!.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  Future<void> deleteVideo() async {
    setState(() {
      loadingDelete = true;
    });
    await context
        .read<VideoProvider>()
        .deleteVideo(widget.video!.videoAffiliate!.videoId!)
        .then((value) async {
      if (value) {
        await context.read<VideoProvider>().setPageMyVideo(1);
        context.read<VideoProvider>().getMyVideo(sort: widget.sort);
        snackBar(context, message: "Success delete video");
      } else {
        snackBar(context, message: "Failed delete video");
      }
      setState(() {
        loadingDelete = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Column(children: [
        GestureDetector(
          onTap: () {
            if (isPlay) {
              controller!.pause();
            } else if (!isPlay) {
              controller!.play();
            }
            setState(() {
              isPlay = !isPlay;
            });
          },
          child: Container(
              height: 230,
              margin: EdgeInsets.only(bottom: 10),
              child: VideoPlayer(
                controller!,
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Date : ",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "${widget.video!.videoAffiliate!.date}",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Views : ",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "${widget.video!.videoAffiliate!.views}",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Clicks : ",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "${widget.video!.videoAffiliate!.clicks}",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Sales : ",
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        "${widget.video!.videoAffiliate!.sales}",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  if (!loadingDelete) {
                    deleteVideo();
                  }
                },
                child: loadingDelete
                    ? customLoading()
                    : Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: primaryColor)),
                        child: Icon(
                          Icons.delete,
                          color: primaryColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
