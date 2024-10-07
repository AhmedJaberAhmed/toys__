class ReferalModel {
  String? referralLink;
  String? dashboardLink;
  String? referralValue;
  String? referralPath;

  ReferalModel(
      {this.referralLink,
      this.dashboardLink,
      this.referralValue,
      this.referralPath});

  ReferalModel.fromJson(Map<String, dynamic> json) {
    referralLink = json['referral_link'];
    dashboardLink = json['dashboard_link'];
    referralValue = json['referral_value'];
    referralPath = json['referral_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['referral_link'] = this.referralLink;
    data['dashboard_link'] = this.dashboardLink;
    data['referral_value'] = this.referralValue;
    data['referral_path'] = this.referralPath;
    return data;
  }
}
