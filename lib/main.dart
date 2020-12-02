import 'package:RLRank/providers/playersData.dart';
import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/screens/addPlayerScreen.dart';
import 'package:RLRank/screens/rankListSceen.dart';
import 'package:RLRank/screens/rankScreen.dart';
import 'package:RLRank/screens/sessionsScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrackerData()),
        ChangeNotifierProvider(create: (_) => PlayersData()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          backgroundColor: Colors.black,
          textTheme: TextTheme(
            subtitle1: TextStyle(color: Colors.white),
            caption: TextStyle(color: Colors.white),
            bodyText2: TextStyle(color: Colors.white),
            bodyText1: TextStyle(color: Colors.white),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
        routes: {
          "rank": (c) => RankScreen(),
          "newPlayer": (c) => AddPlayerScreen(),
          "sessions": (c) => SessionsScreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<PlayersData>(context);
    return prov.ready
        ? prov.data.length == 0 ? AddPlayerScreen() : RankListScreen()
        : Center(child: CircularProgressIndicator());
  }
}
