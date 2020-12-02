import 'package:RLRank/providers/trackerData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RankScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<TrackerData>(context);

    String rankName = ModalRoute.of(context).settings.arguments;
    PlaylistRank rank =
        prov.playlistRanks.firstWhere((x) => x.name == rankName);

    var children = <Widget>[
      Center(
          child: Text(
        rank.tierName + " " + rank.divisionName,
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
                    Text(rank.divUp?.toString() ?? "",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          
          if (rank.divUp != null && rank.divDown != null)
            SizedBox(width: 20),
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

    var icon = Container(
      child: Hero(
          tag: "icon_" + rank.name,
          child: CachedNetworkImage(
              placeholder: (c, a) => CircularProgressIndicator(),
              imageUrl: rank.tierIcon)),
    );
    AppBar appbar = AppBar(
      title: Text(rank.name),
      backgroundColor: Color(0xff041d59),
    );
    var mq = MediaQuery.of(context);
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: prov.disconnectedIcon(scaffoldKey),
      backgroundColor: Color(0xff001538),
      appBar: appbar,
      body: RefreshIndicator(
        onRefresh: () => prov.refresh(context),
        child: mq.orientation == Orientation.portrait
            ? ListView(children: [SizedBox(height: 20), ...children, icon])
            : Center(
                child: FittedBox(
                  child: SingleChildScrollView(
                    child: Container(
                      height: mq.size.height -
                          mq.viewInsets.top -
                          mq.viewPadding.top -
                          mq.viewPadding.bottom -
                          mq.viewInsets.bottom -
                          appbar.preferredSize.height +
                          1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          icon,
                          FittedBox(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: children),
                          )
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
      width: 45,
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
