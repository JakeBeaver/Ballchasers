import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class RankWidget extends StatelessWidget {
  // final String _imageUrl = "https://trackercdn.com/cdn/tracker.gg/rocket-league/ranks/s4-5.png";
  final PlaylistRank rank;
  RankWidget(this.rank);
  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context);
    var screenWidth = mq.size.width - mq.viewInsets.left - mq.viewInsets.right;
    var maxCount = (screenWidth / (375 + 7)).floor();
    var width = (screenWidth / maxCount) - 7; // padding;;
    return Container(
      width: width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[800], width: 1)),
      margin: EdgeInsets.all(3),
      child: ListTile(
        isThreeLine: true,
        dense: true,
        onTap: () =>
            {Navigator.of(context).pushNamed("rank", arguments: rank.name)},
        title: blueTitle(rank.name, sizeAdjust: 2),
        leading: Hero(
            tag: "icon_" + rank.name,
            child: CachedNetworkImage(
                placeholder: (c, a) => CircularProgressIndicator(),
                imageUrl: rank.tierIcon)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                whiteTitle("" + rank.mmr.toString()),
                if (rank.tierName != "Unranked" || rank.tierName == "Supersonic Legend")
                  Text(" • " + rank.tierName + " " + rank.divisionName)
                else
                  Text(" • " + rank.tierName),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (rank.matchesPlayed != 0)
                  Text("${rank.matchesPlayed} games  "),
                if (rank.winStreak > 0)
                  winStreakTitle("Win strk: ${rank.winStreak}"),
                if (rank.lossStreak > 0)
                  lossStreakTitle("Loss strk: ${rank.lossStreak}"),
                // Container(),
              ],
            ),
          ],
        ),
        trailing: Container(
          width: 55,
          height: 50,
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (rank.divUp != null)
                    Row(children: [
                      Icon(Icons.arrow_drop_up, color: Colors.green),
                      Text(
                        rank.divUp.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ]),
                  if (rank.divDown != null)
                    Row(children: [
                      Icon(Icons.arrow_drop_down, color: Colors.red),
                      Text(
                        rank.divDown.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
