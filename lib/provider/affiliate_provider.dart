import 'package:flutter/material.dart';
import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/widgets/webview/inapp_webview.dart';

import '../app_localizations.dart';
import '../constant/global_url.dart';
import '../services/session.dart';

class AffiliateProvider with ChangeNotifier {
  // Store the URL once to avoid repeated construction
  String? _affiliateUrl;

  // Method to get the affiliate URL
  String get affiliateUrl {
    if (_affiliateUrl == null) {
      var cookie = Session.data.getString('cookie');
      _affiliateUrl = '$url/wp-json/revo-admin/v1/$affiliateDetail?cookie=$cookie';
    }
    return _affiliateUrl!;
  }

  Future<void> affiliateDetails(BuildContext context) async {
    // Ensure that we await this navigation
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebview(
          url: affiliateUrl,
          title: AppLocalizations.of(context)!.translate('details')!,
        ),
      ),
    );
  }
}
