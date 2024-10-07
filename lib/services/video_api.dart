import 'dart:convert';

import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class VideoAPI {
  getProductVideo({String search = ""}) async {
    var response = await baseAPI.getAsync(
      "video/get-product?product=$search",
      isCustom: true,
    );
    return response;
  }

  getMyVideo({String? sort = "", int page = 1}) async {
    Map data = {
      'cookie': Session.data.getString('cookie'),
      'sort': sort,
      'page': page,
      'per_page': 6,
    };
    var response =
        await baseAPI.postAsync('video/get/my-video', data, isCustom: true);
    return response;
  }

  deleteVideo(String videoId) async {
    Map data = {
      'cookie': Session.data.getString('cookie'),
      'video_id': videoId
    };
    var response =
        await baseAPI.postAsync('video/delete', data, isCustom: true);
    printLog(json.encode(response));
    return response;
  }

  getVideo(int page, {String video = ""}) async {
    var response = await baseAPI.getAsync(
        'video/get?page=$page&per_page=6&video=$video',
        isCustom: true);
    return response;
  }

  viewVideo(String videoId) async {
    Map data = {
      'video_id': videoId,
    };
    var response = await baseAPI.postAsync('video/views', data,
        isCustom: true, printedLog: true);
    return response;
  }
}
