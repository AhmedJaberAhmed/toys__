import 'dart:convert';
import 'dart:io';

import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class ReviewAPI {
  historyReview() async {
    Map data = {
      "cookie": Session.data.getString('cookie'),
    };
    printLog(data.toString());
    var response = await baseAPI.postAsync(
      '$historyReviewUrl',
      data,
      isCustom: true,
    );
    return response;
  }

  inputReview(productId, review, rating, reviewTitle, caption,
      {List<File>? image, String name = "", String email = ""}) async {
    Map data = {
      "product_id": productId,
      "comments": review,
      "cookie": Session.data.getString('cookie') ?? "",
      "rating": rating,
      "review_title": reviewTitle,
      "caption": caption,
      if (image != null) "media[]": image,
      if (name != "") "author_name": name,
      if (email != "") "author_email": email
    };
    printLog(data.toString());
    var response = await baseAPI.postAsync('$addReviewUrl', data,
        isCustom: true, isReview: true);
    printLog(json.encode(response), name: "Response Review");
    return response;
  }

  productReview(productId) async {
    var response = await baseAPI.getAsync(
        'products/reviews?product=$productId&user_id=${Session.data.getInt('id') ?? ""}',
        isCustom: true,
        printedLog: true);
    return response;
  }

  voteReview(String commentId, String vote) async {
    Map data = {
      'cookie': Session.data.getString('cookie') ?? "",
      'comment_id': commentId,
      'vote': vote
    };
    var response = await baseAPI.postAsync('vote-review', data,
        isCustom: true, printedLog: true);
    return response;
  }
}
