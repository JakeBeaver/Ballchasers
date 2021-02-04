import 'dart:ui';
import 'package:RLRank/providers/adMobService.dart';

import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/playerListDrawer.dart';
import 'package:RLRank/widgets/rankWidget.dart';
import 'package:RLRank/widgets/seasonRewardTileWidget.dart';
import 'package:RLRank/widgets/sessionWidget.dart';
import 'package:RLRank/widgets/textWidgets.dart';
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
    var mq = MediaQuery.of(context);
    if (prov.player == null) {
      prov.refresh(context);
    }
    var listViewChildren = [
      if (prov.seasonReward != null) SeasonRewardTile(prov.seasonReward),
      if (prov.playlistRanks != null)
        if (mq.orientation == Orientation.portrait)
          ...prov.playlistRanks.map((x) => RankWidget(x)).toList()
        else
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: prov.playlistRanks.map((x) => RankWidget(x)).toList(),
          ),
      // if ((prov.sessions?.length ?? 0) > 0)
      //   SizedBox(height: 20),
      AdMobService.nativeAd(context, "rank list screen ad"),
      if (prov.sessionsLoadingError)
        if (!prov.offline) redTitle("Provider error\nShowing cached sessions"),
      if ((prov.sessions?.length ?? 0) > 0)
        ...SessionWidget(prov.sessions[0], prov.sessionsLoadingError)
            .getChildren(),

      // ...prov.sessions
      //     .map((session) => SessionWidget(session))
      //     .toList(),
      if ((prov.sessions?.length ?? 0) > 1)
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          height: 50,
          child: RaisedButton(
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(18.0)),
            color: AppColors.button,
            child: const Text("View More Sessions"),
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pushNamed("sessions");
            },
          ),
        ),
    ];
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Scaffold(
          key: scaffoldKey,
          floatingActionButton: prov.disconnectedIcon(scaffoldKey: scaffoldKey),
          drawer: const PlayerListDrawer(),
          backgroundColor: AppColors.background,
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => Navigator.of(context).pushNamed("about"),
              ),
              IconButton(
                icon: Icon(Icons.help_outline),
                onPressed: () {
                  setState(() {
                    helping = true;
                  });
                },
              ),
            ],
            title: Text(prov.player?.handle ?? prov.player?.name ?? ""),
            leading: prov.player == null
                ? const CircularProgressIndicator()
                : GestureDetector(
                    child: ClipOval(
                      child: prov.player.picUrl == null
                          ? prov.player.defaultProfileIcon
                          : CachedNetworkImage(
                              placeholder: (c, a) =>
                                  CircularProgressIndicator(),
                              imageUrl: prov.player.picUrl),
                    ),
                    onTap: prov.isLoading
                        ? null
                        : () {
                            scaffoldKey.currentState.openDrawer();
                          },
                  ),
            backgroundColor: AppColors.appBar,
          ),
          body: RefreshIndicator(
            onRefresh: () => prov.refresh(context),
            child: prov.isLoading
                ? loadingData()
                : ListView.builder(
                    itemBuilder: (ctx, index) =>
                        listViewChildren.elementAt(index),
                    itemCount: listViewChildren.length,
                    // children: listViewChildren,
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
                          child: prov.player?.picUrl == null
                              ? CircularProgressIndicator()
                              : CachedNetworkImage(
                                  placeholder: (c, a) =>
                                      CircularProgressIndicator(),
                                  imageUrl: prov.player?.picUrl),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border:
                                Border.all(color: AppColors.helpText, width: 5),
                          ),
                        ),
                      ],
                    ),
                    title: helpText("Tap for players list"),
                  ),
                  body: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border:
                            Border.all(color: AppColors.helpText, width: 5)),
                    alignment: Alignment.center,
                    child: FittedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          helpText("Pull down\nto refresh", 20),
                          const Icon(Icons.arrow_downward,
                              color: AppColors.helpText, size: 140),
                        ],
                      ),
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

  Widget loadingData() => Center(
        child: FittedBox(
          child: Column(
            children: [
              Container(
                  height: 150,
                  child: Image.asset(
                      'assets/BallChasersLogo_transparentBackground.png')),
              SizedBox(height: 20),
              Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text(
                    "Fetching provider data...",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      );

  Widget helpText(String text, [double adjustSize = 0]) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20 + adjustSize,
        fontWeight: FontWeight.bold,
        color: AppColors.helpText,
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
