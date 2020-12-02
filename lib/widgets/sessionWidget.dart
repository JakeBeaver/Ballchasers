import 'package:RLRank/providers/trackerData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'matchWidget.dart';

class SessionWidget extends StatelessWidget {
  final Session session;
  SessionWidget(this.session);
  final df = DateFormat('EEEE, d MMM\nHH:mm, ');
  final tf = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final String title =
        df.format(session.matches.last.dateCollected.toLocal()) +
            session.matches.length.toString() +
            (session.matches.length == 1 ? " Match" : " Matches");
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
