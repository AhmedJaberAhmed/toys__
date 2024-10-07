import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // For caching example

class Services {
  final BuildContext context;
  Services(this.context);

  var api = "https://demoonlineshop.revoapps.id/wp-json/revo-admin/v1/";
  final int _timeoutDuration = 10; // Timeout duration in seconds

  Future<dynamic> getData(String apiName) async {
    final cacheKey = apiName; // Define a cache key based on the API name
    final prefs = await SharedPreferences.getInstance();

    // Check if data is cached
    if (prefs.containsKey(cacheKey)) {
      return jsonDecode(prefs.getString(cacheKey)!);
    }

    try {
      final response = await http.get(
        Uri.parse('$api$apiName'),
        headers: {"Accept": "application/json"},
      ).timeout(Duration(seconds: _timeoutDuration));

      // Check for a successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Cache the data
        await prefs.setString(cacheKey, response.body);

        return data;
      } else {
        // Handle error response
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions (timeout, network issues, etc.)
      print("Error occurred: $error");
      return null; // or throw error to be handled by the caller
    }
  }
}
