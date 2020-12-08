import 'dart:math';

import 'package:RLRank/providers/trackerData.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RankGraphWidget extends StatelessWidget {
  final PlaylistRank rank;
  RankGraphWidget(this.rank);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 10),
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
              List<FlSpot> chartData =
                  (snapshot.data as PlaylistRank).chartData;
              List<TierData> tierDatas =
                  (snapshot.data as PlaylistRank).allTierDatas;
              var days = chartData.length;
              var daysToShow = 5;
              const double msPerDay = 86400000;
              List<double> ys = (chartData).map((x) => x.y).toList();
              var minDataPoint = ys.reduce(min);
              var maxDataPoint = ys.reduce(max);
              var interval = msPerDay * ((days / daysToShow).floor());
              if (interval == 0) interval = msPerDay;
              return LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      showOnTopOfTheChartBoxArea: true,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      maxContentWidth: 200,
                      tooltipBgColor: Color(0xbb041d59),
                      tooltipRoundedRadius: 20,
                      getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                        return lineBarsSpot.map((lineBarSpot) {
                          return LineTooltipItem(
                            getTooltipTitle(tierDatas, lineBarSpot),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [data(chartData)],
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                      drawVerticalLine: false,
                      // verticalInterval: msPerDay,
                      drawHorizontalLine: true,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (val) => FlLine(
                          strokeWidth:
                              getTier(tierDatas, val.toInt())?.division ==
                                      "Division I"
                                  ? 1
                                  : 0.25,
                          color: getSplitColor(tierDatas, val.toInt()))),
                  minY: minDataPoint * .8,
                  maxY: maxDataPoint > tierDatas.last.minMMR
                      ? maxDataPoint
                      : min(
                          maxDataPoint * 1.2, tierDatas.last.minMMR.toDouble()),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      margin: 10,
                      interval: 1,
                      getTitles: (value) => getSplitName(
                          tierDatas, value.toInt(),
                          onlyFirstDivision: true),
                      getTextStyles: (value) => TextStyle(
                        color: getSplitColor(tierDatas, value.toInt()),
                        fontSize: 10,
                      ),
                    ),
                    bottomTitles: SideTitles(
                        interval: interval,
                        margin: 0,
                        showTitles: true,
                        rotateAngle: 90,
                        reservedSize: 12,
                        getTextStyles: (value) => const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                        getTitles: (value) {
                          final tf = DateFormat("d MMM ''yy");
                          var dt = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt());

                          return tf.format(dt);
                        }),
                  ),
                ),
              );
          }
          return null;
        },
      ),
    );
  }

  LineChartBarData data(List<FlSpot> data) => LineChartBarData(
        spots: data,
        colors: const [const Color(0xffe58517)],
        isCurved: true,
        dotData: FlDotData(show: data.length < 30),
      );

  Color getSplitColor(List<TierData> tiers, int value) {
    var name = getSplitName(tiers, value);
    if (name == null) return Colors.transparent;
    switch (name.split(' ')[0]) {
      case ("Brown"):
        return const Color(0xff834c0f);
      case ("Silver"):
        return const Color(0xff949493);
      case ("Gold"):
        return const Color(0xffc6961b);
      case ("Platinm"):
        return const Color(0xff42b7e8);
      case ("Diamond"):
        return const Color(0xff0794f8);
      case ("Champ"):
        return const Color(0xff916ec8);
      case ("Grand"):
        return const Color(0xffff5a5a);
      case ("Supersonic"):
        return Colors.white;
    }
    return Colors.transparent;
  }

  String getSplitName(
    List<TierData> tiers,
    int value, {
    bool onlyFirstDivision = false,
  }) {
    var tier = getTier(tiers, value, onlyFirstDivision: onlyFirstDivision);
    return tier?.tier;
  }

  TierData getTier(
    List<TierData> tiers,
    int value, {
    bool onlyFirstDivision = false,
  }) {
    var tier = tiers.firstWhere(
      (x) =>
          x.minMMR == value &&
          (!onlyFirstDivision || x.division == "Division I"),
      orElse: () => null,
    );
    return tier;
  }

  String getTooltipTitle(
    List<TierData> tiers,
    LineBarSpot lineBarSpot,
  ) {
    var mmr = lineBarSpot.y.toInt();
    var date = DateTime.fromMillisecondsSinceEpoch(lineBarSpot.x.toInt());

    final tf = DateFormat("dd/MM/yyyy");
    var formattedDate = tf.format(date);
    var maxMMR = tiers.last.maxMMR;
    var tier = tiers.firstWhere(
      (x) => x.minMMR <= mmr && (x.maxMMR == maxMMR || x.maxMMR >= mmr),
      orElse: () => null,
    );

    print("mmr: $mmr, tier: $tier");
    return "$formattedDate\nRating: $mmr\n${tier?.tier} ${tier?.division}";
  }
}
