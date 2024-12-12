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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Center(child: const Text('NEWS HEADLINES',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.black),)),
      ),
      body: Column(
        children: [
Padding(
  padding: const EdgeInsets.all(8.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      GestureDetector(
      onTap: () => _updateCategory('business'),
      child: Text("BUSINESS",
          style: TextStyle(
            fontSize: 15,
            color: selectedCategory == 'business' ? Colors.black : Colors.red,
            fontWeight: FontWeight.bold,
          )),
    ),
    GestureDetector(
      onTap: () => _updateCategory('entertainment'),
      child: Text("ENTERTAINMENT",
          style: TextStyle(
            fontSize: 15,
            color: selectedCategory == 'entertainment' ? Colors.black : Colors.red,
            fontWeight: FontWeight.bold,
          )),
    ),
    GestureDetector(
      onTap: () => _updateCategory('sports'),
      child: Text("SPORTS",
          style: TextStyle(
            fontSize: 15,
            color: selectedCategory == 'sports' ? Colors.black : Colors.red,
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
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search,),
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
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                article.urlToImage.isNotEmpty
                                    ? Image.network(
                                        article.urlToImage,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image_not_supported, size: 100),
                                const SizedBox(height: 8),
                                
                                Text(
                                  article.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                
                                Text(
                                  article.description,
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                               
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ArticleDetailPage(article: article),
                                        ),
                                      );
                                    },
                                    child: const Text('Read More'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
    return Expanded(
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

        
        return ListView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: article.urlToImage.isNotEmpty
                    ? Image.network(
                        article.urlToImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported),
                title: Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  article.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailPage(article: article),
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
);

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Search articles by title or description.'),
    );
  }
}