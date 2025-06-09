class FeedUtils {
  static List<String> prepareFeedImagePaths(Map<String, dynamic> postJson) {
    return [
      postJson['image_1'] ?? '',
      postJson['image_2'] ?? '',
      postJson['image_3'] ?? '',
      postJson['image_4'] ?? '',
      postJson['image_5'] ?? '',
    ].map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
}
