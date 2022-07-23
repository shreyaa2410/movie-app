import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:footer/footer.dart';

void main() => runApp(const MoviesApp());

class MoviesApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);
  const MoviesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.blue),
            darkTheme: ThemeData.dark(),
            themeMode: currentMode,
            home: const MoviesListing(),
          );
        });
  }
}

class MoviesProvider {
  static const String imagePathPrefix = 'https://image.tmdb.org/t/p/w500/';

  //REPLACE: Replace YOUR_API_KEY with your API key
  static const apiKey = "613a8abfb61a4ff3e490a7a327a0b9d4";

  static Future<Map> getJson() async {
    final apiEndPoint =
        "http://api.themoviedb.org/3/discover/movie?api_key=${apiKey}&sort_by=popularity.desc";
    final apiResponse = await http.get(apiEndPoint);
    return json.decode(apiResponse.body);
  }
}

class MoviesListing extends StatefulWidget {
  const MoviesListing({Key? key}) : super(key: key);

  @override
  _MoviesListingState createState() => _MoviesListingState();
}

class _MoviesListingState extends State<MoviesListing> {
  List<MovieModel> movies = <MovieModel>[];

  //Counter to keep track of netwrok requests
  int counter = 0;

  fetchMovies() async {
    var data = await MoviesProvider.getJson();

    setState(() {
      //Increasing counter here
      counter++;

      List<dynamic> results = data['results'];
      for (var element in results) {
        movies.add(
          MovieModel.fromJson(element),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    //SOLUTION: Fetch movies data only once.
    fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("MovieMania"),
        leading: const Icon(Icons.movie_outlined),
        actions: [
          IconButton(
              icon: Icon(MoviesApp.themeNotifier.value == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode),
              onPressed: () {
                MoviesApp.themeNotifier.value =
                    MoviesApp.themeNotifier.value == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
              })
        ],
      ),
      body: ListView.builder(
        itemCount: movies == null ? 0 : movies.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                MovieTile(movies, index),
                //Widget added to print number of requests made to fetch movies
                // Text("Movies fetcgfhfhed: ${counter}"),
              ],
            ),
          );
        },
        // footer: Footer(
        //   child: Center(child: const Text('Developed by Shreya')),
        //   padding: EdgeInsets.all(10.0),
        // ),
      ),
    );
  }
}

class MovieTile extends StatelessWidget {
  final List<MovieModel> movies;
  final index;

  const MovieTile(this.movies, this.index);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          movies[index].poster_path != null
              ? Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height / 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey,
                    image: DecorationImage(
                        image: NetworkImage(MoviesProvider.imagePathPrefix +
                            movies[index].poster_path),
                        fit: BoxFit.cover),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 3.0,
                          offset: Offset(1.0, 3.0)),
                    ],
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              movies[index].title,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: MoviesApp.themeNotifier.value == ThemeMode.light
                      ? Colors.black
                      : Color.fromARGB(255, 238, 233, 233)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              movies[index].overview,
            ),
          ),
          Divider(color: Colors.grey.shade500),
        ],
      ),
    );
  }
}

class MovieModel {
  final int id;
  final num popularity;
  final int vote_count;
  final bool video;
  final String poster_path;
  final String backdrop_path;
  final bool adult;
  final String original_language;
  final String original_title;
  final List<dynamic> genre_ids;
  final String title;
  final num vote_average;
  final String overview;
  final String release_date;

  MovieModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        popularity = json['popularity'],
        vote_count = json['vote_count'],
        video = json['video'],
        poster_path = json['poster_path'],
        adult = json['adult'],
        original_language = json['original_language'],
        original_title = json['original_title'],
        genre_ids = json['genre_ids'],
        title = json['title'],
        vote_average = json['vote_average'],
        overview = json['overview'],
        release_date = json['release_date'],
        backdrop_path = json['backdrop_path'];
}
