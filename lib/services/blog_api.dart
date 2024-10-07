import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class BlogAPI {
  // Caching response to minimize network calls
  final Map<String, dynamic> _cache = {};

  // Method to fetch the language code once
  String _getLanguageCode() {
    return Session.data.getString('language_code') ?? 'id';
  }

  // Fetch blog with search and pagination
  Future<dynamic> fetchBlog(String search, int page) async {
    String cacheKey = 'fetchBlog_$search$page';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]; // Return cached response
    }

    var response = await baseAPI.getAsync(
        '$blog?search=$search&page=$page&per_page=6&_embed',
        version: 2);
    _cache[cacheKey] = response; // Cache the response
    return response;
  }

  // Fetch blogs with language and pagination
  Future<dynamic> fetchBlogs(String search, int page) async {
    String langCode = _getLanguageCode();
    printLog("bahasa : $langCode");

    String cacheKey = 'fetchBlogs_$search$page';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]; // Return cached response
    }

    var response = await baseAPI.getAsync(
        '$listBlog?_embed=true&lang=$langCode&page=$page&per_page=6&search=$search',
        isCustom: true,
        printedLog: true);
    printLog("response blog : ${(response.body)}");
    _cache[cacheKey] = response; // Cache the response
    return response;
  }

  // Fetch detailed blog by post ID
  Future<dynamic> fetchDetailBlog(int postId) async {
    String langCode = _getLanguageCode();
    String cacheKey = 'fetchDetailBlog_$postId';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]; // Return cached response
    }

    var response = await baseAPI.getAsync(
      '$listBlog?_embed=true&lang=$langCode&post_id=$postId',
      isCustom: true,
    );
    printLog("response blog detail : ${response.body}");
    _cache[cacheKey] = response; // Cache the response
    return response;
  }

  // Post a comment on a blog
  Future<dynamic> postCommentBlog(String postId, String? comment) async {
    Map<String, String?> data = {
      'cookie': Session.data.getString('cookie'),
      'post': postId,
      'comment': comment,
    };
    var response = await baseAPI.postAsync(
      '$postComment',
      data,
      isCustom: true,
    );
    return response;
  }

  // Fetch comments for a blog post
  Future<dynamic> fetchBlogComment(String postId) async {
    var response =
    await baseAPI.getAsync('$listComment?post=$postId', version: 2);
    return response;
  }

  // Fetch blog detail by post ID
  Future<dynamic> fetchBlogDetailById(int postId) async {
    var response = await baseAPI.getAsync('$blog/$postId?_embed', version: 2);
    return response;
  }

  // Fetch blog detail by slug
  Future<dynamic> fetchBlogDetailBySlug(String slug) async {
    var response =
    await baseAPI.getAsync('$blog/?_embed&slug=$slug', version: 2);
    return response;
  }
}
