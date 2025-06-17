class PostModel {
  final String postTitle;
  final String description;
  final String image1;
  final String image2;
  final String image3;
  final String image4;
  final String image5;
  final String video;

  PostModel({
    required this.postTitle,
    required this.description,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.image4,
    required this.image5,
    required this.video,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postTitle: json['postTitle'] ?? '',
      description: json['description'] ?? '',
      image1: json['image_1'] ?? '',
      image2: json['image_2'] ?? '',
      image3: json['image_3'] ?? '',
      image4: json['image_4'] ?? '',
      image5: json['image_5'] ?? '',
      video: json['video'] ?? '',
    );
  }
}
