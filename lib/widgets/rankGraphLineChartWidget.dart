import 'dart:math';

import 'package:RLRank/methods/graphMethods.dart';
import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RankGraphLineChart extends StatelessWidget {
  final List<TierGraphPoint> chartData;
  final List<TierData> tierDatas;
  RankGraphLineChart(this.chartData, this.tierDatas);

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) return Text("nope");
    var days = chartData.length;
    var daysToShow = 5;
    const double msPerDay = 86400000;
    List<double> ys = (chartData).map((x) => x.spot.y).toList();
    var minDataPoint = ys.reduce(min);
    var maxDataPoint = ys.reduce(max);
    var interval = msPerDay * ((days / daysToShow).floor());
    double minY = minDataPoint * .8;

    double maxY = tierDatas.isEmpty || maxDataPoint > tierDatas.last.minMMR
        ? maxDataPoint
        : min(maxDataPoint * 1.2, tierDatas.last.minMMR.toDouble());
    if (interval == 0) interval = msPerDay;

    List<TierData> tierDatasAggregated = [];
    for (TierData tier in tierDatas) {
      var tierInList = tierDatasAggregated.any((x) => tier.tier == x.tier)
          ? tierDatasAggregated.singleWhere((x) => tier.tier == x.tier)
          : null;
      if (tierInList == null) {
        tierDatasAggregated
            .add(TierData.copyFrom(tier, division: "All divisions aggregated"));
      } else {
        tierInList.maxMMR = max(tierInList.maxMMR, tier.maxMMR);
        tierInList.minMMR = min(tierInList.minMMR, tier.minMMR);
      }
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes
              .map((i) => TouchedSpotIndicatorData(
                    FlLine(color: barData.colors[i]),
                    FlDotData(),
                  ))
              .toList(),
          touchTooltipData: LineTouchTooltipData(
            // showOnTopOfTheChartBoxArea: true,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            maxContentWidth: 200,
            tooltipBgColor: AppColors.tooltipbackground,
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
          horizontalLines: [
            ...tierDatasAggregated
                .where((x) =>
                    x.maxMMR > minY && x.minMMR < maxY && x.tier != "Unranked")
                .map((x) => tierTitleText(
                      max(x.minMMR.toDouble(), minY),
                      x.tier,
                    ))
                .toList(),
            ...tierDatasAggregated
                .where((x) => x.tier != "Unranked")
                .fold<List<int>>(
                  [],
                  (output, tier) => [...output, tier.minMMR, tier.maxMMR],
                )
                .where((x) => x > minY && x < maxY)
                .map(
                  (e) => HorizontalLine(
                    y: e.toDouble(),
                    strokeWidth: 1,
                    color: Colors.white.withOpacity(0.05),
                  ),
                )
                .toList(),
          ],
        ),
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: tierDatasAggregated
              .where((x) =>
                  x.minMMR < maxY && x.maxMMR > minY && x.tier != "Unranked")
              .map(
                (x) => HorizontalRangeAnnotation(
                  y1: max(minY, x.minMMR.toDouble()),
                  y2: min(maxY, x.maxMMR.toDouble()),
                  color: addOpacity(getTierColorByName(x.tier), 0.5),
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
                var dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());

                return tf.format(dt);
              }),
        ),
      ),
    );
  }
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
  var colors = data.map((x) => getTierColorByName(x.tier)).toList();
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
  return "$formattedDate\nRating: $mmr\n${tier?.tier} ${tier?.division}";
}
