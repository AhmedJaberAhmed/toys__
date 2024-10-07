import 'package:flutter/material.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/pages/account/add_video_screen.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/video/my_video_shimmer.dart';
import 'package:nyoba/widgets/video/my_video_widget.dart';
import 'package:provider/provider.dart';
import 'package:nyoba/provider/video_provider.dart';

class MyVideoScreen extends StatefulWidget {
  const MyVideoScreen({super.key});

  @override
  State<MyVideoScreen> createState() => _MyVideoScreenState();
}

class _MyVideoScreenState extends State<MyVideoScreen> {
  List<String> sortBy = ['Popularity', 'Latest', 'Clicks', 'Sales'];
  int selectedSort = 0;
  ScrollController? scrollController = new ScrollController();
  VideoProvider? videoProvider;

  @override
  void initState() {
    super.initState();
    videoProvider = Provider.of<VideoProvider>(context, listen: false);
    scrollController!.addListener(() {
      if (scrollController!.hasClients) {
        if (scrollController!.position.pixels ==
            scrollController!.position.maxScrollExtent) {
          if (!videoProvider!.loadingGetMyVideo &&
              videoProvider!.listMyVideo.length % 6 == 0) {
            videoProvider!.setPageMyVideo(videoProvider!.pageMyVideo + 1);
            videoProvider!.getMyVideo(sort: sortBy[selectedSort].toLowerCase());
          }
        }
      }
    });
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      context.read<VideoProvider>().setPageMyVideo(1);
      context
          .read<VideoProvider>()
          .getMyVideo(sort: sortBy[selectedSort].toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Video",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [AddVideoWidget()],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppLocalizations.of(context)!.translate('sort')}",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: MediaQuery.of(context).size.height / 21,
              margin: EdgeInsets.only(bottom: 10),
              child: ListView.separated(
                itemCount: sortBy.length,
                physics: ScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSort = index;
                      });
                      context.read<VideoProvider>().setPageMyVideo(1);
                      context
                          .read<VideoProvider>()
                          .getMyVideo(sort: sortBy[selectedSort]);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      width: MediaQuery.of(context).size.width / 2.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: selectedSort == index
                                  ? Colors.transparent
                                  : Colors.grey.shade400),
                          color: selectedSort == index ? primaryColor : null),
                      child: Center(
                        child: Text(
                          sortBy[index],
                          style: TextStyle(
                              fontSize: 12,
                              color: selectedSort == index
                                  ? Colors.white
                                  : Colors.grey.shade400),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: 10,
                  );
                },
              ),
            ),
            Consumer<VideoProvider>(
              builder: (context, value, child) => Container(
                height: MediaQuery.of(context).size.height * 0.75,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      GridView.builder(
                        itemCount:
                            value.loadingGetMyVideo && value.pageMyVideo == 1
                                ? 4
                                : value.listMyVideo.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.5),
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (value.loadingGetMyVideo &&
                              value.pageMyVideo == 1) {
                            return MyVideoShimmer();
                          }
                          return MyVideoWidget(
                            video: value.listMyVideo[index],
                            sort: sortBy[selectedSort],
                          );
                        },
                      ),
                      Visibility(
                          visible:
                              value.loadingGetMyVideo && value.pageMyVideo != 1,
                          child: Center(
                            child: customLoading(),
                          ))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddVideoWidget extends StatelessWidget {
  const AddVideoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVideoScreen(),
            ));
      },
      child: Container(
        width: 45,
        height: 30,
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Stack(children: [
          Positioned(
            child: Icon(
              Icons.smart_display_rounded,
              size: 28,
            ),
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
          ),
          Positioned(
              bottom: 10,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white),
                    color: primaryColor),
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 10,
                ),
              ))
        ]),
      ),
    );
  }
}
