import 'package:RLRank/providers/adMobService.dart';
import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/sessionWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionsScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<TrackerData>(context);

    List<Widget> children = [];
    if (!prov.isLoading) {
      int count = 0;
      int listAdId = 0;

      for (var session in prov.sessions) {
        children.addAll(SessionWidget(session).getChildren());
        count += (session.matches.length + 1);
        if (count > 10) {
          count = 0;
          children.add(AdMobService.nativeAd(
            "ad after session ${listAdId++}",
            full: true,
          ));
        }
      }
    }

    // AppBar appbar = AppBar(
    //   title: Text("Sessions"),
    //   backgroundColor: Color(0xff041d59),
    // );
    // var mq = MediaQuery.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xff001538),
      // appBar: appbar,
      floatingActionButton: prov.disconnectedIcon(scaffoldKey: scaffoldKey),
      body: RefreshIndicator(
        onRefresh: () => prov.refresh(context),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text("Sessions"),
              backgroundColor: Color(0xff041d59),
              floating: true,
            ),
            new SliverList(
              delegate: new SliverChildBuilderDelegate(
                (ctx, index) => children.elementAt(index),
                addAutomaticKeepAlives:  true,
                addRepaintBoundaries: true,
                childCount: children.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
