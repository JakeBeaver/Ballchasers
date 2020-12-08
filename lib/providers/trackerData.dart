import 'dart:convert';

import 'package:RLRank/providers/playersData.dart';
import 'package:fl_chart/fl_chart.dart';
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
    if (player == null) return;
    _statsBody = player.statsBody;
    _sessionsBody = player.sessionsBody;
    bool failed = false;
    try {
      await Future.wait([
        fetchStats(),
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
      var playerId = _statsBody["data"]["metadata"]["playerId"];
      var segments = _statsBody["data"]["segments"] as List<dynamic>;
      playlistRanks = segments
          .map<PlaylistRank>((e) => PlaylistRank(e, playerId: playerId))
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

  Widget disconnectedIcon({
    GlobalKey<ScaffoldState> scaffoldKey,
    String heroTag = "Disconnected Button Hero Tag",
  }) {
    return offline
        ? FloatingActionButton(
            heroTag: heroTag,
            elevation: 0,
            splashColor: Colors.black.withOpacity(0),
            backgroundColor: Colors.black.withOpacity(0),
            child: Image(image: AssetImage("assets/disconnected.png")),
            onPressed: scaffoldKey == null
                ? null
                : () {
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
  bool get isMvp => mvps > 0;
  String iconUrl;
  String tier;
  String division;
  int ratingDelta;
  int mmr;
  int mvps;
  bool get isMultipleMatches => matches > 1;
  int matches;
  int wins;
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
    mvps = map["stats"]["mvps"]["value"];
    iconUrl = map["stats"]["rating"]["metadata"]["iconUrl"];
    tier = map["stats"]["rating"]["metadata"]["tier"];
    division = map["stats"]["rating"]["metadata"]["division"];
    ratingDelta = map["stats"]["rating"]["metadata"]["ratingDelta"];
    mmr = map["stats"]["rating"]["value"];
    matches = map["stats"]["matchesPlayed"]["value"];
    wins = map["stats"]["wins"]["value"];

    result = capitalize(result.replaceAll("victory", "win"));

    if (matches > 1 && wins == 1) {
      result = '1 Win';
    }
  }
}

class PlaylistRank {
  final int playerId;
  String _getMMRAddress() {
    return "https://api.tracker.gg/api/v1/rocket-league/player-history/mmr/$playerId/";
  }

  String _getDistributionAddress() {
    return "https://api.tracker.gg/api/v1/rocket-league/distribution/$playlistId";
  }

  int playlistId;
  bool display = true;
  String type;
  String name;
  int mmr;
  String tierIcon;
  String tierName;
  String divisionName;
  int divDown;
  int divUp;
  int matchesPlayed;
  int winStreak = 0;
  int lossStreak = 0;
  PlaylistRank(Map<String, dynamic> map, {this.playerId}) {
    type = map["type"];
    if (type != "playlist") {
      display = false;
      return;
    }

    matchesPlayed = map["stats"]["matchesPlayed"]["value"];
    if (matchesPlayed == 0) {
      display = false;
      return;
    }

    playlistId = map["attributes"]["playlistId"];

    name = map["metadata"]["name"];

    mmr = map["stats"]["rating"]["value"];

    tierIcon = map["stats"]["tier"]["metadata"]["iconUrl"];
    tierName = map["stats"]["tier"]["metadata"]["name"]
        .replaceAll("Champion", "Champ");
    divisionName = map["stats"]["division"]["metadata"]["name"]
        .replaceAll("Division", "Div");
    // divisionName.;
    divDown = map["stats"]["division"]["metadata"]["deltaDown"];
    divUp = map["stats"]["division"]["metadata"]["deltaUp"];
    int streak = map["stats"]["winStreak"]["value"];
    bool isWinStreak = map["stats"]["winStreak"]["metadata"]["type"] == 'win';
    if (isWinStreak) {
      winStreak = streak;
    } else {
      lossStreak = streak;
    }
  }

  List<TierData> topDivisionTierDatas;
  List<TierData> allTierDatas;
  List<FlSpot> chartData;

  Future<PlaylistRank> getChartData() async {
    await Future.wait([
      if (topDivisionTierDatas == null) _getDistributions(),
      if (chartData == null) _getChartData(),
    ]);
    return this;
  }

  Future _getDistributions() async {
    var address = _getDistributionAddress();
    final response = await http.get(address);
    var parsedResponse = json.decode(response.body) as Map<String, dynamic>;
    var tiers = parsedResponse["data"]["tiers"] as List<dynamic>;
    var divisions = parsedResponse["data"]["divisions"] as List<dynamic>;

    var distributions = parsedResponse["data"]["data"] as List<dynamic>;
    var newList = distributions
    .map(
      (x) => TierData(
        x,
        tiers,
        divisions,
      ),
    ).where((x)=>x.tier != "Unranked" ).toList();

    List<TierData> newerList = [];
    for (int i = 1; i < newList.length; i++){
      newList[i].minMMR = newList[i-1].maxMMR;
    }
    for (TierData d in newList) {
      if (newerList.isEmpty || newerList.last.tier != d.tier) {
        newerList.add(d);
      }
    }
    allTierDatas = newList.toList();
    topDivisionTierDatas = newerList;
  }

  Future _getChartData() async {
    var address = _getMMRAddress();
    final response = await http.get(address);
    var parsedResponse = json.decode(response.body) as Map<String, dynamic>;
    var playlistData = parsedResponse["data"]["$playlistId"] as List<dynamic>;
    int i = 0;
    var newData = playlistData
        .map((x) => FlSpot(
              (DateTime.parse(x["collectDate"])
                  .millisecondsSinceEpoch + i++)
                  .toDouble(),
              x["rating"].toDouble(),
            ))
        .toList();
    chartData = newData;
  }
}

class TierData {
  int minMMR;
  int maxMMR;
  String tier;
  String division;
  TierData(
    Map<String, dynamic> x,
    List<dynamic> tiers,
    List<dynamic> divisions,
  ) {
    minMMR = x["minMMR"];
    maxMMR = x["maxMMR"];
    tier = tiers[x["tier"]].replaceAll("Champion", "Champ");
    division = divisions[x["division"]];
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
