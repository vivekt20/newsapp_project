import 'package:flutter/material.dart';

import 'package:newsapp_project/newsmodel_api.dart';
import 'model.dart';
import 'article_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<NewsApiModel>> futureNews;
  String selectedCategory = 'business'; // Default category

  @override
  void initState() {
    super.initState();
    futureNews = getNews(category: selectedCategory);
  }

  void _updateCategory(String category) {
    setState(() {
      selectedCategory = category;
      futureNews = getNews(category: selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Headlines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NewsSearchDelegate(futureNews),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryButton('Business', Icons.business, 'business'),
                _buildCategoryButton(
                    'Entertainment', Icons.movie, 'entertainment'),
                _buildCategoryButton('Sports', Icons.sports, 'sports'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NewsApiModel>>(
              future: futureNews,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No articles found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final article = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: article.urlToImage.isNotEmpty
                              ? Image.network(article.urlToImage,
                                  width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.image_not_supported),
                          title: Text(article.title,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text(article.description,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ArticleDetailPage(article: article),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
      String label, IconData icon, String category) {
    return GestureDetector(
      onTap: () => _updateCategory(category),
      child: Column(
        children: [
          Icon(icon, size: 30, color: selectedCategory == category ? Colors.blue : Colors.grey),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: selectedCategory == category ? Colors.blue : Colors.grey)),
        ],
      ),
    );
  }
}

class NewsSearchDelegate extends SearchDelegate {
  final Future<List<NewsApiModel>> futureNews;

  NewsSearchDelegate(this.futureNews);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<NewsApiModel>>(
      future: futureNews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No articles found.'));
        } else {
          final results = snapshot.data!.where((article) {
            return article.title.toLowerCase().contains(query.toLowerCase()) ||
                article.description.toLowerCase().contains(query.toLowerCase());
          }).toList();

          if (results.isEmpty) {
            return const Center(child: Text('No articles match your search.'));
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final article = results[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: article.urlToImage.isNotEmpty
                      ? Image.network(article.urlToImage,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported),
                  title: Text(article.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(article.description,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ArticleDetailPage(article: article),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Search articles by title or description.'),
    );
  }
}