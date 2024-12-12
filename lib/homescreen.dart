import 'package:flutter/material.dart';

import 'package:newsapp_project/article_detail.dart';
import 'package:newsapp_project/newsmodel_api.dart';
import 'model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<NewsApiModel>> futureNews;
  String selectedCategory = 'business'; 
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Center(child: const Text('NEWS HEADLINES',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    GestureDetector(
      onTap: () => _updateCategory('bussines'),
      child: Text("BUSSINES",
          style: TextStyle(
            fontSize: 15,
            color: selectedCategory == 'bussines' ? Colors.blue : Colors.black,
            fontWeight: FontWeight.bold,
          )),
    ),
    GestureDetector(
      onTap: () => _updateCategory('entertainment'),
      child: Text("ENTERTAINMENT",
          style: TextStyle(
            fontSize: 15,
            color: selectedCategory == 'entertainment' ? Colors.blue : Colors.black,
            fontWeight: FontWeight.bold,
          )),
    ),
    GestureDetector(
      onTap: () => _updateCategory('sports'),
      child: Text("SPORTS",
          style: TextStyle(
            fontSize: 15,
            color: selectedCategory == 'sports' ? Colors.blue : Colors.black,
            fontWeight: FontWeight.bold,
          )),
    ),
  ],
),

          ),
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
            
              controller: _searchController,
              onChanged: _updateSearchQuery, 
              decoration: InputDecoration(
                labelText: 'Search News',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: NewsSearchDelegate(futureNews, query: _searchQuery),
                    );
                  },
                ),
              ),
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
                  List<NewsApiModel> articles = snapshot.data!;

                  
                  if (_searchQuery.isNotEmpty) {
                    articles = articles.where((article) {
                      return article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          article.description.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: articles.map((article) {
                        return GestureDetector(
                            onTap: (){
                                Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ArticleDetailPage(article: article),
                      ),
                    );
                            },
                            child: Container(
                            margin: EdgeInsets.all(15),
                            child: Column(
                                children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                      child: Image.network(article.urlToImage,
                                      height: 250,
                                      width: 400,
                                      fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Text(article.title,style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
                                    Divider(thickness: 2,),
                                ],
                            ),
                        ),
                        );
                      }
                      
                      ).toList(),
                    ),
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
  final String query;

  NewsSearchDelegate(this.futureNews, {required this.query});

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
