import 'package:RLRank/providers/trackerData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'matchWidget.dart';

class SessionWidget extends StatelessWidget {
  final Session session;
  SessionWidget(this.session);
  final df = DateFormat('EEEE, d MMM');
  final tf = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final nOfMatches =
        session.matches.map((x) => x.matches).fold(0, (x, y) => x + y);
    final nOfWins = session.matches.map((x) => x.wins).fold(0, (x, y) => x + y);
    final timeStamp = session.matches.last.dateCollected.toLocal();
    final String time = tf.format(timeStamp);
    final String date = df.format(timeStamp);
    final String matches = nOfMatches == 1 ? "Match" : "Matches";
    final String wins = nOfWins == 1 ? "Win" : " Wins";
    final String winPerc = "${(nOfWins / nOfMatches * 100).round()}%";
    final String title = "$date" +
        "\n$time, $nOfMatches $matches" +
        "\n$nOfWins $wins ($winPerc)";

    return Column(
      children: <Widget>[
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff4c138e), Color(0xff239ad9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 5),
        ...session.matches.map((x) => MatchWidget(x)).toList(),
      ],
    );
  }
}
