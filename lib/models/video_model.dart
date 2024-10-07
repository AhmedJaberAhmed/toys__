class VideoModel {
  VideoAffiliateModel? videoAffiliate;
  ProductDataVideoModel? productDataVideo;
  DataUserModel? dataUser;

  VideoModel({this.videoAffiliate, this.productDataVideo, this.dataUser});

  Map toJson() => {
        'video_affiliate': videoAffiliate,
        'product_data': productDataVideo,
        'data_user': dataUser,
      };

  VideoModel.fromJson(Map json) {
    if (json['video_affiliate'] != null) {
      videoAffiliate = VideoAffiliateModel.fromJson(json['video_affiliate']);
    }
    if (json['product_data'] != null) {
      productDataVideo = ProductDataVideoModel.fromJson(json['product_data']);
    }
    if (json['data_user'] != null) {
      dataUser = DataUserModel.fromJson(json['data_user']);
    }
  }
}

class VideoAffiliateModel {
  String? videoId,
      videoUrl,
      date,
      views,
      clicks,
      sales,
      status,
      createdAt,
      linkShare;

  VideoAffiliateModel({
    this.videoId,
    this.videoUrl,
    this.date,
    this.status,
    this.createdAt,
    this.views,
    this.clicks,
    this.sales,
    this.linkShare,
  });

  Map toJson() => {
        'video_id': videoId,
        'video_url': videoUrl,
        'date': date,
        'views': views,
        'clicks': clicks,
        'sales': sales,
        'status': status,
        'creted_at': createdAt,
        'link_share': linkShare,
      };

  VideoAffiliateModel.fromJson(Map json) {
    videoId = json['video_id'];
    videoUrl = json['video_url'];
    date = json['date'];
    views = json['views'];
    clicks = json['clicks'];
    sales = json['sales'];
    status = json['status'];
    createdAt = json['created_at'];
    linkShare = json['link_share'];
  }
}

class ProductDataVideoModel {
  int? productId;
  String? postTitle;
  String? postContent;
  String? thumbnail;
  String? type;

  ProductDataVideoModel(
      {this.productId,
      this.postTitle,
      this.postContent,
      this.thumbnail,
      this.type});

  Map toJson() => {
        'product_id': productId,
        'post_title': postTitle,
        'post_content': postContent,
        'thumbnail': thumbnail,
        'type': type,
      };

  ProductDataVideoModel.fromJson(Map json) {
    productId = json['product_id'];
    postTitle = json['post_title'];
    postContent = json['post_content'];
    thumbnail = json['thumbnail'];
    type = json['type'];
  }
}

class DataUserModel {
  int? userId;
  String? name, username, email;

  DataUserModel({this.userId, this.name, this.username, this.email});

  Map toJson() =>
      {'user_id': userId, 'name': name, 'username': username, 'email': email};

  DataUserModel.fromJson(Map json) {
    userId = json['user_id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
  }
}
