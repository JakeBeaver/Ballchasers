import 'package:flutter/material.dart';

const Color blueTitleColor = Color(0xffb5d0ff);
const Color deepBlueTitleColor = Color(0xff239ad9);
const Color goldTitleColor = Color(0xffcbb765);
const Color buttonColor =  Color(0xff123280);
const Color appBarColor = Color(0xff041d59);

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
      color: goldTitleColor,
    ),
  );
}

Widget blueTitle(String text, {double sizeAdjust = 0}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 14 + sizeAdjust,
      fontWeight: FontWeight.bold,
      color: blueTitleColor,
    ),
  );
}

Widget deepBlueTitle(String text, {double sizeAdjust = 0}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 14 + sizeAdjust,
      fontWeight: FontWeight.bold,
      color: deepBlueTitleColor,
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
