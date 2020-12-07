import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/sessionWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionsScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    var prov = Provider.of<TrackerData>(context);
    // AppBar appbar = AppBar(
    //   title: Text("Sessions"),
    //   backgroundColor: Color(0xff041d59),
    // );
    // var mq = MediaQuery.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xff001538),
      // appBar: appbar,
      floatingActionButton: prov.disconnectedIcon(scaffoldKey),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("Sessions"),
            backgroundColor: Color(0xff041d59),
            floating: true,
          ),
          new SliverList(
            delegate: new SliverChildListDelegate(
              prov.sessions.map((session) => SessionWidget(session)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  RefreshIndicator getSessionsView(TrackerData prov, BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => prov.refresh(context),
      child: prov.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              shrinkWrap: true,
              children: [
                // ...prov.playlistRanks.map((x) => RankWidget(x)).toList(),
                // if (prov.sessions.length > 0)
                // SizedBox(height: 20),
                // if (prov.sessions.length > 0)
                // SessionWidget(prov.sessions[0], latest: true),

                ...prov.sessions
                    .map((session) => SessionWidget(session))
                    .toList(),
              ],
            ),
    );
  }
}
