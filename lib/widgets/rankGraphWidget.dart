// import 'dart:math';
// import 'dart:ui' as ui;
// import 'dart:math';

import 'package:RLRank/providers/trackerData.dart';
// import 'package:RLRank/widgets/rankGraphLineChart.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RankGraphWidget extends StatelessWidget {
  final PlaylistRank rank;
  final bool isPortrait;
  final Widget Function(
    List<TierGraphPoint> chartData,
    List<TierData> tierData,
  ) getLineChart;
  final Widget Function(
    List<TierCount> tierDistributions,
  ) getDistributionChart;
  RankGraphWidget(
    this.rank, {
    @required this.getLineChart,
    @required this.getDistributionChart,
    @required this.isPortrait,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: FutureBuilder(
        future: rank.getChartData(),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text("none");
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return Text("active");
            case ConnectionState.done:
              if (snapshot.error != null)
                return AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Provider.of<TrackerData>(context, listen: false)
                            .disconnectedIcon(heroTag: null),
                        Text("Could not reach tracker"),
                      ],
                    ),
                  ),
                );
              List<TierGraphPoint> chartData =
                  (snapshot.data as PlaylistRank).chartData;
              List<TierData> tierDatas =
                  (snapshot.data as PlaylistRank).allTierDatas;

              return isPortrait
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        getLineChart(chartData, tierDatas),
                        SizedBox(height: 50),
                        getDistributionChart(rank.tierDistributions),
                      ],
                    )
                  : getLineChart(chartData, tierDatas);
          }
          return null;
        },
      ),
    );
  }
}
