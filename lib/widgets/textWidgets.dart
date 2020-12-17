import 'package:flutter/material.dart';

class AppColors {
  static const Color blue = const Color(0xffb5d0ff);
  static const Color deepBlue = const Color(0xff239ad9);
  static const Color gold = const Color(0xffcbb765);
  static const Color helpText = gold;//const Color(0xffab9745);
  static const Color button = const Color(0xff123280);
  static const Color appBar = const Color(0xff041d59);
  static const Color tooltipbackground = const Color(0xbb041d59); // appbar opacity
  static const Color background = const Color(0xff001538);
  static const Color purple = const Color(0xff4c138e);
  static const Color lossStreak = const Color(0xff2b9fea);
  static const Color winStreak = const Color(0xffe68617);
}

Widget whiteTitle(
  String text, {
  double sizeAdjust = 0,
  TextAlign textAlign = TextAlign.start,
}) {
  return Text(
    text,
    textAlign: textAlign,
    style: TextStyle(
      fontSize: 18 + sizeAdjust,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );
}

Widget goldTitle(
  String text, {
  double sizeAdjust = 0,
  TextAlign textAlign = TextAlign.start,
}) {
  return Text(
    text,
    textAlign: textAlign,
    style: TextStyle(
      fontSize: 18 + sizeAdjust,
      fontWeight: FontWeight.bold,
      color: AppColors.gold,
    ),
  );
}

Widget blueTitle(String text, {double sizeAdjust = 0}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 14 + sizeAdjust,
      fontWeight: FontWeight.bold,
      color: AppColors.blue,
    ),
  );
}

Widget deepBlueTitle(String text, {double sizeAdjust = 0}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 14 + sizeAdjust,
      fontWeight: FontWeight.bold,
      color: AppColors.deepBlue,
    ),
  );
}

Widget lossStreakTitle(String text) {
  return Row(
    children: [
      const Icon(Icons.ac_unit, color: AppColors.lossStreak, size: 20),
      Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.lossStreak,
        ),
      ),
    ],
  );
}

Widget winStreakTitle(String text) {
  return Row(
    children: [
      const Icon(Icons.whatshot, color: AppColors.winStreak, size: 20),
      Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.winStreak,
        ),
      ),
    ],
  );
}
