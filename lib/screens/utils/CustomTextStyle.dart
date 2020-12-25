import 'package:flutter/material.dart';

class CustomColors {
  static const darkBlue = Color(0xff1B3A57);
}

class CustomTextStyle {
  static const TextStyle blue_bold_big = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 19,
    color: CustomColors.darkBlue,
  );
  static const TextStyle blue_bold_med = TextStyle(
    fontWeight: FontWeight.bold,
    color: CustomColors.darkBlue,
  );
  static const TextStyle blue_reg_med = TextStyle(
    fontWeight: FontWeight.w500,
    color: CustomColors.darkBlue,
  );
  static TextStyle grey_bold_small = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: Colors.grey[600],
  );
  static const TextStyle bigIcons = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 25,
  );
}
