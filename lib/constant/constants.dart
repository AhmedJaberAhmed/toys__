import 'package:nyoba/services/base_woo_api.dart';

String appId = '6670460041';
String url = "https://babybesttoy.com";

// oauth_consumer_key
String consumerKey = "ck_24bb9fd4d9bcb1f8abd1854629b5743e109bc943";
String consumerSecret = "cs_0092f87f65a0abf331c448cbbe9447bfcb962c1f";

// String version = '2.5.6';

// baseAPI for WooCommerce
BaseWooAPI baseAPI = BaseWooAPI(url, consumerKey, consumerSecret);

const debugNetworkProxy = false;
