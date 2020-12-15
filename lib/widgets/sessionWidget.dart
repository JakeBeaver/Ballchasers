import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'matchWidget.dart';

class SessionWidget extends StatelessWidget {
  final Session session;
  SessionWidget(this.session);

  List<Widget> getChildren() => [
        SessionHeader(session),
        ...session.matches.map((x) => MatchWidget(x)).toList(),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: getChildren(),
    );
  }
}

class SessionHeader extends StatelessWidget {
  const SessionHeader(this.session);
  final Session session;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEEE, d MMM');
    final tf = DateFormat('HH:mm');
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
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [AppColors.purple, AppColors.deepBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
