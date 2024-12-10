import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';

Future<List<NewsApiModel>> getNews({required String category}) async {
  Uri uri = Uri.parse(
    "https://newsapi.org/v2/top-headlines?country=us&apiKey=8fa00ba1169d491bb7a76a8a2e9c7cfe",
  );

  final response = await http.get(uri);

  if (response.statusCode == 200 || response.statusCode == 201) {
    Map<String, dynamic> map = json.decode(response.body);
    List<dynamic> _articlesList = map['articles'];

    List<NewsApiModel> newsList = _articlesList
        .map((jsonData) => NewsApiModel.fromJson(jsonData))
        .toList();

    return newsList;
  } else {
    print("Error: ${response.statusCode}");
    return [];
  }
}