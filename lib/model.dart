class NewsApiModel {
  final String title;
  final String description;
  final String urlToImage;
  final String content;

  NewsApiModel({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.content,
  });

  factory NewsApiModel.fromJson(Map<String, dynamic> json) {
    return NewsApiModel(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      urlToImage: json['urlToImage'] ?? '',
      content: json['content'] ?? 'No Content',
    );
  }
}