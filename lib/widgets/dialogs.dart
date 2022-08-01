import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    duration: const Duration(milliseconds: 1200),
    elevation: 10,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(5),
      topRight: Radius.circular(5),
    )),
    backgroundColor: Colors.purple,
    content: Text(message),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

//Very smart way of creating snackBars, no need of creating it everytime we need it