import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchWidget extends StatelessWidget {
  final Match match;
  final bool offline;
  MatchWidget(this.match, this.offline);

  final tf = DateFormat('HH:mm');
  @override
  Widget build(BuildContext context) {
    final nOfMatches = match.matches;
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: offline ? Colors.red[800] : Colors.grey[700],
        ),
      ),
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              blueTitle(
                nOfMatches.toString() +
                    (nOfMatches == 1 ? " Match" : " Matches"),
                sizeAdjust: 1,
              ),
              whiteTitle(
                " - " + tf.format(match.dateCollected.toLocal()),
                sizeAdjust: -3,
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: <Widget>[
              matchListTile(
                title: Row(
                  children: [
                    whiteTitle(match.result),
                    if (match.isMvp)
                      goldTitle(
                          " ${match.matches > 1 ? (match.mvps.toString() + ' ') : ''}MVP")
                  ],
                ),
                subtitle: blueTitle(match.playlist),
              ),
              matchListTile(
                leading: match.iconUrl == null
                    ? null
                    : CachedNetworkImage(
                        placeholder: (c, a) => CircularProgressIndicator(),
                        imageUrl: match.iconUrl,
                      ),
                title: Row(
                  children: <Widget>[
                    if (match.mmr != null) whiteTitle(match.mmr.toString()),
                    if (match.mmr != null) gainWidget(match.ratingDelta),
                  ],
                ),
                subtitle:
                    match.division == null ? null : blueTitle(match.division),
              ),
              matchListTile(
                title: blueTitle("Goals / Shots"),
                subtitle: Row(
                  children: [
                    whiteTitle(match.goals.toString() +
                        " / " +
                        match.shots.toString()),
                    if (match.shots != 0)
                      blueTitle(
                        "  (" +
                            ((match.goals) / (match.shots) * 100)
                                .round()
                                .toString() +
                            "%)",
                      ),
                  ],
                ),
              ),
              matchListTile(
                title: Row(
                  children: <Widget>[
                    blueTitle("Assists: "),
                    whiteTitle(match.assists.toString()),
                  ],
                ),
                subtitle: Row(
                  children: <Widget>[
                    blueTitle("Saves: "),
                    whiteTitle(match.saves.toString()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget matchListTile({Widget leading, Widget title, Widget subtitle}) {
    return Container(
      width: 170,
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        dense: true,
        leading: leading,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  Widget gainWidget(int gain) {
    if (gain == null) {
      return Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: const Icon(Icons.star, color: AppColors.gold),
      );
    }
    bool up = gain > 0;
    Color color = up ? Colors.green : Colors.red;
    if (!up) gain = -gain;
    return Row(
      children: <Widget>[
        const SizedBox(width: 4),
        Text(
          gain.toString(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Icon(
          up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: color,
        ),
      ],
    );
  }
}
