import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  final Color textColor;

  const LoadingScreen({this.message, this.textColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text(message, style: TextStyle(color: textColor ?? Colors.black)),
        ],
      ),
    );
  }
}
