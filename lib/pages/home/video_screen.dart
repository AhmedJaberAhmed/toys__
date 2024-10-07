import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nyoba/provider/video_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../app_localizations.dart';
import '../../widgets/video/video_player_widget.dart';

class VideoScreen extends StatefulWidget {
  final String? video;
  const VideoScreen({super.key, this.video});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  bool isPlaying = true;

  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
    viewportFraction: 1,
  );

  int _currentPage = 0;
  bool _isOnPageTurning =
      false; // flag to check the video item in on playing or not

  @override
  void initState() {
    super.initState();
    context
        .read<VideoProvider>()
        .getVideo(reset: true, video: widget.video ?? "");

    _pageController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_isOnPageTurning &&
        _pageController.page == _pageController.page!.roundToDouble()) {
      setState(() {
        _currentPage = _pageController.page!.toInt();
        _isOnPageTurning = false;
      });
    } else if (!_isOnPageTurning &&
        _currentPage.toDouble() != _pageController.page) {
      if ((_currentPage.toDouble() - _pageController.page!).abs() > 0.7) {
        setState(() {
          _isOnPageTurning = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
        color: Colors.transparent,
        child: Scaffold(
          body: Consumer<VideoProvider>(
            builder: (context, value, child) => value.loadingGetVideo &&
                    value.pageVideo == 1
                ? Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.black,
                      ),
                      Positioned(
                        bottom: 0,
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.white, size: 30),
                        ),
                      ),
                    ],
                  )
                : value.listVideos.isNotEmpty
                    ? PageView.builder(
                        itemCount: value.listVideos.length,
                        controller: _pageController,
                        physics: ScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        onPageChanged: (page) {
                          // context.read<VideoProvider>().setPlayingVideo(true);
                          if (value.listVideos.length % 6 == 0 &&
                              page ==
                                  ((4 * value.pageVideo) +
                                      ((value.pageVideo - 1) * 2))) {
                            context
                                .read<VideoProvider>()
                                .getVideo(reset: false);
                          }
                        },
                        itemBuilder: (context, index) {
                          return VideoPlayerWidget(
                            url: value
                                .listVideos[index].videoAffiliate!.videoUrl,
                            videoId:
                                value.listVideos[index].videoAffiliate!.videoId,
                            index: index,
                          );
                        },
                      )
                    : Center(
                        child: Text(
                            "${AppLocalizations.of(context)!.translate('no_video')}")),
          ),
        ));
  }
}
