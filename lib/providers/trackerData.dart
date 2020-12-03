import 'dart:convert';

import 'package:RLRank/providers/playersData.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TrackerData with ChangeNotifier {
  bool isLoading = true;

  Player player;

  Player previousPlayer;
  List<Session> previousSessions;
  List<PlaylistRank> previousRanks;

  Future setPlayer(
    Player player,
    BuildContext context, {
    bool revertIfFailed = false,
  }) async {
    if (revertIfFailed) {
      previousPlayer = this.player;
      previousSessions = this.sessions;
      previousRanks = this.playlistRanks;
    }
    this.player = player;
    isLoading = true;
    notifyListeners();
    await refresh(context, revertIfFailed: revertIfFailed);
  }

  bool offline = false;

  Future refresh(BuildContext context, {bool revertIfFailed = false}) async {
    // isLoading = true;
    // notifyListeners();
    var prov = Provider.of<PlayersData>(context, listen: false);
    if (player == null) {
      player = prov.lastUsedPlayer;
    }
    _statsBody = player.statsBody;
    _sessionsBody = player.sessionsBody;
    bool failed = false;
    try {
      await Future.wait([
        fetchStats(),
        // fetchDistribution(),
        fetchSessions(),
      ]);
      offline = false;
    } catch (e) {
      if (revertIfFailed) {
        this.player = previousPlayer;
        this.sessions = previousSessions;
        this.playlistRanks = previousRanks;
        failed = true;
      } else {
        offline = true;
      }
    }
    isLoading = false;
    notifyListeners();
    player.statsBody = _statsBody;
    player.sessionsBody = _sessionsBody;
    if (failed) {
      throw new Exception();
    }
    prov.addOrUpdatePlayer(player);
  }

  String getPlatformString(Platform platform) {
    switch (platform) {
      case Platform.psn:
        return "psn";
      case Platform.xbox:
        return "xbl";
      case Platform.steam:
        return "steam";
    }
    return "error";
  }

  String getStatsAddress(Platform platform, String name) {
    String plString = getPlatformString(platform);
    return "https://api.tracker.gg/api/v2/rocket-league/standard/profile/" +
        plString +
        "/" +
        name;
  }

  String getSessionsAddress(Platform platform, String name) {
    String plString = getPlatformString(platform);
    return "https://api.tracker.gg/api/v2/rocket-league/standard/profile/" +
        plString +
        "/" +
        name +
        "/sessions";
  }

  String getDistributionAddress() {
    return "https://api.tracker.gg/api/v1/rocket-league/distribution/";
  }

  // Future fetchDistribution() async {
  //   String address = getDistributionAddress();
  //   final response = await http.get(address);
  //   _distributionBody = json.decode(response.body) as Map<String, dynamic>;
  // }

  Map<String, dynamic> _statsBody;
  Map<String, dynamic> _sessionsBody;
  // Map<String, dynamic> _distributionBody;
  // String avatarUrl() => isLoading ? null :
  List<PlaylistRank> playlistRanks;

  Future fetchStats() async {
    try {
      String address = getStatsAddress(player.platform, player.nameForSearch);
      final response = await http.get(address);
      var tempStatsBody = json.decode(response.body) as Map<String, dynamic>;
      if (tempStatsBody["data"]["segments"] != null) {
        _statsBody = tempStatsBody;
      } else {
        throw new Exception();
      }
    } finally {
      var segments = _statsBody["data"]["segments"] as List<dynamic>;
      playlistRanks = segments
          .map<PlaylistRank>((e) => PlaylistRank(e))
          .where((x) => x.display)
          .toList();

      var handle = _statsBody["data"]["platformInfo"]["platformUserHandle"];
      var avatarUrl = _statsBody["data"]["platformInfo"]["avatarUrl"];
      this.player = Player(
        name: player.name,
        handle: handle,
        platform: player.platform,
        picUrl: avatarUrl,
      );
    }
  }

  List<Session> sessions;

  Future fetchSessions() async {
    try {
      String address =
          getSessionsAddress(player.platform, player.nameForSearch);
      final response = await http.get(address);
      var tempSessionsBody = json.decode(response.body) as Map<String, dynamic>;
      if (tempSessionsBody["data"]["items"] != null) {
        _sessionsBody = tempSessionsBody;
      } else {
        throw new Exception();
      }
    } finally {
      var items = _sessionsBody["data"]["items"] as List<dynamic>;
      sessions = items
          .map((x) => Session(x))
          .where((x) => x.matches.length > 0)
          .toList();
    }
  }

  Widget disconnectedIcon(GlobalKey<ScaffoldState> scaffoldKey) {
    return offline
        ? FloatingActionButton(
            elevation: 0,
            splashColor: Colors.black.withOpacity(0),
            backgroundColor: Colors.black.withOpacity(0),
            child: Image(image: AssetImage("assets/disconnected.png")),
            onPressed: () {
              scaffoldKey.currentState.hideCurrentSnackBar();
              scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red[800],
                  content: Text(
                    "Loading from tracker server failed. Showing cached info.",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          )
        : null;
  }
}

class Session {
  DateTime startDate;
  DateTime endDate;
  List<Match> matches;
  Session(Map<String, dynamic> map) {
    startDate = DateTime.parse(map["metadata"]["startDate"]["value"]);
    endDate = DateTime.parse(map["metadata"]["endDate"]["value"]);
    var mats = (map["matches"] as List<dynamic>);
    var tempMatches = mats.map((x) => Match(x)).where((x) => x.show).toList();

    final tf = DateFormat('HH:mm');
    String lastDate = "";
    matches = [];
    for (var match in tempMatches) {
      var date = tf.format(match.dateCollected);
      if (date != lastDate) {
        matches.add(match);
        lastDate = date;
      }
    }
  }
}

class Match {
  bool show = true;
  String playlist;
  String result;
  DateTime dateCollected;
  int saves;
  int assists;
  int goals;
  int shots;
  bool mvp;
  String iconUrl;
  String tier;
  String division;
  int ratingDelta;
  int mmr;
  Match(Map<String, dynamic> map) {
    goals = map["stats"]["goals"]["value"];
    if (goals == null) {
      show = false;
      return;
    }
    playlist = map["metadata"]["playlist"];
    result = map["metadata"]["result"];
    dateCollected = DateTime.parse(map["metadata"]["dateCollected"]);
    saves = map["stats"]["saves"]["value"];
    assists = map["stats"]["assists"]["value"];
    shots = map["stats"]["shots"]["value"];
    mvp = map["stats"]["mvps"]["value"] == 1;
    iconUrl = map["stats"]["rating"]["metadata"]["iconUrl"];
    tier = map["stats"]["rating"]["metadata"]["tier"];
    division = map["stats"]["rating"]["metadata"]["division"];
    ratingDelta = map["stats"]["rating"]["metadata"]["ratingDelta"];
    mmr = map["stats"]["rating"]["value"];

    result = capitalize(result.replaceAll("victory", "win"));
  }
}

class PlaylistRank {
  bool display = true;
  String type;
  String name;
  int mmr;
  String tierIcon;
  String tierName;
  String divisionName;
  int divDown;
  int divUp;
  PlaylistRank(Map<String, dynamic> map) {
    type = map["type"];
    if (type != "playlist") {
      display = false;
      return;
    }
    name = map["metadata"]["name"];

    mmr = map["stats"]["rating"]["value"];

    tierIcon = map["stats"]["tier"]["metadata"]["iconUrl"];
    tierName = map["stats"]["tier"]["metadata"]["name"];
    divisionName = map["stats"]["division"]["metadata"]["name"];
    divDown = map["stats"]["division"]["metadata"]["deltaDown"];
    divUp = map["stats"]["division"]["metadata"]["deltaUp"];
  }
}

String capitalize(String string) {
  return string.split(" ").map((x) => capitalizeFirstLetter(x)).join((" "));
}

String capitalizeFirstLetter(String string) {
  if (string.length > 1)
    return string[0].toUpperCase() + string.substring(1).toLowerCase();
  if (string.length == 1) return string.toUpperCase();
  return "";
}
