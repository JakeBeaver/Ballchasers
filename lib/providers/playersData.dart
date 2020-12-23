import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class PlayersData with ChangeNotifier {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/players.txt');
  }

  List<Player> _data = [];
  List<Player> get data => [..._data];

  bool ready = false;
  PlayersData() {
    _loadData().then((_) {
      ready = true;
      notifyListeners();
    });
  }

  Player get lastUsedPlayer {
    if (data.isEmpty) return null;
    var d = data;
    if (d.length > 1) d.sort((x, y) => y.lastUse.compareTo(x.lastUse));
    return d.first;
  }

  bool get hasPlayers => _data.length > 0;

  addOrUpdatePlayer(Player player) {
    _deletePlayer(player);
    _data.add(player);
    _data.sort((x, y) => x.handle.compareTo(y.handle));
    _saveData();
    notifyListeners();
  }

  Future removePlayer(Player player) async {
    _deletePlayer(player);
    await _saveData();
    notifyListeners();
  }

  _deletePlayer(Player player) {
    _data.removeWhere(
        (x) => x.platform == player.platform && x.name == player.name);
  }

  Future _saveData() async {
    var encoded = json.encode(_data.map((x) => x.toJson()).toList());
    final file = await _localFile;
    await file.writeAsString(encoded);
  }

  Future _loadData() async {
    final file = await _localFile;

    if (!await file.exists()) return;

    String contents = await file.readAsString();
    if (contents.isEmpty) return;
    var list = json.decode(contents) as List<dynamic>;
    _data = list.map((x) => Player.fromJson(x)).toList();
  }
}

enum Platform { psn, xbox, steam }

class Player {
  final String handle;
  final String name;
  final String picUrl;
  final Platform platform;
  DateTime _lastUse;

  DateTime get lastUse => _lastUse;

  Map<String, dynamic> distributionsBody;
  Map<String, dynamic> statsBody;
  Map<String, dynamic> sessionsBody;

  Player({
    @required this.platform,
    @required this.name,
    this.handle,
    this.picUrl,
    lastUse,
  }) {
    _lastUse = lastUse ?? DateTime.now();
  }

  String get nameForSearch {
    var lowerCaseName = name.toLowerCase();
    if (lowerCaseName.contains("steamcommunity.com/profiles/")) {
      return name
          .toLowerCase()
          .split("steamcommunity.com/profiles/")[1]
          .split("/")[0];
    }
    return lowerCaseName;
  }

  Map<String, dynamic> toJson() => {
        "handle": handle,
        "name": name,
        "picUrl": picUrl,
        "platform": platform.toString(),
        "lastUse": _lastUse.millisecondsSinceEpoch,
        "statsBody": json.encode(statsBody),
        "sessionsBody": json.encode(sessionsBody),
        "distributionsBody": json.encode(distributionsBody),
      };

  Player.fromJson(Map<String, dynamic> map)
      : name = map["name"],
        handle = map["handle"],
        picUrl = map["picUrl"],
        platform = Player.getPlatformFromString(map["platform"]),
        _lastUse = DateTime.fromMillisecondsSinceEpoch(map["lastUse"]),
        statsBody = json.decode(map["statsBody"] ?? "{}"),
        sessionsBody = json.decode(map["sessionsBody"] ?? "{}"),
        distributionsBody = json.decode(map["distributionsBody"] ?? "{}");

  static Platform getPlatformFromString(String platformString) {
    for (Platform element in Platform.values) {
      if (element.toString() == platformString) {
        return element;
      }
    }
    return null;
  }
}
