import 'package:RLRank/methods/graphMethods.dart';
import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/rankGraphLineChartWidget.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RankGraphDistributions extends StatelessWidget {
  final List<TierCount> tierDistributions;
  final String currentTier;
  RankGraphDistributions(this.tierDistributions, this.currentTier);

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
    tierDistributions.sort(
      (a, b) =>
          ((getTierOrdinalFromName(a.name) * 1000) + a.name.length) -
          ((getTierOrdinalFromName(b.name) * 1000) + b.name.length),
    );

    int total = 0;
    int unrankedCount = 0;
    Map<int, TierCount> ordered = {};
    for (var c in tierDistributions) {
      total += c.count;
      if (c.name == 'Unranked') {
        unrankedCount = c.count;
        continue;
      }
      int tierNumber = c.name.endsWith('I') ? c.name.split(' ').last.length : 0;
      ordered[getTierOrdinalFromName(c.name) * 10 - (2 - tierNumber)] = c;
    }
    var mq = MediaQuery.of(context);
    var nf = NumberFormat.compact();
    String numberString = nf.format(total).replaceAll(',', ' ');
    return total == unrankedCount
        ? Container()
        : Column(
            children: [
              SizedBox(height: 20),
              whiteTitle(
                  "Distribution of $numberString players tracked this season:",
                  textAlign: TextAlign.center),
              SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      barGroups: ordered.keys
                          .map(
                            (index) => getBarFromTier(
                                index, ordered[index], mq, currentTier),
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
                          getTitles: (value) {
                            var name = ordered[value].name;
                            if (name.endsWith(" II"))
                              name = name
                                  .split(" ")
                                  .where((x) => !x.endsWith("I"))
                                  .join(" ");
                            else if (!name.endsWith("I"))
                              name = name;
                            else
                              return "";
                            
                            if (name.contains(' '))
                              name = name.split(' ').map((x)=>x[0]).join('');
                            if (name == 'SL') return "SSL";  
                            return name;
                          },
                          rotateAngle: 20,
                          reservedSize: 30,
                          margin: 12,
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          // showOnTopOfTheChartBoxArea: true,
                          fitInsideHorizontally: true,
                          // fitInsideVertically: true,
                          maxContentWidth: 200,
                          tooltipBgColor: AppColors.tooltipbackground,
                          tooltipRoundedRadius: 20,
                          getTooltipItem: (
                            BarChartGroupData group,
                            int groupIndex,
                            BarChartRodData rod,
                            int rodIndex,
                          ) {
                            return BarTooltipItem(
                              "${ordered[group.x].name}" +
                                  "\n${rod.y.round()} players" +
                                  "\n${(rod.y / total * 100 * 1000).round() / 1000}%",
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
              ),
            ],
          );
  }

  BarChartGroupData getBarFromTier(
    int index,
    TierCount tier,
    MediaQueryData mq,
    String currentTier,
  ) {
    double y = (tier.count ?? 0).toDouble();
    bool isCurrent = tier.name == currentTier;
    return BarChartGroupData(
      x: index,
      barsSpace: 0,
      barRods: [
        BarChartRodData(
          y: y,
          width: (mq.size.width - 120) / 22,
          colors: [
            addOpacity(getTierColorByName(tier.name), isCurrent ? 1 : 0.5)
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }
}
