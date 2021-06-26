import 'package:RLRank/providers/playersData.dart';
import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPlayerScreen extends StatefulWidget {
  @override
  _AddPlayerScreenState createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  Platform currentPlatform = Platform.psn;
  setPlatform(Platform platform) {
    setState(() {
      this.currentPlatform = platform;
    });
  }

  final nameController = TextEditingController();
  final snackBar = SnackBar(
      backgroundColor: Colors.red[800],
      content: Text(
        "User not found or can't reach tracker server.",
        textAlign: TextAlign.center,
      ));
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  bool finding = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Add New Player"),
        backgroundColor: AppColors.appBar,
      ),
      body: finding
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Choose platform",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          getPlatformButton("PSN", Platform.psn),
                          getPlatformButton("Xbox", Platform.xbox),
                          getPlatformButton("Steam", Platform.steam),
                          getPlatformButton("Epic", Platform.epic),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        prompt,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          fillColor: AppColors.appBar,
                          filled: true,
                        ),
                        controller: nameController,
                      ),
                      if (currentPlatform == Platform.epic) ...[
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            "Tracker.Network\ndoes not currently allow\nthird party apps\nto fetch stats from Epic.\n\nSorry for the inconvenience.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      SizedBox(height: 20),
                      RaisedButton(
                        child: Text("Add"),
                        onPressed: () async {
                          try {
                            setState(() {
                              finding = true;
                            });
                            await Provider.of<TrackerData>(context,
                                    listen: false)
                                .setPlayer(
                              Player(
                                  name: nameController.text,
                                  platform: currentPlatform),
                              context,
                              revertIfFailed: true,
                            );
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          } catch (ex) {
                            scaffoldKey.currentState.hideCurrentSnackBar();
                            scaffoldKey.currentState.showSnackBar(snackBar);
                            setState(() {
                              finding = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  RaisedButton getPlatformButton(String name, Platform platform) {
    return RaisedButton(
      color: this.currentPlatform == platform
          ? AppColors.deepBlue
          : Colors.blueGrey[800],
      textColor: Colors.white,
      child: Text(name),
      onPressed: () => setPlatform(platform),
    );
  }

  String get prompt {
    switch (currentPlatform) {
      case Platform.psn:
        return "Provide PlayStation Network Account Name";
      case Platform.xbox:
        return "Provide Xbox Live Account Name";
      case Platform.steam:
        return "Provide Steam ID or SteamCommunity.com profile url";
      case Platform.epic:
        return "Provide Epic Account Name";
      default:
        return "";
    }
  }
}
