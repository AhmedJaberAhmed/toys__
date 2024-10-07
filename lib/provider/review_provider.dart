import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nyoba/models/review_model.dart';
import 'package:nyoba/models/review_product_model.dart';
import 'package:nyoba/services/review_api.dart';
import 'package:nyoba/utils/utility.dart';

class ReviewProvider with ChangeNotifier {
  bool isLoading = false;
  bool isLoadingReview = false;

  List<ReviewHistoryModel> listHistory = [];
  List<ReviewProduct> listReviewLimit = [];

  List<ReviewProduct> listReviewAllStar = [];
  List<ReviewProduct> listReviewFiveStar = [];
  List<ReviewProduct> listReviewFourStar = [];
  List<ReviewProduct> listReviewThreeStar = [];
  List<ReviewProduct> listReviewTwoStar = [];
  List<ReviewProduct> listReviewOneStar = [];
  List<ReviewProduct> listReviewImage = [];
  List<ReviewProduct> listReviewVerified = [];

  Future<List?> fetchHistoryReview() async {
    isLoading = !isLoading;
    var result;
    await ReviewAPI().historyReview().then((data) {
      result = data;

      listHistory.clear();

      printLog(result.toString());

      for (Map item in result) {
        listHistory.add(ReviewHistoryModel.fromJson(item));
      }

      isLoading = !isLoading;
      notifyListeners();
      printLog(result.toString());
    });
    return result;
  }

  Future<List?> fetchReviewProduct(productId) async {
    isLoadingReview = true;
    listReviewAllStar.clear();
    listReviewOneStar.clear();
    listReviewTwoStar.clear();
    listReviewThreeStar.clear();
    listReviewFourStar.clear();
    listReviewFiveStar.clear();
    listReviewImage.clear();
    listReviewVerified.clear();
    listReviewLimit.clear();
    var result;
    await ReviewAPI().productReview(productId).then((data) {
      if (data.statusCode == 200) {
        result = json.decode(data.body);
        printLog(result.toString(), name: "Review product");

        for (Map item in result) {
          if (item['status'] == 'approved') {
            listReviewAllStar.add(ReviewProduct.fromJson(item));
          }
        }

        if (listReviewAllStar.isNotEmpty) {
          listReviewLimit.clear();
          listReviewLimit.add(listReviewAllStar.first);
        }

        listReviewAllStar.forEach((element) {
          if (element.image!.isNotEmpty) {
            listReviewImage.add(element);
          }
          if (element.verified!) {
            listReviewVerified.add(element);
          }
          if (element.rating! == 5) {
            listReviewFiveStar.add(element);
          } else if (element.rating! == 4) {
            listReviewFourStar.add(element);
          } else if (element.rating! == 3) {
            listReviewThreeStar.add(element);
          } else if (element.rating! == 2) {
            listReviewTwoStar.add(element);
          } else if (element.rating! == 1) {
            listReviewOneStar.add(element);
          }
        });
      }

      isLoadingReview = false;
      notifyListeners();
      printLog(result.toString());
    });
    return result;
  }

  Future<bool> voteReview(
      String reviewType, String commentId, String vote) async {
    bool res = false;
    try {
      await ReviewAPI().voteReview(commentId, vote).then((data) {
        if (data != null) {
          printLog(json.encode(data), name: "Response Vote Review");
          if (data['status'] == "success") {
            res = true;
            if (reviewType == "limit") {
              listReviewLimit[listReviewLimit.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalUp = data['up'];
              listReviewLimit[listReviewLimit.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalDown = data['down'];
              listReviewLimit[listReviewLimit.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .userVote = vote;
            }
            if (reviewType == "all") {
              listReviewAllStar[listReviewAllStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalUp = data['up'];
              listReviewAllStar[listReviewAllStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalDown = data['down'];
              listReviewAllStar[listReviewAllStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .userVote = vote;
            }
            if (reviewType == "image") {
              listReviewImage[listReviewImage.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalUp = data['up'];
              listReviewImage[listReviewImage.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalDown = data['down'];
              listReviewImage[listReviewImage.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .userVote = vote;
            }
            if (reviewType == "verified") {
              listReviewVerified[listReviewVerified.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalUp = data['up'];
              listReviewVerified[listReviewVerified.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalDown = data['down'];
              listReviewVerified[listReviewVerified.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .userVote = vote;
            }
            if (reviewType == "five") {
              listReviewFiveStar[listReviewFiveStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalUp = data['up'];
              listReviewFiveStar[listReviewFiveStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalDown = data['down'];
              listReviewFiveStar[listReviewFiveStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .userVote = vote;
            }
            if (reviewType == "four") {
              listReviewFourStar[listReviewFourStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalUp = data['up'];
              listReviewFourStar[listReviewFourStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalDown = data['down'];
              listReviewFourStar[listReviewFourStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .userVote = vote;
            }
            if (reviewType == "three") {
              listReviewThreeStar[listReviewThreeStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalUp = data['up'];
              listReviewThreeStar[listReviewThreeStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalDown = data['down'];
              listReviewThreeStar[listReviewThreeStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .userVote = vote;
            }
            if (reviewType == "two") {
              listReviewTwoStar[listReviewTwoStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalUp = data['up'];
              listReviewTwoStar[listReviewTwoStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalDown = data['down'];
              listReviewTwoStar[listReviewTwoStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .userVote = vote;
            }
            if (reviewType == "one") {
              listReviewOneStar[listReviewOneStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalUp = data['up'];
              listReviewOneStar[listReviewOneStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .totalDown = data['down'];
              listReviewOneStar[listReviewOneStar.indexWhere(
                      (element) => element.id.toString() == commentId)]
                  .userVote = vote;
            }

            notifyListeners();
          } else {
            res = false;
            notifyListeners();
          }
        }
      });
    } catch (e) {
      printLog(e.toString());
      res = false;
      notifyListeners();
    }
    return res;
  }
}
