import 'package:flutter/material.dart';

class CustomColors {
  static const darkBlue = Color(0xff1B3A57);
  static const lightGrey = Color(0xffF2F3F4);
  static const bgBlue = Color(0xffF6F7F9);
}

class CustomTextStyle {
  static const TextStyle h1 = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 30,
    color: CustomColors.darkBlue,
  );
  static const TextStyle blue_bold_big = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 19,
    color: CustomColors.darkBlue,
  );
  static const TextStyle blue_bold_reg = TextStyle(
    fontWeight: FontWeight.bold,
    color: CustomColors.darkBlue,
  );
  static const TextStyle blue_bold_med = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: CustomColors.darkBlue,
  );
  static const TextStyle blue_reg_med = TextStyle(
    fontWeight: FontWeight.w500,
    color: CustomColors.darkBlue,
  );
  // ignore: non_constant_identifier_names
  static TextStyle grey_bold_small = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: Colors.grey[600],
  );
  static const TextStyle bigIcons = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 25,
  );
  static const TextStyle bold_med = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
}
