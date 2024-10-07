import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyoba/constant/cache_config.dart';
import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/models/video_model.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/services/video_api.dart';
import 'package:nyoba/utils/utility.dart';

class VideoProvider with ChangeNotifier {
  bool loadingGetProduct = false;
  List<Map<String, dynamic>> listProducts = [];

  Map<String, dynamic> selectedProduct = {};

  bool isPlaying = false;

  setPlayingVideo(val) {
    isPlaying = val;
    notifyListeners();
  }

  setSelectedProduct(val) {
    bool cek = false;
    Map<String, dynamic> tempProduct = {};
    for (var i in listProducts) {
      if (i['name'] == val) {
        tempProduct = i;
        cek = true;
      }
    }
    if (cek) {
      selectedProduct = tempProduct;
    } else {
      selectedProduct = {};
    }
    printLog(json.encode(selectedProduct));
    notifyListeners();
  }

  Future<List<String>> getProductVideo({String search = ""}) async {
    loadingGetProduct = true;
    notifyListeners();
    List<String> result = [];
    try {
      await VideoAPI().getProductVideo(search: search).then((data) {
        final responseJson = json.decode(data.body);
        listProducts = [];
        if (responseJson != null) {
          if (responseJson['data'] != null && responseJson['data'].isNotEmpty) {
            responseJson['data'].forEach((v) {
              listProducts.add(v);
              result.add(v['name']);
            });
            loadingGetProduct = false;
            notifyListeners();
          }
        } else {
          listProducts = [];
          loadingGetProduct = false;
          notifyListeners();
        }
      });
    } catch (e) {
      printLog(e.toString(), name: "Error Get Product Video");
      listProducts = [];
      loadingGetProduct = false;
      notifyListeners();
    }
    return result;
  }

  /*--------------------------------------------------------------------------*/

  bool loadingUploadVideo = false;
  double uploadedByte = 0;

  Dio dio = Dio();

  Future<bool> uploadVideo({int? productId, File? video}) async {
    loadingUploadVideo = true;
    notifyListeners();
    bool result = false;
    try {
      var url = baseAPI.getOAuthURL("POST", "video/store", 3, true, false);
      XFile file = XFile(video!.path);
      FormData form = FormData.fromMap({
        'cookie': Session.data.getString('cookie')!,
        'id_product': productId.toString(),
        'video': await MultipartFile.fromFile(file.path, filename: file.name)
      });
      var dataResponse = await dio.post(
        url,
        onSendProgress: (count, total) {
          printLog("$count $total");
          uploadedByte = (count / total);
          notifyListeners();
        },
        data: form,
      );
      if (dataResponse.data['status'] == "success") {
        result = true;
        loadingUploadVideo = false;
        uploadedByte = 0;
        notifyListeners();
      } else {
        result = false;
        loadingUploadVideo = false;
        uploadedByte = 0;
        notifyListeners();
      }
    } catch (e) {
      loadingUploadVideo = false;
      result = false;
      uploadedByte = 0;
      printLog(e.toString());
      rethrow;
    }
    return result;
  }

  /*-------------------------------------------------------------------------*/

  int pageMyVideo = 1;
  bool loadingGetMyVideo = false;
  List<VideoModel> listMyVideo = [];

  setPageMyVideo(val) {
    pageMyVideo = val;
    notifyListeners();
  }

  Future<void> getMyVideo({String? sort = ""}) async {
    loadingGetMyVideo = true;
    notifyListeners();
    await VideoAPI().getMyVideo(sort: sort, page: pageMyVideo).then((data) {
      if (pageMyVideo == 1) {
        listMyVideo = [];
      }
      if (data['data'] != null) {
        for (var i in data['data']) {
          listMyVideo.add(VideoModel.fromJson(i));
        }
        loadingGetMyVideo = false;
        notifyListeners();
      } else {
        listMyVideo = [];
        loadingGetMyVideo = false;
        notifyListeners();
      }
    });
  }

  /*-------------------------------------------------------------------------*/

  Future<bool> deleteVideo(String videoId) async {
    bool ret = false;
    await VideoAPI().deleteVideo(videoId).then((data) {
      if (data['status'].toString().toLowerCase() == "success") {
        ret = true;
      } else {
        ret = false;
      }
    });
    return ret;
  }

  /*-------------------------------------------------------------------------*/
  int pageVideo = 1;
  List<VideoModel> listVideos = [];
  bool loadingGetVideo = false;

  setPageVideo(val) {
    pageVideo = val;
    notifyListeners();
  }

  Future<void> getVideo({bool reset = false, String video = ""}) async {
    loadingGetVideo = true;
    notifyListeners();
    if (reset) {
      pageVideo = 1;
    }
    if (!reset) {
      pageVideo++;
    }
    await VideoAPI().getVideo(pageVideo, video: video).then((data) {
      final responseJson = json.decode(data.body);
      if (pageVideo == 1) {
        listVideos = [];
      }

      if (responseJson != null) {
        for (var i in responseJson['data']) {
          listVideos.add(VideoModel.fromJson(i));
          cacheVideos(i['video_affiliate']['video_url']);
        }
        loadingGetVideo = false;
        notifyListeners();
      } else {
        listVideos.clear();
        loadingGetVideo = false;
        notifyListeners();
      }
    });
  }

  cacheVideos(String url) async {
    FileInfo? fileInfo = await kCacheManager.getFileFromCache(url);
    if (fileInfo == null) {
      printLog('downloading file ##------->$url##');
      await kCacheManager.downloadFile(url);
      printLog('downloaded file ##------->$url##');
    }
  }

  Future<bool> viewVideo(String videoId) async {
    bool ret = false;
    await VideoAPI().viewVideo(videoId).then((data) {
      printLog(json.encode(data));
      if (data['status'].toString().toLowerCase() == "success") {
        ret = true;
      }
    });
    return ret;
  }
}
