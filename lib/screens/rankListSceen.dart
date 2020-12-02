import 'dart:ui';

import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/playerListDrawer.dart';
import 'package:RLRank/widgets/rankWidget.dart';
import 'package:RLRank/widgets/sessionWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RankListScreen extends StatefulWidget {
  @override
  _RankListScreenState createState() => _RankListScreenState();
}

class _RankListScreenState extends State<RankListScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  bool helping = false;

  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<TrackerData>(context);
    if (prov.player == null) {
      prov.refresh(context);
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Scaffold(
          key: scaffoldKey,
          floatingActionButton: prov.disconnectedIcon(scaffoldKey),
          drawer: PlayerListDrawer(),
          backgroundColor: Color(0xff001538),
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.help_outline),
                onPressed: () {
                  setState(() {
                    helping = true;
                  });
                },
              )
            ],
            title:
                Text(prov.player?.handle ?? prov.player?.name ?? "loading..."),
            leading: prov.player.picUrl == null
                ? CircularProgressIndicator()
                : GestureDetector(
                    child: ClipOval(
                      child: CachedNetworkImage(
                          placeholder: (c, a) => CircularProgressIndicator(),
                          imageUrl: prov.player.picUrl),
                    ),
                    onTap: prov.isLoading
                        ? null
                        : () {
                            scaffoldKey.currentState.openDrawer();
                          },
                  ),
            backgroundColor: Color(0xff041d59),
          ),
          body: RefreshIndicator(
            onRefresh: () => prov.refresh(context),
            child: prov.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    shrinkWrap: true,
                    children: [
                      if (prov.playlistRanks != null)
                        ...prov.playlistRanks
                            .map((x) => RankWidget(x))
                            .toList(),
                      if ((prov.sessions?.length ?? 0) > 0)
                        SizedBox(height: 20),
                      if ((prov.sessions?.length ?? 0) > 0)
                        SessionWidget(prov.sessions[0]),

                      // ...prov.sessions
                      //     .map((session) => SessionWidget(session))
                      //     .toList(),

                      if ((prov.sessions?.length ?? 0) > 1)
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          height: 50,
                          child: RaisedButton(
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(18.0)),
                            color: Color(0xff123280),
                            child: Text("View More Sessions"),
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pushNamed("sessions");
                            },
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        // if (helping)
        IgnorePointer(
          ignoring: !helping,
          child: GestureDetector(
            onVerticalDragDown: (_) {
              setState(() {
                helping = false;
              });
            },
            child: AnimatedOpacity(
              opacity: helping ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Scaffold(
                  backgroundColor: Colors.black.withOpacity(.2),
                  appBar: AppBar(
                    backgroundColor: Colors.black.withOpacity(0),
                    leading: Stack(
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                              placeholder: (c, a) =>
                                  CircularProgressIndicator(),
                              imageUrl: prov.player.picUrl),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border:
                                Border.all(color: Color(0xffab9745), width:5),
                          ),
                        ),
                      ],
                    ),
                    title: helpText("Tap for players list"),
                  ),
                  body: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Color(0xffab9745), width: 5)),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        helpText("Pull down to refresh", 20),
                        Icon(Icons.arrow_downward,
                            color: Color(0xffab9745), size: 140),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget helpText(String text, [double adjustSize = 0]) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20 + adjustSize,
        fontWeight: FontWeight.bold,
        color: Color(0xffab9745),
      ),
    );
  }

  anyGestureDetector({Widget child, void Function() onGesture}) {
    return GestureDetector(
      child: child,
      onTap: onGesture,
      onVerticalDragStart: (_) => onGesture(),
    );
  }
}
