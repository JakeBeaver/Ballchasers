import 'package:RLRank/providers/adMobService.dart';
import 'package:RLRank/providers/playersData.dart';
import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/screens/addPlayerScreen.dart';
import 'package:RLRank/screens/rankListSceen.dart';
import 'package:RLRank/screens/rankScreen.dart';
import 'package:RLRank/screens/sessionsScreen.dart';
import 'package:RLRank/screens/aboutScreen.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

Future setAnalytics(BuildContext context) async {
  await FirebaseAnalytics().setAnalyticsCollectionEnabled(
    await AdMobService.getHasConsent(context),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    setAnalytics(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrackerData()),
        ChangeNotifierProvider(create: (_) => PlayersData()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          backgroundColor: AppColors.background,
          appBarTheme: AppBarTheme(color: AppColors.appBar),
          scaffoldBackgroundColor: AppColors.background,
          dialogBackgroundColor: AppColors.background,
          cardColor: AppColors.background,
          colorScheme: ColorScheme.dark(),
          accentColor: AppColors.deepBlue,
          textTheme: const TextTheme(
              // subtitle1: const TextStyle(color: Colors.white),
              // sub
              // caption: const TextStyle(color: Colors.white),
              // bodyText2: const TextStyle(color: Colors.white),
              // bodyText1: const TextStyle(color: Colors.white),
              // subtitle2: const TextStyle(color: Colors.white),
              // headline1: const TextStyle(color: Colors.white),
              // headline2:  const TextStyle(color: Colors.white),
              // headline3:  const TextStyle(color: Colors.white),
              // headline4:  const TextStyle(color: Colors.white),
              // headline5:  const TextStyle(color: Colors.white),
              // headline6:  const TextStyle(color: Colors.white),
              ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
        routes: {
          "rank": (c) => RankScreen(),
          "newPlayer": (c) => AddPlayerScreen(),
          "sessions": (c) => SessionsScreen(),
          "about": (c) => AboutScreen(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<PlayersData>(context);
    bool showAddPlayerScreen = prov.ready && prov.data.length == 0;
    return showAddPlayerScreen ? AddPlayerScreen() : RankListScreen();
    // : Center(child: CircularProgressIndicator());
  }
}
