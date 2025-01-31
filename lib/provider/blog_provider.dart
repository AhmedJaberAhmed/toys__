import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:nyoba/services/blog_api.dart';
import 'package:nyoba/models/blog_model.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class BlogProvider with ChangeNotifier {
  BlogModel? blog;
  bool? loading = true;
  bool loadingComment = true;
  bool loadingDetail = false;

  List<BlogModel> blogs = [];
  String? searchBlogs = "";
  int? currentPage;
  List<BlogCommentModel> blogComment = [];

  Future<void> fetchBlogs({search, page, loadingList}) async {
    loading = loadingList;
    searchBlogs = search;
    currentPage = page;
    await BlogAPI().fetchBlogs(search, page).then((data) {
      //printLog("Data blog : ${json.encode(data)}");
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);
        Session.data.setString("listBlog", json.encode(responseJson));

        blogs.clear();
        for (Map item in responseJson) {
          blogs.add(BlogModel.fromJson(item));
        }
        loading = false;
        notifyListeners();
      } else {
        blogs.clear();
        loading = false;
        notifyListeners();
      }
    });
  }

  setListBlogFromSession() {
    final responseJson = jsonDecode(Session.data.getString('listBlog')!);
    blogs.clear();
    for (Map item in responseJson) {
      blogs.add(BlogModel.fromJson(item));
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> postComment(postId, {comment}) async {
    var result;
    await BlogAPI().postCommentBlog(postId.toString(), comment).then((data) {
      result = data;
      loading = false;
      notifyListeners();
      printLog(result.toString());
    });
    return result;
  }

  Future<void> fetchBlogComment(postId, loading) async {
    loadingComment = loading;
    await BlogAPI().fetchBlogComment(postId).then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        blogComment.clear();
        for (Map item in responseJson) {
          blogComment.add(BlogCommentModel.fromJson(item));
        }
        loadingComment = false;
        notifyListeners();
      } else {
        loadingComment = false;
        notifyListeners();
      }
    });
  }

  Future<BlogModel?> fetchBlogDetailById(postId) async {
    loadingDetail = true;
    BlogModel? blogModel;

    await BlogAPI().fetchDetailBlog(postId).then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);
        printLog("responseJson : $responseJson");

        blogModel = BlogModel.fromJson(responseJson[0]);

        loadingDetail = false;
        notifyListeners();
      } else {
        loadingDetail = false;
        notifyListeners();
      }
    });
    return blogModel;
  }

  Future<BlogModel?> fetchBlogDetailBySlug(slug) async {
    loadingDetail = true;
    BlogModel? blogModel;

    await BlogAPI().fetchBlogDetailBySlug(slug).then((data) {
      if (data.statusCode == 200) {
        final responseJson = json.decode(data.body);

        for (Map item in responseJson) {
          blogModel = BlogModel.fromJson(item);
        }
        loadingDetail = false;
        notifyListeners();
      } else {
        loadingDetail = false;
        notifyListeners();
      }
    });
    return blogModel;
  }
}
