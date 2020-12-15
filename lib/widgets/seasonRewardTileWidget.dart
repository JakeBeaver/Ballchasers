import 'package:RLRank/providers/trackerData.dart';
import 'package:RLRank/widgets/textWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SeasonRewardTile extends StatelessWidget {
  final SeasonReward seasonReward;
  SeasonRewardTile(this.seasonReward);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [AppColors.purple, AppColors.deepBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 70,
              child: CachedNetworkImage(
                imageUrl: seasonReward.picUrl,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                blueTitle("Season reward"),
                whiteTitle(seasonReward.rank),
              ],
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                blueTitle("Wins"),
                whiteTitle("${seasonReward.wins}/10"),
              ],
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
