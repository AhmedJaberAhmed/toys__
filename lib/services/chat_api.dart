import 'dart:convert';

import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class ChatAPI {
  Future<dynamic> fetchDetailChat() async {
    Map<String, dynamic> data = {'cookie': Session.data.getString('cookie')};
    try {
      var response = await baseAPI.postAsync('$detailChat', data, isCustom: true).timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      printLog("Error fetching detail chat: $e");
      return null; // Handle as appropriate (e.g., return default value)
    }
  }

  Future<dynamic> sendChat({String? message, String? type, int? postId, String? image}) async {
    if (message == null || type == null) {
      printLog("Message and type cannot be null.");
      return null; // Or handle appropriately
    }

    Map<String, dynamic> data = {
      'cookie': Session.data.getString('cookie'),
      'message': message,
      'type': type,
      'post_id': postId,
      'image': image
    };

    printLog("Data Send Chat : ${json.encode(data)}");
    try {
      var response = await baseAPI.postAsync('$insertChat', data, isCustom: true).timeout(const Duration(seconds: 10));
      printLog("Response send chat : $response");
      return response;
    } catch (e) {
      printLog("Error sending chat: $e");
      return null; // Handle as appropriate
    }
  }

  Future<dynamic> checkUnreadMessage() async {
    Map<String, dynamic> data = {
      'cookie': Session.data.getString('cookie'),
      'incoming_chat': true
    };
    try {
      var response = await baseAPI.postAsync('$listUserChat', data, isCustom: true).timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      printLog("Error checking unread messages: $e");
      return null; // Handle as appropriate
    }
  }

  Future<dynamic> uploadImage({String? title, String? mediaAttachment}) async {
    if (title == null || mediaAttachment == null) {
      printLog("Title and mediaAttachment cannot be null.");
      return null; // Or handle appropriately
    }

    Map<String, dynamic> data = {'title': title, 'media_attachment': mediaAttachment};

    try {
      var response = await baseAPI.postAsync('$inputImage', data, isCustom: true).timeout(const Duration(seconds: 10));
      printLog("Response image : $response");
      return response;
    } catch (e) {
      printLog("Error uploading image: $e");
      return null; // Handle as appropriate
    }
  }
}
