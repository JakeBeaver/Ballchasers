import 'package:RLRank/providers/adMobService.dart';
import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/sessionWidget.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionsScreen extends StatefulWidget {
  @override
  _SessionsScreenState createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  DateTime lastRefresh = DateTime.fromMicrosecondsSinceEpoch(0);
  List<Widget> children = [];
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<TrackerData>(context);
    if (prov.lastRefresh.isAfter(lastRefresh)) {
      children = [];
      if (!prov.isLoading) {
        this.lastRefresh = DateTime.now();
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
    }
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      floatingActionButton: prov.disconnectedIcon(scaffoldKey: scaffoldKey),
      body: RefreshIndicator(
        onRefresh: () => prov.refresh(context),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text("Sessions"),
              backgroundColor: AppColors.appBar,
              floating: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, index) => children.elementAt(index),
                childCount: children.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
