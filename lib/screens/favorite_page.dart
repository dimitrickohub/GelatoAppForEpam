import 'package:flutter/material.dart';
import 'package:flutter_application_2/classes/favorite_list.dart';
import 'package:flutter_application_2/localization/language_constants.dart';
import 'package:flutter_application_2/screens/music_data.dart';

import 'package:page_transition/page_transition.dart';

import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<FavoriteList>? songs;
  List<FavoriteList>? songlist;
  String? songsString;
  Future _fetchSongs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      songsString = (prefs.getString('favList') ?? '');
      songs = FavoriteList.decode(songsString.toString());
    });

    return songs;
  }

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar() as PreferredSizeWidget?,
      body: getBody(),
    );
  }

  Widget getAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      title: SafeArea(
        child: Container(
          alignment: Alignment.centerLeft,
          child: Text(
            getTranslated(context, 'favorites')!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget getBody() {
    return FutureBuilder(
      builder: (context, AsyncSnapshot snapshot) {
        // ignore: unnecessary_null_comparison
        if (ConnectionState.active != null && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        // ignore: unnecessary_null_comparison
        if (ConnectionState.done != null && snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        alignment: Alignment.bottomCenter,
                        child: MusicData(
                          title: songs![index].title.toString(),
                          description: songs![index].description.toString(),
                          img: songs![index].img.toString(),
                          songUrl: songs![index].songUrl.toString(),
                        ),
                        type: PageTransitionType.scale));
              },
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                    NetworkImage(songs![index].img.toString()),
                                fit: BoxFit.contain)),
                      ),
                      Expanded(
                        child: Container(
                          height: 60,
                          child: Column(
                            children: <Widget>[
                              Text(
                                songs![index].title.toString(),
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                  child: Container(
                                      child: Text(
                                songs![index].description.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ))),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      future: _fetchSongs(),
    );
  }
}
