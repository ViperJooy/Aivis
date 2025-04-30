class VideoListModel {
  VideoListModel({
    this.page,
    this.perPage,
    this.videos,
    this.totalResults,
    this.nextPage,
    this.url,
  });

  VideoListModel.fromJson(dynamic json) {
    page = json['page'];
    perPage = json['per_page'];
    if (json['videos'] != null) {
      videos = [];
      json['videos'].forEach((v) {
        videos?.add(VideoItemModel.fromJson(v));
      });
    }
    totalResults = json['total_results'];
    nextPage = json['next_page'];
    url = json['url'];
  }
  num? page;
  num? perPage;
  List<VideoItemModel>? videos;
  num? totalResults;
  String? nextPage;
  String? url;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['page'] = page;
    map['per_page'] = perPage;
    if (videos != null) {
      map['videos'] = videos?.map((v) => v.toJson()).toList();
    }
    map['total_results'] = totalResults;
    map['next_page'] = nextPage;
    map['url'] = url;
    return map;
  }
}

class VideoItemModel {
  VideoItemModel({
    this.id,
    this.width,
    this.height,
    this.duration,
    this.fullRes,
    this.tags,
    this.url,
    this.image,
    this.avgColor,
    this.user,
    this.videoFiles,
    this.videoPictures,
  });

  VideoItemModel.fromJson(dynamic json) {
    id = json['id'];
    width = json['width'];
    height = json['height'];
    duration = json['duration'];
    fullRes = json['full_res'];
    if (json['tags'] != null) {
      tags = [];
      json['tags'].forEach((v) {
        tags?.add(v);
      });
    }
    url = json['url'];
    image = json['image'];
    avgColor = json['avg_color'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['video_files'] != null) {
      videoFiles = [];
      json['video_files'].forEach((v) {
        videoFiles?.add(VideoFiles.fromJson(v));
      });
    }
    if (json['video_pictures'] != null) {
      videoPictures = [];
      json['video_pictures'].forEach((v) {
        videoPictures?.add(VideoPictures.fromJson(v));
      });
    }
  }
  num? id;
  num? width;
  num? height;
  num? duration;
  dynamic fullRes;
  List<dynamic>? tags;
  String? url;
  String? image;
  dynamic avgColor;
  User? user;
  List<VideoFiles>? videoFiles;
  List<VideoPictures>? videoPictures;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['width'] = width;
    map['height'] = height;
    map['duration'] = duration;
    map['full_res'] = fullRes;
    if (tags != null) {
      map['tags'] = tags?.map((v) => v.toJson()).toList();
    }
    map['url'] = url;
    map['image'] = image;
    map['avg_color'] = avgColor;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (videoFiles != null) {
      map['video_files'] = videoFiles?.map((v) => v.toJson()).toList();
    }
    if (videoPictures != null) {
      map['video_pictures'] = videoPictures?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class VideoPictures {
  VideoPictures({this.id, this.nr, this.picture});

  VideoPictures.fromJson(dynamic json) {
    id = json['id'];
    nr = json['nr'];
    picture = json['picture'];
  }
  num? id;
  num? nr;
  String? picture;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['nr'] = nr;
    map['picture'] = picture;
    return map;
  }
}

class VideoFiles {
  VideoFiles({
    this.id,
    this.quality,
    this.fileType,
    this.width,
    this.height,
    this.fps,
    this.link,
    this.size,
  });

  VideoFiles.fromJson(dynamic json) {
    id = json['id'];
    quality = json['quality'];
    fileType = json['file_type'];
    width = json['width'];
    height = json['height'];
    fps = json['fps'];
    link = json['link'];
    size = json['size'];
  }
  num? id;
  String? quality;
  String? fileType;
  num? width;
  num? height;
  num? fps;
  String? link;
  num? size;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['quality'] = quality;
    map['file_type'] = fileType;
    map['width'] = width;
    map['height'] = height;
    map['fps'] = fps;
    map['link'] = link;
    map['size'] = size;
    return map;
  }
}

class User {
  User({this.id, this.name, this.url});

  User.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    url = json['url'];
  }
  num? id;
  String? name;
  String? url;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['url'] = url;
    return map;
  }
}

// extension VideoFileLabel on VideoFiles {
//   String get label {
//     var convertSize = size! / 1024 / 1024;
//     if (quality != null && width != null && height != null && size != null) {
//       return "${quality!.toUpperCase()} (${width}×$height) ${convertSize.toStringAsFixed(2)} MB";
//     } else {
//       return quality ?? "Unknown";
//     }
//   }
// }
