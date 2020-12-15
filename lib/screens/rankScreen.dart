import 'package:RLRank/providers/trackerData.dart';
// import 'package:RLRank/widgets/rankGraphDistributionsWidget.dart';
// import 'package:RLRank/widgets/rankGraphLineChartWidget.dart';
import 'package:RLRank/widgets/rankGraphWidget.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RankScreen extends StatefulWidget {
  @override
  _RankScreenState createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  static const double arrowWidth = 45;
  DateTime lastRefresh = DateTime.fromMillisecondsSinceEpoch(0);
  List<Widget> children;
  AppBar appbar;
  PlaylistRank rank;
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<TrackerData>(context);

    if (prov.lastRefresh.isAfter(lastRefresh)) {
      String rankName = ModalRoute.of(context).settings.arguments;
      rank = prov.playlistRanks.firstWhere((x) => x.name == rankName);

      children = <Widget>[
        Center(
            child: Text(
          rank.tierName + "\n" + rank.divisionName,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        )),
        SizedBox(height: 20),
        Center(
            child: Text("MMR: " + rank.mmr.toString(),
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
        Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (rank.divUp != null)
              Row(
                children: [
                  iconUp(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      iconUp(visible: false),
                      Text(
                        rank.divUp?.toString() ?? "",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            if (rank.divUp != null && rank.divDown != null)
              SizedBox(width: arrowWidth),
            if (rank.divDown != null)
              Row(
                // alignment: Alignment.bottomCenter,
                children: [
                  iconDown(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      iconDown(visible: false),
                      Text(rank.divDown?.toString() ?? "",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
          ]),
        ),
      ];

      appbar = AppBar(
        title: Text(rank.name),
        backgroundColor: AppColors.appBar,
      );
      lastRefresh = DateTime.now();
    }
    var mq = MediaQuery.of(context);

    var icon = Container(
      child: Opacity(
        opacity: 0.4,
        child: Align(
          heightFactor: mq.orientation == Orientation.portrait ? 0.8 : 1,
          widthFactor: mq.orientation == Orientation.portrait ? 0.8 : 1,
          child: Hero(
              tag: "icon_" + rank.name,
              child: CachedNetworkImage(
                  placeholder: (c, a) => const CircularProgressIndicator(),
                  imageUrl: rank.tierIcon)),
        ),
      ),
    );

    bool isPortraitList = mq.size.aspectRatio < 1.5;

    var iconGraphStack = RankGraphWidget(
      rank,
      isPortrait: isPortraitList,
      icon: icon,
    );

    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: prov.disconnectedIcon(scaffoldKey: scaffoldKey),
      backgroundColor: AppColors.background,
      appBar: appbar,
      body: RefreshIndicator(
        onRefresh: () => prov.refresh(context),
        child: isPortraitList
            ? ListView(
                children: [
                  const SizedBox(height: 20),
                  ...children,
                  iconGraphStack,
                ],
              )
            : Center(
                child: SingleChildScrollView(
                  child: Container(
                    height: mq.size.height -
                        mq.viewInsets.top -
                        mq.viewPadding.top -
                        mq.viewPadding.bottom -
                        mq.viewInsets.bottom -
                        appbar.preferredSize.height +
                        0.001,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FittedBox(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: children),
                          ),
                          iconGraphStack
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget iconUp({bool visible = true}) =>
      iconDown(visible: visible, isUp: true);

  Widget iconDown({bool visible = true, bool isUp = false}) {
    var color = isUp ? Colors.green : Colors.red;
    return Container(
      // decoration: BoxDecoration(border: Border.all(color: Colors.white)),
      width: arrowWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          smallIcon(
            isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: color.withOpacity(visible ? 1 : 0),
            size: 80,
          ),
        ],
      ),
    );
  }

  Widget smallIcon(IconData icon, {Color color, double size}) {
    return Text(
      String.fromCharCode(icon.codePoint),
      textAlign: TextAlign.center,
      style: TextStyle(
          fontFamily: Icons.details.fontFamily,
          package: Icons.details.fontPackage,
          fontSize: size,
          color: color),
    );
  }
}
