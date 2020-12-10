import 'package:flutter/material.dart';

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
      color: Color(0xffcbb765),
    ),
  );
}

Widget blueTitle(String text, {double sizeAdjust = 0}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 14 + sizeAdjust,
      fontWeight: FontWeight.bold,
      color: Color(0xffb5d0ff),
    ),
  );
}

Widget deepBlueTitle(String text, {double sizeAdjust = 0}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 14 + sizeAdjust,
      fontWeight: FontWeight.bold,
      color: Color(0xff239ad9),
    ),
  );
}

Widget lossStreakTitle(String text, {double sizeAdjust = 0}) {
  return Row(
    children: [
      Icon(Icons.ac_unit, color: Color(0xff2b9fea), size: 20),
      Text(
        text,
        style: TextStyle(
          // fontSize: 14 + sizeAdjust,
          fontWeight: FontWeight.bold,
          color: Color(0xff2b9fea),
        ),
      ),
    ],
  );
}

Widget winStreakTitle(String text, {double sizeAdjust = 0}) {
  return Row(
    children: [
      Icon(Icons.whatshot, color: Color(0xffe68617), size: 20),
      Text(
        text,
        style: TextStyle(
          // fontSize: 14 + sizeAdjust,
          fontWeight: FontWeight.bold,
          color: Color(0xffe68617),
        ),
      ),
    ],
  );
}
