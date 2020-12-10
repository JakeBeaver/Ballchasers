import 'package:RLRank/providers/trackerData.dart';
import 'package:flutter/material.dart';

Color getSplitColor(List<TierData> tiers, int value) {
  var name = getSplitName(tiers, value);
  return getTierColorByName(name);
}

Color getTierColorByName(String name) {
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

int getTierOrdinalFromName(String name) {
  if (name == null) return -1;
  switch (name.split(' ')[0]) {
    case ("Unranked"):
      return -1;
    case ("Bronze"):
      return 1;
    case ("Silver"):
      return 2;
    case ("Gold"):
      return 3;
    case ("Platinum"):
      return 4;
    case ("Diamond"):
      return 5;
    case ("Champ"):
      return 6;
    case ("Grand"):
      return 7;
    case ("Supersonic"):
      return 8;
  }
  return -1;
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
