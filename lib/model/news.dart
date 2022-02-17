class Article {
  //--- Name Of City
  final String title;
  //-- image
  final String image;

  Article({this.title, this.image});

  static List<Article> allNews() {
    var listNews = new List<Article>();
    listNews.add(new Article(
        title: "news title 1",
        image:
            'https://cdn2.iconfinder.com/data/icons/metro-uinvert-dock/256/Fox_News.png'));


    return listNews;
  }
}
