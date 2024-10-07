import 'dart:convert';
import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/models/address_model.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:http/http.dart' as http;

class UserAPI {
  Future<dynamic> fetchDetail() async {
    Map data = {"cookie": Session.data.get('cookie')};
    printLog(data.toString(), name: "DATA FETCH USER");

    try {
      var response = await baseAPI.postAsync('$userDetail', data,
          isCustom: true, printedLog: true);
      return response;
    } catch (error) {
      print("Error fetching user details: $error");
      return null; // Handle error accordingly
    }
  }

  Future<dynamic> updateUserInfo({
    String? firstName,
    String? lastName,
    String? email,
    required String password,
    String? oldPassword,
    String? countryCode = "",
    String? phone = "",
  }) async {
    Map data = {
      "cookie": Session.data.get('cookie'),
      "first_name": firstName,
      "last_name": lastName,
      "user_email": email,
      "country_code": countryCode,
      "phone_number": phone,
      if (password.isNotEmpty) "user_pass": password,
      if (password.isNotEmpty) "old_pass": oldPassword,
    };
    printLog(json.encode(data), name: "Data update user");

    try {
      var response = await baseAPI.postAsync('$updateUser', data, isCustom: true);
      return response;
    } catch (error) {
      print("Error updating user info: $error");
      return null; // Handle error accordingly
    }
  }

  Future<dynamic> checkPhoneNumber({String? phone, String? countryCode}) async {
    Map data = {
      "cookie": Session.data.getString("cookie"),
      "country_code": countryCode,
      "phone_number": phone,
    };
    printLog(json.encode(data), name: "Data Check Phone");

    try {
      var response = await baseAPI.postAsync('$checkPhone', data, isCustom: true);
      printLog(json.encode(response), name: "Response Check Phone");
      return response;
    } catch (error) {
      print("Error checking phone number: $error");
      return null; // Handle error accordingly
    }
  }

  Future<dynamic> getAddress() async {
    try {
      var response = await baseAPI.getAsync(
          '$shippingAddress?user_id=${Session.data.getInt('id')}',
          isCustom: true);
      return response;
    } catch (error) {
      print("Error fetching addresses: $error");
      return null; // Handle error accordingly
    }
  }

  Future<dynamic> setDefaultAddress(String key) async {
    Map data = {'user_id': Session.data.getInt('id'), 'address_key': key};

    try {
      var response = await baseAPI.postAsync('$setDefault', data, isCustom: true);
      return response;
    } catch (error) {
      print("Error setting default address: $error");
      return null; // Handle error accordingly
    }
  }

  Future<dynamic> deleteAddress(String key) async {
    Map data = {'user_id': Session.data.getInt('id'), 'address_key': key};

    try {
      var response = await baseAPI.postAsync('$deleteAdress', data, isCustom: true);
      return response;
    } catch (error) {
      print("Error deleting address: $error");
      return null; // Handle error accordingly
    }
  }

  Future<dynamic> addAddress(AddressModel address) async {
    Map data = address.toJson();
    printLog(json.encode(data), name: "Data insert address");

    try {
      var response = await baseAPI.postAsync('$insertAddress', data, isCustom: true);
      return response;
    } catch (error) {
      print("Error adding address: $error");
      return null; // Handle error accordingly
    }
  }

  Future<dynamic> editAddress(AddressModel address) async {
    Map data = address.toJson();
    printLog(json.encode(data), name: "Data update Address");

    try {
      var response = await baseAPI.postAsync('$updateAddress', data, isCustom: true);
      return response;
    } catch (error) {
      print("Error editing address: $error");
      return null; // Handle error accordingly
    }
  }

  Future<dynamic> getFullAddress(String query, String key) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$key";
    printLog(url);

    try {
      var response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      return response;
    } catch (error) {
      print("Error fetching full address: $error");
      return null; // Handle error accordingly
    }
  }
}
