import 'dart:math';
// import 'dart:ui' as ui;
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

              if (chartData.isEmpty) return Text("nope");
              var days = chartData.length;
              var daysToShow = 5;
              const double msPerDay = 86400000;
              List<double> ys = (chartData).map((x) => x.spot.y).toList();
              var minDataPoint = ys.reduce(min);
              var maxDataPoint = ys.reduce(max);
              var interval = msPerDay * ((days / daysToShow).floor());
              double minY = minDataPoint * .8;

              double maxY = tierDatas.isEmpty ||
                      maxDataPoint > tierDatas.last.minMMR
                  ? maxDataPoint
                  : min(maxDataPoint * 1.2, tierDatas.last.minMMR.toDouble());
              if (interval == 0) interval = msPerDay;

              List<TierData> tierDatasAggregated = [];
              for (TierData tier in tierDatas) {
                var tierInList =
                    tierDatasAggregated.any((x) => tier.tier == x.tier)
                        ? tierDatasAggregated
                            .singleWhere((x) => tier.tier == x.tier)
                        : null;
                if (tierInList == null) {
                  tierDatasAggregated.add(TierData.copyFrom(tier,
                      division: "All divisions aggregated"));
                } else {
                  tierInList.maxMMR = max(tierInList.maxMMR, tier.maxMMR);
                  tierInList.minMMR = min(tierInList.minMMR, tier.minMMR);
                }
              }
              return LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    getTouchedSpotIndicator: (barData, spotIndexes) =>
                        spotIndexes
                            .map((i) => TouchedSpotIndicatorData(
                                  FlLine(color: barData.colors[i]),
                                  FlDotData(),
                                ))
                            .toList(),
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
                            getTooltipTitle(chartData, lineBarSpot),
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
                  extraLinesData: ExtraLinesData(
                    extraLinesOnTop: false,
                    horizontalLines: tierDatasAggregated
                        .where((x) => x.maxMMR > minY && x.minMMR < maxY && x.tier != "Unranked")
                        .map((x) => tierTitleText(
                              max(x.minMMR.toDouble(), minY),
                              x.tier,
                              // x.pic,
                            ))
                        .toList(),
                  ),
                  rangeAnnotations: RangeAnnotations(
                    horizontalRangeAnnotations: tierDatasAggregated
                        .where((x) => x.minMMR < maxY && x.maxMMR > minY && x.tier != "Unranked")
                        .map(
                          (x) => HorizontalRangeAnnotation(
                            y1: max(minY, x.minMMR.toDouble()),
                            y2: min(maxY, x.maxMMR.toDouble()),
                            color: addOpacity(
                                getTierColorByName(x.maxMMR, x.tier), 0.5),
                          ),
                        )
                        .toList(),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: true,
                    verticalInterval: interval,
                    getDrawingVerticalLine: (val) => FlLine(
                      strokeWidth: 0.25,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    drawHorizontalLine: false,
                    // horizontalInterval: 1,
                    // getDrawingHorizontalLine: (val) => FlLine(
                    //   strokeWidth: 0, //(maxY - minY) / 90,
                    //   // strokeWidth:
                    //   //     getTier(tierDatas, val.toInt())?.division ==
                    //   //             "Division I"
                    //   //         ? 1
                    //   //         : 0.25,
                    //   color: addOpacity(
                    //       getSplitColor(tierDatas, val.toInt()), 0.3),
                    // ),
                  ),
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: false,
                    ),
                    bottomTitles: SideTitles(
                        interval: interval,
                        margin: 10,
                        showTitles: true,
                        rotateAngle: 45,
                        reservedSize: 20,
                        getTextStyles: (value) => const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
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

  HorizontalLine tierTitleText(
    double y,
    String title,
    // ui.Image pic,
  ) {
    return HorizontalLine(
      // image: pic,
      y: y,
      color: Colors.transparent,
      strokeWidth: 0,
      label: HorizontalLineLabel(
        show: true,
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.only(left: 5, bottom: 0),
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        labelResolver: (line) => title,
      ),
    );
  }

  LineChartBarData data(List<TierGraphPoint> data) {
    var spots = data.map((x) => x.spot).toList();
    var colors = data.map((x) => getTierColorByName(x.mmr, x.tier)).toList();
    double min = spots.first.x;
    double max = spots.last.x;
    double range = max - min;
    var stops = spots.map((x) => (x.x - min) / range).toList();
    return LineChartBarData(
      spots: spots,
      colors: colors,
      colorStops: stops,
      shadow: const Shadow(
        blurRadius: 8,
        color: Colors.black,
      ),
      isCurved: data.length < 30,
      curveSmoothness: 0.2,
      dotData: FlDotData(show: data.length < 30),
    );
  }

  Color addOpacity(Color color, double opacity) {
    if (color == Colors.transparent) return color;
    return color.withOpacity(opacity);
  }

  Color getSplitColor(List<TierData> tiers, int value) {
    var name = getSplitName(tiers, value);
    return getTierColorByName(value, name);
  }

  Color getTierColorByName(int value, String name) {
    if (name == null) return Colors.transparent;
    switch (name.split(' ')[0]) {
      case ("Unranked"):
        return const Color(0xffe58517);
      case ("Bronze"):
        return const Color(0xffa5600d);
      case ("Silver"):
        return const Color(0xff949493);
      case ("Gold"):
        return const Color(0xffc6961b);
      case ("Platinum"):
        return const Color(0xff48bbe9);
      case ("Diamond"):
        return const Color(0xff0061e1);
      case ("Champ"):
        return const Color(0xff916ec8);
      case ("Grand"):
        return const Color(0xfffe6386);
      case ("Supersonic"):
        return const Color(0xfff7f2f6);
    }
    return Colors.transparent;
  }

  String getSplitName(
    List<TierData> tiers,
    int value, {
    bool onlyMiddle = false,
  }) {
    var tier = getTier(tiers, value);
    if (onlyMiddle) {
      if (tier == null) return null;
      // var allThisTier = tiers.where((x) => x.tier == tier.tier);
      // int minMMR = tier.map((x) => x.minMMR).reduce(min);
      // int maxMMR = tier.map((x) => x.maxMMR).reduce(max);
      var averageMMR = ((tier.maxMMR + tier.minMMR) / 2).floor();
      if (tier.tier.startsWith("Grand") &&
          averageMMR - 4 < value &&
          averageMMR + 4 > value) {
        print(averageMMR);
      }
      if (averageMMR != value) return null;
    }
    return tier?.tier;
  }

  TierData getTier(List<TierData> tiers, int value) {
    var tier = tiers.firstWhere(
      (x) => x.minMMR <= value && x.maxMMR >= value,
      orElse: () => null,
    );
    return tier;
  }

  String getTooltipTitle(
    List<TierGraphPoint> data,
    LineBarSpot lineBarSpot,
  ) {
    // var maxMMR = tiers.last.maxMMR;
    var tier = data.firstWhere(
      (x) => x.collectionDateMillisecondsSinceEpoch == lineBarSpot.x.toInt(),
      orElse: () => null,
    );

    var date = DateTime.fromMillisecondsSinceEpoch(lineBarSpot.x.toInt());
    final tf = DateFormat("d MMM ''yy");
    var formattedDate = tf.format(date);

    var mmr = lineBarSpot.y.toInt();
    // print("mmr: $mmr, tier: $tier");
    return "$formattedDate\nRating: $mmr\n${tier?.tier} ${tier?.division}";
  }
}
