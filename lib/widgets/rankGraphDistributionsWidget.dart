import 'package:RLRank/methods/graphMethods.dart';
import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/rankGraphLineChartWidget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RankGraphDistributions extends StatelessWidget {
  final List<TierCount> tierDistributions;
  RankGraphDistributions(this.tierDistributions);

  @override
  Widget build(BuildContext context) {
    List<TierCount> aggregated = [];
    for (var c in tierDistributions) {
      var aggName = c.name
          .split(' ')
          .where(
            (x) => !x.endsWith("I"),
          )
          .join(' ');
      int index = aggregated.indexWhere((x) => x.name == aggName);
      if (index == -1) {
        aggregated.add(TierCount(aggName, c.count));
      } else {
        var existing = aggregated[index];
        aggregated[index] = TierCount(aggName, c.count + existing.count);
      }
    }
    
    aggregated.sort(
      (a, b) => getTierOrdinalFromName(a.name) - getTierOrdinalFromName(b.name),
    );

    int total = 0;

    Map<int, TierCount> ordered = {};
    for (var c in aggregated) {
      total += c.count;
      if (c.name == 'Unranked') continue;
      ordered[getTierOrdinalFromName(c.name)] = c;
    }
    return AspectRatio(
      aspectRatio: 3,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: BarChart(
          BarChartData(
            gridData: FlGridData(
              show: true,
              checkToShowHorizontalLine: (value) => value % 5 == 0,
              getDrawingHorizontalLine: (value) {
                if (value == 0) {
                  return FlLine(color: const Color(0xff363753), strokeWidth: 3);
                }
                return FlLine(
                  color: const Color(0xff2a2747),
                  strokeWidth: 0.8,
                );
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: ordered.keys
                .map(
                  (index) => getBarFromTier(index, ordered[index]),
                )
                .toList(),
            titlesData: FlTitlesData(
              leftTitles: SideTitles(),
              bottomTitles: SideTitles(
                showTitles: true,
                getTextStyles: (value) => TextStyle(
                  fontSize: 10,
                  color: getTierColorByName(ordered[value].name),
                ),
                getTitles: (value) => ordered[value].name,
                rotateAngle: 20,
                reservedSize: 30,
                margin: 12,
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                // showOnTopOfTheChartBoxArea: true,
                // fitInsideHorizontally: true,
                // fitInsideVertically: true,
                maxContentWidth: 200,
                tooltipBgColor: Color(0xbb041d59),
                tooltipRoundedRadius: 20,
                getTooltipItem: (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  return BarTooltipItem(
                    "${rod.y.round()} (${(rod.y/total*100 * 1000).round()/1000}%)",
                    // rod.y.round().toString(),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData getBarFromTier(int index, TierCount tier) {
    double y = (tier.count ?? 0).toDouble();
    return BarChartGroupData(
      x: index,
      barsSpace: 0,
      barRods: [
        BarChartRodData(
          y: y,
          width: 20,
          colors: [addOpacity(getTierColorByName(tier.name), 0.9)],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }
}
